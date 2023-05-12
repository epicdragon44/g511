Return to [DOCS.md](DOCS.md)

# Welcome to the Test File

We'll endeavor to explain testing decisions in this file. This is primarily for CS 3110 project graders.

First, you must be aware of the structure of our project. If you are still unfamiliar with it, please return to the [README](README.md) and read the section on **Project Structure**.

---

Having been made aware of the project structure, you will see that it logically follows that:

-   Automated testing will be done on all of the actual logic and functionality, which is housed in `server/lib`. This is because the `server` is the only part of the project that actually does anything. The `bot` is merely a conduit for the `server` to interact with Telegram. Thus, we will test all actual programmatic functionality.
-   Manual testing will be done via hitting the endpoints in our server, as well as messaging the Telegram bot, as described in the [README](README.md) section on **Interacting with the Bot**. This makes sure that the aforementioned conduit is actually functional.

It also thus follows, of course, that OUnit will be testing the `lib/main.ml` module in `server`.

Testing will be conducted in a "globally" glass-box manner in that we do not test the overall project-wide loop from Telegram to Server and back to Telegram via OUnit, and expect a certain result. Rather, we test the implementation, i.e. each individual function in `server/lib` in isolation, and expect a certain result. Those tests are, then, in a sense, "locally" black-box tests -- in that they do not care about the implementation of the functions they are testing, but rather, only the input and output.

This is a verifiably correct testing plan for many reasons:

1. We are testing the functionality of each function in `server/lib` in isolation, which is the most granular level of testing possible.
2. We test all relevant input and output combinations for each function, which is the most comprehensive testing possible.
3. We eschew the [brittle](https://softwareengineering.stackexchange.com/questions/356236/definition-of-brittle-unit-tests) nature of testing the overall project-wide loop, which is the most robust testing possible.
4. We do not test the implementation of the functions, but rather, the input and output, which is the most correct testing possible.
5. We do not test boilerplate code and external library code (provided by [TelegraML](https://github.com/nv-vn/TelegraML) and [Opium](https://github.com/rgrinberg/opium)), which is the most efficient testing possible.

---

Wondering how to test the bot? Return to the [DOCS.md](DOCS.md) file and read the section **Test the Project**.
