# Changelog

## Release v2.0.1 (2026-03-13)

### Fix and enhancements

* Drop commented-out dead code (old registration token resource)
* Add examples

## Release v2.0.0 (2025-05-21)

### Major compatibility breaks

* Drop old registration workflow (registration token)

### Minor compatibility breaks

* Drop `registration_url` and `registration_token` variables
  * Replaced by `runner_type` variable and optional (`group_id`, `project_id`)

### Features

* Implement the new registration workflow (authentication token)

### Fix and enhancements

* Prevent infinite recreate by declaring `network_mode` to `bridge`

## Release v1.0.0 (2025-01-20)

Initial release
