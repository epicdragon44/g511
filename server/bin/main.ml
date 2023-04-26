open Opium
open Server.Lib
open Lwt

(* let print_param_handler req =
   Printf.sprintf "Hello, %s\n" (Router.param req "name")
   |> Response.of_plain_text |> Lwt.return *)

(** Chat with a general AI using the ChatGPT API.
      [Router.param req "msg"] is the message to send to the AI.
      [Router.param req "id"] is the ID of the user sending the message (to remember chat history).
  *)
(* let general_chat_handler req =
   "TODO: @Ken Implement general chat by interfacing with the OpenAI API. This \
    code should evaluate to a string." |> Response.of_plain_text |> Lwt.return *)

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
  let combined_response = Response.of_plain_text combined_body in
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
  Response.of_plain_text response_body |> Lwt.return

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
  Response.of_plain_text response_body |> Lwt.return

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
  Response.of_plain_text answer_formatted |> Lwt.return

(** Convert between units of measurement.
      [Router.param req "amt"] is the amount to convert.
      [Router.param req "from"] is the unit to convert from.
      [Router.param req "to"] is the unit to convert to.
  *)

let from_kg amt final =
  match final with
  | "g" -> amt *. 1000.0
  | "mg" -> amt *. 1000000.0
  | "lb" -> amt *. 2.20462
  | "oz" -> amt *. 35.274
  | "st" -> amt *. 0.157473
  | "ton" -> amt *. 0.00110231
  | "n" -> amt *. 9.81
  | "ct" -> amt *. 5000.0
  | "tael" -> amt *. 26.4555
  | "momme" -> amt *. 266.67
  | "baht" -> amt *. 66.67
  | "dram" -> amt *. 564.382
  | _ -> failwith "invalid"

let from_g amt final =
  match final with
  | "kg" -> amt *. 0.001
  | "mg" -> amt *. 1000.0
  | "lb" -> amt *. 0.00220462
  | "oz" -> amt *. 0.035274
  | "st" -> amt *. 0.000157473
  | "ton" -> amt *. 1.10231e-6
  | "n" -> amt *. 0.009806652
  | "ct" -> amt *. 5.0
  | "tael" -> amt *. 0.0264555
  | "momme" -> amt *. 0.264555
  | "baht" -> amt *. 0.0667
  | "dram" -> amt *. 0.564382
  | _ -> failwith "invalid"

let from_mg amt final =
  match final with
  | "kg" -> amt *. 1e-6
  | "g" -> amt *. 0.001
  | "lb" -> amt *. 2.20462e-6
  | "oz" -> amt *. 3.5274e-5
  | "st" -> amt *. 1.57473e-7
  | "ton" -> amt *. 1.10231e-9
  | "n" -> amt *. 0.0000098
  | "ct" -> amt *. 0.005
  | "tael" -> amt *. 2.64555e-5
  | "momme" -> amt *. 0.000264555
  | "baht" -> amt *. 15000.0
  | "dram" -> amt *. 0.000564382
  | _ -> failwith "invalid"

let from_lb amt final =
  match final with
  | "kg" -> amt *. 0.453592
  | "g" -> amt *. 453.592
  | "mg" -> amt *. 453592.0
  | "oz" -> amt *. 16.0
  | "st" -> amt *. 0.0714286
  | "ton" -> amt *. 0.0005
  | "n" -> amt *. 4.4482216
  | "ct" -> amt *. 2267.96
  | "tael" -> amt *. 12.0
  | "momme" -> amt *. 120.0
  | "baht" -> amt *. 30.239491333333
  | "dram" -> amt *. 0.00390626
  | _ -> failwith "invalid"

let from_oz amt final =
  match final with
  | "kg" -> amt *. 0.0283495
  | "g" -> amt *. 28.3495
  | "mg" -> amt *. 28349.5
  | "lb" -> amt *. 0.0625
  | "st" -> amt *. 0.00446429
  | "ton" -> amt *. 3.125e-5
  | "n" -> amt *. 0.2780136822
  | "ct" -> amt *. 141.748
  | "tael" -> amt *. 0.75
  | "momme" -> amt *. 7.5
  | "baht" -> amt *. 1.8899682083333
  | "dram" -> amt *. 16.0
  | _ -> failwith "invalid"

