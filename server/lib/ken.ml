open Opium
open Lwt
open Cohttp_lwt_unix
open Yojson.Safe.Util

(* TODO: Fill out this file, using dan.ml as an example template.
    - Extract out functionality from bin/main.ml into this file. For each function:
        - Implement as many helper functions where possible.
        - Document every function you write carefully with a full description, including pre and post conditions, as well as what the inputs are and what the output will be.
        - CHECK for pre conditions in the body of the function, and raise an exception if they are not met!
        - Write readable, verbose code where possible.
    - Add unit tests to server/tests/main.ml for each function you write.
        - You can import your module using `open Server.<YourModule>` at the top. If there's an error, run `make build` in root as usual.
        - From there, just use OUnit as usual. You can mimic the code I already have in there.
*)

(* ========= HELPER FUNCTIONS: Move functionality from bin/main.ml  ========= *)

(** [header_creator key] is a function that returns a Cohttp.Header.t type that is sent in an API request
    @param key The OpenAI key used to access the chatbot
    @return The Cohttp.Header.t type that will be sent as a header in the POST request
    @precond [key] must be a non-empty string
    @postcond The result is of type Cohttp.Header.t *)
let header_creator key =
  if String.length key > 0 then
    Cohttp.Header.of_list
      [
        ("Content-Type", "application/json"); ("Authorization", "Bearer " ^ key);
      ]
  else failwith "Invalid api key"

(** [param_creator req] is a function that returns a Assoc object, which is the parameters for the API request
    @param [req] The message that the user wants to send to the chatbot
    @return The Assoc type that will be sent as a parameter in the POST request
    @precond [req] must be a non-empty Request.t object
    @postcond The result is of type Assoc *)
let param_creator req =
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

(** [chatbot_postrequest header param endpoint] is a function that makes a POST request
    @param [header] [param] [endpoint] The message that the user wants to send to the chatbot
    @return Returns a pair with the Response and Body of the request
    @precond [header] [param] and [endpoint] must be non-empty
    @postcond The result is a pair of the Response and Body of the request that was made *)
let chatbot_postrequest header param endpoint =
  Cohttp_lwt_unix.Client.post ~headers:header
    ~body:(`String (Yojson.Safe.to_string param))
    endpoint

(** [json_parser parsed_body] is a function that parses the body of the made request into a Yojson
    @param [parsed_body] Is the string version of the body
    @return Returns the json version of the string
    @precond [parsed_body] is a non-empty string
    @postcond Creates a string list version of the string body *)
let json_parser parsed_body =
  if String.length parsed_body > 0 then
    parsed_body |> Yojson.Basic.from_string
    |> Yojson.Basic.Util.member "choices"
    |> Yojson.Basic.Util.to_list
    |> List.map (fun message ->
           message
           |> Yojson.Basic.Util.member "message"
           |> Yojson.Basic.Util.member "content"
           |> Yojson.Basic.Util.to_string)
  else failwith "Invalid Input: Empty body"

(** [chatbot_body_handler parsed_body] is a function that parses the body and returns it in a readable format
    @param [parsed_body] Is the string version of the body
    @return Outputs a readable version of the body
    @precond [parsed_body] is a string
    @postcond Outputs a readable version of the body *)
let chatbot_body_handler parsed_body =
  let json = json_parser parsed_body in
  match json with
  | [] -> Printf.sprintf "Empty" |> Opium.Response.of_plain_text
  | h :: _ -> Printf.sprintf "%s\n" h |> Opium.Response.of_plain_text

(** [chatbot_error_handler resp] is a function that handles errors from the chatbot
    @param [resp] Is the response from the chatbot's POST request
    @return Outputs an error message of Response.t
    @precond [resp] is a Cohttp.Response.t type
    @postcond Outputs an error message *)
let chatbot_error_handler resp =
  Printf.sprintf "Error: %s\n"
    (Cohttp_lwt.Response.status resp |> Cohttp.Code.string_of_status)
  |> Opium.Response.of_plain_text |> Lwt.return

(* let general_chat_handler openai_key req =
   (* One test that can be done is to test a helper function that parses json files? *)
   let endpoint = Uri.of_string "https://api.openai.com/v1/chat/completions" in
   let header = header_creator openai_key in
   let param = param_creator req in
   chatbot_postrequest header param endpoint >>= fun (resp, body) ->
   (* This is to handle any error response code *)
   match Cohttp_lwt.Response.status resp with
   | `OK -> body |> Cohttp_lwt.Body.to_string >|= chatbot_body_handler
   | _ -> chatbot_error_handler resp *)

(* ========= TESTS: Using Jane Street's PPX Inline Syntax Extension ========= *)
