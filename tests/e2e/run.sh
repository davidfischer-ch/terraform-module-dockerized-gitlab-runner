#!/usr/bin/env sh

# Apply the module against the local Docker daemon and a stub of the GitLab API (stub.py), check the
# runner it runs, run its action on a valid and on a refused token, then destroy everything.
# The Docker daemon must see the data directory at the same path: set E2E_DATA_DIRECTORY to a
# directory both share when Terraform runs in a container of its own. Terraform reaches the stub on
# a port the daemon publishes, on loopback, or on the daemon's host under a TCP DOCKER_HOST: set
# E2E_STUB_ADDRESS to an address of the daemon's host that Terraform reaches otherwise.
#
#   E2E_IMAGE=gitlab/gitlab-runner:ubuntu-v19.5.2 sh tests/e2e/run.sh

set -eu

# The data directory: a fresh temporary one, or the one E2E_DATA_DIRECTORY names, absent or empty.
# The cleanup removes only what this run created.
if [ -n "${E2E_DATA_DIRECTORY:-}" ]; then
  DATA_DIRECTORY="${E2E_DATA_DIRECTORY}"
  case "${DATA_DIRECTORY}" in
    /*) ;;
    *)
      echo "FAILED: E2E_DATA_DIRECTORY must be an absolute path" >&2
      exit 1
      ;;
  esac
  if [ -e "${DATA_DIRECTORY}" ] || [ -L "${DATA_DIRECTORY}" ]; then
    if [ -L "${DATA_DIRECTORY}" ] || [ ! -d "${DATA_DIRECTORY}" ] \
      || [ -n "$(ls -A "${DATA_DIRECTORY}")" ]; then
      echo "FAILED: E2E_DATA_DIRECTORY ${DATA_DIRECTORY} is not an empty directory" >&2
      exit 1
    fi
    DATA_DIRECTORY_CREATED=false
  else
    mkdir "${DATA_DIRECTORY}"
    DATA_DIRECTORY_CREATED=true
  fi
else
  DATA_DIRECTORY=$(mktemp -d)
  DATA_DIRECTORY_CREATED=true
fi

# The stub's port binds to the address Terraform reaches it at. A daemon reached over TCP runs on a
# host of its own, the job's under Docker-in-Docker: the port binds to all its addresses.
STUB_ADDRESS=127.0.0.1
STUB_HOST=127.0.0.1
case "${DOCKER_HOST:-}" in
  tcp://*)
    STUB_ADDRESS=0.0.0.0
    STUB_HOST="${DOCKER_HOST#tcp://}"
    STUB_HOST="${STUB_HOST%%[:/]*}"
    ;;
esac
if [ -n "${E2E_STUB_ADDRESS:-}" ]; then
  STUB_ADDRESS="${E2E_STUB_ADDRESS}"
  STUB_HOST="${E2E_STUB_ADDRESS}"
fi

cd "$(dirname "$0")"

CONTAINER=gitlab-runner-e2e
COORDINATOR=gitlab-runner-e2e-coordinator
TOKEN=glrt-an-e2e-token

tf() {
  terraform "$@" -input=false -no-color \
    -var "image=${E2E_IMAGE}" -var "data_directory=${DATA_DIRECTORY}" \
    -var "stub_address=${STUB_ADDRESS}" -var "stub_host=${STUB_HOST}"
}

expect() {
  if [ "$2" != "$3" ]; then
    echo "FAILED: ${1}: expected ${3}, got ${2}" >&2
    exit 1
  fi
  echo "ok: ${1}"
}

invoke() {
  echo "==> action ${1}"
  if ! output=$(tf apply -auto-approve "-invoke=module.runner.action.docker_exec.${1}" 2>&1); then
    echo "${output}" >&2
    echo "FAILED: action ${1}" >&2
    exit 1
  fi
}

invoke_fails() {
  echo "==> action ${1}, expected to fail"
  if tf apply -auto-approve "-invoke=module.runner.action.docker_exec.${1}" > /dev/null 2>&1; then
    echo "FAILED: action ${1} succeeded" >&2
    exit 1
  fi
  echo "ok: action ${1} fails"
}

# Print the output of the command the arguments after $1 form, once it reads $1 or after 90 seconds.
wait_for() {
  expected="$1"
  shift
  tries=0
  while [ "$("$@")" != "${expected}" ] && [ "${tries}" -lt 90 ]; do
    tries=$((tries + 1))
    sleep 1
  done
  "$@"
}

health() {
  docker inspect -f '{{.State.Health.Status}}' "${CONTAINER}"
}

# The status of the metrics endpoint, requested from the daemon's host: the port binds there.
metrics() {
  docker run --rm --network host --entrypoint curl "${E2E_IMAGE}" \
    -s -o /dev/null -m 5 -w '%{http_code}' http://127.0.0.1:19252/metrics || true
}

# Whether the coordinator stub answered a job request with no job: 204.
polled() {
  if docker logs "${COORDINATOR}" 2>&1 | grep -q '"POST /api/v4/jobs/request HTTP/1.1" 204'; then
    echo yes
  else
    echo no
  fi
}

# The bind mounts live on the daemon's filesystem, which is not this one under Docker-in-Docker:
# remove them through the daemon too.
cleanup() {
  tf destroy -auto-approve > /dev/null || true
  docker run --rm --entrypoint rm -v "${DATA_DIRECTORY}:/e2e" "${E2E_IMAGE}" \
    -rf /e2e/builds /e2e/cache /e2e/config /e2e/scripts /e2e/storage || true
  [ "${DATA_DIRECTORY_CREATED}" = false ] || rm -rf "${DATA_DIRECTORY}"
}
trap cleanup EXIT

waited=0
until docker info > /dev/null 2>&1; do
  waited=$((waited + 1))
  if [ "${waited}" -ge 300 ]; then
    echo "FAILED: no Docker daemon reachable within 300 seconds" >&2
    exit 1
  fi
  sleep 1
done

terraform init -input=false -no-color > /dev/null
tf apply -auto-approve > /dev/null

# The module does not wait for the container: its healthcheck starts after 10 seconds.
expect 'the healthcheck reports the runner healthy' "$(wait_for healthy health)" healthy
expect 'the runner requests jobs with its token' "$(wait_for yes polled)" yes
expect 'config.toml holds the token' \
  "$(docker exec "${CONTAINER}" grep -c -F "token = \"${TOKEN}\"" /tmp/config.toml)" 1
expect 'config.toml is readable by its owner alone' \
  "$(docker exec "${CONTAINER}" stat -c '%a %U' /tmp/config.toml)" '600 root'
case "$(docker inspect "${CONTAINER}")" in
  *"${TOKEN}"*)
    echo 'FAILED: the container definition holds the token' >&2
    exit 1
    ;;
  *) echo 'ok: the container definition holds no token' ;;
esac
expect 'the metrics port binds to loopback' \
  "$(docker port "${CONTAINER}" 9252/tcp)" 127.0.0.1:19252
expect 'the metrics listener answers on loopback' "$(wait_for 200 metrics)" 200

invoke verify
docker exec "${COORDINATOR}" touch /tmp/refuse-token
invoke_fails verify

status=0
tf plan -detailed-exitcode > /dev/null || status=$?
expect 'the plan is clean after the apply and the action' "${status}" 0
