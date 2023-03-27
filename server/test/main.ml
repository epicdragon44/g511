open Server.Dan

let%test "rand_btwn" =
  let low = 1 in
  let high = 10 in
  let result = rand_btwn low high in
  result >= low && result <= high

let%test "coin_flip" =
  let result = coin_flip () in
  result = "Heads" || result = "Tails"
