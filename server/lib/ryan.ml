open Lwt.Syntax
open Cohttp
open Opium
open Cohttp_lwt_unix
open Lwt

(* ========= HELPER FUNCTIONS: Move functionality from bin/main.ml  ========= *)

(** [create_weather_url api_key location] is a function that creates a Uri for the weather API request
@param api_key The weather API key used to access the weather data
@param location The location for which the weather data is requested
@return A Uri for the weather API request
@precond [api_key] and [location] must be non-empty strings
@postcond The result is of type Uri.t *)

let create_weather_url api_key location =
  if String.length api_key > 0 && String.length location > 0 then
    Uri.of_string
      (Printf.sprintf
         "http://api.weatherstack.com/current?access_key=%s&query=%s" api_key
         location)
  else failwith "Invalid Input: Empty api_key or location"

(** [get_response_body location weather] is a function that creates a response body string
@param location The location for which the weather data is requested
@param weather The weather description
@return A response body string
@precond [location] and [weather] must be non-empty strings
@postcond The result is of type string *)

let get_response_body location weather =
  if String.length location > 0 && String.length weather > 0 then
    Printf.sprintf "The weather in %s is %s." location weather
  else failwith "Invalid Input: Empty location or weather"

(** [extract_weather_description json] is a function that extracts the weather description from the given JSON
@param json A JSON object containing the weather data
@return The weather description as a string
@precond [json] must be a valid JSON object
@postcond The result is of type string *)

let extract_weather_description json =
  Yojson.Safe.Util.(
    json |> member "current"
    |> member "weather_descriptions"
    |> to_list |> List.hd |> to_string)

(** [api_key_provider ()] is a function that returns the API key for the Yandex Translate service.
@return The API key string
@postcond The result is a non-empty string *)

let api_key_provider () =
  "trnsl.1.1.20230317T192942Z.38aa007e66112d27.70023d1d131998c0c80fd04ef3c38c5024a7068c"

(** [translation_url_creator api_key input lang_from_match lang_to_match] is a function that creates a URL for the translation request
@param api_key The API key for the Yandex Translate service
@param input The input string to be translated
@param lang_from_match The language code of the source language
@param lang_to_match The language code of the target language
@return A Uri.t type URL for the translation request
@precond [api_key], [input], [lang_from_match], and [lang_to_match] must be non-empty strings
@postcond The result is of type Uri.t *)

let translation_url_creator api_key input lang_from_match lang_to_match =
  Uri.of_string
    (Printf.sprintf
       "https://translate.yandex.net/api/v1.5/tr.json/translate?key=%s&text=%s&lang=%s-%s"
       api_key input lang_from_match lang_to_match)

(** [api_key_provider ()] is a function that returns the API key for the Yandex Translate service.
@return The API key string
@postcond The result is a non-empty string *)

let api_key_provider () =
  "trnsl.1.1.20230317T192942Z.38aa007e66112d27.70023d1d131998c0c80fd04ef3c38c5024a7068c"

(** [translation_url_creator api_key input lang_from_match lang_to_match] is a function that creates a URL for the translation request
@param api_key The API key for the Yandex Translate service
@param input The input string to be translated
@param lang_from_match The language code of the source language
@param lang_to_match The language code of the target language
@return A Uri.t type URL for the translation request
@precond [api_key], [input], [lang_from_match], and [lang_to_match] must be non-empty strings
@postcond The result is of type Uri.t *)

let translation_url_creator api_key input lang_from_match lang_to_match =
  Uri.of_string
    (Printf.sprintf
       "https://translate.yandex.net/api/v1.5/tr.json/translate?key=%s&text=%s&lang=%s-%s"
       api_key input lang_from_match lang_to_match)

(** [translation_get_request url] is a function that makes a GET request to the given URL
@param url The Uri.t type URL for the translation request
@return A pair containing the response and body of the GET request
@precond [url] must be a valid Uri.t type URL
@postcond The result is a pair of the response and body of the GET request *)

let translation_get_request url = Cohttp_lwt_unix.Client.get url

(** [extract_translation_from_body body] is a function that extracts the translation text from the response body
@param body The Cohttp_lwt.Body.t type response body
@return The translated text as a string
@precond [body] must be a valid Cohttp_lwt.Body.t type
@postcond The result is a non-empty string *)

