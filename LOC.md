Return to [DOCS.md](DOCS.md)

# Welcome to the Lines of Code File

We'll endeavor to explain decisions regarding how we counted lines of code in this file. This is primarily for CS 3110 project graders.

---

The `cloc` command that the Final Project assignment on Canvas recommends (`cloc --by-file --include-lang=OCaml .`) actually includes `_build` folders. We prefer not to use that metric.

Thus, our `make loc` command counts all lines of code in `.ml` and `.mli` files, and those files only. Obviously, it excludes `_build` folders.

---

Wondering how to count the lines of code yourself? Return to the [DOCS.md](DOCS.md) file and read the section **Counting Lines of Code**.
