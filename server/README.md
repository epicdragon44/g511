# Docs

Main file is `bin/main.ml`.

When installing new packages with OPAM, make sure to add them to `libraries` in `bin/dune`, and `scripts/init.sh`.

Checkout our [Postman](https://app.getpostman.com/join-team?invite_code=19786b3504f32611f7d4ec9a9c7a8fe1).

# Scripts

### `./scripts/build.sh`

Formats and then builds the project.

Run this script before attempting to run the server!

### `./scripts/run.sh`

Runs the project in silent mode (production-ready) on port 9000.

### `./scripts/kill.sh`

Kills the silent server process (kills whatever's running on port 9000).

### `./scripts/run-dev.sh`

Runs the project in development mode (with debug logs) on port 9000.

Note that it may look like the script has frozen. It (probably) hasn't!

### `./scripts/test.sh`

Runs tests in `lib`.
