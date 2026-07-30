module FromSvgTest exposing (suite)

import Evg
import Evg.Advanced as Advanced
import Evg.Animate as Animate
import Evg.Clip as Clip
import Expect
import Html.Attributes
import Svg
import Svg.Attributes
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


icon : String -> Svg.Svg msg
icon color =
    Svg.g []
        [ Svg.path [ Svg.Attributes.d "M0 0 L10 10", Svg.Attributes.stroke color ] [] ]


suite : Test
suite =
    describe "Advanced.fromSvg"
        [ test "embedded elm/svg renders into the drawing" <|
            \_ ->
                Evg.svg []
                    { width = 50, height = 50 }
                    [ Evg.circle [] { r = 5, center = ( 25, 25 ) }
                    , Advanced.fromSvg { id = "icon", svg = icon "red", fallback = Advanced.notSupported }
                    ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.findAll [ Selector.tag "path" ] >> Query.count (Expect.equal 1)
                        , Query.findAll [ Selector.tag "circle" ] >> Query.count (Expect.equal 1)
                        ]
        , test "distinct keys give distinct clip stencils" <|
            \_ ->
                Evg.svg []
                    { width = 50, height = 50 }
                    [ Evg.rect [ Clip.clip (Advanced.fromSvg { id = "a", svg = icon "red", fallback = Evg.none }) ]
                        { x = 0, y = 0, width = 20, height = 20 }
                    , Evg.rect [ Clip.clip (Advanced.fromSvg { id = "b", svg = icon "blue", fallback = Evg.none }) ]
                        { x = 20, y = 0, width = 20, height = 20 }
                    ]
                    |> Query.fromHtml
                    |> Query.findAll [ Selector.tag "clipPath" ]
                    |> Query.count (Expect.equal 2)
        , test "toString emits the fallback in place of the embedded svg" <|
            \_ ->
                let
                    str =
                        Evg.toString []
                            { width = 50, height = 50 }
                            [ Advanced.fromSvg
                                { id = "icon"
                                , svg = icon "red"
                                , fallback = Advanced.notSupported
                                }
                            ]
                in
                Expect.all
                    [ -- The opaque markup itself cannot be recovered.
                      \_ -> String.contains "<path" str |> Expect.equal False

                    -- But the stand-in is there, so the file is not silently
                    -- missing the graphic.
                    , \_ -> String.contains "NOT SUPPORTED" str |> Expect.equal True
                    ]
                    ()
        , test "a custom fallback is used when given" <|
            \_ ->
                Evg.toString []
                    { width = 50, height = 50 }
                    [ Advanced.fromSvg
                        { id = "icon"
                        , svg = icon "red"
                        , fallback =
                            Evg.circle [ Evg.fillStr "grey" ]
                                { r = 10, center = ( 25, 25 ) }
                        }
                    ]
                    |> String.contains "<circle r=\"10\""
                    |> Expect.equal True
        , test "Evg.none as fallback leaves nothing behind" <|
            \_ ->
                Evg.toString []
                    { width = 50, height = 50 }
                    [ Advanced.fromSvg
                        { id = "icon", svg = icon "red", fallback = Evg.none }
                    ]
                    |> Expect.equal
                        ("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 50 50\""
                            ++ " width=\"50\" height=\"50\"></svg>"
                        )
        , test "wrapping in a group applies attributes to embedded graphics" <|
            \_ ->
                Evg.svg []
                    { width = 50, height = 50 }
                    [ Evg.group [ Evg.opacity 0.5 ] [ Advanced.fromSvg { id = "logo", svg = icon "red", fallback = Advanced.notSupported } ] ]
                    |> Query.fromHtml
                    |> Query.find
                        [ Selector.tag "g"
                        , Selector.attribute (Html.Attributes.attribute "opacity" "0.5")
                        ]
                    |> Query.has [ Selector.tag "g" ]
        , test "animating embedded graphics draws the fallback instead" <|
            -- Animation works by putting an element inside the animated
            -- shape, which is impossible for an opaque value, so the
            -- fallback stands in rather than the effect being dropped.
            \_ ->
                Evg.svg []
                    { width = 50, height = 50 }
                    [ Advanced.fromSvg
                        { id = "icon"
                        , svg = icon "red"
                        , fallback = Advanced.notSupported
                        }
                        |> Animate.rotate [ Animate.duration 2 ]
                            [ ( 1, Animate.easeLinear, 360 ) ]
                    ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.findAll [ Selector.text "NOT SUPPORTED" ]
                            >> Query.count (Expect.equal 1)
                        , Query.findAll [ Selector.tag "path" ]
                            >> Query.count (Expect.equal 0)
                        ]
        ]
