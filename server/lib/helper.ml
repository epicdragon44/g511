(* ========================================================================== *)

(* TODO: Insert helper functions to make API requests here *)

(** Example: make a CURL request to the given URL and return the response. *)
let curl_request p_url =
  match Curly.(run (Request.make ~url:p_url ~meth:`GET ())) with
  | Ok x ->
      Format.printf "status: %d\n" x.Curly.Response.code;
      Format.printf "headers: %a\n" Curly.Header.pp x.Curly.Response.headers;
      Format.printf "body: %s\n" x.Curly.Response.body
  | Error e -> Format.printf "Failed: %a" Curly.Error.pp e

(* ========================================================================== *)

(* In the future, we could add a database.
   That could let us do more complex features that require a knowledge of
   previous messages and context, user information, etc.
   Eg. news aggregator based on their favorite news sources; todo lists; fitness tracker; etc.
   Information would essentially be keyed by the chat ID.
   If/when we decide to do that, we can add database helper functions here.
*)