let from_st amt final =
  match final with
  | "kg" -> amt *. 0.157473
  | "g" -> amt *. 6350.29
  | "mg" -> amt *. 6.35e+6
  | "lb" -> amt *. 14.0
  | "oz" -> amt *. 224.0
  | "ton" -> amt *. 0.0714286
  | "n" -> amt *. 62.28
  | "ct" -> amt *. 31751.5
  | "tael" -> amt *. 168.0
  | "momme" -> amt *. 1680.0
  | "baht" -> amt *. 423.35287866667
  | "dram" -> amt *. 3583.99
  | _ -> failwith "invalid"

let from_ton amt final =
  match final with
  | "kg" -> amt *. 907.185
  | "g" -> amt *. 907185.0
  | "mg" -> amt *. 9.072e+8
  | "lb" -> amt *. 2000.0
  | "oz" -> amt *. 3.125e-5
  | "st" -> amt *. 142.857
  | "n" -> amt *. 8896.44323
  | "ct" -> amt *. 4.536e+6
  | "tael" -> amt *. 24000.0
  | "momme" -> amt *. 240000.0
  | "baht" -> amt *. 60478.982666667
  | "dram" -> amt *. 511999.0
  | _ -> failwith "invalid"

let from_n amt final =
  match final with
  | "kg" -> amt *. 0.102
  | "g" -> amt *. 100.0
  | "mg" -> amt *. 101971.6
  | "lb" -> amt *. 3.597
  | "oz" -> amt *. 3.597
  | "st" -> amt *. 0.016
  | "ton" -> amt *. 0.00022481
  | "ct" -> amt *. 0.020394
  | "tael" -> amt *. 2.70
  | "momme" -> amt *. 11.604
  | "baht" -> amt *. 6.7981080666667
  | "dram" -> amt *. 57.551089265457
  | _ -> failwith "invalid"

let from_ct amt final =
  match final with
  | "kg" -> amt *. 0.0002
  | "g" -> amt *. 0.2
  | "mg" -> amt *. 200.0
  | "lb" -> amt *. 0.000440925
  | "oz" -> amt *. 0.00705479
  | "st" -> amt *. 3.14946e-5
  | "ton" -> amt *. 2.20462e-7
  | "n" -> amt *. 0.00196133
  | "tael" -> amt *. 0.00529109
  | "momme" -> amt *. 0.0529109
  | "baht" -> amt *. 0.0132
  | "dram" -> amt *. 0.112876
  | _ -> failwith "invalid"

let from_tael amt final =
  match final with
  | "kg" -> amt *. 0.0377994
  | "g" -> amt *. 37.7994
  | "mg" -> amt *. 37799.4
  | "lb" -> amt *. 0.0833333
  | "oz" -> amt *. 1.33333
  | "st" -> amt *. 0.00595238
  | "ton" -> amt *. 4.16667e-5
  | "n" -> amt *. 0.36784744257424
  | "ct" -> amt *. 188.997
  | "momme" -> amt *. 10.0
  | "baht" -> amt *. 2.5006666666667
  | "dram" -> amt *. 21.3333
  | _ -> failwith "invalid"

let from_momme amt final =
  match final with
  | "kg" -> amt *. 0.00377994
  | "g" -> amt *. 3.77994
  | "mg" -> amt *. 3779.94
  | "lb" -> amt *. 0.00833333
  | "oz" -> amt *. 0.133333
  | "st" -> amt *. 0.000595238
  | "ton" -> amt *. 4.16667e-6
  | "n" -> amt *. 0.036774937607396
  | "ct" -> amt *. 18.8997
  | "tael" -> amt *. 0.1
  | "baht" -> amt *. 0.25
  | "dram" -> amt *. 2.13333
  | _ -> failwith "invalid"

