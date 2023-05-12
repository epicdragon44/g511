open Opium
open Lwt
open Cohttp_lwt_unix
open Yojson.Safe.Util
open Lwt.Syntax
open Cohttp

(** Make a CURL request to the given URL and return the response. *)
let curl_request p_url =
  match Curly.(run (Request.make ~url:p_url ~meth:`GET ())) with
  | Ok x ->
      Format.printf "status: %d\n" x.Curly.Response.code;
      Format.printf "headers: %a\n" Curly.Header.pp x.Curly.Response.headers;
      Format.printf "body: %s\n" x.Curly.Response.body
  | Error e -> Format.printf "Failed: %a" Curly.Error.pp e

(* Unit Converter Helpers *)

(** [conv_helper amt from_unit to_unit] is a function that returns a float that is the converted (amt) from from_unit to to_unit
    @param amt is the amount to convert
    @param from_unit is the unit to convert from
    @param to_unit is the unit to convert to
    @return a float that is the converted (amt) from from_unit to to_unit
    @precond [amt] must be a float; [from_unit] and [to_unit] must be strings and among the supported units of measurements
    @postcond Return type is float *)
let conv_helper amt from_unit to_unit =
  (* enforce preconds *)
  if not (Float.is_finite amt) then
    failwith "amt and converted_amt should be finite floats";
  if not (String.length from_unit > 0 && String.length to_unit > 0) then
    failwith "from_unit and to_unit should be non-empty strings";
  let conversion_factor =
    match (from_unit, to_unit) with
    | "m", "ft" -> 3.28084
    | "ft", "m" -> 0.3048
    | "kg", "lb" -> 2.20462
    | "lb", "kg" -> 0.453592
    | "m", "cm" -> 100.0
    | "cm", "m" -> 0.01
    | "m", "mm" -> 1000.0
    | "mm", "m" -> 0.001
    | "km", "m" -> 1000.0
    | "m", "km" -> 0.001
    | "in", "cm" -> 2.54
    | "cm", "in" -> 0.393701
    | "ft", "in" -> 12.0
    | "in", "ft" -> 0.0833333
    | "mi", "km" -> 1.60934
    | "km", "mi" -> 0.621371
    | "gal", "L" -> 3.78541
    | "L", "gal" -> 0.264172
    | "oz", "g" -> 28.3495
    | "g", "oz" -> 0.035274
    | "lb", "oz" -> 16.0
    | "oz", "lb" -> 0.0625
    | "ton", "kg" -> 907.185
    | "kg", "ton" -> 0.00110231
    | "mph", "km/h" -> 1.60934
    | "km/h", "mph" -> 0.621371
    | "N", "lbf" -> 0.224809
    | "lbf", "N" -> 4.44822
    | _ -> 1.0
  in
  amt *. conversion_factor

(** [pp_unit_conv amt from_unit to_unit converted_amt] is a function that pretty prints a string for output 
    @param amt is the amount to convert
    @param from_unit is the unit to convert from
    @param to_unit is the unit to convert to
    @param converted_amt is amt in the new unit (to_unit)
    @return a string formatted as follows: "[amt] [from_unit] = [converted_amt] [to_unit]"
    @precond [amt] and [converted_amt] are floats; [from_unit] and [to_unit] are strings
    @postcond return type is a string *)
let pp_unit_conv amt from_unit to_unit converted_amt =
  (* enforce preconds *)
  if not (Float.is_finite amt && Float.is_finite converted_amt) then
    failwith "amt and converted_amt should be finite floats";
  if not (String.length from_unit > 0 && String.length to_unit > 0) then
    failwith "from_unit and to_unit should be non-empty strings";
  Printf.sprintf "%g %s = %g %s" amt from_unit converted_amt to_unit

(* Currency Converter Helpers *)

(* Timezone Helpers*)

(**
  * [rand_btwn low high] is a random integer between [low] and [high], inclusive.
  * Requires: [low] <= [high]
  * Example: [rand_btwn 1 3] is either 1, 2, or 3.
  *)
let rand_btwn (low : int) (high : int) : int = low + Random.int (high - low + 1)

(**
    * [coin_flip ()] is either "Heads" or "Tails".
    *)
let coin_flip () = if Random.int 2 = 0 then "Heads" else "Tails"

(** [header_creator key] is a function that returns a Cohttp.Header.t type that is sent in an API request

    @param key The OpenAI key used to access the chatbot

    @return The Cohttp.Header.t type that will be sent as a header in the POST request

    @precond [key] must be a non-empty string

    @postcond The result is of type Cohttp.Header.t
     *)
let header_creator key =
  if String.length key > 0 then
    Cohttp.Header.of_list
      [
        ("Content-Type", "application/json"); ("Authorization", "Bearer " ^ key);
      ]
  else failwith "Invalid api key"

(** [param_creator msg] is a function that returns a Assoc object, which is the parameters for the API request

    @param [msg] The message that the user wants to send to the chatbot

    @return The Assoc type that will be sent as a parameter in the POST request

    @precond [msg] must be a non-empty string

    @postcond The result is of type Assoc
    *)
let param_creator msg =
  if String.length msg > 0 then
    `Assoc
      [
        ("model", `String "gpt-3.5-turbo");
        ( "messages",
          `List
            [ `Assoc [ ("role", `String "user"); ("content", `String msg) ] ] );
      ]
  else failwith "Error: Empty Message"

(** [chatbot_postrequest header param endpoint] is a function that makes a POST request

    @param [header] [param] [endpoint] The message that the user wants to send to the chatbot

    @return Returns a pair with the Response and Body of the request

    @precond [header] [param] and [endpoint] must be non-empty

    @postcond The result is a pair of the Response and Body of the request that was made
     *)
let chatbot_postrequest header param endpoint =
  Cohttp_lwt_unix.Client.post ~headers:header
    ~body:(`String (Yojson.Safe.to_string param))
    endpoint

(** [json_parser parsed_body] is a function that parses the body of the made request into a Yojson

    @param [parsed_body] Is the string version of the body

    @return Returns the json version of the string

    @precond [parsed_body] is a non-empty string

    @postcond Creates a string list version of the string body
     *)
let json_parser parsed_body =
  if String.length parsed_body > 0 then
    parsed_body |> Yojson.Basic.from_string
    |> Yojson.Basic.Util.member "choices"
    |> Yojson.Basic.Util.to_list
    |> List.map (fun message ->
           message
           |> Yojson.Basic.Util.member "message"
           |> Yojson.Basic.Util.member "content"
           |> Yojson.Basic.Util.to_string)
  else failwith "Invalid Input: Empty body"

(** [chatbot_body_handler parsed_body] is a function that parses the body and returns it in a readable format

    @param [parsed_body] Is the string version of the body

    @return Outputs a readable version of the body

    @precond [parsed_body] is a string

    @postcond Outputs a readable version of the body 
    *)
let chatbot_body_handler parsed_body =
  let json = json_parser parsed_body in
  match json with
  | [] -> Printf.sprintf "Empty" |> Opium.Response.of_plain_text
  | h :: _ -> Printf.sprintf "%s\n" h |> Opium.Response.of_plain_text

(** [chatbot_error_handler resp] is a function that handles errors from the chatbot

    @param [resp] Is the response from the chatbot's POST request

    @return Outputs an error message of Response.t

    @precond [resp] is a Cohttp.Response.t type

    @postcond Outputs an error message
     *)
let chatbot_error_handler resp =
  Printf.sprintf "Error: %s\n"
    (Cohttp_lwt.Response.status resp |> Cohttp.Code.string_of_status)
  |> Opium.Response.of_plain_text |> Lwt.return

(* let general_chat_handler openai_key req =
   (* One test that can be done is to test a helper function that parses json files? *)
   let msg = Router.param req "msg" in
   let endpoint = Uri.of_string "https://api.openai.com/v1/chat/completions" in
   let header = header_creator openai_key in
   let param = param_creator msg in
   chatbot_postrequest header param endpoint >>= fun (resp, body) ->
   (* This is to handle any error response code *)
   match Cohttp_lwt.Response.status resp with
   | `OK -> body |> Cohttp_lwt.Body.to_string >|= chatbot_body_handler
   | _ -> chatbot_error_handler resp *)

(** [create_weather_url api_key location] is a function that creates a Uri for the weather API request
@param api_key The weather API key used to access the weather data
@param location The location for which the weather data is requested
@return A Uri for the weather API request
@precond [api_key] and [location] must be non-empty strings
@postcond The result is of type Uri.t *)

let create_weather_url api_key location =
  if String.length api_key > 0 && String.length location > 0 then
    Uri.of_string
      (Printf.sprintf
         "http://api.weatherstack.com/current?access_key=%s&query=%s" api_key
         location)
  else failwith "Invalid Input: Empty api_key or location"

(** [get_response_body location weather] is a function that creates a response body string
@param location The location for which the weather data is requested
@param weather The weather description
@return A response body string
@precond [location] and [weather] must be non-empty strings
@postcond The result is of type string *)

let get_response_body location weather =
  if String.length location > 0 && String.length weather > 0 then
    Printf.sprintf "The weather in %s is %s." location weather
  else failwith "Invalid Input: Empty location or weather"

(** [extract_weather_description json] is a function that extracts the weather description from the given JSON
@param json A JSON object containing the weather data
@return The weather description as a string
@precond [json] must be a valid JSON object
@postcond The result is of type string *)

let extract_weather_description json =
  Yojson.Safe.Util.(
    json |> member "current"
    |> member "weather_descriptions"
    |> to_list |> List.hd |> to_string)

(** [api_key_provider ()] is a function that returns the API key for the Yandex Translate service.
@return The API key string
@postcond The result is a non-empty string *)

let api_key_provider () =
  "trnsl.1.1.20230317T192942Z.38aa007e66112d27.70023d1d131998c0c80fd04ef3c38c5024a7068c"

(** [translation_url_creator api_key input lang_from_match lang_to_match] is a function that creates a URL for the translation request
@param api_key The API key for the Yandex Translate service
@param input The input string to be translated
@param lang_from_match The language code of the source language
@param lang_to_match The language code of the target language
@return A Uri.t type URL for the translation request
@precond [api_key], [input], [lang_from_match], and [lang_to_match] must be non-empty strings
@postcond The result is of type Uri.t *)

let translation_url_creator api_key input lang_from_match lang_to_match =
  Uri.of_string
    (Printf.sprintf
       "https://translate.yandex.net/api/v1.5/tr.json/translate?key=%s&text=%s&lang=%s-%s"
       api_key input lang_from_match lang_to_match)

(** [api_key_provider ()] is a function that returns the API key for the Yandex Translate service.
@return The API key string
@postcond The result is a non-empty string *)

let api_key_provider () =
  "trnsl.1.1.20230317T192942Z.38aa007e66112d27.70023d1d131998c0c80fd04ef3c38c5024a7068c"

(** [translation_url_creator api_key input lang_from_match lang_to_match] is a function that creates a URL for the translation request
@param api_key The API key for the Yandex Translate service
@param input The input string to be translated
@param lang_from_match The language code of the source language
@param lang_to_match The language code of the target language
@return A Uri.t type URL for the translation request
@precond [api_key], [input], [lang_from_match], and [lang_to_match] must be non-empty strings
@postcond The result is of type Uri.t *)

let translation_url_creator api_key input lang_from_match lang_to_match =
  Uri.of_string
    (Printf.sprintf
       "https://translate.yandex.net/api/v1.5/tr.json/translate?key=%s&text=%s&lang=%s-%s"
       api_key input lang_from_match lang_to_match)

(** [translation_get_request url] is a function that makes a GET request to the given URL
@param url The Uri.t type URL for the translation request
@return A pair containing the response and body of the GET request
@precond [url] must be a valid Uri.t type URL
@postcond The result is a pair of the response and body of the GET request *)

let translation_get_request url = Cohttp_lwt_unix.Client.get url

(** [extract_translation_from_body body] is a function that extracts the translation text from the response body
@param body The Cohttp_lwt.Body.t type response body
@return The translated text as a string
@precond [body] must be a valid Cohttp_lwt.Body.t type
@postcond The result is a non-empty string *)

let extract_translation_from_body body =
  body |> Cohttp_lwt.Body.to_string >|= fun body_str ->
  let json = Yojson.Safe.from_string body_str in
  Yojson.Safe.Util.(json |> member "text" |> to_list |> List.hd |> to_string)

(** [translation_response_builder translation] is a function that builds an Opium.Response.t object containing the translation
@param translation The translated text as a string
@return An Opium.Response.t object containing the translation
@precond [translation] must be a non-empty string
@postcond The result is of type Opium.Response.t *)

let translation_response_builder translation =
  let response_body = Printf.sprintf "Translation: %s" translation in
  Opium.Response.of_plain_text response_body

(** [lang_matcher lang] is a function that matches a string lang with a langauge that the translation API supports
@param lang The string that is to be matched with the supported API languages 
@return A string containing the encoding of the API language
@precond [lang] must be a non-empty string
@postcond The result is of type string *)

let lang_matcher lang =
  match lang with
  | "Azerbaijani" -> "az"
  | "Albanian" -> "sq"
  | "Amharic" -> "am"
  | "English" -> "en"
  | "Arabic" -> "ar"
  | "Armenian" -> "hy"
  | "Afrikaans" -> "af"
  | "Basque" -> "eu"
  | "Bashkir" -> "ba"
  | "Belarusian" -> "be"
  | "Bengal" -> "bn"
  | "Burmese" -> "my"
  | "Bulgarian" -> "bg"
  | "Bosnian" -> "bs"
  | "Welsh" -> "cy"
  | "Hungarian" -> "hu"
  | "Vietnamese" -> "vi"
  | "Haitian" -> "ht"
  | "Galician" -> "gl"
  | "Dutch" -> "nl"
  | "Hill Mari" -> "mrj"
  | "Greek" -> "el"
  | "Georgian" -> "ka"
  | "Gujarati" -> "gu"
  | "Danish" -> "da"
  | "Hebrew" -> "he"
  | "Yiddish" -> "yi"
  | "Indonesian" -> "id"
  | "Irish" -> "ga"
  | "Italian" -> "it"
  | "Icelandic" -> "is"
  | "Spanish" -> "es"
  | "Kazakh" -> "kk"
  | "Kannada" -> "kn"
  | "Catalan" -> "ca"
  | "Kirghiz" -> "ky"
  | "Chinese" -> "zh"
  | "Korean" -> "ko"
  | "Xhosa" -> "xh"
  | "Khmer" -> "km"
  | "Laotian" -> "lo"
  | "Latin" -> "la"
  | "Latvian" -> "lv"
  | "Lithuanian" -> "lt"
  | "Luxembourg" -> "lb"
  | "Malagasy" -> "mg"
  | "Malay" -> "ms"
  | "Malayalam" -> "ml"
  | "Maltese" -> "mt"
  | "Macedonian" -> "mk"
  | "Maori" -> "mi"
  | "Marathi" -> "mr"
  | "Mari" -> "mhr"
  | "Mongolian" -> "mn"
  | "German" -> "de"
  | "Nepalese" -> "ne"
  | "Norwegian" -> "no"
  | "Punjabi" -> "pa"
  | "Papiamento" -> "pap"
  | "Persian" -> "fa"
  | "Polish" -> "pl"
  | "Portuguese" -> "pt"
  | "Romanian" -> "ro"
  | "Russian" -> "ru"
  | "Cebuano" -> "ceb"
  | "Serbian" -> "sr"
  | "Sinhalese" -> "si"
  | "Slovak" -> "sk"
  | "Slovenian" -> "sl"
  | "Swahili" -> "sw"
  | "Sundanese" -> "su"
  | "Tajik" -> "tg"
  | "Thai" -> "th"
  | "Tagalog" -> "tl"
  | "Tamil" -> "ta"
  | "Tartar" -> "tt"
  | "Telugu" -> "te"
  | "Turkish" -> "tr"
  | "Udmurt" -> "udm"
  | "Uzbek" -> "uz"
  | "Ukrainian" -> "uk"
  | "Urdu" -> "ur"
  | "Finnish" -> "fi"
  | "French" -> "fr"
  | "Hindi" -> "hi"
  | "Croatian" -> "hr"
  | "Czech" -> "cs"
  | "Swedish" -> "sv"
  | "Scottish" -> "gd"
  | "Estonian" -> "et"
  | "Esperanto" -> "eo"
  | "Javanese" -> "jv"
  | "Japanese" -> "ja"
  | _ -> "unsupported"

(** [text_board board] is a function that converts a game board to a string
@param board The game board as a list of lists of strings
@return A string representation of the game board
@precond [board] must be a valid game board represented as a list of lists of strings
@postcond The result is a string representation of the game board *)

let text_board board =
  let row_strings =
    List.map
      (fun row ->
        "|"
        ^ String.concat "|" (List.map (fun x -> if x = "_" then " " else x) row)
        ^ "|\n")
      board
  in
  String.concat "" row_strings

open Yojson.Basic.Util

(** [other_player player] is a function that returns the other player
@param player The current player as a string ("x" or "o")
@return The other player as a string ("x" or "o")
@precond [player] must be either "x" or "o"
@postcond The result is either "x" or "o", the other player *)

let other_player player = if player = "x" then "o" else "x"

(** [check_winner board_str player] is a function that checks if the given player has won the game
@param board_str The game board as a JSON string
@param player The player to check for win as a string ("x" or "o")
@return A boolean indicating whether the player has won
@precond [board_str] must be a valid JSON string representing a game board, [player] must be either "x" or "o"
@postcond The result is a boolean value indicating whether the player has won *)

let check_winner board_str player =
  let board_json = Yojson.Basic.from_string board_str in
  let board =
    board_json |> member "board" |> to_list
    |> List.map (fun row -> to_list row |> List.map to_string)
  in
  let check_row row = List.for_all (( = ) player) row in
  let check_col col =
    List.for_all (( = ) player) (List.map (fun row -> List.nth row col) board)
  in
  let check_diag1 () =
    List.for_all2 (fun i row -> List.nth row i = player) [ 0; 1; 2 ] board
  in
  let check_diag2 () =
    List.for_all2 (fun i row -> List.nth row (2 - i) = player) [ 0; 1; 2 ] board
  in
  List.exists check_row board
  || List.exists (fun i -> check_col i) [ 0; 1; 2 ]
  || check_diag1 () || check_diag2 ()

(** [empty_positions board] is a function that returns a list of empty positions on the game board
@param board The game board as a list of lists of strings
@return A list of empty positions on the game board, each position represented as a pair of integers
@precond [board] must be a valid game board represented as a list of lists of strings
@postcond The result is a list of pairs of integers representing the empty positions on the game board *)

let empty_positions board =
  let positions = ref [] in
  for i = 0 to 2 do
    for j = 0 to 2 do
      let cell = List.nth (List.nth board i) j in
      if cell <> "x" && cell <> "o" then positions := (i, j) :: !positions
    done
  done;
  !positions

(** [is_valid_position board pos] is a function that checks if a given position is valid (empty) on the game board
@param board The game board as a list of lists of strings
@param pos The position to check as a pair of integers
@return A boolean indicating whether the position is valid
@precond [board] must be a valid game board represented as a list of lists of strings, [pos] must be a pair of integers
@postcond The result is a boolean value indicating whether the position is valid *)

let is_valid_position board pos =
  let row = List.nth board (fst pos) in
  let cell = List.nth row (snd pos) in
  cell <> "x" && cell <> "o"

(** [string_to_board board_str] is a function that converts a JSON string representation of a game board to a list of lists of strings
@param board_str The game board as a JSON string
@return The game board as a list of lists of strings
@precond [board_str] must be a valid JSON string representing a game board
@postcond The result is a game board represented as a list of lists of strings *)

let string_to_board board_str =
  let board_json = Yojson.Basic.from_string board_str in
  board_json |> member "board" |> to_list
  |> List.map (fun row -> to_list row |> List.map to_string)

(** [board_to_string board] is a function that converts a game board from a list of lists of strings to a JSON string
@param board The game board as a list of lists of strings
@return The game board as a JSON string
@precond [board] must be a valid game board represented as a list of lists of strings
@postcond The result is a JSON string representing a game board *)

let board_to_string board =
  let board_json =
    `Assoc
      [
        ( "board",
          `List
            (List.map
               (fun row -> `List (List.map (fun cell -> `String cell) row))
               board) );
      ]
  in
  Yojson.Basic.to_string board_json

(** [minimax board_str player] is a function that uses the minimax algorithm to determine the best move for the given player
@param board_str The game board as a JSON string
@param player The current player as a string ("x" or "o")
@return A pair consisting of the score of the best move and the best move itself as a pair of integers
@precond [board_str] must be a valid JSON string representing a game board, [player] must be either "x" or "o"
@postcond The result is a pair consisting of the score of the best move and the best move itself as a pair of integers *)

let rec minimax board_str player =
  let board = string_to_board board_str in
  if check_winner board_str (other_player player) then (-1, (0, 0))
  else if empty_positions board = [] then (0, (0, 0))
  else
    let rec aux best_score best_move = function
      | [] -> (best_score, best_move)
      | (i, j) :: tail ->
          let row = List.nth board i in
          let updated_row =
            List.mapi (fun k cell -> if k = j then player else cell) row
          in
          let updated_board =
            List.mapi (fun k row -> if k = i then updated_row else row) board
          in
          let updated_board_str = board_to_string updated_board in
          let score, _ = minimax updated_board_str (other_player player) in
          let score = -score in
          if score > best_score then aux score (i, j) tail
          else aux best_score best_move tail
    in
    aux min_int (0, 0) (empty_positions board)

(** [ai_move board player] is a function that determines the best move for the AI
@param board The game board as a list of lists of strings
@param player The AI player as a string ("x" or "o")
@return The best move for the AI as a pair of integers
@precond [board] must be a valid game board represented as a list of lists of strings, [player] must be either "x" or "o"
@postcond The result is a pair of integers representing the best move for the AI *)

let ai_move board player =
  let _, best_move = minimax (board_to_string board) player in
  best_move

let mutable_game_board =
  ref [ [ "1"; "2"; "3" ]; [ "4"; "5"; "6" ]; [ "7"; "8"; "9" ] ]

(** [reference_board ()] is a function that returns a reference game board as a string
@return A string representation of a reference game board
@postcond The result is a string representation of a reference game board *)

let reference_board () =
  let reference = [ [ "1"; "2"; "3" ]; [ "4"; "5"; "6" ]; [ "7"; "8"; "9" ] ] in
  "Reference board:\n" ^ text_board reference

(** [digit_to_position digit] is a function that converts a digit (1-9) to a position on the game board
@param digit The digit to convert as an integer
@return The position on the game board as a pair of integers
@precond [digit] must be an integer between 1 and 9 inclusive
@postcond The result is a pair of integers representing a position on the game board *)

let digit_to_position digit =
  let row = (digit - 1) / 3 in
  let col = (digit - 1) mod 3 in
  (row, col)
