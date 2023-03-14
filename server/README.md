# Docs

Main file is `bin/main.ml`.

When installing new packages with OPAM, make sure to add them to `libraries` in `bin/dune`, and `scripts/init.sh`.

Checkout our [Postman collection](https://warped-moon-285755.postman.co/workspace/Bocaml~a26ce1ab-6db1-4d26-aa45-114b3ce81672/collection/15334621-ea56c1af-bc1a-4daf-887d-a7d34f38e87f?action=share&creator=15334621).

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
