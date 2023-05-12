(** This is the interface for the Bot library, which contains all bot functionality. *)

val get_weather : string -> string
(** Fetches the weather for a given location.
    @param location The name of the location for which to fetch weather data.
    @return The weather condition of the provided location as a string.
    @example get_weather "New York" = "Sunny"
    @see <http://localhost:9000/weather/> *)

val get_translate : string -> string -> string -> string
(** Translates a given string from one language to another.
        @param body The text to be translated.
        @param f The source language code.
        @param t The target language code.
        @return The translated text.
        @example get_translate "Hello" "English" "Spanish" = "Hola"
        @see <http://localhost:9000/translate/> *)

val get_ai_text : string -> string -> int -> string
(** Interacts with the AI Tic Tac Toe game handler.
        @param action The game action to be performed.
        @param player The player's marker type.
        @param pos The position the player wants to place their marker.
        @return The game board state as a string.
        @example get_ai_text "start" "x" 5 = "Game started!"
        @see <http://localhost:9000/ai_t_game_handler/> *)

val general_chat_handler_call : string -> string
(** Returns a string that is the response from the server when the user sends a message in the general chat handler.
        @param msg The message sent by the user.
        @return The response from the server.
        @example general_chat_handler "Tell me the news" 1 = "Here's the news: ..."
        @see <http://localhost:9000/chat/general/> *)

val convert_units : string -> string -> string -> string
(** Converts a given amount from one unit of measurement to another.
        @param amt The amount to convert.
        @param from The unit to convert from.
        @param too The unit to convert to.
        @return The amount converted to the new unit of measurement.
        @example convert_units "1.5" "m" "cm" = "1.5 m = 150 cm"
        @see <http://localhost:9000/convert/> *)

val convert_curr : string -> string -> string -> string
(** Converts a given amount from one currency to another.
        @param amt The amount to convert.
        @param from The currency to convert from.
        @param too The currency to convert to.
        @return The amount converted to the new currency.
        @example convert_curr "20.5" "USD" "USD" = "20.5 USD is equivalent to 20.5 USD"
        @see <http://localhost:9000/convert/> *)

val get_curr_time : string -> string -> string
(** Returns the current time in a given timezone.
        @param area The major geographical area of the timezone.
        @param location The specific location within the area of the timezone.
        @return The current time in the requested timezone.
        @example get_curr_time "America" "New_York" = "The current time in America/New_York is 18:00:00"
        @see <http://localhost:9000/convert/> *)

val echo : string -> string
(** Echoes a string back to you.
        @param msg The string to echo.
        @return The string that was passed in.
        @example echo "hello" = "hello" *)

val flip_coin : string -> string
(** Flips a coin and returns the result.
    @param () The unit value.
    @return The result of the coin flip.
    @example flip_coin () = "Heads" || flip_coin () = "Tails"
    @see <http://localhost:9000/coinflip> *)

val rng_btwn : int -> int -> string
(** Returns a random number between the given range.
    @param min The lower bound of the range.
    @param max The upper bound of the range.
    @return A random number between the given range.
    @see <http://localhost:9000/rng/> *)

val remove_first_word_of : string -> string
(** Removes the first word of a string.
    @param s The string to remove the first word of.
    @return The string with the first word removed.
    @raise Invalid_argument if the string is empty.
    @example remove_first_word_of "hello world" = "world" *)
