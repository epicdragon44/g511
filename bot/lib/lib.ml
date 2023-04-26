include Dan
include Ken
include Ryan
include Ant

(** Removes the first word of a string.

      Precondition: The string is not empty.
      Postcondition: The string is only one word shorter.
  
      @param s The string to remove the first word of.
  
      @return The string with the first word removed.

      @raise Invalid_argument if the string is empty.

      @example
      {[
        remove_first_word_of "hello world" = "world"
      ]}
*)
let remove_first_word_of (s : string) : string =
  if s = "" then raise (Invalid_argument "remove_first_word_of: empty string")
  else
    let len = String.length s in
    let rec loop i =
      if i = len then ""
      else if s.[i] = ' ' then String.sub s (i + 1) (len - i - 1)
      else loop (i + 1)
    in
    loop 0

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
