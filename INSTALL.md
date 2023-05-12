Return to [README.md](README.md)

---

# Installation

This document is for first-time setup only! If you've already done this, you can skip this document and go to the [docs](DOCS.md).

---

## 0. Pre-requisites

You must have Ubuntu 18.04 LTS or later, or Mac OSX 10.14 or later. Windows is NOT supported.

If you are on Mac, you must also have [Homebrew](https://brew.sh/) installed.

Then, you must have OCaml and OPAM installed as described in the Cornell CS 3110 Textbook [installation instructions](https://cs3110.github.io/textbook/chapters/preface/install.html#).

## 1. Check your Secrets

-   You'll need to create/have a file `bot/.env` that contains one line: `BOT_TOKEN = <some key>`, where `some key` is the Telegram bot token provided by BotFather. **If you're a Cornell CS3110 grader, you should already have this file.**

-   You'll need to create/have a file `server/.env` that contains one line: `OPENAI_TOKEN = <some key>`, where `some key` is the OpenAI API key provided by OpenAI. **If you're a Cornell CS3110 grader, you should already have this file.**

## 2. Installation

Make sure you are in the root directory of the repository, then run `make initialize` to setup everything for the first time.

## 3. Next Steps

Having done all this, proceed to the [docs](DOCS.md) and keep reading for instructions on building, testing, and running. This is **required**, including for CS3110 graders!

---

## Notices

### A Message from the Team

You might be thinking "surely there's more to it than a simple `make initialize`?!"

I'm afraid you would be mistaken. We tried to make this as seamless as humanly possible. If you have any questions, please reach out!

### Managing OPAM Switches

Our initialization script will create a new switch called `bocaml` and install all relevant packages there. If you want to switch out of it or back into this OPAM switch, run:

```bash
opam switch # lists all available switches
opam switch bocaml # switches to the bocaml switch
opam switch <some-other-switch> # switches to some-other-switch
```
