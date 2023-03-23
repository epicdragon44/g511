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

    (** TODO: For each and every server function you wrote:
    
      - Insert an "and" block here that looks like the `echo` example above, which takes an input
          and pattern matches to see if the input contains text. If it does, you'll want to:
            1. Remove the first word of the text (the command itself) with the `remove_first_word_of` function I provided you.
            2. Send the remaining text to a helper in lib/<your name>.ml that you built according to the TODOs in that file.
            3. Send the output of that helper function as a message back to the chat with `send_message ~chat_id:chat.id "%s" <your stuff>`. 
          If it doesn't, you can basically do whatever.

      - Then, insert an object into the array below with an arbitrary name and description, a boolean which must be true,
        and a `run` parameter that is the function you just wrote above.
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
