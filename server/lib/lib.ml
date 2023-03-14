include Helper

let rand_btwn (low : int) (high : int) : int = low + Random.int (high - low + 1)
let coin_flip () = if Random.int 2 = 0 then "Heads" else "Tails"

(* ========= TESTS: Using Jane Street's PPX Inline Syntax Extension ========= *)

let%test "rand_btwn" =
  let low = 1 in
  let high = 10 in
  let result = rand_btwn low high in
  result >= low && result <= high

let%test "coin_flip" =
  let result = coin_flip () in
  result = "Heads" || result = "Tails"
