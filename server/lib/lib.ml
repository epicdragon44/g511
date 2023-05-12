open Opium
open Lwt
open Cohttp_lwt_unix
open Yojson.Safe.Util
open Lwt.Syntax
open Cohttp

let conv_helper (amt : float) (from_unit : string) (to_unit : string) : float =
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

let pp_unit_conv (amt : float) (from_unit : string) (to_unit : string)
    (converted_amt : float) : string =
  (* enforce preconds *)
  if not (Float.is_finite amt && Float.is_finite converted_amt) then
    failwith "amt and converted_amt should be finite floats";
  if not (String.length from_unit > 0 && String.length to_unit > 0) then
    failwith "from_unit and to_unit should be non-empty strings";
  Printf.sprintf "%g %s = %g %s" amt from_unit converted_amt to_unit

let rand_btwn (low : int) (high : int) : int = low + Random.int (high - low + 1)
let coin_flip () : string = if Random.int 2 = 0 then "Heads" else "Tails"

let header_creator (key : string) : Cohttp.Header.t =
  let key_trim = String.trim key in
  if String.length key_trim > 0 then
    Cohttp.Header.of_list
      [
        ("Content-Type", "application/json");
        ("Authorization", "Bearer " ^ key_trim);
      ]
  else failwith "Invalid api key"

let param_creator (msg : string) =
  if String.length msg > 0 then
    `Assoc
      [
        ("model", `String "gpt-3.5-turbo");
        ( "messages",
          `List
            [ `Assoc [ ("role", `String "user"); ("content", `String msg) ] ] );
      ]
  else failwith "Error: Empty Message"

let chatbot_postrequest (header : Header.t) (param : Yojson.Safe.t)
    (endpoint : Uri.t) : (Cohttp.Response.t * Cohttp_lwt.Body.t) t =
  Cohttp_lwt_unix.Client.post ~headers:header
    ~body:(`String (Yojson.Safe.to_string param))
    endpoint

let json_parser (parsed_body : string) : string list =
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

let chatbot_body_handler (parsed_body : string) : Rock.Response.t =
  let json = json_parser parsed_body in
  match json with
  | [] -> Printf.sprintf "Empty" |> Opium.Response.of_plain_text
  | h :: _ -> Printf.sprintf "%s\n" h |> Opium.Response.of_plain_text

let chatbot_error_handler (resp : Cohttp.Response.t) : Rock.Response.t t =
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

let create_weather_url (api_key : string) (location : string) : Uri.t =
  if String.length api_key > 0 && String.length location > 0 then
    Uri.of_string
      (Printf.sprintf
         "http://api.weatherstack.com/current?access_key=%s&query=%s" api_key
         location)
  else failwith "Invalid Input: Empty api_key or location"

let get_response_body (location : string) (weather : string) : string =
  if String.length location > 0 && String.length weather > 0 then
    Printf.sprintf "The weather in %s is %s." location weather
  else failwith "Invalid Input: Empty location or weather"

let extract_weather_description (json : Yojson.Safe.t) : string =
  Yojson.Safe.Util.(
    json |> member "current"
    |> member "weather_descriptions"
    |> to_list |> List.hd |> to_string)

let api_key_provider () : string =
  "trnsl.1.1.20230317T192942Z.38aa007e66112d27.70023d1d131998c0c80fd04ef3c38c5024a7068c"

let translation_url_creator (api_key : string) (input : string)
    (lang_from_match : string) (lang_to_match : string) : Uri.t =
  Uri.of_string
    (Printf.sprintf
       "https://translate.yandex.net/api/v1.5/tr.json/translate?key=%s&text=%s&lang=%s-%s"
       api_key input lang_from_match lang_to_match)

let translation_get_request (url : Uri.t) :
    (Cohttp.Response.t * Cohttp_lwt.Body.t) t =
  Cohttp_lwt_unix.Client.get url

let extract_translation_from_body (body : Cohttp_lwt.Body.t) : string t =
  body |> Cohttp_lwt.Body.to_string >|= fun body_str ->
  let json = Yojson.Safe.from_string body_str in
  Yojson.Safe.Util.(json |> member "text" |> to_list |> List.hd |> to_string)

let translation_response_builder (translation : string) : Rock.Response.t =
  let response_body = Printf.sprintf "Translation: %s" translation in
  Opium.Response.of_plain_text response_body

let lang_matcher (lang : string) : string =
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

let text_board (board : string list list) : string =
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

let other_player (player : string) : string = if player = "x" then "o" else "x"

let check_winner (board_str : string) (player : string) : bool =
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

let empty_positions (board : string list list) : (int * int) list =
  let positions = ref [] in
  for i = 0 to 2 do
    for j = 0 to 2 do
      let cell = List.nth (List.nth board i) j in
      if cell <> "x" && cell <> "o" then positions := (i, j) :: !positions
    done
  done;
  !positions

let is_valid_position (board : string list list) (pos : int * int) : bool =
  let row = List.nth board (fst pos) in
  let cell = List.nth row (snd pos) in
  cell <> "x" && cell <> "o"

let string_to_board (board_str : string) : string list list =
  let board_json = Yojson.Basic.from_string board_str in
  board_json |> member "board" |> to_list
  |> List.map (fun row -> to_list row |> List.map to_string)

let board_to_string (board : string list list) : string =
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

let rec minimax (board_str : string) (player : string) : int * (int * int) =
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

let ai_move (board : string list list) (player : string) : int * int =
  let _, best_move = minimax (board_to_string board) player in
  best_move

let mutable_game_board =
  ref [ [ "1"; "2"; "3" ]; [ "4"; "5"; "6" ]; [ "7"; "8"; "9" ] ]

let reference_board () : string =
  let reference = [ [ "1"; "2"; "3" ]; [ "4"; "5"; "6" ]; [ "7"; "8"; "9" ] ] in
  "Reference board:\n" ^ text_board reference

let digit_to_position (digit : int) : int * int =
  let row = (digit - 1) / 3 in
  let col = (digit - 1) mod 3 in
  (row, col)
