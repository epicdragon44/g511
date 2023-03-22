# Bocaml

This is the monorepo for a little Telegram chat-bot named Bo, after the Ithaca Bo Burger. Implemented in OCaml.

### Contributors

-   Daniel Wei
-   Ryan Lee
-   Ken Chiem
-   Anthony Huang

# Documentation

## Installation

See `INSTALL.md` for instructions.

## Local Development

Assuming you've run through the installation instructions, you can run the bot locally with `make dev`. This will start the bot and the server, and you can interact with the bot on Telegram `@bocaml-beta-1`.

Commands to help you along your way:

-   `make build` will build the bot and server. This might help with red squiggly lines everywhere.
-   `make clean` will clean the bot and server of build artifacts. Don't run this unless you know what you're doing.

## Deployment

Run `make deploy` to deploy the bot to the server.

If you need to kill it, run `make kill` to kill the bot and the server.

## Further Documentation

Within the `bot` and `server` directories, there should be a `README.md` with information pertinent to each sub-repo.
