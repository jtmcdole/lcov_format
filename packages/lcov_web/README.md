# lcov_web

A [jaspr](https://jaspr.site/) implementation of lcov rendering from `lcov_format`.

This is not meant to be run directly, but to be used to produce a `web.zip`
for lcov_format to use.

## Setup

1. [install jaspr](https://docs.jaspr.site/get_started/installation)
2. Run `dart run bin/build.dart` to produce the archive.
3. Add said archive to `lcov_format/assets`.
