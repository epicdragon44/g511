(* ========= HELPER FUNCTIONS: Move functionality from bin/main.ml  ========= *)

(**
  * [rand_btwn low high] is a random integer between [low] and [high], inclusive.
  * Requires: [low] <= [high]
  * Example: [rand_btwn 1 3] is either 1, 2, or 3.
  *)
let rand_btwn (low : int) (high : int) : int = low + Random.int (high - low + 1)

(**
  * [coin_flip ()] is either "Heads" or "Tails".
  *)
let coin_flip () = if Random.int 2 = 0 then "Heads" else "Tails"
