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

let translation_url_creator_test_helper api_key input lang_from_match
    lang_to_match expected _ =
  let r = translation_url_creator api_key input lang_from_match lang_to_match in
  let res = Uri.to_string r in
  assert_equal expected res

let lang_matcher_test_helper lang expected _ =
  let r = lang_matcher lang in
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

let translation_url_creator_tests =
  [
    "translation_url_creator"
    >:: translation_url_creator_test_helper "test_key" "Hello" "en" "es"
          "https://translate.yandex.net/api/v1.5/tr.json/translate?key=test_key&text=Hello&lang=en-es";
  ]

let lang_matcher_tests =
  [
    "lang_matcher" >:: lang_matcher_test_helper "English" "en";
    "lang_matcher" >:: lang_matcher_test_helper "German" "de";
    "lang_matcher"
    >:: lang_matcher_test_helper "UnsupportedLanguage" "unsupported";
  ]

let translation_get_request_test_helper url expected_status _ =
  let open Lwt.Infix in
  let uri = Uri.of_string url in
  Lwt_main.run
    ( translation_get_request uri >>= fun (response, _) ->
      let status_code =
        Cohttp.Response.status response |> Cohttp.Code.code_of_status
      in
      Lwt.return (assert_equal expected_status status_code) )

let extract_translation_from_body_test_helper body expected _ =
  let r = extract_translation_from_body (Cohttp_lwt.Body.of_string body) in
  let res = Lwt_main.run r in
  assert_equal expected res

let translation_response_builder_test_helper translation expected _ =
  let r = translation_response_builder translation in
  let res = r |> Opium.Response.to_plain_text |> Lwt_main.run in
  assert_equal expected res

let translation_get_request_tests =
  [
    "translation_get_request"
    >:: translation_get_request_test_helper "https://example.com" 404;
  ]

let extract_translation_from_body_tests =
  [
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Bonjour\"]}"
          "Bonjour";
  ]

let translation_response_builder_tests =
  [
    "translation_response_builder"
    >:: translation_response_builder_test_helper "Bonjour"
          "Translation: Bonjour";
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
           translation_url_creator_tests;
           lang_matcher_tests;
           translation_get_request_tests;
           extract_translation_from_body_tests;
           translation_response_builder_tests;
         ]

let _ = run_test_tt_main suite
