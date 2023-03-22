open Opium
open Server.Lib
open Lwt

(*Load all env variables*)
let _ = Dotenv.export () |> ignore
let openai_key = Sys.getenv "OPENAI_TOKEN"

let get_env target =
  let env_variables = Dotenv.parse () in
  match List.find_opt (fun (name, _) -> name = target) env_variables with
  | Some (_, value) -> value
  | None -> raise (Failure "Could not find environment variable!")

let print_param_handler req =
  Printf.sprintf "Hello, %s\n" (Router.param req "name")
  |> Response.of_plain_text |> Lwt.return

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
      | [] -> Printf.sprintf "Empty" |> Response.of_plain_text
      | h :: _ -> Printf.sprintf "%s\n" h |> Response.of_plain_text)
  | _ ->
      Printf.sprintf "Error: %s\n"
        (Cohttp_lwt.Response.status resp |> Cohttp.Code.string_of_status)
      |> Response.of_plain_text |> Lwt.return

(** Remind the user of something.
      [Router.param req "msg"] is the message to send back to the user.
      [Router.param req "id"] is the ID of the user sending the message (to remember chat history).
      [Router.param req "time"] is the time to wait before sending the message, in seconds.
  *)
(* let remind_me_handler req =
   "TODO: Implement a reminder system. This code should evaluate to a string."
   |> Response.of_plain_text |> Lwt.return *)

(** Get the weather for a given location.
      [Router.param req "location"] is the location to get the weather for (just a string)
  *)
(* let get_weather_handler req =
   "TODO: @Ryan Use some weather API to get the weather for a given location. \
    This code should evaluate to a string." |> Response.of_plain_text
   |> Lwt.return *)

(** Translate a given string.
      [Router.param req "string"] is the string to translate.
      [Router.param req "from"] is the language to translate from.
      [Router.param req "to"] is the language to translate to.
  *)
(* let translate_handler req =
   "TODO: @Ryan Use some Translate API to translate a given string. This code \
    should evaluate to a string." |> Response.of_plain_text |> Lwt.return *)

(** Calculate the math expression in a given string.
      [Router.param req "expr"] is the string to calculate.
  *)
(* let calculate_handler req =
   "TODO: @Ken or @Ryan Implement a calculator that calculates the value of a \
    given string expression. This code should evaluate to a string."
   |> Response.of_plain_text |> Lwt.return *)

(** Convert between units of measurement.
      [Router.param req "amt"] is the amount to convert.
      [Router.param req "from"] is the unit to convert from.
      [Router.param req "to"] is the unit to convert to.
  *)
(* let convert_units_handler req =
   "TODO: @Ant Implement a unit converter that converts between units of \
    measurement. This code should evaluate to a string."
   |> Response.of_plain_text |> Lwt.return *)

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

(** Get a random number between a low and high bound, inclusive.
      [Router.param req "low"] is the low bound.
      [Router.param req "high"] is the high bound.
  *)
(* let rng_handler req =
   let low = int_of_string (Router.param req "low") in
   let high = int_of_string (Router.param req "high") in
   let num = rand_btwn low high in
   string_of_int num |> Response.of_plain_text |> Lwt.return *)

(** Flip a coin.
      Return either "Heads" or "Tails"
  *)
let coin_flip_handler _ = coin_flip () |> Response.of_plain_text |> Lwt.return

let _ =
  App.empty
  |> App.get "/healthcheck/hello/:name" print_param_handler
  |> App.get "/chat/general/:msg/:id" general_chat_handler
     (* |> App.get "/remind/:msg/:id/:time" remind_me_handler
        |> App.get "/weather/:location" get_weather_handler
        |> App.get "/translate/:string/:from/:to" translate_handler
        |> App.get "/calculate/:expr" calculate_handler
        |> App.get "/convert/units/:amt/:from/:to" convert_units_handler
        |> App.get "/convert/currency/:amt/:from/:to" convert_currency_handler
        |> App.get "/time/:timezone" time_handler
        |> App.get "/rng/:low/:high" rng_handler *)
  |> App.get "/coinflip" coin_flip_handler
  |> App.run_command
