open Lwt
open Cohttp
open Cohttp_lwt_unix

(** Calls [url] and returns the body as a string

    Precondition: the URL being called is valid and takes GET requests and returns text/plain data.
    Postcondition: the body of the response is returned as a string.
*)
let call url =
  let fetch_url_body target =
    Client.get (Uri.of_string target) >>= fun (resp, body) ->
    if Cohttp.Response.status resp = `OK then
      Cohttp_lwt.Body.to_string body >>= fun body_str ->
      Lwt.return (Ok body_str)
    else Lwt.return (Error (Cohttp.Response.status resp, "Failed to fetch URL"))
  in
  let result = Lwt_main.run (fetch_url_body url) in
  match result with
  | Ok body -> body
  | Error (status, msg) ->
      let _ =
        Printf.printf "Error: %s, %s\n"
          (Cohttp.Code.string_of_status status)
          msg
      in
      "Internal Error"
