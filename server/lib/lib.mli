(** This is the interface for the Server library, which contains all server functionality. *)

val conv_helper : float -> string -> string -> float
(** [conv_helper amt from_unit to_unit] is a function that returns a float that is the converted (amt) from from_unit to to_unit
    @param amt is the amount to convert
    @param from_unit is the unit to convert from
    @param to_unit is the unit to convert to
    @return a float that is the converted (amt) from from_unit to to_unit
    @precond [amt] must be a float; [from_unit] and [to_unit] must be strings and among the supported units of measurements
    @postcond Return type is float *)

val pp_unit_conv : float -> string -> string -> float -> string
(** [pp_unit_conv amt from_unit to_unit converted_amt] is a function that pretty prints a string for output 
    @param amt is the amount to convert
    @param from_unit is the unit to convert from
    @param to_unit is the unit to convert to
    @param converted_amt is amt in the new unit (to_unit)
    @return a string formatted as follows: "[amt] [from_unit] = [converted_amt] [to_unit]"
    @precond [amt] and [converted_amt] are floats; [from_unit] and [to_unit] are strings
    @postcond return type is a string *)

val rand_btwn : int -> int -> int
(**
  * [rand_btwn low high] is a random integer between [low] and [high], inclusive.
  * Requires: [low] <= [high]
  * Example: [rand_btwn 1 3] is either 1, 2, or 3.
  *)

val coin_flip : unit -> string
(**
  * [coin_flip ()] is either "Heads" or "Tails".
  *)

val header_creator : string -> Cohttp.Header.t
(** [header_creator key] is a function that returns a Cohttp.Header.t type that is sent in an API request
    @param key The OpenAI key used to access the chatbot
    @return The Cohttp.Header.t type that will be sent as a header in the POST request
    @precond [key] must be a non-empty string
    @postcond The result is of type Cohttp.Header.t
     *)

