open Telegram.Api
open Lwt
open Cohttp
open Cohttp_lwt_unix
open Bot.Lib

let get_env target =
  let env_variables = Dotenv.parse () in
  match List.find_opt (fun (name, _) -> name = target) env_variables with
  | Some (_, value) -> value
  | None -> raise (Failure "Could not find environment variable!")

let tokenize str =
  let rec aux acc = function
    | [] -> List.rev acc
    | hd :: tl -> aux (hd :: acc) tl
  in
  aux [] (String.split_on_char ' ' str)

(** String parsing helper*)
let rec get_element_at_index lst index =
  match lst with
  | [] -> raise (Invalid_argument "List is empty")
  | x :: xs -> if index = 0 then x else get_element_at_index xs (index - 1)

module MyBot = Mk (struct
  open Chat

  (* open User *)

  open Command
  open Message

  (* open UserProfilePhotos *)

  include Telegram.BotDefaults

  let token = get_env "BOT_TOKEN"
  let command_postfix = Some "bocaml"

  let commands =
    let open Telegram.Actions in
    let health_check { chat = { id; _ }; _ } =
      send_message ~chat_id:id "Hi there!"
    and echome input =
      match input with
      | { chat; text = Some text; _ } ->
          text |> remove_first_word_of |> echo
          |> send_message ~chat_id:chat.id "%s"
      | { chat; _ } -> send_message ~chat_id:chat.id "Invalid usage of /echo"
    and coinflipme input =
      match input with
      | { chat; text = Some text; _ } ->
          text |> remove_first_word_of |> flip_coin
          |> send_message ~chat_id:chat.id "%s"
      | { chat; _ } -> send_message ~chat_id:chat.id "Invalid usage"
    and rngme input =
      let first_member (ls : string list) =
        match ls with [] -> "" | hd :: _ -> hd
      in
      let second_member (ls : string list) =
        match ls with [] -> "" | _ :: hd :: _ -> hd | _ -> ""
      in
      match input with
      | { chat; text = Some text; _ } ->
          let input_arr = text |> remove_first_word_of |> tokenize in
          let first = first_member input_arr |> int_of_string in
          let second = second_member input_arr |> int_of_string in
          rng_btwn first second |> send_message ~chat_id:chat.id "%s"
      | { chat; _ } -> send_message ~chat_id:chat.id "Invalid usage"
    and convertunits input =
      match input with
      | { chat; text = Some text; _ } ->
          let input_arr = text |> String.split_on_char ' ' in
          let amt = get_element_at_index input_arr 1 in
          let from = get_element_at_index input_arr 2 in
          let too = get_element_at_index input_arr 3 in
          convert_units amt from too |> send_message ~chat_id:chat.id "%s"
      | { chat; _ } -> send_message ~chat_id:chat.id "Invalid usage"
    and convertcurr input =
      match input with
      | { chat; text = Some text; _ } ->
          let input_arr = text |> String.split_on_char ' ' in
          let amt = get_element_at_index input_arr 1 in
          let from = get_element_at_index input_arr 2 in
          let too = get_element_at_index input_arr 3 in
          convert_curr amt from too |> send_message ~chat_id:chat.id "%s"
      | { chat; _ } -> send_message ~chat_id:chat.id "Invalid usage"
    and timenow input =
      match input with
      | { chat; text = Some text; _ } ->
          let input_arr = text |> String.split_on_char ' ' in
          let area = get_element_at_index input_arr 1 in
          let location = get_element_at_index input_arr 2 in
          get_curr_time area location |> send_message ~chat_id:chat.id "%s"
      | { chat; _ } -> send_message ~chat_id:chat.id "Invalid usage"
    and general_chat input =
      match input with
      | { chat; text = Some text; _ } ->
          text |> remove_first_word_of |> general_chat_handler_call
          |> send_message ~chat_id:chat.id "%s"
      | { chat; _ } -> send_message ~chat_id:chat.id "Invalid usage"
    and weatherme input =
      match input with
      | { chat; text = Some text; _ } ->
          text |> remove_first_word_of |> get_weather
          |> send_message ~chat_id:chat.id "%s"
      | { chat; _ } -> send_message ~chat_id:chat.id "Invalid usage"
    and translateme input =
      let parse_translation_text text =
        match String.split_on_char ' ' text with
        | _command :: lang_from :: lang_to :: text_to_translate_parts ->
            let text_to_translate = String.concat " " text_to_translate_parts in
            (lang_from, lang_to, text_to_translate)
        | _ -> failwith "Invalid usage: /translate <from_lang> <to_lang> <text>"
      in
      match input with
      | { chat; text = Some text; _ } ->
          let lang_from, lang_to, text_to_translate =
            parse_translation_text text
          in
          text_to_translate
          |> get_translate lang_from lang_to
          |> send_message ~chat_id:chat.id "%s"
      | { chat; _ } -> send_message ~chat_id:chat.id "Invalid usage"
    and ai_handler_me input =
      match input with
      | { chat; text = Some text; _ } ->
          let params = String.split_on_char ' ' text in
          let _ = List.hd params in
          let action, player, pos =
            match List.tl params with
            | [ action; player; pos ] -> (action, player, int_of_string pos)
            | _ -> failwith "Invalid parameters"
          in
          get_ai_text action player pos |> send_message ~chat_id:chat.id "%s"
      | { chat; _ } -> send_message ~chat_id:chat.id "Invalid usage"
    in

    [
      {
        name = "health_check";
        description = "Responds if the bot is up.";
        enabled = true;
        run = health_check;
      };
      { name = "echo"; description = "Echo text"; enabled = true; run = echome };
      {
        name = "coinflip";
        description = "Flip a coin";
        enabled = true;
        run = coinflipme;
      };
      {
        name = "rng";
        description = "Generate a random number between two numbers";
        enabled = true;
        run = rngme;
      };
      {
        name = "general_chat";
        description = "Ask the bot any question and it will try to answer it";
        enabled = true;
        run = general_chat;
      };
      {
        name = "convert_units";
        description =
          "Converts a given amount from one unit of measurement to another";
        enabled = true;
        run = convertunits;
      };
      {
        name = "convert_currency";
        description =
          "Converts a given amount from one unit of measurement to another";
        enabled = true;
        run = convertcurr;
      };
      {
        name = "time_now";
        description = "Returns the current time in a given timezone";
        enabled = true;
        run = timenow;
      };
      {
        name = "weather";
        description = "Get the current weather for a specified location";
        enabled = true;
        run = weatherme;
      };
      {
        name = "translate";
        description =
          "Get the translation of a body of text from one language to another";
        enabled = true;
        run = translateme;
      };
      {
        name = "play";
        description =
          "Play a game of Tic Tac Toe against an AI. Use '/play_tic_tac_toe \
           start x' to start a new game as X, or '/play_tic_tac_toe move x 5' \
           to place your X at position 5.";
        enabled = true;
        run = ai_handler_me;
      };
    ]
end)

let () = MyBot.run ()
