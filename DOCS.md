Return to [README.md](README.md)

---

# Documentation

See [INSTALL.md](INSTALL.md) for _first-time_ setup instructions. The following assumes you've already done so.

## Table of Contents

0. [Read the Docs](#read-the-docs)
1. [Start the Project](#start-the-project)
2. [Stop the Project](#stop-the-project)
3. [Test the Project](#test-the-project)
4. [Contribute Code](#contribute-code)
5. [Interact with the Bot](#interact-with-the-bot)
6. [Helping with Submissions](#helping-with-submissions)

---

## Read the Docs

-   `make doc` will generate documentation for the bot and server. If you're on Mac, it will also open the docs in your browser. Otherwise, you can find the docs in `docs/index.html`.

## Start the Project

-   `make build` will build the bot and server, as well as format the code. This might help with red squiggly lines everywhere. Run this before you start working!
-   `make run` will start the server on port 9000 and the bot on port 9001.

## Stop the Project

-   `make kill` will kill the bot and the server (terminates all processes on ports 9000 and 9001).
-   `make clean` will remove all build artifacts.

You can interact with the bot while the code is running on Telegram `@bocaml-beta-1`.
You can test the server via Postman. Checkout **Server API** below.

## Test the Project

Simply run `make test`!

---

## Contribute Code

Edit these two files to get started!

-   `bot/bin/main.ml` is the entry point for the bot.
-   `server/bin/main.ml` is the entry point for the server.

### Manage Dependencies

This project uses OPAM to manage dependencies.

To install a new dependency, run `make install` and follow the instructions.

---

## Interact with the Bot

Assuming you've [started the project](#start-the-project), you can interact with the bot on Telegram `@bocaml-beta-1`. Just send it messages! For instance, try sending "/health_check", and it should respond with "Hi there!".

If you want to more directly interact with the server functions, you can use whatever HTTP client you want. For instance, you can use Postman for a GUI interface; or cURL if you prefer the command line. Check out **Server API** above for the endpoints.

---

## Helping with Submissions

If you're a grader, you might be interested in this!

#### Zipping

`make zip` will clean build artifacts, and then zip the files into a shareable archive.

Note that the generated ZIP archive will include `.env` files. This makes it ideal for internal transfers, submissions to CMSX, etc. It is NOT to be made public. The generated zip archive will NOT be committed to git.

#### Counting Lines of Code

`make loc` will return you a count of the total number of lines of code spread across all `.ml` files in the monorepo.