val param_creator :
  string ->
  [> `Assoc of
     (string
     * [> `List of [> `Assoc of (string * [> `String of string ]) list ] list
       | `String of string ])
     list ]
(** [param_creator msg] is a function that returns a Assoc object, which is the parameters for the API request
    @param [msg] The message that the user wants to send to the chatbot
    @return The Assoc type that will be sent as a parameter in the POST request
    @precond [msg] must be a non-empty string
    @postcond The result is of type Assoc
    *)

val chatbot_postrequest :
  Cohttp.Header.t ->
  Yojson.Safe.t ->
  Uri.t ->
  (Cohttp.Response.t * Cohttp_lwt.Body.t) Lwt.t
(** [chatbot_postrequest header param endpoint] is a function that makes a POST request
    @param [header] [param] [endpoint] The message that the user wants to send to the chatbot
    @return Returns a pair with the Response and Body of the request
    @precond [header] [param] and [endpoint] must be non-empty
    @postcond The result is a pair of the Response and Body of the request that was made
     *)

val json_parser : string -> string list
(** [json_parser parsed_body] is a function that parses the body of the made request into a Yojson
    @param [parsed_body] Is the string version of the body
    @return Returns the json version of the string
    @precond [parsed_body] is a non-empty string
    @postcond Creates a string list version of the string body
     *)

val chatbot_body_handler : string -> Rock.Response.t
(** [chatbot_body_handler parsed_body] is a function that parses the body and returns it in a readable format
    @param [parsed_body] Is the string version of the body
    @return Outputs a readable version of the body
    @precond [parsed_body] is a string
    @postcond Outputs a readable version of the body 
    *)

val chatbot_error_handler : Cohttp.Response.t -> Rock.Response.t Lwt.t
(** [chatbot_error_handler resp] is a function that handles errors from the chatbot
    @param [resp] Is the response from the chatbot's POST request
    @return Outputs an error message of Response.t
    @precond [resp] is a Cohttp.Response.t type
    @postcond Outputs an error message
     *)

val create_weather_url : string -> string -> Uri.t
(** [create_weather_url api_key location] is a function that creates a Uri for the weather API request
    @param api_key The weather API key used to access the weather data
    @param location The location for which the weather data is requested
    @return A Uri for the weather API request
    @precond [api_key] and [location] must be non-empty strings
    @postcond The result is of type Uri.t *)

val get_response_body : string -> string -> string
(** [get_response_body location weather] is a function that creates a response body string
    @param location The location for which the weather data is requested
    @param weather The weather description
    @return A response body string
    @precond [location] and [weather] must be non-empty strings
    @postcond The result is of type string *)

val extract_weather_description : Yojson.Safe.t -> string
(** [extract_weather_description json] is a function that extracts the weather description from the given JSON
    @param json A JSON object containing the weather data
    @return The weather description as a string
    @precond [json] must be a valid JSON object
    @postcond The result is of type string *)

val api_key_provider : unit -> string
(** [api_key_provider ()] is a function that returns the API key for the Yandex Translate service.
    @return The API key string
    @postcond The result is a non-empty string *)

val translation_url_creator : string -> string -> string -> string -> Uri.t
(** [translation_url_creator api_key input lang_from_match lang_to_match] is a function that creates a URL for the translation request
    @param api_key The API key for the Yandex Translate service
    @param input The input string to be translated
    @param lang_from_match The language code of the source language
    @param lang_to_match The language code of the target language
    @return A Uri.t type URL for the translation request
    @precond [api_key], [input], [lang_from_match], and [lang_to_match] must be non-empty strings
    @postcond The result is of type Uri.t *)

val translation_get_request :
  Uri.t -> (Cohttp.Response.t * Cohttp_lwt.Body.t) Lwt.t
(** [translation_get_request url] is a function that makes a GET request to the given URL
    @param url The Uri.t type URL for the translation request
    @return A pair containing the response and body of the GET request
    @precond [url] must be a valid Uri.t type URL
    @postcond The result is a pair of the response and body of the GET request *)

val extract_translation_from_body : Cohttp_lwt.Body.t -> string Lwt.t
(** [extract_translation_from_body body] is a function that extracts the translation text from the response body
    @param body The Cohttp_lwt.Body.t type response body
    @return The translated text as a string
    @precond [body] must be a valid Cohttp_lwt.Body.t type
    @postcond The result is a non-empty string *)

val translation_response_builder : string -> Rock.Response.t
(** [translation_response_builder translation] is a function that builds an Opium.Response.t object containing the translation
    @param translation The translated text as a string
    @return An Opium.Response.t object containing the translation
    @precond [translation] must be a non-empty string
    @postcond The result is of type Opium.Response.t *)

val lang_matcher : string -> string
(** [lang_matcher lang] is a function that matches a string lang with a langauge that the translation API supports
    @param lang The string that is to be matched with the supported API languages 
    @return A string containing the encoding of the API language
    @precond [lang] must be a non-empty string
    @postcond The result is of type string *)

val text_board : string list list -> string
(** [text_board board] is a function that converts a game board to a string
    @param board The game board as a list of lists of strings
    @return A string representation of the game board
    @precond [board] must be a valid game board represented as a list of lists of strings
    @postcond The result is a string representation of the game board *)

val other_player : string -> string
(** [other_player player] is a function that returns the other player
    @param player The current player as a string ("x" or "o")
    @return The other player as a string ("x" or "o")
    @precond [player] must be either "x" or "o"
    @postcond The result is either "x" or "o", the other player *)

val check_winner : string -> string -> bool
(** [check_winner board_str player] is a function that checks if the given player has won the game
    @param board_str The game board as a JSON string
    @param player The player to check for win as a string ("x" or "o")
    @return A boolean indicating whether the player has won
    @precond [board_str] must be a valid JSON string representing a game board, [player] must be either "x" or "o"
    @postcond The result is a boolean value indicating whether the player has won *)

val empty_positions : string list list -> (int * int) list
(** [empty_positions board] is a function that returns a list of empty positions on the game board
    @param board The game board as a list of lists of strings
    @return A list of empty positions on the game board, each position represented as a pair of integers
    @precond [board] must be a valid game board represented as a list of lists of strings
    @postcond The result is a list of pairs of integers representing the empty positions on the game board *)

val is_valid_position : string list list -> int * int -> bool
(** [is_valid_position board pos] is a function that checks if a given position is valid (empty) on the game board
    @param board The game board as a list of lists of strings
    @param pos The position to check as a pair of integers
    @return A boolean indicating whether the position is valid
    @precond [board] must be a valid game board represented as a list of lists of strings, [pos] must be a pair of integers
    @postcond The result is a boolean value indicating whether the position is valid *)

val string_to_board : string -> string list list
(** [string_to_board board_str] is a function that converts a JSON string representation of a game board to a list of lists of strings
    @param board_str The game board as a JSON string
    @return The game board as a list of lists of strings
    @precond [board_str] must be a valid JSON string representing a game board
    @postcond The result is a game board represented as a list of lists of strings *)

val board_to_string : string list list -> string
(** [board_to_string board] is a function that converts a game board from a list of lists of strings to a JSON string
    @param board The game board as a list of lists of strings
    @return The game board as a JSON string
    @precond [board] must be a valid game board represented as a list of lists of strings
    @postcond The result is a JSON string representing a game board *)

val minimax : string -> string -> int * (int * int)
(** [minimax board_str player] is a function that uses the minimax algorithm to determine the best move for the given player
    @param board_str The game board as a JSON string
    @param player The current player as a string ("x" or "o")
    @return A pair consisting of the score of the best move and the best move itself as a pair of integers
    @precond [board_str] must be a valid JSON string representing a game board, [player] must be either "x" or "o"
    @postcond The result is a pair consisting of the score of the best move and the best move itself as a pair of integers *)

val ai_move : string list list -> string -> int * int
(** [ai_move board player] is a function that determines the best move for the AI
    @param board The game board as a list of lists of strings
    @param player The AI player as a string ("x" or "o")
    @return The best move for the AI as a pair of integers
    @precond [board] must be a valid game board represented as a list of lists of strings, [player] must be either "x" or "o"
    @postcond The result is a pair of integers representing the best move for the AI *)

val mutable_game_board : string list list ref

val reference_board : unit -> string
(** [reference_board ()] is a function that returns a reference game board as a string
    @return A string representation of a reference game board
    @postcond The result is a string representation of a reference game board *)

val digit_to_position : int -> int * int
(** [digit_to_position digit] is a function that converts a digit (1-9) to a position on the game board
    @param digit The digit to convert as an integer
    @return The position on the game board as a pair of integers
    @precond [digit] must be an integer between 1 and 9 inclusive
    @postcond The result is a pair of integers representing a position on the game board *)
