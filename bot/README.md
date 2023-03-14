# Docs

Main file is `bin/main.ml`.

When installing new packages with OPAM, make sure to add them to `libraries` in `bin/dune`, and `scripts/init.sh`.

## Secrets

This repository must contain a .env file with the following variables:

-   `BOT_TOKEN`: The Telegram bot token provided by BotFather. If you need a new Bot Token, message @BotFather on Telegram (/start).

## Scripts

### `./scripts/build.sh`

Format and build your code.

Run this before attempting to run anything else!

### `./scripts/run.sh`

Runs the project in silent mode (production-ready) on port 9001.

### `./scripts/kill.sh`

Kills the silent server process (kills whatever's running on port 9001).

### `./scripts/run-dev.sh`

Runs the project in development mode (with debug logs) on port 9001.

Note that it may look like the script has frozen. It (probably) hasn't!
