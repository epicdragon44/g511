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

(** Fetches the weather for a given location.

      Precondition: 
      1. The location must be a valid string representing a place for which weather data is available. 
      2. The server at "http://localhost:9000/weather/" should be active and correctly functioning.
      
      Postcondition: The returned string should represent the weather condition of the provided location.

      @param location The name of the location for which to fetch weather data.

      @return The weather condition of the provided location as a string.

      @example
      {[
        get_weather "New York" = "Sunny" || get_weather "New York" = "Cloudy" || get_weather "New York" = "Rainy" || ...
      ]}
*)
let get_weather (location : string) : string =
  call ("http://localhost:9000/weather/" ^ location)

(** Translates a given string from one language to another.

      Precondition: 
      1. The 'body' must be a valid string in the source language.
      2. The 'f' must be a valid language code representing the source language. 
      3. The 't' must be a valid language code representing the target language.
      4. The server at "http://localhost:9000/translate/" should be active and correctly functioning.
      
      Postcondition: The returned string is the translated text in the target language.

      @param body The text to be translated.
      @param f The source language code.
      @param t The target language code.

      @return The translated text.

      @example
      {[
        get_translate "Hello" "English" "Spanish" = "Hola"
      ]}
*)
let get_translate (body : string) (f : string) (t : string) : string =
  call ("http://localhost:9000/translate/" ^ body ^ "/" ^ f ^ "/" ^ t)

(** Interacts with the AI Tic Tac Toe game handler.

      Precondition: 
      1. The 'action' should be a valid game action ("start" or "move").
      2. The 'player' should be a valid player marker (i.e. "x" or "o").
      3. The 'pos' should be a valid position (i.e. an integer between 1 and 9 inclusive).
      4. The server at "http://localhost:9000/ai_t_game_handler/" should be active and correctly functioning.
      
      Postcondition: The returned string should represent the state of the game board after the player's and AI's moves.

      @param action The game action to be performed.
      @param player The player's marker type.
      @param pos The position the player wants to place their marker.

      @return The game board state as a string.

      @example
      {[
        get_ai_text "start" "x" 5 = "Game started!\n" || get_ai_text "move" "x" 1 = "Game Board:\n| | | |\n| |X| |\n| | | |\n"
      ]}
*)
let get_ai_text (action : string) (player : string) (pos : int) : string =
  call
    ("http://localhost:9000/ai_t_game_handler/" ^ action ^ "/" ^ player ^ "/"
   ^ string_of_int pos)
