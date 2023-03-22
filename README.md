# Bocaml

This is the monorepo for a little Telegram chat-bot named Bo, after the Ithaca Bo Burger. Implemented in OCaml.

### Contributors

-   Daniel Wei
-   Ryan Lee
-   Ken Chiem
-   Anthony Huang

# Documentation

See `INSTALL.md` for first-time setup instructions. Assuming you've already done that, here's some more information.

### Running the code

To start:

-   `make build` will build the bot and server, as well as format the code. This might help with red squiggly lines everywhere. Run this before you start working!
-   `make run` will start the server on port 9000 and the bot on port 9001.

To stop:

-   `make kill` will kill the bot and the server (terminates all processes on ports 9000 and 9001).

You can interact with the bot on Telegram `@bocaml-beta-1`.

### Files

Edit these two files to get started!

-   `bot/bin/main.ml` is the entry point for the bot.
-   `server/bin/main.ml` is the entry point for the server.

Helper functions and tests are in `bot/lib/` and `server/lib/`.

### Secrets

-   You'll need to create a file `bot/.env` that contains one line: `BOT_TOKEN = <some key>`, where `some key` is the Telegram bot token provided by BotFather. If you need a new Bot Token, message @BotFather on Telegram (/start). Otherwise, refer to our Discord for the token.

### Server API

Check out our [Postman](https://app.getpostman.com/join-team?invite_code=19786b3504f32611f7d4ec9a9c7a8fe1).

### Dependency Management

This project uses OPAM to manage dependencies.

To install a new dependency, run `make install` and follow the instructions.
