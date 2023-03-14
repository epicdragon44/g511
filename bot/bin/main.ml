open Telegram.Api

let get_env target =
  let env_variables = Dotenv.parse () in
  match List.find_opt (fun (name, _) -> name = target) env_variables with
  | Some (_, value) -> value
  | None -> raise (Failure "Could not find environment variable!")

module MyBot = Mk (struct
  open Chat
  open User
  open Command
  open Message
  open UserProfilePhotos
  include Telegram.BotDefaults

  let token = get_env "BOT_TOKEN"
  let command_postfix = Some "bocaml_beta-1"
  (* Can be replaced with whatever the bot's name is, makes the bot only respond to /say_hi *)

  let commands =
    let open Telegram.Actions in
    let health_check { chat = { id; _ }; _ } =
      send_message ~chat_id:id "Hi there!"
    and my_pics = function
      | { chat; from = Some { id; _ }; _ } -> (
          get_user_profile_photos id /> function
          | Result.Success photos ->
              send_message ~chat_id:chat.id "Your photos: %d" photos.total_count
          | Result.Failure _ ->
              send_message ~chat_id:chat.id
                "Couldn't get your profile pictures!")
      | { chat = { id; _ }; _ } ->
          send_message ~chat_id:id "Couldn't get your profile pictures!"
    in
    [
      {
        name = "health_check";
        description = "Responds if the bot is up.";
        enabled = true;
        run = health_check;
      };
      {
        name = "my_pics";
        description = "Count profile pictures";
        enabled = true;
        run = my_pics;
      };
    ]
end)

let () = MyBot.run ()
