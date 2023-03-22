open Telegram.Api

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
  (* Can be replaced with whatever the bot's name is, makes the bot only respond to /say_hi *)

  let commands =
    let open Telegram.Actions in
    let health_check { chat = { id; _ }; _ } =
      send_message ~chat_id:id "Hi there!"
    and echo input =
      match input with
      | { chat; text = Some text; _ } -> send_message ~chat_id:chat.id "%s" text
      | { chat; _ } -> send_message ~chat_id:chat.id "Invalid usage of /echo"
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
