"""
A stub of the GitLab API, answering the calls of the gitlab provider's `gitlab_user_runner` and of
a runner registered with the token in STUB_TOKEN.

Registered runners live in memory. Creating the file /tmp/refuse-token makes the stub refuse the
token on `POST /api/v4/runners/verify`. Every request is logged to stderr, with its status.
"""

from __future__ import annotations

import http.server
import itertools
import json
import os
import re
from typing import ClassVar, Final

TOKEN: Final[str] = os.environ['STUB_TOKEN']
REFUSE_TOKEN_FILE: Final[str] = '/tmp/refuse-token'

RUNNER_PATH: Final[re.Pattern[str]] = re.compile(r'^/api/v4/runners/(\d+)$')

# The attributes of a runner the provider reads back, with GitLab's defaults.
RUNNER_DEFAULTS: Final[dict[str, object]] = {
    'access_level': 'not_protected',
    'description': '',
    'locked': False,
    'maintenance_note': '',
    'maximum_timeout': 0,
    'paused': False,
    'run_untagged': False,
    'runner_type': 'instance_type',
    'tag_list': [],
}


class Handler(http.server.BaseHTTPRequestHandler):
    """Handler of the API calls, one per request."""

    ids: ClassVar[itertools.count[int]] = itertools.count(1)
    runners: ClassVar[dict[int, dict]] = {}

    def body(self) -> dict:
        """Return the request's JSON body, an empty object when it has none."""
        length = int(self.headers.get('Content-Length') or 0)
        return json.loads(self.rfile.read(length)) if length else {}

    def do_DELETE(self) -> None:
        match = RUNNER_PATH.match(self.path)
        if match and self.runners.pop(int(match[1]), None):
            self.reply(204)
        else:
            self.reply(404, {'message': '404 Not found'})

    def do_GET(self) -> None:
        match = RUNNER_PATH.match(self.path)
        if self.path == '/-/health':
            self.reply(200, {'status': 'ok'})
        elif match and int(match[1]) in self.runners:
            self.reply(200, self.runners[int(match[1])])
        else:
            self.reply(404, {'message': '404 Not found'})

    def do_POST(self) -> None:
        body = self.body()
        if self.path == '/api/v4/user/runners':
            runner_id = next(self.ids)
            self.runners[runner_id] = {
                **RUNNER_DEFAULTS,
                **{key: body[key] for key in RUNNER_DEFAULTS if key in body},
                'id': runner_id,
            }
            self.reply(201, {'id': runner_id, 'token': TOKEN, 'token_expires_at': None})
        elif self.path == '/api/v4/runners/verify':
            if body.get('token') == TOKEN and not os.path.exists(REFUSE_TOKEN_FILE):
                self.reply(200, {'id': 1, 'token': TOKEN, 'token_expires_at': None})
            else:
                self.reply(403, {'message': '403 Forbidden'})
        elif self.path == '/api/v4/jobs/request':
            if body.get('token') == TOKEN:
                self.reply(204)
            else:
                self.reply(403, {'message': '403 Forbidden'})
        else:
            self.reply(404, {'message': '404 Not found'})

    def reply(self, status: int, payload: dict | None = None) -> None:
        """Send the status, and the payload as JSON when there is one."""
        content = b'' if payload is None else json.dumps(payload).encode()
        self.send_response(status)
        if content:
            self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(content)))
        self.end_headers()
        self.wfile.write(content)


if __name__ == '__main__':
    http.server.ThreadingHTTPServer(('', 8080), Handler).serve_forever()
