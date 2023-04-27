open Server.Dan
open Server.Ken
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

let rand_btwn_tests = [ rand_btwn_test_helper 0 10; rand_btwn_test_helper 1 1 ]
let coin_flip_tests = [ coin_flip_test_helper () ]

let suite =
  "test suite for all server functions"
  >::: List.flatten
         [
           rand_btwn_tests;
           coin_flip_tests;
           header_creator_tests;
           param_creator_tests;
           json_parser_tests;
         ]

let _ = run_test_tt_main suite
