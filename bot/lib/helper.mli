(** This is the interface for the Helper module, which supplies helper functions for the Bot library *)

val call : string -> string
(** Calls [url] and returns the body as a string

    Precondition: the URL being called is valid and takes GET requests and returns text/plain data.
    Postcondition: the body of the response is returned as a string.
*)
