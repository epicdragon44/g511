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
    let say_hi { chat = { id; _ }; _ } = send_message ~chat_id:id "Hi there!"
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
    and check_admin { chat = { id; _ }; _ } =
      send_message ~chat_id:id "Congrats, you're an admin!"
    in
    [
      { name = "say_hi"; description = "Say hi!"; enabled = true; run = say_hi };
      {
        name = "my_pics";
        description = "Count profile pictures";
        enabled = true;
        run = my_pics;
      };
      {
        name = "admin";
        description = "Check whether you're an admin";
        enabled = true;
        run = with_auth ~command:check_admin;
      };
    ]
end)

let () = MyBot.run ()
