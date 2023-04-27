open Server.Dan
open Server.Ryan
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

let create_weather_url_test_helper api_key location expected _ =
  let r = create_weather_url api_key location in
  let res = Uri.to_string r in
  assert_equal expected res

let get_response_body_test_helper location weather expected _ =
  let r = get_response_body location weather in
  assert_equal expected r

let extract_weather_description_test_helper json expected _ =
  let r = extract_weather_description (Yojson.Safe.from_string json) in
  assert_equal expected r

let rand_btwn_tests = [ rand_btwn_test_helper 0 10; rand_btwn_test_helper 1 1 ]
let coin_flip_tests = [ coin_flip_test_helper () ]

let create_weather_url_tests =
  [
    "create_weather_url"
    >:: create_weather_url_test_helper "test_key" "New York"
          "http://api.weatherstack.com/current?access_key=test_key&query=New%20York";
  ]

let get_response_body_tests =
  [
    "get_response_body"
    >:: get_response_body_test_helper "New York" "Sunny"
          "The weather in New York is Sunny.";
  ]

let extract_weather_description_tests =
  [
    "extract_weather_description"
    >:: extract_weather_description_test_helper
          {|{"current":{"weather_descriptions":["Sunny"]}}|} "Sunny";
  ]

let suite =
  "test suite for all server functions"
  >::: List.flatten
         [
           rand_btwn_tests;
           coin_flip_tests;
           create_weather_url_tests;
           get_response_body_tests;
           extract_weather_description_tests;
         ]

let _ = run_test_tt_main suite
