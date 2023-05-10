open Helper

(* TODO:

    1. Write a helper function below, in this file, that calls the server API we built previously.
        To help, I made a helper function [call <some url>] in [Helper.ml] that gets you the text that a server returns.
        You can use it like this: [call "http://localhost:9000/coinflip"].
       Do this for *every* server endpoint you built previously.

       For each one, as usual, include documentation on pre and post-conditions, parameters, what it returns, what it does, etc.

    2. Write unit tests in [bot/test/main.ml] for all the helper functions you wrote here.

    3. Go to [bot/bin/main.ml] and read through and do the "Secondary TODO" there.

    If you need some examples, search the whole project for the word "rng". You'll see I:
    - I have an rng endpoint in [server/bin/main.ml] that looks like this: ["/rng/:min/:max"].
    - So I made an rng_btwn helper function in [bot/lib/dan.ml] that calls that endpoint.
    - Then I wrote some unit tests for it in [bot/test/main.ml].
    - Then I followed the instructions in [bot/bin/main.ml] to connect it to the Telegram bot.
*)

(** Helper function for convert_units and convert_curr below *)
let convert (typ : string) (amt : float) (from : string) (too : string) : string
    =
  call
    ("http://localhost:9000/convert/" ^ typ ^ "/" ^ string_of_float amt ^ "/"
   ^ from ^ "/" ^ too)

(** Converts a given amount from one unit of measurement to another.

      Preconditions:
      - amt is a float
      - from and too are (lowercase) strings that represent a supported unit of measurement,
      which is listed here: ["m", "ft", "kg", "lb", "cm", "mm", "km", "in", 
      "mi", "gal", "L", "oz", "ton", "mph", "km/h", "N", "lbf"]
      - any inputs of from and too that are not from the list given above 
      will not result in a valid conversion


      Postcondition: returns a string in the format of 
      "(amt) (from) = [converted amount] (too)".

      @param amt is the amount to convert
      @param from is the unit to convert from
      @param too is the unit to convert to

      @return amt converted to the new unit of measurement

      @example the call [convert_units 1.5 m cm] returns "1.5 m = 150 cm"
*)
let convert_units (amt : float) (from : string) (too : string) : string =
  convert "units" amt from too

(** Converts a given amount from one currency to another.

      Preconditions:
      - amt is a float
      - from and too are (uppercase) strings that represent a valid currency
        * it must be a valid ISO currency code


      Postcondition: returns a string in the format of 
      "(amt) (from) is equivalent to [converted amount] (too)".

      @param amt is the amount to convert
      @param from is the currency to convert from
      @param too is the currency to convert to

      @return amt converted to the new currency

      @example the call [convert_units 20.5 USD USD] returns 
      "20.5 USD is equivalent to 20.5 USD"
*)
let convert_curr (amt : float) (from : string) (too : string) : string =
  convert "currency" amt from too

(** Returns the current time in a given timezone.
    
    Preconditions: the inputs [area] and [location] must be a 
    valid TZ identifier (see 'tz database' online). 
    
    Example: if I wanted to query about the time in New York City, 
    the TZ identifier for that would be America/New_York. In that case, 
    the [area] input would be "America" and 
    the [location] input would be "New_York".

    Postcondition: returns a string in the format of
    "The current time in (area)/(location) is [hh:mm:ss]"

    @param [area]/[location] is the TZ identifier of a timezone

    @return the current time (24hr) in the requested timezone

    @example if I call [get_curr_time "America" "New_York"] at 6:00pm, the return
    string will be "The current time in America/New_York is 18:00:00"
*)
let get_curr_time (area : string) (location : string) =
  call ("http://localhost:9000/convert/" ^ area ^ "/" ^ location)
