open Bot.Lib
open OUnit2

let echo_test_helper (input : string) (expected_output : string) =
  "echo" >:: fun _ -> assert_equal expected_output (echo input)

let flip_coin_test_helper () =
  "coin flip" >:: fun _ ->
  assert_equal true
    (flip_coin "" = "Heads" || flip_coin "" = "Tails")
    ~printer:string_of_bool

let rng_btwn_test_helper (min : int) (max : int) =
  "rng_btwn" >:: fun _ ->
  assert_equal true
    (rng_btwn min max |> int_of_string >= min
    && rng_btwn min max |> int_of_string <= max)
    ~printer:string_of_bool

let echo_tests = [ echo_test_helper "echo" "echo"; echo_test_helper "" "" ]
let coin_tests = [ flip_coin_test_helper () ]
let rng_btwn_tests = [ rng_btwn_test_helper 0 10; rng_btwn_test_helper 1 1 ]

let suite =
  "test suite for all bot functions"
  >::: List.flatten [ echo_tests; coin_tests; rng_btwn_tests ]

let _ = run_test_tt_main suite
