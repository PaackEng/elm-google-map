module Internals.Polygon exposing
    ( Polygon
    , init
    , onClick
    , toHtml
    , withClosedMode
    , withFillColor
    , withFillOpacity
    , withStrokeColor
    , withStrokeWeight
    , withZIndex
    )

import Html exposing (Html, node)
import Html.Attributes exposing (attribute)
import Html.Events exposing (on)
import Internals.Helpers exposing (addIf, maybeAdd)
import Json.Decode as Decode


type alias Latitude =
    Float


type alias Longitude =
    Float


type Polygon msg
    = Polygon (Options msg)


type alias Options msg =
    { points : List ( Latitude, Longitude )
    , fillColor : String
    , fillOpacity : Float
    , strokeColor : String
    , strokeWeight : Int
    , zIndex : Int
    , isClosed : Bool
    , onClick : Maybe msg
    }


init : List ( Latitude, Longitude ) -> Polygon msg
init points =
    Polygon
        { points = points
        , fillColor = ""
        , fillOpacity = 0
        , strokeColor = "black"
        , strokeWeight = 3
        , zIndex = 0
        , isClosed = False
        , onClick = Nothing
        }


withFillColor : String -> Polygon msg -> Polygon msg
withFillColor color (Polygon polygon) =
    Polygon { polygon | fillColor = color }


withFillOpacity : Float -> Polygon msg -> Polygon msg
withFillOpacity opacity (Polygon polygon) =
    Polygon { polygon | fillOpacity = opacity }


withStrokeWeight : Int -> Polygon msg -> Polygon msg
withStrokeWeight strokeWeight (Polygon polygon) =
    Polygon { polygon | strokeWeight = strokeWeight }


withStrokeColor : String -> Polygon msg -> Polygon msg
withStrokeColor strokeColor (Polygon polygon) =
    Polygon { polygon | strokeColor = strokeColor }


withZIndex : Int -> Polygon msg -> Polygon msg
withZIndex zIndex (Polygon polygon) =
    Polygon { polygon | zIndex = zIndex }


onClick : msg -> Polygon msg -> Polygon msg
onClick msg (Polygon polygon) =
    Polygon { polygon | onClick = Just msg }


withClosedMode : Polygon msg -> Polygon msg
withClosedMode (Polygon polygon) =
    Polygon { polygon | isClosed = True }


toHtml : Polygon msg -> Html msg
toHtml (Polygon polygon) =
    let
        points =
            List.map buildPointHtml polygon.points

        attrs =
            [ attribute "fill-color" polygon.fillColor
            , attribute "fill-opacity" (String.fromFloat polygon.fillOpacity)
            , attribute "stroke-weight" (String.fromInt polygon.strokeWeight)
            , attribute "stroke-color" polygon.strokeColor
            , attribute "z-index" (String.fromInt polygon.zIndex)
            ]
                |> addIf polygon.isClosed (attribute "closed" "")
                |> maybeAdd
                    (\msg ->
                        [ on "google-map-poly-click" (Decode.succeed msg)
                        , attribute "click-events" "true"
                        , attribute "clickable" "true"
                        ]
                    )
                    polygon.onClick
    in
    node "google-map-poly"
        attrs
        points


buildPointHtml : ( Latitude, Longitude ) -> Html msg
buildPointHtml ( latitude, longitude ) =
    node "google-map-point"
        [ attribute "latitude" (String.fromFloat latitude)
        , attribute "longitude" (String.fromFloat longitude)
        ]
        []
