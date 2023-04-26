open Opium
open Server.Lib
open Lwt
open Cohttp_lwt_unix
open Yojson.Safe.Util

(*Load all env variables*)
let _ = Dotenv.export () |> ignore
let openai_key = Sys.getenv "OPENAI_TOKEN"

let print_param_handler req =
  Printf.sprintf "Hello, %s\n" (Router.param req "name")
  |> Opium.Response.of_plain_text |> Lwt.return

(** Chat with a general AI using the ChatGPT API.
      [Router.param req "msg"] is the message to send to the AI.
      [Router.param req "id"] is the ID of the user sending the message (to remember chat history).
  *)
let general_chat_handler req =
  (* One test that can be done is to test a helper function that parses json files? *)
  let endpoint = Uri.of_string "https://api.openai.com/v1/chat/completions" in
  let header =
    Cohttp.Header.of_list
      [
        ("Content-Type", "application/json");
        ("Authorization", "Bearer " ^ openai_key);
      ]
  in
  let param =
    `Assoc
      [
        ("model", `String "gpt-3.5-turbo");
        ( "messages",
          `List
            [
              `Assoc
                [
                  ("role", `String "user");
                  ("content", `String (Router.param req "msg"));
                ];
            ] );
      ]
  in
  Cohttp_lwt_unix.Client.post ~headers:header
    ~body:(`String (Yojson.Safe.to_string param))
    endpoint
  >>= fun (resp, body) ->
  (* This is to handle any error response code *)
  match Cohttp_lwt.Response.status resp with
  | `OK -> (
      body |> Cohttp_lwt.Body.to_string >|= fun parsed_body ->
      let json =
        parsed_body |> Yojson.Basic.from_string
        |> Yojson.Basic.Util.member "choices"
        |> Yojson.Basic.Util.to_list
        |> List.map (fun message ->
               message
               |> Yojson.Basic.Util.member "message"
               |> Yojson.Basic.Util.member "content"
               |> Yojson.Basic.Util.to_string)
      in
      match json with
      | [] -> Printf.sprintf "Empty" |> Opium.Response.of_plain_text
      | h :: _ -> Printf.sprintf "%s\n" h |> Opium.Response.of_plain_text)
  | _ ->
      Printf.sprintf "Error: %s\n"
        (Cohttp_lwt.Response.status resp |> Cohttp.Code.string_of_status)
      |> Opium.Response.of_plain_text |> Lwt.return

(** Remind the user of something.
      [Router.param req "msg"] is the message to send back to the user.
      [Router.param req "id"] is the ID of the user sending the message (to remember chat history).
      [Router.param req "time"] is the time to wait before sending the message, in seconds.
  *)

let remind_me_handler req =
  let msg = Router.param req "msg" in
  let id = Router.param req "id" in
  let time_str = Router.param req "time" in
  let time = int_of_string time_str in
  Lwt_unix.sleep (float_of_int time) >>= fun () ->
  let response_body = "Reminder: " ^ msg ^ " (sent by " ^ id ^ ")" in
  let response_str = "Reminder scheduled in " ^ time_str ^ " seconds." in
  let combined_body = response_body ^ " " ^ response_str in
  let combined_response = Opium.Response.of_plain_text combined_body in
  Lwt.return combined_response

(** Get the weather for a given location.
      [Router.param req "location"] is the location to get the weather for (just a string)
  *)
let get_weather_handler req =
  let location = Router.param req "location" in
  let api_key = "2978b8fab18e4db495bf9b5a423d4f0d" in
  let url =
    Uri.of_string
      (Printf.sprintf
         "http://api.weatherstack.com/current?access_key=%s&query=%s" api_key
         location)
  in
  Cohttp_lwt_unix.Client.get url >>= fun (_, body) ->
  body |> Cohttp_lwt.Body.to_string >>= fun body_str ->
  let json = Yojson.Safe.from_string body_str in
  let weather =
    Yojson.Safe.Util.(
      json |> member "current"
      |> member "weather_descriptions"
      |> to_list |> List.hd |> to_string)
  in
  let response_body =
    Printf.sprintf "The weather in %s is %s." location weather
  in
  Opium.Response.of_plain_text response_body |> Lwt.return

(** Translate a given string.
      [Router.param req "string"] is the string to translate.
      [Router.param req "from"] is the language to translate from.
      [Router.param req "to"] is the language to translate to.
  *)
let translate_handler req =
  let input = Router.param req "string" in
  let lang_from = Router.param req "from" in
  let lang_from_match =
    match lang_from with
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
  in
  let lang_to = Router.param req "to" in
  let lang_to_match =
    match lang_to with
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
  in
  let api_key =
    "trnsl.1.1.20230317T192942Z.38aa007e66112d27.70023d1d131998c0c80fd04ef3c38c5024a7068c"
  in
  let url =
    Uri.of_string
      (Printf.sprintf
         "https://translate.yandex.net/api/v1.5/tr.json/translate?key=%s&text=%s&lang=%s-%s"
         api_key input lang_from_match lang_to_match)
  in
  Cohttp_lwt_unix.Client.get url >>= fun (_, body) ->
  body |> Cohttp_lwt.Body.to_string >>= fun body_str ->
  let json = Yojson.Safe.from_string body_str in
  let translation =
    Yojson.Safe.Util.(json |> member "text" |> to_list |> List.hd |> to_string)
  in
  let response_body = Printf.sprintf "Translation: %s" translation in
  Opium.Response.of_plain_text response_body |> Lwt.return

(** Calculate the math expression in a given string.
      [Router.param req "expr"] is the string to calculate.
  *)

let remove_space item lst =
  List.fold_right (fun h acc -> if h <> item then h :: acc else acc) lst []

let sign m x y =
  match m with
  | "*" -> x * y
  | "/" -> x / y
  | "+" -> x + y
  | "-" -> x - y
  | _ -> failwith "not supported"

let rec process lst result =
  match lst with
  | [ _ ] -> result
  | s :: m :: e :: t ->
      let exp = sign m (int_of_string s) (int_of_string e) in
      process (string_of_int exp :: t) exp
  | _ -> failwith "invalid"

let calculate_handler req =
  let answer =
    process
      (remove_space "" (String.split_on_char ' ' (Router.param req "expr")))
      0
  in
  let answer_formatted = Printf.sprintf "Answer: %s" (string_of_int answer) in
  Opium.Response.of_plain_text answer_formatted |> Lwt.return

(** Convert between units of measurement.
      [Router.param req "amt"] is the amount to convert.
      [Router.param req "from"] is the unit to convert from.
      [Router.param req "to"] is the unit to convert to.
  *)

let convert_units_handler req =
  let amt = float_of_string (Router.param req "amt") in
  let from_unit = Router.param req "from" in
  let to_unit = Router.param req "to" in
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
  let converted_amt = amt *. conversion_factor in
  let response_string =
    Printf.sprintf "%g %s = %g %s" amt from_unit converted_amt to_unit
  in
  response_string |> Opium.Response.of_plain_text |> Lwt.return

(** Convert between currencies at their current exchange rate.
      [Router.param req "amt"] is the amount to convert.
      [Router.param req "from"] is the currency to convert from.
      [Router.param req "to"] is the currency to convert to.
  *)

let convert_currency_handler req =
  let amt = Router.param req "amt" in
  let from_cur = Router.param req "from" in
  let to_cur = Router.param req "to" in
  let url =
    "https://api.exchangerate.host/convert?from=" ^ from_cur ^ "&to=" ^ to_cur
    ^ "&amount=" ^ amt
  in
  let uri = Uri.of_string url in
  Client.get uri >>= fun (_, body) ->
  Cohttp_lwt.Body.to_string body >>= fun body_str ->
  let json = Yojson.Safe.from_string body_str in
  let result = json |> member "result" |> to_float in
  let output_str =
    amt ^ " " ^ from_cur ^ " is equivalent to " ^ string_of_float result ^ " "
    ^ to_cur
  in
  output_str |> Opium.Response.of_plain_text |> Lwt.return

(** Get the current time in a given timezone (format: Area/Location). *)
let time_handler req =
  let area = Router.param req "area" in
  let location = Router.param req "location" in
  let uri =
    Uri.of_string
      ("http://worldtimeapi.org/api/timezone/" ^ area ^ "/" ^ location)
  in
  Client.get uri >>= fun (_, body) ->
  Cohttp_lwt.Body.to_string body >>= fun body_str ->
  let json = Yojson.Safe.from_string body_str in
  let datetime = json |> member "datetime" |> to_string in
  let parts = String.split_on_char 'T' datetime in
  let time_part = List.nth parts 1 in
  let time = String.sub time_part 0 8 in
  let output_str =
    "The current time in " ^ area ^ "/" ^ location ^ " is " ^ time
  in
  output_str |> Opium.Response.of_plain_text |> Lwt.return

(** Play tic tac toe against an AI gamemaster using Minimax decision algorithm.
      [Router.param req "initialize"] starts the game if true.
      [Router.param req "player"] is the marker type of the player (i.e. "x" or "o").
      [Router.param req "pos"] is the position the player wants to place their marker.
  *)

type game = { current_board : string list list }

(*Helper function for representing game board in text*)
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

let other_player player = if player = "x" then "o" else "x"

(*Return true if there is a winner, else false*)
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

(*Check what positions are not already occupied by a marker*)
let empty_positions board =
  let positions = ref [] in
  for i = 0 to 2 do
    for j = 0 to 2 do
      if List.nth (List.nth board i) j = "_" then
        positions := (i, j) :: !positions
    done
  done;
  !positions

let string_to_board board_str =
  let board_json = Yojson.Basic.from_string board_str in
  board_json |> member "board" |> to_list
  |> List.map (fun row -> to_list row |> List.map to_string)

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

let rec minimax board_str player =
  let board = string_to_board board_str in
  if check_winner board_str (other_player player) then -1
  else if empty_positions board = [] then 0
  else
    let scores =
      empty_positions board
      |> List.map (fun (i, j) ->
             let row = List.nth board i in
             let updated_row =
               List.mapi (fun k cell -> if k = j then player else cell) row
             in
             let updated_board =
               List.mapi (fun k row -> if k = i then updated_row else row) board
             in
             let updated_board_str = board_to_string updated_board in
             -minimax updated_board_str (other_player player))
    in
    List.fold_left max min_int scores

let ai_move board player =
  let best_score = ref min_int in
  let best_move = ref (0, 0) in
  empty_positions board
  |> List.iter (fun (i, j) ->
         let row = List.nth board i in
         let updated_row =
           List.mapi (fun k cell -> if k = j then player else cell) row
         in
         let updated_board =
           List.mapi (fun k row -> if k = i then updated_row else row) board
         in
         let updated_board_str = board_to_string updated_board in
         let score = minimax updated_board_str (other_player player) in
         if score > !best_score then (
           best_score := score;
           best_move := (i, j)));
  !best_move

let init_game start =
  if start = true then
    {
      current_board =
        string_to_board "[['_','_','_'],['_','_','_'],['_','_','_']]";
    }
  else failwith "game not initialized"

let step req game =
  let board = game.current_board in
  let player = Router.param req "player" in
  let pos_str = Router.param req "pos" in
  let pos = Scanf.sscanf pos_str "(%d,%d)" (fun x y -> (x, y)) in
  let row = List.nth board (fst pos) in
  let updated_row =
    List.mapi (fun i cell -> if i = snd pos then player else cell) row
  in
  let updated_board =
    List.mapi (fun i row -> if i = fst pos then updated_row else row) board
  in
  let ai_player = other_player player in
  let ai_pos = ai_move updated_board ai_player in
  let ai_row = List.nth updated_board (fst ai_pos) in
  let ai_updated_row =
    List.mapi (fun i cell -> if i = snd ai_pos then ai_player else cell) ai_row
  in
  let ai_updated_board =
    List.mapi
      (fun i row -> if i = fst ai_pos then ai_updated_row else row)
      updated_board
  in
  { current_board = ai_updated_board }

let ai_t_game_handler req game =
  let board = (step req game).current_board in
  let ai_text_board = text_board board in
  Opium.Response.of_plain_text ai_text_board |> Lwt.return

(** Get a random number between a low and high bound, inclusive.
      [Router.param req "low"] is the low bound.
      [Router.param req "high"] is the high bound.
  *)
let rng_handler req =
  let low = int_of_string (Router.param req "low") in
  let high = int_of_string (Router.param req "high") in
  let num = rand_btwn low high in
  string_of_int num |> Opium.Response.of_plain_text |> Lwt.return

(** Flip a coin.
      Return either "Heads" or "Tails"
  *)
let coin_flip_handler _ =
  coin_flip () |> Opium.Response.of_plain_text |> Lwt.return

let _ =
  App.empty
  |> App.get "/healthcheck/hello/:name" print_param_handler
  |> App.get "/chat/general/:msg/:id" general_chat_handler
  |> App.get "/convert/units/:amt/:from/:to" convert_units_handler
  |> App.get "/convert/currency/:amt/:from/:to" convert_currency_handler
  |> App.get "/time/:area/:location" time_handler
  |> App.get "/remind/:msg/:id/:time" remind_me_handler
  |> App.get "/weather/:location" get_weather_handler
  |> App.get "/translate/:string/:from/:to" translate_handler
  |> App.get "/calculate/:expr" calculate_handler
  (* |> App.get "/ai_t_game_handler/:initialize/:player/:pos" ai_t_game_handler *)
  |> App.get "/rng/:low/:high" rng_handler
  |> App.get "/coinflip" coin_flip_handler
  |> App.run_command
