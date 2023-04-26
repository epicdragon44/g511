# Bocaml

This is the monorepo for a little Telegram chat-bot named Bo, after the Ithaca Bo Burger. Implemented in OCaml.

### Contributors

-   Daniel Wei
-   Ryan Lee
-   Ken Chiem
-   Anthony Huang

# Documentation

See [INSTALL.md](INSTALL.md) for _first-time_ setup instructions. Assuming you've already done that, the following sections are mostly in-order of what you should probably do.

### Check your Secrets

-   You'll need to create/have a file `bot/.env` that contains one line: `BOT_TOKEN = <some key>`, where `some key` is the Telegram bot token provided by BotFather. If you need a new Bot Token, message @BotFather on Telegram (/start). Otherwise, refer to our Discord for the token.

-   You'll need to create/have a file `server/.env` that contains one line: `OPENAI_TOKEN = <some key>`, where `some key` is the OpenAI API key provided by OpenAI. If you need a new API key, refer to our Discord for the key.

## Build the Code

To start:

-   `make build` will build the bot and server, as well as format the code. This might help with red squiggly lines everywhere. Run this before you start working!
-   `make run` will start the server on port 9000 and the bot on port 9001.

To stop:

-   `make kill` will kill the bot and the server (terminates all processes on ports 9000 and 9001).
-   `make clean` will remove all build artifacts.

You can interact with the bot while the code is running on Telegram `@bocaml-beta-1`.
You can test the server via Postman. Checkout **Server API** below.

## Test the Code

-   `make test` will run all the tests in server and bot (using OUnit). Expect to see two OKs -- one for the bot and one for the server!

### Get Crackin'

Edit these two files to get started!

-   `bot/bin/main.ml` is the entry point for the bot.
-   `server/bin/main.ml` is the entry point for the server.

### Cross-reference the Server API

Check out our [Postman](https://app.getpostman.com/join-team?invite_code=19786b3504f32611f7d4ec9a9c7a8fe1).

### Manage Dependencies

This project uses OPAM to manage dependencies.

To install a new dependency, run `make install` and follow the instructions.

## Running the Code

Assuming the code is built and running on a server somewhere, you can interact with the bot on Telegram `@bocaml-beta-1`. Just send it messages! For instance, try sending "/health_check", and it should respond with "Hi there!".

If you want to more directly interact with the server functions, you can use whatever HTTP client you want. For instance, you can use Postman for a GUI interface; or cURL if you prefer the command line. Check out **Server API** above for the endpoints.

### Submissions

If you're a grader, you might be interested in this!

#### Zipping

`make zip` will clean build artifacts, and then zip the files into a shareable archive.

Note that the generated ZIP archive will include `.env` files. This makes it ideal for internal transfers, submissions to CMSX, etc. It is NOT to be made public. The generated zip archive will NOT be committed to git.

#### Counting Lines of Code

`make loc` will return you a count of the total number of lines of code spread across all `.ml` files in the monorepo.
