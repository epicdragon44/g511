open Opium
open Lwt
open Cohttp_lwt_unix
open Yojson.Safe.Util

(* TODO: Fill out this file, using dan.ml as an example template.
    - Extract out functionality from bin/main.ml into this file. For each function:
        - Implement as many helper functions where possible.
        - Document every function you write carefully with a full description, including pre and post conditions, as well as what the inputs are and what the output will be.
        - CHECK for pre conditions in the body of the function, and raise an exception if they are not met!
        - Write readable, verbose code where possible.
    - Add unit tests to server/tests/main.ml for each function you write.
        - You can import your module using `open Server.<YourModule>` at the top. If there's an error, run `make build` in root as usual.
        - From there, just use OUnit as usual. You can mimic the code I already have in there.
*)

(* ========= HELPER FUNCTIONS: Move functionality from bin/main.ml  ========= *)

(* Unit Converter Helpers *)

(** [conv_helper amt from_unit to_unit] is a function that returns a float that is the converted (amt) from from_unit to to_unit
    @param amt is the amount to convert
    @param from_unit is the unit to convert from
    @param to_unit is the unit to convert to
    @return a float that is the converted (amt) from from_unit to to_unit
    @precond [amt] must be a float; [from_unit] and [to_unit] must be strings and among the supported units of measurements
    @postcond Return type is float *)
let conv_helper amt from_unit to_unit =
  (* enforce preconds *)
  if not (Float.is_finite amt) then
    failwith "amt and converted_amt should be finite floats";
  if not (String.length from_unit > 0 && String.length to_unit > 0) then
    failwith "from_unit and to_unit should be non-empty strings";
  let conversion_factor =
    match (from_unit, to_unit) with
    | "m", "ft" -> 3.28084
    | "ft", "m" -> 0.3048
    | "kg", "lb" -> 2.20462
    | "lb", "kg" -> 0.453592
    | "m", "cm" -> 100.0
    | "cm", "m" -> 0.01
    | "m", "mm" -> 1000.0
    | "mm", "m" -> 0.001
    | "km", "m" -> 1000.0
    | "m", "km" -> 0.001
    | "in", "cm" -> 2.54
    | "cm", "in" -> 0.393701
    | "ft", "in" -> 12.0
    | "in", "ft" -> 0.0833333
    | "mi", "km" -> 1.60934
    | "km", "mi" -> 0.621371
    | "gal", "L" -> 3.78541
    | "L", "gal" -> 0.264172
    | "oz", "g" -> 28.3495
    | "g", "oz" -> 0.035274
    | "lb", "oz" -> 16.0
    | "oz", "lb" -> 0.0625
    | "ton", "kg" -> 907.185
    | "kg", "ton" -> 0.00110231
    | "mph", "km/h" -> 1.60934
    | "km/h", "mph" -> 0.621371
    | "N", "lbf" -> 0.224809
    | "lbf", "N" -> 4.44822
    | _ -> 1.0
  in
  amt *. conversion_factor

(** [pp_unit_conv amt from_unit to_unit converted_amt] is a function that pretty prints a string for output 
    @param amt is the amount to convert
    @param from_unit is the unit to convert from
    @param to_unit is the unit to convert to
    @param converted_amt is amt in the new unit (to_unit)
    @return a string formatted as follows: "[amt] [from_unit] = [converted_amt] [to_unit]"
    @precond [amt] and [converted_amt] are floats; [from_unit] and [to_unit] are strings
    @postcond return type is a string *)
let pp_unit_conv amt from_unit to_unit converted_amt =
  (* enforce preconds *)
  if not (Float.is_finite amt && Float.is_finite converted_amt) then
    failwith "amt and converted_amt should be finite floats";
  if not (String.length from_unit > 0 && String.length to_unit > 0) then
    failwith "from_unit and to_unit should be non-empty strings";
  Printf.sprintf "%g %s = %g %s" amt from_unit converted_amt to_unit

(* Currency Converter Helpers *)

(* Timezone Helpers*)
