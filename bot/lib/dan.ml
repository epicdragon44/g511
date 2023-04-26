(* TODO: Implement helper functions here that:
   - checks pre-conditions and throws error on violation
   - take in user text,
   - processes it,
   - calls the server at http://localhost:9000/ with your request,
   - and then takes the result, re-processes it into a user-readable string, and then returns that string.

   Split this into multiple functions as you see fit.

   Document each one with a description of
   - what it does
   - what it takes as input
   - what it returns
   - pre-conditions and post-conditions
   - an example of how to use it
   Example in lib.ml

   Then, TEST each one. Write unit tests in bot/test/main.ml using OUnit.

   This should be similar to how you did server/lib/<ur name>.ml
*)

(** Echoes a string back to you.

      Precondition: None.
      Postcondition: The string is the same as the string passed in.

      @param msg The string to echo.

      @return The string that was passed in.

      @example
      {[
        echo "hello" = "hello"
      ]}
*)
let echo (msg : string) = msg