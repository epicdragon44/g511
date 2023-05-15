open Server.Lib
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
    ( "testing with empty key" >:: fun _ ->
      assert_raises (Failure "Invalid api key") (fun _ -> header_creator "") );
    header_creator_test_helper "inputting some key with special characters"
      "g43308?!@#dwiodjaiojFWDW3122"
      (Cohttp.Header.of_list
         [
           ("Content-Type", "application/json");
           ("Authorization", "Bearer " ^ "g43308?!@#dwiodjaiojFWDW3122");
         ]);
    header_creator_test_helper "inputting a key with only uppercase letters"
      "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      (Cohttp.Header.of_list
         [
           ("Content-Type", "application/json");
           ("Authorization", "Bearer " ^ "ABCDEFGHIJKLMNOPQRSTUVWXYZ");
         ]);
    header_creator_test_helper "inputting a key with only lowercase letters"
      "abcdefghijklmnopqrstuvwxyz"
      (Cohttp.Header.of_list
         [
           ("Content-Type", "application/json");
           ("Authorization", "Bearer " ^ "abcdefghijklmnopqrstuvwxyz");
         ]);
    header_creator_test_helper "inputting a key with whitespace"
      "g433081FWDW 3122"
      (Cohttp.Header.of_list
         [
           ("Content-Type", "application/json");
           ("Authorization", "Bearer " ^ "g433081FWDW 3122");
         ]);
    header_creator_test_helper
      "inputting a key with leading/trailing whitespace" "  g433081FWDW3122  "
      (Cohttp.Header.of_list
         [
           ("Content-Type", "application/json");
           ("Authorization", "Bearer " ^ "g433081FWDW3122");
         ]);
    header_creator_test_helper "inputting a key with leading whitespace"
      "   g83u219hduhw8921"
      (Cohttp.Header.of_list
         [
           ("Content-Type", "application/json");
           ("Authorization", "Bearer " ^ "g83u219hduhw8921");
         ]);
    header_creator_test_helper "inputting a key with trailing whitespace"
      "jiiuu2hue2189e189  "
      (Cohttp.Header.of_list
         [
           ("Content-Type", "application/json");
           ("Authorization", "Bearer " ^ "jiiuu2hue2189e189");
         ]);
    ( "testing with only whitespaces" >:: fun _ ->
      assert_raises (Failure "Invalid api key") (fun _ ->
          header_creator "      ") );
    ( "testing with only tabs" >:: fun _ ->
      assert_raises (Failure "Invalid api key") (fun _ ->
          header_creator "\t\t\t\t\t\t\t") );
    ( "testing with only newlines" >:: fun _ ->
      assert_raises (Failure "Invalid api key") (fun _ ->
          header_creator "\n\n\n\n\n\n\n\n") );
    header_creator_test_helper
      "inputting a key with mixed whitespace characters"
      "  \t\n\r gijh392yr89e2hr98\t \n\r "
      (Cohttp.Header.of_list
         [
           ("Content-Type", "application/json");
           ("Authorization", "Bearer " ^ "gijh392yr89e2hr98");
         ]);
    header_creator_test_helper "inputting a key with multiple tabs"
      "g433081FWDW\t3122"
      (Cohttp.Header.of_list
         [
           ("Content-Type", "application/json");
           ("Authorization", "Bearer " ^ "g433081FWDW\t3122");
         ]);
    header_creator_test_helper "inputting a key with trailing tabs"
      "weeu2198ue281ue1\t\t"
      (Cohttp.Header.of_list
         [
           ("Content-Type", "application/json");
           ("Authorization", "Bearer " ^ "weeu2198ue281ue1");
         ]);
    header_creator_test_helper "inputting a key that has random input"
      "dnwjqdnoiu1jhd9h280919wdWQCASFWQ"
      (Cohttp.Header.of_list
         [
           ("Content-Type", "application/json");
           ("Authorization", "Bearer " ^ "dnwjqdnoiu1jhd9h280919wdWQCASFWQ");
         ]);
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
    ( "parses a message with special characters" >:: fun _ ->
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
                              `String
                                "This message has !@#$%^&*()_+{}|:\"<>?/\\ \
                                 characters." );
                            ("role", `String "user");
                          ] );
                    ];
                ] );
          ]
        |> Yojson.Basic.to_string
      in
      assert_equal
        [ "This message has !@#$%^&*()_+{}|:\"<>?/\\ characters." ]
        (json_parser parsed_body) );
    ( "parses a message with newlines" >:: fun _ ->
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
                              `String "This is a message\nwith multiple\nlines."
                            );
                            ("role", `String "user");
                          ] );
                    ];
                ] );
          ]
        |> Yojson.Basic.to_string
      in
      assert_equal
        [ "This is a message\nwith multiple\nlines." ]
        (json_parser parsed_body) );
    ( "parses a message with leading/trailing spaces" >:: fun _ ->
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
                              `String "  This message has spaces around it.   "
                            );
                            ("role", `String "user");
                          ] );
                    ];
                ] );
          ]
        |> Yojson.Basic.to_string
      in
      assert_equal
        [ "This message has spaces around it." ]
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
      Lwt.return
        (assert_equal expected_status status_code ~printer:string_of_int) )

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

