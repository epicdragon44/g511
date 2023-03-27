(* ========= HELPER FUNCTIONS: Move functionality from bin/main.ml  ========= *)

let rand_btwn (low : int) (high : int) : int = low + Random.int (high - low + 1)
let coin_flip () = if Random.int 2 = 0 then "Heads" else "Tails"