let extract_translation_from_body body =
  body |> Cohttp_lwt.Body.to_string >|= fun body_str ->
  let json = Yojson.Safe.from_string body_str in
  Yojson.Safe.Util.(json |> member "text" |> to_list |> List.hd |> to_string)

(** [translation_response_builder translation] is a function that builds an Opium.Response.t object containing the translation
@param translation The translated text as a string
@return An Opium.Response.t object containing the translation
@precond [translation] must be a non-empty string
@postcond The result is of type Opium.Response.t *)

let translation_response_builder translation =
  let response_body = Printf.sprintf "Translation: %s" translation in
  Opium.Response.of_plain_text response_body

(** [lang_matcher lang] is a function that matches a string lang with a langauge that the translation API supports
@param lang The string that is to be matched with the supported API languages 
@return A string containing the encoding of the API language
@precond [lang] must be a non-empty string
@postcond The result is of type string *)

let lang_matcher lang =
  match lang with
  | "Azerbaijani" -> "az"
  | "Albanian" -> "sq"
  | "Amharic" -> "am"
  | "English" -> "en"
  | "Arabic" -> "ar"
  | "Armenian" -> "hy"
  | "Afrikaans" -> "af"
  | "Basque" -> "eu"
  | "Bashkir" -> "ba"
  | "Belarusian" -> "be"
  | "Bengal" -> "bn"
  | "Burmese" -> "my"
  | "Bulgarian" -> "bg"
  | "Bosnian" -> "bs"
  | "Welsh" -> "cy"
  | "Hungarian" -> "hu"
  | "Vietnamese" -> "vi"
  | "Haitian" -> "ht"
  | "Galician" -> "gl"
  | "Dutch" -> "nl"
  | "Hill Mari" -> "mrj"
  | "Greek" -> "el"
  | "Georgian" -> "ka"
  | "Gujarati" -> "gu"
  | "Danish" -> "da"
  | "Hebrew" -> "he"
  | "Yiddish" -> "yi"
  | "Indonesian" -> "id"
  | "Irish" -> "ga"
  | "Italian" -> "it"
  | "Icelandic" -> "is"
  | "Spanish" -> "es"
  | "Kazakh" -> "kk"
  | "Kannada" -> "kn"
  | "Catalan" -> "ca"
  | "Kirghiz" -> "ky"
  | "Chinese" -> "zh"
  | "Korean" -> "ko"
  | "Xhosa" -> "xh"
  | "Khmer" -> "km"
  | "Laotian" -> "lo"
  | "Latin" -> "la"
  | "Latvian" -> "lv"
  | "Lithuanian" -> "lt"
  | "Luxembourg" -> "lb"
  | "Malagasy" -> "mg"
  | "Malay" -> "ms"
  | "Malayalam" -> "ml"
  | "Maltese" -> "mt"
  | "Macedonian" -> "mk"
  | "Maori" -> "mi"
  | "Marathi" -> "mr"
  | "Mari" -> "mhr"
  | "Mongolian" -> "mn"
  | "German" -> "de"
  | "Nepalese" -> "ne"
  | "Norwegian" -> "no"
  | "Punjabi" -> "pa"
  | "Papiamento" -> "pap"
  | "Persian" -> "fa"
  | "Polish" -> "pl"
  | "Portuguese" -> "pt"
  | "Romanian" -> "ro"
  | "Russian" -> "ru"
  | "Cebuano" -> "ceb"
  | "Serbian" -> "sr"
  | "Sinhalese" -> "si"
  | "Slovak" -> "sk"
  | "Slovenian" -> "sl"
  | "Swahili" -> "sw"
  | "Sundanese" -> "su"
  | "Tajik" -> "tg"
  | "Thai" -> "th"
  | "Tagalog" -> "tl"
  | "Tamil" -> "ta"
  | "Tartar" -> "tt"
  | "Telugu" -> "te"
  | "Turkish" -> "tr"
  | "Udmurt" -> "udm"
  | "Uzbek" -> "uz"
  | "Ukrainian" -> "uk"
  | "Urdu" -> "ur"
  | "Finnish" -> "fi"
  | "French" -> "fr"
  | "Hindi" -> "hi"
  | "Croatian" -> "hr"
  | "Czech" -> "cs"
  | "Swedish" -> "sv"
  | "Scottish" -> "gd"
  | "Estonian" -> "et"
  | "Esperanto" -> "eo"
  | "Javanese" -> "jv"
  | "Japanese" -> "ja"
  | _ -> "unsupported"