let test_conv_helper_m_to_cm _ =
  let conversion_factor = 100.0 in
  let result = conv_helper 1.0 "m" "cm" in
  assert_bool "conversion from meters to centimeters"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_cm_to_m _ =
  let conversion_factor = 0.01 in
  let result = conv_helper 1.0 "cm" "m" in
  assert_bool "conversion from centimeters to meters"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_m_to_mm _ =
  let conversion_factor = 1000.0 in
  let result = conv_helper 1.0 "m" "mm" in
  assert_bool "conversion from meters to millimeters"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_mm_to_m _ =
  let conversion_factor = 0.001 in
  let result = conv_helper 1.0 "mm" "m" in
  assert_bool "conversion from millimeters to meters"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_km_to_m _ =
  let conversion_factor = 1000.0 in
  let result = conv_helper 1.0 "km" "m" in
  assert_bool "conversion from kilometers to meters"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_m_to_km _ =
  let conversion_factor = 0.001 in
  let result = conv_helper 1.0 "m" "km" in
  assert_bool "conversion from meters to kilometers"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_in_to_cm _ =
  let conversion_factor = 2.54 in
  let result = conv_helper 1.0 "in" "cm" in
  assert_bool "conversion from inches to centimeters"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_cm_to_in _ =
  let conversion_factor = 0.393701 in
  let result = conv_helper 1.0 "cm" "in" in
  assert_bool "conversion from centimeters to inches"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_ft_to_in _ =
  let conversion_factor = 12.0 in
  let result = conv_helper 1.0 "ft" "in" in
  assert_bool "conversion from feet to inches"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_in_to_ft _ =
  let conversion_factor = 0.0833333 in
  let result = conv_helper 1.0 "in" "ft" in
  assert_bool "conversion from inches to feet"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_mi_to_km _ =
  let conversion_factor = 1.60934 in
  let result = conv_helper 1.0 "mi" "km" in
  assert_bool "conversion from miles to kilometers"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_km_to_mi _ =
  let conversion_factor = 0.621371 in
  let result = conv_helper 1.0 "km" "mi" in
  assert_bool "conversion from kilometers to miles"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_gal_to_L _ =
  let conversion_factor = 3.78541 in
  let result = conv_helper 1.0 "gal" "L" in
  assert_bool "conversion from gallons to liters"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_L_to_gal _ =
  let conversion_factor = 0.264172 in
  let result = conv_helper 1.0 "L" "gal" in
  assert_bool "conversion from liters to gallons"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_oz_to_g _ =
  let conversion_factor = 28.3495 in
  let result = conv_helper 1.0 "oz" "g" in
  assert_bool "conversion from ounces to grams"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_g_to_oz _ =
  let conversion_factor = 0.035274 in
  let result = conv_helper 1.0 "g" "oz" in
  assert_bool "conversion from grams to ounces"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_lb_to_oz _ =
  let conversion_factor = 16.0 in
  let result = conv_helper 1.0 "lb" "oz" in
  assert_bool "conversion from pounds to ounces"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_oz_to_lb _ =
  let conversion_factor = 0.0625 in
  let result = conv_helper 1.0 "oz" "lb" in
  assert_bool "conversion from ounces to pounds"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_ton_to_kg _ =
  let conversion_factor = 907.185 in
  let result = conv_helper 1.0 "ton" "kg" in
  assert_bool "conversion from tons to kilograms"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_kg_to_ton _ =
  let conversion_factor = 0.00110231 in
  let result = conv_helper 1.0 "kg" "ton" in
  assert_bool "conversion from kilograms to tons"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_mph_to_km_h _ =
  let conversion_factor = 1.60934 in
  let result = conv_helper 1.0 "mph" "km/h" in
  assert_bool "conversion from miles per hour to kilometers per hour"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_km_h_to_mph _ =
  let conversion_factor = 0.621371 in
  let result = conv_helper 1.0 "km/h" "mph" in
  assert_bool "conversion from kilometers per hour to miles per hour"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_N_to_lbf _ =
  let conversion_factor = 0.224809 in
  let result = conv_helper 1.0 "N" "lbf" in
  assert_bool "conversion from newtons to pounds-force"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper_lbf_to_N _ =
  let conversion_factor = 4.44822 in
  let result = conv_helper 1.0 "lbf" "N" in
  assert_bool "conversion from pounds-force to newtons"
    (Float.abs (result -. conversion_factor) < 0.0001)

