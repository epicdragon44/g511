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

module MyBot = Mk (struct
  open Chat

  (* open User *)
  open Command
  open Message

  (* open UserProfilePhotos *)
  include Telegram.BotDefaults

  let token = get_env "BOT_TOKEN"
  let command_postfix = Some "bocaml-beta-1"

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
        let first_member (ls: string list) =
            match ls with
            | [] -> ""
            | hd :: _ -> hd
        in
        let second_member (ls: string list) =
            match ls with
            | [] -> ""
            | _ :: hd :: _ -> hd
            | _ -> ""
        in
      match input with
      | { chat; text = Some text; _ } ->
          let input_arr = text |> remove_first_word_of |> tokenize in
          let first = first_member input_arr |> int_of_string in
          let second = second_member input_arr |> int_of_string in
          rng_btwn first second 
          |> send_message ~chat_id:chat.id "%s"
      | { chat; _ } -> send_message ~chat_id:chat.id "Invalid usage"

    (** Secondary TODO: For each and every server function you wrote:
    
      - Copy paste the following bit of code, fill in the <template bits>, and then paste it immediately above.

          and <YOUR_FUNCTION_NAME> input =
            match input with
            | { chat; text = Some text; _ } ->
                text |> remove_first_word_of |> <YOUR_FUNCTION_IN_LIB/YOURNAME.ml> <-- do something with the text you're being passed here.
                |> send_message ~chat_id:chat.id "%s"
            | { chat; _ } -> send_message ~chat_id:chat.id "Invalid usage"

          Check that you don't introduce naming conflicts! Might sound dumb, but fair warning lmao.

      - Copy and paste the following bit of code, fill in the <template bits>, and then paste it in the array below.

          {
            name = "<HUMAN_TYPE-ABLE_FUNCTION>"; <-- eg. if your function is called `play`, the user will send `/play` to the bot to trigger this function.
            description = "<HUMAN_READABLE_DESCRIPTION>";
            enabled=true;
            run = <YOUR_FUNCTION_NAME>;
          }
    *)

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
      }
    ]
end)

let () = MyBot.run ()
