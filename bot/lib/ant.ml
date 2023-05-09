open Helper

(* TODO:

    1. Write a helper function below, in this file, that calls the server API we built previously.
        To help, I made a helper function [call <some url>] in [Helper.ml] that gets you the text that a server returns.
        You can use it like this: [call "http://localhost:9000/coinflip"].
       Do this for *every* server endpoint you built previously.

       For each one, as usual, include documentation on pre and post-conditions, parameters, what it returns, what it does, etc.

    2. Write unit tests in [bot/test/main.ml] for all the helper functions you wrote here.

    3. Go to [bot/bin/main.ml] and read through and do the "Secondary TODO" there.

    If you need some examples, search the whole project for the word "rng". You'll see I:
    - I have an rng endpoint in [server/bin/main.ml] that looks like this: ["/rng/:min/:max"].
    - So I made an rng_btwn helper function in [bot/lib/dan.ml] that calls that endpoint.
    - Then I wrote some unit tests for it in [bot/test/main.ml].
    - Then I followed the instructions in [bot/bin/main.ml] to connect it to the Telegram bot.
*)

let hi = "hello"