let test_conv_helper =
  [
    "test_conv_helper_m_to_ft" >:: test_conv_helper_m_to_ft;
    "test_conv_helper_ft_to_m" >:: test_conv_helper_ft_to_m;
    "test_conv_helper_kg_to_lb" >:: test_conv_helper_kg_to_lb;
    "test_conv_helper_lb_to_kg" >:: test_conv_helper_lb_to_kg;
    "test_conv_helper_m_to_cm" >:: test_conv_helper_m_to_cm;
    "test_conv_helper_cm_to_m" >:: test_conv_helper_cm_to_m;
    "test_conv_helper_m_to_mm" >:: test_conv_helper_m_to_mm;
    "test_conv_helper_mm_to_m" >:: test_conv_helper_mm_to_m;
    "test_conv_helper_km_to_m" >:: test_conv_helper_km_to_m;
    "test_conv_helper_m_to_km" >:: test_conv_helper_m_to_km;
    "test_conv_helper_in_to_cm" >:: test_conv_helper_in_to_cm;
    "test_conv_helper_cm_to_in" >:: test_conv_helper_cm_to_in;
    "test_conv_helper_ft_to_in" >:: test_conv_helper_ft_to_in;
    "test_conv_helper_in_to_ft" >:: test_conv_helper_in_to_ft;
    "test_conv_helper_mi_to_km" >:: test_conv_helper_mi_to_km;
    "test_conv_helper_km_to_mi" >:: test_conv_helper_km_to_mi;
    "test_conv_helper_gal_to_L" >:: test_conv_helper_gal_to_L;
    "test_conv_helper_L_to_gal" >:: test_conv_helper_L_to_gal;
    "test_conv_helper_oz_to_g" >:: test_conv_helper_oz_to_g;
    "test_conv_helper_g_to_oz" >:: test_conv_helper_g_to_oz;
    "test_conv_helper_lb_to_oz" >:: test_conv_helper_lb_to_oz;
    "test_conv_helper_oz_to_lb" >:: test_conv_helper_oz_to_lb;
    "test_conv_helper_ton_to_kg" >:: test_conv_helper_ton_to_kg;
    "test_conv_helper_kg_to_ton" >:: test_conv_helper_kg_to_ton;
    "test_conv_helper_km_h_to_mph" >:: test_conv_helper_km_h_to_mph;
    "test_conv_helper_mph_to_km_h" >:: test_conv_helper_mph_to_km_h;
    "test_conv_helper_N_to_lbf" >:: test_conv_helper_N_to_lbf;
    "test_conv_helper_lbf_to_N" >:: test_conv_helper_lbf_to_N;
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

let test_pp_unit_conv_lb_to_kg _ =
  assert_equal "200 lb = 90.72 kg" (pp_unit_conv 200.0 "lb" "kg" 90.72)

let test_pp_unit_conv_kmh_to_mph _ =
  assert_equal "100 km/h = 62.14 mph" (pp_unit_conv 100.0 "km/h" "mph" 62.14)

let test_pp_unit_conv_zero_value _ =
  assert_equal "0 m = 0 cm" (pp_unit_conv 0.0 "m" "cm" 0.0)

let test_pp_unit_conv_negative_value _ =
  assert_equal "-1.5 m = -150 cm" (pp_unit_conv (-1.5) "m" "cm" (-150.0))

let test_pp_unit_conv_same_units _ =
  assert_equal "1.5 m = 1.5 m" (pp_unit_conv 1.5 "m" "m" 1.5)

let test_pp_unit_conv_empty_unit_2 _ =
  assert_raises (Failure "from_unit and to_unit should be non-empty strings")
    (fun () -> pp_unit_conv 1.5 "m" "" 150.0)

let test_pp_unit_conv_empty_unit_3 _ =
  assert_raises (Failure "from_unit and to_unit should be non-empty strings")
    (fun () -> pp_unit_conv 1.5 "" "" 150.0)

let test_pp_unit_conv =
  [
    "test_pp_unit_conv_m_to_cm" >:: test_pp_unit_conv_m_to_cm;
    "test_pp_unit_conv_usd_to_cad" >:: test_pp_unit_conv_usd_to_cad;
    "test_pp_unit_conv_nonfinite_amt" >:: test_pp_unit_conv_nonfinite_amt;
    "test_pp_unit_conv_empty_unit" >:: test_pp_unit_conv_empty_unit;
    "test_pp_unit_conv_lb_to_kg" >:: test_pp_unit_conv_lb_to_kg;
    "test_pp_unit_conv_kmh_to_mph" >:: test_pp_unit_conv_kmh_to_mph;
    "test_pp_unit_conv_zero_value" >:: test_pp_unit_conv_zero_value;
    "test_pp_unit_conv_negative_value" >:: test_pp_unit_conv_negative_value;
    "test_pp_unit_conv_same_units" >:: test_pp_unit_conv_same_units;
    "test_pp_unit_conv_empty_unit_2" >:: test_pp_unit_conv_empty_unit_2;
    "test_pp_unit_conv_empty_unit_3" >:: test_pp_unit_conv_empty_unit_3;
  ]

let create_weather_url_tests =
  [
    "create_weather_url"
    >:: create_weather_url_test_helper "test_key" "New York"
          "http://api.weatherstack.com/current?access_key=test_key&query=New%20York";
    "create_weather_url"
    >:: create_weather_url_test_helper "test_key2" "Los Angeles"
          "http://api.weatherstack.com/current?access_key=test_key2&query=Los%20Angeles";
    "create_weather_url"
    >:: create_weather_url_test_helper "test_key3" "Chicago"
          "http://api.weatherstack.com/current?access_key=test_key3&query=Chicago";
    "create_weather_url"
    >:: create_weather_url_test_helper "test_key4" "Houston"
          "http://api.weatherstack.com/current?access_key=test_key4&query=Houston";
    "create_weather_url"
    >:: create_weather_url_test_helper "test_key5" "Phoenix"
          "http://api.weatherstack.com/current?access_key=test_key5&query=Phoenix";
    "create_weather_url"
    >:: create_weather_url_test_helper "test_key6" "Philadelphia"
          "http://api.weatherstack.com/current?access_key=test_key6&query=Philadelphia";
    "create_weather_url"
    >:: create_weather_url_test_helper "test_key7" "San Antonio"
          "http://api.weatherstack.com/current?access_key=test_key7&query=San%20Antonio";
    "create_weather_url"
    >:: create_weather_url_test_helper "test_key8" "San Diego"
          "http://api.weatherstack.com/current?access_key=test_key8&query=San%20Diego";
    "create_weather_url"
    >:: create_weather_url_test_helper "test_key9" "Dallas"
          "http://api.weatherstack.com/current?access_key=test_key9&query=Dallas";
    "create_weather_url"
    >:: create_weather_url_test_helper "test_key10" "San Jose"
          "http://api.weatherstack.com/current?access_key=test_key10&query=San%20Jose";
    "create_weather_url"
    >:: create_weather_url_test_helper "test_key11" "Austin"
          "http://api.weatherstack.com/current?access_key=test_key11&query=Austin";
    "create_weather_url"
    >:: create_weather_url_test_helper "test_key12" "Jacksonville"
          "http://api.weatherstack.com/current?access_key=test_key12&query=Jacksonville";
    "create_weather_url"
    >:: create_weather_url_test_helper "test_key13" "San Francisco"
          "http://api.weatherstack.com/current?access_key=test_key13&query=San%20Francisco";
    "create_weather_url"
    >:: create_weather_url_test_helper "test_key14" "Indianapolis"
          "http://api.weatherstack.com/current?access_key=test_key14&query=Indianapolis";
    "create_weather_url"
    >:: create_weather_url_test_helper "test_key15" "Columbus"
          "http://api.weatherstack.com/current?access_key=test_key15&query=Columbus";
    "create_weather_url"
    >:: create_weather_url_test_helper "test_key16" "Fort Worth"
          "http://api.weatherstack.com/current?access_key=test_key16&query=Fort%20Worth";
    "create_weather_url"
    >:: create_weather_url_test_helper "test_key17" "Charlotte"
          "http://api.weatherstack.com/current?access_key=test_key17&query=Charlotte";
    "create_weather_url"
    >:: create_weather_url_test_helper "test_key18" "Detroit"
          "http://api.weatherstack.com/current?access_key=test_key18&query=Detroit";
    "create_weather_url"
    >:: create_weather_url_test_helper "test_key19" "El Paso"
          "http://api.weatherstack.com/current?access_key=test_key19&query=El%20Paso";
    "create_weather_url"
    >:: create_weather_url_test_helper "test_key20" "Seattle"
          "http://api.weatherstack.com/current?access_key=test_key20&query=Seattle";
  ]

let get_response_body_tests =
  [
    "get_response_body"
    >:: get_response_body_test_helper "New York" "Sunny"
          "The weather in New York is Sunny.";
  ]

let extract_weather_description_tests =
  [
    "extract_weather_description_1"
    >:: extract_weather_description_test_helper
          {|{"current":{"weather_descriptions":["Sunny"]}}|} "Sunny";
    "extract_weather_description_2"
    >:: extract_weather_description_test_helper
          {|{"current":{"weather_descriptions":["Clear"]}}|} "Clear";
    "extract_weather_description_3"
    >:: extract_weather_description_test_helper
          {|{"current":{"weather_descriptions":["Partly Cloudy"]}}|}
          "Partly Cloudy";
    "extract_weather_description_4"
    >:: extract_weather_description_test_helper
          {|{"current":{"weather_descriptions":["Overcast"]}}|} "Overcast";
    "extract_weather_description_5"
    >:: extract_weather_description_test_helper
          {|{"current":{"weather_descriptions":["Cloudy"]}}|} "Cloudy";
    "extract_weather_description_6"
    >:: extract_weather_description_test_helper
          {|{"current":{"weather_descriptions":["Fog"]}}|} "Fog";
    "extract_weather_description_7"
    >:: extract_weather_description_test_helper
          {|{"current":{"weather_descriptions":["Mist"]}}|} "Mist";
    "extract_weather_description_8"
    >:: extract_weather_description_test_helper
          {|{"current":{"weather_descriptions":["Rain"]}}|} "Rain";
    "extract_weather_description_9"
    >:: extract_weather_description_test_helper
          {|{"current":{"weather_descriptions":["Drizzle"]}}|} "Drizzle";
    "extract_weather_description_10"
    >:: extract_weather_description_test_helper
          {|{"current":{"weather_descriptions":["Snow"]}}|} "Snow";
    "extract_weather_description_11"
    >:: extract_weather_description_test_helper
          {|{"current":{"weather_descriptions":["Sleet"]}}|} "Sleet";
    "extract_weather_description_12"
    >:: extract_weather_description_test_helper
          {|{"current":{"weather_descriptions":["Hail"]}}|} "Hail";
    "extract_weather_description_13"
    >:: extract_weather_description_test_helper
          {|{"current":{"weather_descriptions":["Thunderstorm"]}}|}
          "Thunderstorm";
    "extract_weather_description_14"
    >:: extract_weather_description_test_helper
          {|{"current":{"weather_descriptions":["Tornado"]}}|} "Tornado";
    "extract_weather_description_15"
    >:: extract_weather_description_test_helper
          {|{"current":{"weather_descriptions":["Blizzard"]}}|} "Blizzard";
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
    "lang_matcher" >:: lang_matcher_test_helper "Azerbaijani" "az";
    "lang_matcher" >:: lang_matcher_test_helper "Albanian" "sq";
    "lang_matcher" >:: lang_matcher_test_helper "Amharic" "am";
    "lang_matcher" >:: lang_matcher_test_helper "Arabic" "ar";
    "lang_matcher" >:: lang_matcher_test_helper "Armenian" "hy";
    "lang_matcher" >:: lang_matcher_test_helper "Afrikaans" "af";
    "lang_matcher" >:: lang_matcher_test_helper "Basque" "eu";
    "lang_matcher" >:: lang_matcher_test_helper "Bashkir" "ba";
    "lang_matcher" >:: lang_matcher_test_helper "Belarusian" "be";
    "lang_matcher" >:: lang_matcher_test_helper "Bengal" "bn";
    "lang_matcher" >:: lang_matcher_test_helper "Burmese" "my";
    "lang_matcher" >:: lang_matcher_test_helper "Bulgarian" "bg";
    "lang_matcher" >:: lang_matcher_test_helper "Bosnian" "bs";
    "lang_matcher" >:: lang_matcher_test_helper "Welsh" "cy";
    "lang_matcher" >:: lang_matcher_test_helper "Hungarian" "hu";
    "lang_matcher" >:: lang_matcher_test_helper "Vietnamese" "vi";
    "lang_matcher" >:: lang_matcher_test_helper "Haitian" "ht";
    "lang_matcher" >:: lang_matcher_test_helper "Galician" "gl";
    "lang_matcher" >:: lang_matcher_test_helper "Dutch" "nl";
    "lang_matcher" >:: lang_matcher_test_helper "Hill Mari" "mrj";
    "lang_matcher" >:: lang_matcher_test_helper "Greek" "el";
    "lang_matcher" >:: lang_matcher_test_helper "Georgian" "ka";
    "lang_matcher" >:: lang_matcher_test_helper "Gujarati" "gu";
    "lang_matcher" >:: lang_matcher_test_helper "Danish" "da";
    "lang_matcher" >:: lang_matcher_test_helper "Hebrew" "he";
    "lang_matcher" >:: lang_matcher_test_helper "Yiddish" "yi";
    "lang_matcher" >:: lang_matcher_test_helper "Indonesian" "id";
    "lang_matcher" >:: lang_matcher_test_helper "Irish" "ga";
    "lang_matcher" >:: lang_matcher_test_helper "Italian" "it";
    "lang_matcher" >:: lang_matcher_test_helper "Icelandic" "is";
    "lang_matcher" >:: lang_matcher_test_helper "Spanish" "es";
    "lang_matcher" >:: lang_matcher_test_helper "Kazakh" "kk";
    "lang_matcher" >:: lang_matcher_test_helper "Kannada" "kn";
    "lang_matcher" >:: lang_matcher_test_helper "Catalan" "ca";
    "lang_matcher" >:: lang_matcher_test_helper "Kirghiz" "ky";
    "lang_matcher" >:: lang_matcher_test_helper "Chinese" "zh";
    "lang_matcher" >:: lang_matcher_test_helper "Korean" "ko";
    "lang_matcher" >:: lang_matcher_test_helper "Xhosa" "xh";
  ]

let translation_get_request_tests =
  [
    "translation_get_request"
    >:: translation_get_request_test_helper "https://example.com" 200;
  ]

let extract_translation_from_body_tests =
  [
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Bonjour\"]}"
          "Bonjour";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Hola\"]}"
          "Hola";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Hello\"]}"
          "Hello";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Guten Tag\"]}"
          "Guten Tag";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Ciao\"]}"
          "Ciao";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Oi\"]}" "Oi";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Hej\"]}" "Hej";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Hallo\"]}"
          "Hallo";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper
          "{\"text\": [\"Kon'nichiwa\"]}" "Kon'nichiwa";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Nǐ hǎo\"]}"
          "Nǐ hǎo";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper
          "{\"text\": [\"Anyoung haseyo\"]}" "Anyoung haseyo";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Salam\"]}"
          "Salam";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Jambo\"]}"
          "Jambo";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Namaste\"]}"
          "Namaste";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Zdravo\"]}"
          "Zdravo";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Merhaba\"]}"
          "Merhaba";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Sveiki\"]}"
          "Sveiki";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Tere\"]}"
          "Tere";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Labas\"]}"
          "Labas";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Szia\"]}"
          "Szia";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Aloha\"]}"
          "Aloha";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Shalom\"]}"
          "Shalom";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Salaam\"]}"
          "Salaam";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Privet\"]}"
          "Privet";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"God dag\"]}"
          "God dag";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Buna ziua\"]}"
          "Buna ziua";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper
          "{\"text\": [\"Selamat siang\"]}" "Selamat siang";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper
          "{\"text\": [\"Asalaam alaikum\"]}" "Asalaam alaikum";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper
          "{\"text\": [\"Dzien dobry\"]}" "Dzien dobry";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Sawubona\"]}"
          "Sawubona";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper
          "{\"text\": [\"Sat sri akaal\"]}" "Sat sri akaal";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Yasou\"]}"
          "Yasou";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Ahoj\"]}"
          "Ahoj";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Dobry den\"]}"
          "Dobry den";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Oi\"]}" "Oi";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper
          "{\"text\": [\"Zdravstvuyte\"]}" "Zdravstvuyte";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Hoi\"]}" "Hoi";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Hei\"]}" "Hei";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Moi\"]}" "Moi";
    "extract_translation_from_body"
    >:: extract_translation_from_body_test_helper "{\"text\": [\"Hej\"]}" "Hej";
  ]

let translation_response_builder_tests =
  [
    "translation_response_builder"
    >:: translation_response_builder_test_helper "Bonjour"
          "Translation: Bonjour";
  ]

let text_board_test_helper board expected _ =
  let r = text_board board in
  assert_equal expected r

let other_player_test_helper player expected _ =
  let r = other_player player in
  assert_equal expected r

let is_valid_position_test_helper board pos expected _ =
  let r = is_valid_position board pos in
  assert_equal expected r

let digit_to_position_test_helper digit expected _ =
  let r = digit_to_position digit in
  assert_equal expected r

let text_board_tests =
  [
    "text_board"
    >:: text_board_test_helper
          [ [ "_"; "_"; "_" ]; [ "_"; "_"; "_" ]; [ "_"; "_"; "_" ] ]
          "| | | |\n| | | |\n| | | |\n";
  ]

let other_player_tests =
  [
    "other_player" >:: other_player_test_helper "x" "o";
    "other_player" >:: other_player_test_helper "o" "x";
  ]

let is_valid_position_tests =
  [
    "is_valid_position"
    >:: is_valid_position_test_helper
          [ [ "x"; "_"; "_" ]; [ "_"; "o"; "_" ]; [ "_"; "_"; "x" ] ]
          (0, 1) true;
    "is_valid_position"
    >:: is_valid_position_test_helper
          [ [ "x"; "o"; "_" ]; [ "_"; "o"; "_" ]; [ "_"; "_"; "x" ] ]
          (0, 1) false;
  ]

let digit_to_position_tests =
  [
    "digit_to_position" >:: digit_to_position_test_helper 1 (0, 0);
    "digit_to_position" >:: digit_to_position_test_helper 5 (1, 1);
    "digit_to_position" >:: digit_to_position_test_helper 9 (2, 2);
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
           text_board_tests;
           other_player_tests;
           is_valid_position_tests;
           digit_to_position_tests;
         ]

let _ = run_test_tt_main suite
