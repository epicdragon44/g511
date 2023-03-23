include Dan
include Ant
include Ken
include Ryan

(** Make a CURL request to the given URL and return the response. *)
let curl_request p_url =
  match Curly.(run (Request.make ~url:p_url ~meth:`GET ())) with
  | Ok x ->
      Format.printf "status: %d\n" x.Curly.Response.code;
      Format.printf "headers: %a\n" Curly.Header.pp x.Curly.Response.headers;
      Format.printf "body: %s\n" x.Curly.Response.body
  | Error e -> Format.printf "Failed: %a" Curly.Error.pp e
