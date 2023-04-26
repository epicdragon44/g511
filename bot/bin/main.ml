open Telegram.Api
open Bot.Lib

let get_env target =
  let env_variables = Dotenv.parse () in
  match List.find_opt (fun (name, _) -> name = target) env_variables with
  | Some (_, value) -> value
  | None -> raise (Failure "Could not find environment variable!")

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
    and echo input =
      match input with
      | { chat; text = Some text; _ } ->
          text |> remove_first_word_of |> echo
          |> send_message ~chat_id:chat.id "%s"
      | { chat; _ } -> send_message ~chat_id:chat.id "Invalid usage of /echo"

    (** Secondary TODO: For each and every server function you wrote:
    
      - Copy paste the following bit of code, fill in the <template bits>, and then paste it immediately above.

          and <YOUR_FUNCTION_NAME> input =
            match input with
            | { chat; text = Some text; _ } ->
                text |> remove_first_word_of |> <YOUR_FUNCTION_IN_LIB/YOURNAME.ml> <-- do something with the text you're being passed here.
                |> send_message ~chat_id:chat.id "%s"
            | { chat; _ } -> send_message ~chat_id:chat.id "Invalid usage"

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
      { name = "echo"; description = "Echo text"; enabled = true; run = echo };
    ]
end)

let () = MyBot.run ()
