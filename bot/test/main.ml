open Bot.Dan
open OUnit2

let echo_test_helper (input : string) (expected_output : string) =
  "echo" >:: fun _ -> assert_equal expected_output (echo input)

let echo_tests = [ echo_test_helper "echo" "echo"; echo_test_helper "" "" ]
let suite = "test suite for all bot functions" >::: List.flatten [ echo_tests ]
let _ = run_test_tt_main suite
