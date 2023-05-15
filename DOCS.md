Return to [README.md](README.md)

---

# Documentation

See [INSTALL.md](INSTALL.md) for _first-time_ setup instructions. The following assumes you've already done so.

Please, _please_ read this file carefully and in its entirety.

## Table of Contents

0. [Read the Docs](#read-the-docs)
1. [Start the Project](#start-the-project)
2. [Stop the Project](#stop-the-project)
3. [Test the Project](#test-the-project)
4. [Contribute Code](#contribute-code)
5. [Interact with the Bot](#interact-with-the-bot)
6. [For Project Graders](#for-project-graders)

---

## Read the Docs

-   `make doc` will generate documentation for the bot and server. If you're on Mac, it will also automatically open the docs in your browser for you. Otherwise, you can manually find the docs in `docs/index.html`.

### Documentation Decisions

We've documented our choices in regards to, well, documentation, at length in [DOC.md](DOC.md). If you're confused about things, please read that file.

### Project Structure

This is important! The project is structured as a monorepo, with two subprojects: `bot/` and `server/`. Each subproject is a _self-contained OCaml project._

Each subproject is comprised of 3 parts:

-   An executable `bin/main.ml`, which contains extensive boilerplate code (eg. to setup a Telegram server, or an HTTP server)
-   A testing file in `test/main.ml`
-   **ALL** the project logic and functionality in `lib/`, which is imported by `bin/main.ml` to be used during executiong, and `test/main.ml` for testing.

The purpose of `server` is to do all the computational heavy-lifting. `bot` exists merely as a medium between the Telegram API and our own server API.

## Start the Project

-   `make build` will build the bot and server, as well as format the code. This might help with red squiggly lines everywhere. Run this before you start working!
-   `make run` will start the server on port 9000 and the bot on port 9001.

## Stop the Project

-   `make kill` will kill the bot and the server (terminates all processes on ports 9000 and 9001).
-   `make clean` will remove all build artifacts.

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

(If, after installing a dependency, documentation no longer works, you may also have to manually add your server dependency to `doc.sh`. You should probably reach out to Daniel if that's the case.)

---

## Interact with the Bot

Assuming you've [started the project](#start-the-project), you can interact with the bot on [Telegram](https://t.me/BocamlBot) `@BocamlBot`. Just send it messages!

(Yes, you'll probably need to download [Telegram](https://telegram.org/) if you don't already have it.)

We recommend starting with one of the following commands to try:

-   "/health_check", and it should respond with "Hi there!".
-   "/rng 1 100", and it should respond with a random number between 1 and 100
-   "/coinflip", and it should respond with either "Heads" or "Tails"
-   "/play start x", and it should start playing Tic Tac Toe with you.
-   "/convert_units 500 ft m", and it should respond with "152.4 m"

Note that the bot does not support some special characters in some commands (question marks, ampersands, etc.).

(If you want to bypass Telegram and directly interact with the server functions, you can use whatever HTTP client you want. For instance, you can use Postman for a GUI interface; or cURL if you prefer the command line.)

---

## For Project Graders

For CS 3110 Project Graders, there's some extra docs for you to read in addition to everything above.

#### Important Files

1. Instead of a singular `test.ml` file, we have multiple. This is a consequence of our project structure. In order to grade our "test file", please direct your attention to [TEST.md](TEST.md) instead, where we have documented our testing choices ad nauseam.

2. Instead of a `LOC.txt` file, we have a [LOC.md](LOC.md) file. Therein, we have explained our lines-of-code counting methodology. We hope you'll excuse the trivial differences in formatting.

#### Zipping

`make zip` will clean build artifacts, and then zip the files into a shareable archive.

Note that the generated ZIP archive will include `.env` files. This makes it ideal for internal transfers, submissions to CMSX, etc. It is NOT to be made public. The generated zip archive will NOT be committed to git. This is probably how you, the Project Grader, will be receiving our code.

#### Counting Lines of Code

`make loc` will return you our total lines of code.

If you're curious about the methodology, direct your attention to [LOC.md](LOC.md), as mentioned above.
