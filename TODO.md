# TODO

## Finalize the first version

- Use var.jobs_volumes
- Ensure the following configuration:
  - Build jobs resources
  - Build jobs volumes (cache, ...)
- Check if the jobs can access the cache directory
- Check if the build directory is used (if we want it)
- Check if the runner can execute basic jobs
- Document multiple example usages in README
- Document behavior (start, stop, cleanup, ...)
- Document directories

## Features

- Implement mode were image is not managed (e.g. if running multiple instances on same machine)
- Implement a persistent mode (e.g. to prevent registering every time the runner is restarted)
- Cleanup runner on stop (related: https://github.com/FlakM/gitlab-runner-auto-register)
