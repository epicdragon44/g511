# Pre-requisites

You must have Ubuntu 18.04 LTS or later, or Mac OSX 10.14 or later. Windows is NOT supported.

If you are on Mac, you must also have [Homebrew](https://brew.sh/) installed.

Then, you must have OCaml and OPAM installed as described in the Cornell CS 3110 Textbook [installation instructions](https://cs3110.github.io/textbook/chapters/preface/install.html#).

# Installation

Make sure you are in the root directory of the repository, then run `make initialize` to setup everything for the first time.

Having done this, return to [README.md](README.md) and keep reading for instructions on building, testing, and running.

# Notice

You might be thinking "surely there's more to it than a simple `make initialize`?!"

I'm afraid you would be mistaken.

# Managing OPAM Switches

Our initialization script will create a new switch called `bocaml` and install all relevant packages there. If you want to switch out of it or back into this OPAM switch, run:

```bash
opam switch # lists all available switches
opam switch bocaml # switches to the bocaml switch
opam switch <some-other-switch> # switches to some-other-switch
```