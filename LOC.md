Return to [DOCS.md](DOCS.md)

# Welcome to the Lines of Code File

We'll endeavor to explain decisions regarding how we counted lines of code in this file. This is primarily for CS 3110 project graders.

---

Our `make loc` command counts all lines of code that are:

-   Not blank (whitespace or empty)
-   Valid OCaml code (located within a `.ml` file)

Note that this definition means that:

-   We do NOT count blank lines.
-   We DO count comments.
-   We do NOT count interface files (`.mli`).

This is a verifiably correct definition for many reasons:

1. We do not count blank lines, because to do so would be to unfairly inflate our lines of code count.
2. We do count comments, because we strongly believe that good, robust documentation is an integral part of good, robust code. Additionally, the bulk of our `.ml` files are NOT comments, and so we do not unfairly inflate our lines of code count.
3. We do not count interface files, mostly because the bulk of our `.mli` files ARE comments, and so we do not unfairly inflate our lines of code count.

---

Wondering how to count the lines of code yourself? Return to the [DOCS.md](DOCS.md) file and read the section **Counting Lines of Code**.
