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

let test_pp_unit_conv_m_to_cm _ =
  assert_equal "1.5 m = 150 cm" (pp_unit_conv 1.5 "m" "cm" 150.0)

let test_pp_unit_conv_usd_to_cad _ =
  assert_equal "10 USD = 12.5 CAD" (pp_unit_conv 10.0 "USD" "CAD" 12.5)

let test_pp_unit_conv_nonfinite_amt _ =
  assert_raises (Failure "amt and converted_amt should be finite floats")
    (fun () -> pp_unit_conv nan "m" "cm" 150.0)

let test_pp_unit_conv_empty_unit _ =
  assert_raises (Failure "from_unit and to_unit should be non-empty strings")
    (fun () -> pp_unit_conv 1.5 "" "cm" 150.0)

let test_pp_unit_conv =
  [
    "test_pp_unit_conv_m_to_cm" >:: test_pp_unit_conv_m_to_cm;
    "test_pp_unit_conv_usd_to_cad" >:: test_pp_unit_conv_usd_to_cad;
    "test_pp_unit_conv_nonfinite_amt" >:: test_pp_unit_conv_nonfinite_amt;
    "test_pp_unit_conv_empty_unit" >:: test_pp_unit_conv_empty_unit;
  ]

let suite =
  "test suite for all server functions"
  >::: List.flatten
         [
           rand_btwn_tests; coin_flip_tests; test_conv_helper; test_pp_unit_conv;
         ]

let _ = run_test_tt_main suite
