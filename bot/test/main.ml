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

let convert_units_test_helper (amt : string) (from : string) (too : string)
    (expected_output : string) =
  "convert units" >:: fun _ ->
  assert_equal expected_output (convert_units amt from too)

let convert_curr_test_helper (amt : string) (from : string) (too : string)
    (expected_output : string) =
  "convert currency" >:: fun _ ->
  assert_equal expected_output (convert_curr amt from too)

(* (let timezone_test_helper (area : string) (location : string)
     (expected_output : string) =
   "current time" >:: fun _ ->
   assert_equal expected_output (get_curr_time area location)) *)

let convert_units_tests =
  [
    convert_units_test_helper "1.5" "m" "cm" "1.5 m = 150 cm";
    convert_units_test_helper "6" "ft" "m" "6 ft = 1.8288 m";
  ]

let convert_currency_tests =
  [
    convert_curr_test_helper "20" "USD" "HKD"
      "20 USD is equivalent to 156.693423 HKD";
    convert_curr_test_helper "30.65" "GBP" "JPY"
      "30.65 GBP is equivalent to 5230.030049 JPY";
  ]

let suite =
  "test suite for all bot functions"
  >::: List.flatten
         [
           echo_tests;
           coin_tests;
           rng_btwn_tests;
           convert_units_tests;
           convert_currency_tests;
         ]

let _ = run_test_tt_main suite
