# Bocaml

This is the monorepo for a little Telegram chat-bot named Bo, after the Ithaca Bo Burger. Implemented in OCaml.

## Contributors

-   Daniel Wei
-   Ryan Lee
-   Ken Chiem
-   Anthony Huang

# Pre-requisites

Development environment: **Mac OS X**

Deployment environment: **Ubuntu**

# Docs

For all scripts, if you are unable to run them due to insufficient permissions, try running `find ./ -type f -iname "*.sh" -exec chmod +x {} \;`.

If you don't have OPAM, refer to the Cornell CS 3110 [installation instructions](https://cs3110.github.io/textbook/chapters/preface/install.html#install-opam): subheadings "Install OPAM" and "Initialize OPAM".

If you don't have `brew`, refer to the [Homebrew installation instructions](https://brew.sh/).

## First-time Setup

First, have `brew` and `opam` installed on your computer.

Then, run `./init.sh` to setup everything for the first time.

## Deployment

Run `./deploy.sh` to deploy the bot to the server.