let from_baht amt final =
  match final with
  | "kg" -> amt *. 0.015
  | "g" -> amt *. 15.244
  | "mg" -> amt *. 15000.0
  | "lb" -> amt *. 0.033069339327732
  | "oz" -> amt *. 0.47295236
  | "st" -> amt *. 0.0023620956662665
  | "ton" -> amt *. 1.6534669663866E-5
  | "n" -> amt *. 0.14709975042958
  | "ct" -> amt *. 75.0
  | "tael" -> amt *. 0.39989336177019
  | "momme" -> amt *. 4.0
  | "dram" -> amt *. 8.4657508678993
  | _ -> failwith "invalid"

let from_dram amt final =
  match final with
  | "kg" -> amt *. 0.00177185
  | "g" -> amt *. 1.77185
  | "mg" -> amt *. 1771.8451953125
  | "lb" -> amt *. 0.00390626
  | "oz" -> amt *. 0.0625002
  | "st" -> amt *. 0.000279019
  | "ton" -> amt *. 1.95313e-6
  | "n" -> amt *. 0.017375865735355
  | "ct" -> amt *. 8.85925
  | "tael" -> amt *. 0.0468751
  | "momme" -> amt *. 0.468751
  | "baht" -> amt *. 0.11812301302083
  | _ -> failwith "invalid"

let convert amt from final =
  match from with
  | "kg" -> from_kg amt final
  | "g" -> from_g amt final
  | "mg" -> from_mg amt final
  | "lb" -> from_lb amt final
  | "oz" -> from_oz amt final
  | "st" -> from_st amt final
  | "ton" -> from_ton amt final
  | "n" -> from_n amt final
  | "ct" -> from_ct amt final
  | "tael" -> from_tael amt final
  | "momme" -> from_momme amt final
  | "baht" -> from_baht amt final
  | "dram" -> from_dram amt final
  | _ -> failwith "invalid"

let convert_units_handler req =
  let amt = Router.param req "amt" in
  let from = Router.param req "from" in
  let final = Router.param req "to" in
  let answer = convert (float_of_string amt) from final in
  let answer_formatted = Printf.sprintf "Answer: %s" (string_of_float answer) in
  Response.of_plain_text answer_formatted |> Lwt.return

(** Convert between currencies at their current exchange rate.
      [Router.param req "amt"] is the amount to convert.
      [Router.param req "from"] is the currency to convert from.
      [Router.param req "to"] is the currency to convert to.
  *)
(* let convert_currency_handler req =
   "TODO: @Ant Implement a currency converter. This code should evaluate to a \
    string." |> Response.of_plain_text |> Lwt.return *)

(** Get the current time in a given timezone.
      [Router.param req "timezone"] is the timezone to get the time for.
  *)
(* let time_handler req =
   "TODO: @Ant Implement a function that gets you the current time in a given \
    timezone. This code should evaluate to a string." |> Response.of_plain_text
   |> Lwt.return *)

(** Play tic tac toe against an AI gamemaster using Minimax decision algorithm.
      [Router.param req "action"] is the current action the user wishes to perform 
      (i.e. "start" starts the game and initializes the gameboard). 
      [Router.param req "player"] is the marker type of the player (i.e. "x" or "o").
      [Router.param req "pos"] is the position the player wants to place their marker.
  *)

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
      let cell = List.nth (List.nth board i) j in
      if cell <> "x" && cell <> "o" then positions := (i, j) :: !positions
    done
  done;
  !positions

(*Check what positions are not already occupied by a marker,
   and if the input position is a valid play*)
let is_valid_position board pos =
  let row = List.nth board (fst pos) in
  let cell = List.nth row (snd pos) in
  cell <> "x" && cell <> "o"

(*Translates the board to a textual representation*)
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

(*OCaml implementation of minimax algorithm,
   dictating the AI's moveset by finding best possible move in the worst
   possible situation*)
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

