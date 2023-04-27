open Server.Dan
open Server.Ant
open Server.Ken
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

let header_creator_test_helper (name : string) (key : string)
    (expected_output : Cohttp.Header.t) =
  name >:: fun _ ->
  let header = header_creator key in
  assert_equal expected_output header

let param_creator_test_helper (name : string) (msg : string) expected_output =
  name >:: fun _ -> assert_equal expected_output (param_creator msg)

let header_creator_tests =
  [
    header_creator_test_helper "inputting some valid formatted key"
      "g433081FWDW3122"
      (Cohttp.Header.of_list
         [
           ("Content-Type", "application/json");
           ("Authorization", "Bearer " ^ "g433081FWDW3122");
         ]);
    header_creator_test_helper "inputting a key of size 1" "1"
      (Cohttp.Header.of_list
         [ ("Content-Type", "application/json"); ("Authorization", "Bearer 1") ]);
  ]

let param_creator_tests =
  [
    param_creator_test_helper "test against some random message" "Hello World!"
      (`Assoc
        [
          ("model", `String "gpt-3.5-turbo");
          ( "messages",
            `List
              [
                `Assoc
                  [
                    ("role", `String "user"); ("content", `String "Hello World!");
                  ];
              ] );
        ]);
    param_creator_test_helper "test against long message"
      "How can one effectively manage their time and improve productivity, \
       while avoiding burnout and maintaining work-life balance, especially in \
       today's fast-paced and highly demanding work environment where there \
       seems to be a never-ending list of tasks to complete and distractions \
       are always just a click away?"
      (`Assoc
        [
          ("model", `String "gpt-3.5-turbo");
          ( "messages",
            `List
              [
                `Assoc
                  [
                    ("role", `String "user");
                    ( "content",
                      `String
                        "How can one effectively manage their time and improve \
                         productivity, while avoiding burnout and maintaining \
                         work-life balance, especially in today's fast-paced \
                         and highly demanding work environment where there \
                         seems to be a never-ending list of tasks to complete \
                         and distractions are always just a click away?" );
                  ];
              ] );
        ]);
    ( "test param_creator against an empty message" >:: fun _ ->
      assert_raises (Failure "Error: Empty Message") (fun _ -> param_creator "")
    );
  ]

let json_parser_tests =
  [
    ( "parses some non-empty string/json" >:: fun _ ->
      let parsed_body =
        `Assoc
          [
            ( "choices",
              `List
                [
                  `Assoc
                    [
                      ( "message",
                        `Assoc
                          [
                            ("content", `String "Hello, world!");
                            ("role", `String "user");
                          ] );
                    ];
                ] );
          ]
        |> Yojson.Basic.to_string
      in
      assert_equal [ "Hello, world!" ] (json_parser parsed_body) );
    ( "fails on empty input" >:: fun _ ->
      assert_raises (Failure "Invalid Input: Empty body") (fun () ->
          json_parser "") );
    ( "testing parsing over a reasonable json" >:: fun _ ->
      let parsed_body =
        `Assoc
          [
            ( "choices",
              `List
                [
                  `Assoc
                    [
                      ( "message",
                        `Assoc
                          [
                            ( "content",
                              `String "The addition of 7 + 9 equals 16" );
                            ("role", `String "user");
                          ] );
                    ];
                ] );
          ]
        |> Yojson.Basic.to_string
      in
      assert_equal
        [ "The addition of 7 + 9 equals 16" ]
        (json_parser parsed_body) );
  ]
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
           test_conv_helper;
           test_pp_unit_conv;
           header_creator_tests;
           param_creator_tests;
           json_parser_tests;
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
