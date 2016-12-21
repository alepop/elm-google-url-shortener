module Shortener exposing (ApiKey, Url, RequestData, Response, send)

{-| This library is an interface to Google Shortener Api

# Types
@docs ApiKey, Url, RequestData, Response

# Sending a request
@docs send
-}

import Http
import Json.Decode as Decode
import Json.Encode exposing (encode, object, string)


-- Types


{-| Google API key
-}
type alias ApiKey =
    String


{-| Alias for url string
-}
type alias Url =
    String


{-| Request data for Shortener Api
-}
type alias RequestData =
    { key : ApiKey
    , longUrl : Url
    }


{-| Shortener Api responce
  - `id` is the short URL that expands to the long URL you provided. If your request includes an auth token, then this URL will be unique. If not, then it might be reused from a previous request to shorten the same URL.
  - `longUrl` s the long URL to which it expands. In most cases, this will be the same as the URL you provided. In some cases, the server may canonicalize the URL
-}
type alias Response =
    { kind : String
    , id : String
    , longUrl : Url
    }



-- Decoder


responceDecoder : Decode.Decoder Response
responceDecoder =
    Decode.map3 Response
        (Decode.field "kind" Decode.string)
        (Decode.field "id" Decode.string)
        (Decode.field "longUrl" Decode.string)



-- Encoder


encodeData : RequestData -> Http.Body
encodeData { longUrl } =
    let
        value =
            object [ ( "longUrl", string longUrl ) ]
    in
        Http.jsonBody value



-- Request Builder


requestBuilder : ApiKey -> Url -> RequestData
requestBuilder key url =
    RequestData key url


shortenUrl : ApiKey -> String
shortenUrl key =
    "https://www.googleapis.com/urlshortener/v1/url?key=" ++ key



--Send Request


{-| Send request to Google Shortener Api
-}
send : (Result Http.Error Response -> msg) -> RequestData -> Cmd msg
send message data =
    Http.post (shortenUrl data.key) (encodeData data) responceDecoder
        |> Http.send message
