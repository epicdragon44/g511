open Helper

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

(** [general_chat_handler_call msg] returns a string that is the response from the
    server when the user sends a message in the general chat handler.

    Precondition: [msg] is a string.
    Postcondition: Returns a string that is the response from the server.

    @param (msg : string) is the message sent by the user

    @return a string that is the response from the server

    @example general_chat_handler "Tell me the news" 1 returns "Here's the news: ..."
*)
let general_chat_handler_call (msg : string) : string =
  call ("http://localhost:9000/chat/general/" ^ msg ^ "/0")

(** Helper function for convert_units and convert_curr below *)
let convert (typ : string) (amt : string) (from : string) (too : string) :
    string =
  call
    ("http://localhost:9000/convert/" ^ typ ^ "/" ^ amt ^ "/" ^ from ^ "/" ^ too)

(** Converts a given amount from one unit of measurement to another.

      Preconditions:
      - amt is the string representation of an int or float (e.g. "20", "30.65")
      - from and too are (lowercase) strings that represent a supported unit of measurement,
      which is listed here: ["m", "ft", "kg", "lb", "cm", "mm", "km", "in", 
      "mi", "gal", "L", "oz", "ton", "mph", "km/h", "N", "lbf"]
      - any inputs of from and too that are not from the list given above 
      will not result in a valid conversion


      Postcondition: returns a string in the format of 
      "(amt) (from) = [converted amount] (too)".
      (converted amount is accurate up to 6 significant figures)

      @param amt is the amount to convert
      @param from is the unit to convert from
      @param too is the unit to convert to

      @return amt converted to the new unit of measurement

      @example the call [convert_units 1.5 m cm] returns "1.5 m = 150 cm"
*)
let convert_units (amt : string) (from : string) (too : string) : string =
  convert "units" amt from too

(** Converts a given amount from one currency to another.

      Preconditions:
      - amt is the string representation of an int or float (e.g. "20", "30.65")
      - from and too are (uppercase) strings that represent a valid currency
        * it must be a valid ISO currency code


      Postcondition: returns a string in the format of 
      "(amt) (from) is equivalent to [converted amount] (too)". 
      (converted amount is accurate to 6 decimal points)

      @param amt is the amount to convert
      @param from is the currency to convert from
      @param too is the currency to convert to

      @return amt converted to the new currency

      @example the call [convert_units 20.5 USD USD] returns 
      "20.5 USD is equivalent to 20.5 USD"
*)
let convert_curr (amt : string) (from : string) (too : string) : string =
  convert "currency" amt from too

(** Returns the current time in a given timezone.
    
    Preconditions: the inputs [area] and [location] must be a 
    valid TZ identifier (see 'tz database' online). 
    
    Example: if I wanted to query about the time in New York City, 
    the TZ identifier for that would be America/New_York. In that case, 
    the [area] input would be "America" and 
    the [location] input would be "New_York".

    Postcondition: returns a string in the format of
    "The current time in (area)/(location) is [hh:mm:ss]"

    @param [area]/[location] is the TZ identifier of a timezone

    @return the current time (24hr) in the requested timezone

    @example if I call [get_curr_time "America" "New_York"] at 6:00pm, the return
    string will be "The current time in America/New_York is 18:00:00"
*)
let get_curr_time (area : string) (location : string) =
  call ("http://localhost:9000/convert/" ^ area ^ "/" ^ location)

(** Echoes a string back to you.

      Precondition: None.
      Postcondition: The string is the same as the string passed in.

      @param msg The string to echo.

      @return The string that was passed in.

      @example
      {[
        echo "hello" = "hello"
      ]}
*)
let echo (msg : string) = msg

(** Flips a coin and returns the result.

      Precondition: None.
      Postcondition: The result is either "heads" or "tails".

      @param () The unit value.

      @return The result of the coin flip.

      @example
      {[
        flip_coin () = "Heads" || flip_coin () = "Tails"
      ]}
*)
let flip_coin (_ : string) : string = call "http://localhost:9000/coinflip"

let rng_btwn (min : int) (max : int) : string =
  call
    ("http://localhost:9000/rng/" ^ string_of_int min ^ "/" ^ string_of_int max)

(** Removes the first word of a string.

      Precondition: The string is not empty.
      Postcondition: The string is only one word shorter.
  
      @param s The string to remove the first word of.
  
      @return The string with the first word removed.

      @raise Invalid_argument if the string is empty.

      @example
      {[
        remove_first_word_of "hello world" = "world"
      ]}
*)
let remove_first_word_of (s : string) : string =
  if s = "" then raise (Invalid_argument "remove_first_word_of: empty string")
  else
    let len = String.length s in
    let rec loop i =
      if i = len then ""
      else if s.[i] = ' ' then String.sub s (i + 1) (len - i - 1)
      else loop (i + 1)
    in
    loop 0
