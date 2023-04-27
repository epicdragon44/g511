open Server.Dan
open Server.Ant
open OUnit2

let rand_btwn_test_helper (min : int) (max : int) =
  "rand_btwn" >:: fun _ ->
  let r = rand_btwn min max in
  let res = r >= min && r <= max in
  assert_equal true res

let coin_flip_test_helper () =
  "coin_flip" >:: fun _ ->
  let r = coin_flip () in
  let res = r = "Heads" || r = "Tails" in
  assert_equal true res

let rand_btwn_tests = [ rand_btwn_test_helper 0 10; rand_btwn_test_helper 1 1 ]
let coin_flip_tests = [ coin_flip_test_helper () ]

let test_conv_helper_m_to_ft _ =
  let conversion_factor = 3.28084 in
  let result = conv_helper 1.0 "m" "ft" in
  assert_bool "conversion from meters to feet"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_ft_to_m _ =
  let conversion_factor = 0.3048 in
  let result = conv_helper 1.0 "ft" "m" in
  assert_bool "conversion from feet to meters"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_kg_to_lb _ =
  let conversion_factor = 2.20462 in
  let result = conv_helper 1.0 "kg" "lb" in
  assert_bool "conversion from kilograms to pounds"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_lb_to_kg _ =
  let conversion_factor = 0.453592 in
  let result = conv_helper 1.0 "lb" "kg" in
  assert_bool "conversion from pounds to kilograms"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_unsupported_units _ =
  assert_raises (Failure "Conversion factor not defined") (fun () ->
      conv_helper 1.0 "mi" "m")

let test_conv_helper =
  [
    "test_conv_helper_m_to_ft" >:: test_conv_helper_m_to_ft;
    "test_conv_helper_ft_to_m" >:: test_conv_helper_ft_to_m;
    "test_conv_helper_kg_to_lb" >:: test_conv_helper_kg_to_lb;
    "test_conv_helper_lb_to_kg" >:: test_conv_helper_lb_to_kg;
    "test_conv_helper_unsupported_units" >:: test_conv_helper_unsupported_units;
  ]

let suite =
  "test suite for all server functions"
  >::: List.flatten [ rand_btwn_tests; coin_flip_tests; test_conv_helper ]

let _ = run_test_tt_main suite