let ai_move board player =
  let _, best_move = minimax (board_to_string board) player in
  best_move

let mutable_game_board =
  ref [ [ "1"; "2"; "3" ]; [ "4"; "5"; "6" ]; [ "7"; "8"; "9" ] ]

let reference_board () =
  let reference = [ [ "1"; "2"; "3" ]; [ "4"; "5"; "6" ]; [ "7"; "8"; "9" ] ] in
  "Reference board:\n" ^ text_board reference

let digit_to_position digit =
  let row = (digit - 1) / 3 in
  let col = (digit - 1) mod 3 in
  (row, col)

(*TTT game handler, compiles all of the above together and has the AI
   interact with the user input*)
let ai_t_game_handler req =
  let action = Router.param req "action" in
  if action = "start" then (
    mutable_game_board :=
      [ [ "_"; "_"; "_" ]; [ "_"; "_"; "_" ]; [ "_"; "_"; "_" ] ];
    Response.of_plain_text "Game started!\n" |> Lwt.return)
  else
    let player = Router.param req "player" in
    let pos_str = Router.param req "pos" in
    let pos = int_of_string pos_str |> digit_to_position in
    let board = !mutable_game_board in
    if not (is_valid_position board pos) then
      Response.of_plain_text
        (reference_board () ^ "\n-----------------------------------\n"
       ^ "\nGame Board:\n" ^ text_board board
       ^ "\nInvalid move! Please choose another cell.\n")
      |> Lwt.return
    else
      let row = List.nth board (fst pos) in
      let updated_row =
        List.mapi (fun i cell -> if i = snd pos then player else cell) row
      in
      let updated_board =
        List.mapi (fun i row -> if i = fst pos then updated_row else row) board
      in
      mutable_game_board := updated_board;
      let ai_player = other_player player in
      let ai_pos = ai_move updated_board ai_player in
      let ai_row = List.nth updated_board (fst ai_pos) in
      let ai_updated_row =
        List.mapi
          (fun i cell -> if i = snd ai_pos then ai_player else cell)
          ai_row
      in
      let ai_updated_board =
        List.mapi
          (fun i row -> if i = fst ai_pos then ai_updated_row else row)
          updated_board
      in
      mutable_game_board := ai_updated_board;
      let ai_text_board = text_board ai_updated_board in
      Response.of_plain_text
        (reference_board () ^ "\n-----------------------------------\n"
       ^ "\nGame Board:\n" ^ ai_text_board ^ "\n")
      |> Lwt.return

(** Get a random number between a low and high bound, inclusive.
      [Router.param req "low"] is the low bound.
      [Router.param req "high"] is the high bound.
  *)
let rng_handler req =
  let low = int_of_string (Router.param req "low") in
  let high = int_of_string (Router.param req "high") in
  let num = rand_btwn low high in
  string_of_int num |> Response.of_plain_text |> Lwt.return

(** Flip a coin.
      Return either "Heads" or "Tails"
  *)
let coin_flip_handler _ = coin_flip () |> Response.of_plain_text |> Lwt.return

let _ =
  App.empty
  (* |> App.get "/healthcheck/hello/:name" print_param_handler *)
  (* |> App.get "/chat/general/:msg/:id" general_chat_handler *)
  |> App.get "/remind/:msg/:id/:time" remind_me_handler
  |> App.get "/weather/:location" get_weather_handler
  |> App.get "/translate/:string/:from/:to" translate_handler
  |> App.get "/calculate/:expr" calculate_handler
  |> App.get "/convert/units/:amt/:from/:to" convert_units_handler
  |> App.get "/ai_t_game_handler/:action/:player/:pos" ai_t_game_handler
  (*  |> App.get "/convert/currency/:amt/:from/:to" convert_currency_handler *)
  (* |> App.get "/time/:timezone" time_handler *)
  |> App.get "/rng/:low/:high" rng_handler
  |> App.get "/coinflip" coin_flip_handler
  |> App.run_command
