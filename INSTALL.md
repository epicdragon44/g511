# Pre-requisites

You must have Ubuntu 18.04 LTS or later, or Mac OSX 10.14 or later. Windows is NOT supported.

If you are on Mac, you must also have [Homebrew](https://brew.sh/) installed.

Then, you must have OCaml and OPAM installed as described in the Cornell CS 3110 Textbook [installation instructions](https://cs3110.github.io/textbook/chapters/preface/install.html#).

# First-time Setup

Make sure you are in the root directory of the repository, then run `./init.sh` to setup everything for the first time.

This will create a new OPAM switch dedicated to our project! Bear with it -- the script may take a while to run.

# Common Issues

If you are unable to run any of the scripts due to insufficient permissions, try running `find ./ -type f -iname "*.sh" -exec chmod +x {} \;`.

Additionally, if red squiggly lines appear anywhere, try running `./scripts/build.sh` _within_ either the `bot` or `server` directories. You may then need to re-save the file to get the error to go away.
