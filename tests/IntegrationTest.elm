module IntegrationTest exposing (suite)

import Color
import Evg
import Evg.Clip as Clip
import Evg.Filter as Filter
import Evg.Marker as Marker
import Evg.Paint as Paint
import Evg.Path exposing (Path(..), PathSegment(..))
import Evg.Transform as Transform
import Html.Attributes
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Cross-module integration"
        [ test "filter + fill on a circle" <|
            \_ ->
                let
                    blur =
                        Filter.sourceGraphic |> Filter.gaussianBlur 3
                in
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.circle [ Evg.fillStr "red", Evg.filter blur ]
                        { r = 30, center = ( 50, 50 ) }
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "circle" ]
                    |> Query.has
                        [ Selector.attribute (Html.Attributes.attribute "fill" "red")
                        ]
        , test "transform + stroke on a line" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.line [ Evg.strokeStr "blue", Transform.rotate 45 ]
                        ( 10, 50 )
                        ( 90, 50 )
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "line" ]
                    |> Query.has
                        [ Selector.attribute (Html.Attributes.attribute "transform" "rotate(45)")
                        , Selector.attribute (Html.Attributes.attribute "stroke" "blue")
                        ]
        , test "clip + gradient fill on a rect" <|
            \_ ->
                let
                    gradient =
                        Paint.linearGradient ( 0, 0 )
                            ( 1, 0 )
                            [ Paint.stop 0 (Color.rgb255 255 0 0)
                            , Paint.stop 1 (Color.rgb255 0 0 255)
                            ]
                in
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect
                        [ Evg.fill gradient
                        , Clip.clip (Evg.circle [] { r = 30, center = ( 50, 50 ) })
                        ]
                        { x = 0, y = 0, width = 100, height = 100 }
                    ]
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.containing [ Selector.tag "linearGradient" ]
                        , Selector.containing [ Selector.tag "clipPath" ]
                        ]
        , test "stroke details + marker on a path" <|
            \_ ->
                let
                    dot =
                        Marker.marker []
                            { width = 6, height = 6, refX = 3, refY = 3 }
                            Marker.AutoOrientation
                            (Evg.circle [ Evg.fillStr "black" ] { r = 3, center = ( 3, 3 ) })
                in
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.path
                        [ Evg.strokeStr "black"
                        , Evg.fillStr "none"
                        , Evg.dashPattern [ 5, 3 ]
                        , Evg.linecapRound
                        , Marker.markerEnd dot
                        ]
                        [ M ( 10, 50 ) [ L ( 90, 50 ) ] ]
                    ]
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.containing [ Selector.tag "marker" ]
                        ]
        , test "multiple transforms + opacity on a group" <|
            \_ ->
                Evg.svg []
                    { width = 200, height = 200 }
                    [ Evg.group
                        [ Evg.opacity 0.5
                        , Transform.translate 50 50
                        , Transform.rotate 30
                        ]
                        [ Evg.rect [ Evg.fillStr "green" ]
                            { x = 0, y = 0, width = 40, height = 40 }
                        ]
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "g" ]
                    |> Query.has
                        [ Selector.attribute (Html.Attributes.attribute "opacity" "0.5")
                        , Selector.attribute (Html.Attributes.attribute "transform" "translate(50 50) rotate(30)")
                        ]
        , test "Evg.fill and Evg.stroke work on shapes" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.circle
                        [ Evg.fill (Paint.solid (Color.rgb255 255 0 0))
                        , Evg.stroke (Paint.solid (Color.rgb255 0 0 0))
                        ]
                        { r = 40, center = ( 50, 50 ) }
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "circle" ]
                    |> Query.has
                        [ Selector.attribute (Html.Attributes.attribute "fill" (Color.toCssString (Color.rgb255 255 0 0)))
                        , Selector.attribute (Html.Attributes.attribute "stroke" (Color.toCssString (Color.rgb255 0 0 0)))
                        ]
        ]
