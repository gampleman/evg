module PaintTest exposing (gradientTests, solidTests, suite)

import Color
import Evg
import Evg.Paint as Paint
import Expect
import Html.Attributes
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Evg.Paint"
        [ solidTests
        , gradientTests
        ]


solidTests : Test
solidTests =
    describe "Solid colors"
        [ test "solid fill applies color as css string" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect [ Evg.fill (Paint.solid (Color.rgb255 255 0 0)) ]
                        { x = 0, y = 0, width = 100, height = 100 }
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "rect" ]
                    |> Query.has [ Selector.attribute (Html.Attributes.attribute "fill" (Color.toCssString (Color.rgb255 255 0 0))) ]
        , test "solid fill with alpha" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect [ Evg.fill (Paint.solid (Color.rgba 0 0.5 1 0.5)) ]
                        { x = 0, y = 0, width = 100, height = 100 }
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "rect" ]
                    |> Query.has [ Selector.attribute (Html.Attributes.attribute "fill" (Color.toCssString (Color.rgba 0 0.5 1 0.5))) ]
        , test "none fill" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect [ Evg.fill Paint.none ]
                        { x = 0, y = 0, width = 100, height = 100 }
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "rect" ]
                    |> Query.has [ Selector.attribute (Html.Attributes.attribute "fill" "none") ]
        ]


gradientTests : Test
gradientTests =
    describe "Gradients"
        [ test "linear gradient creates a linearGradient def" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect
                        [ Evg.fill
                            (Paint.linearGradient ( 0, 0 )
                                ( 1, 0 )
                                [ Paint.stop 0 (Color.rgb255 255 0 0)
                                , Paint.stop 1 (Color.rgb255 0 0 255)
                                ]
                            )
                        ]
                        { x = 0, y = 0, width = 100, height = 100 }
                    ]
                    |> Query.fromHtml
                    |> Query.has [ Selector.containing [ Selector.tag "linearGradient" ] ]
        , test "linear gradient def has correct coordinates" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect
                        [ Evg.fill
                            (Paint.linearGradient ( 0, 0 )
                                ( 1, 0 )
                                [ Paint.stop 0 (Color.rgb255 255 0 0)
                                , Paint.stop 1 (Color.rgb255 0 0 255)
                                ]
                            )
                        ]
                        { x = 0, y = 0, width = 100, height = 100 }
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "linearGradient" ]
                    |> Query.has
                        [ Selector.attribute (Html.Attributes.attribute "x1" "0")
                        , Selector.attribute (Html.Attributes.attribute "y1" "0")
                        , Selector.attribute (Html.Attributes.attribute "x2" "1")
                        , Selector.attribute (Html.Attributes.attribute "y2" "0")
                        ]
        , test "radial gradient creates a radialGradient def" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.circle
                        [ Evg.fill
                            (Paint.radialGradient ( 0.5, 0.5 )
                                40
                                [ Paint.stop 0 (Color.rgb255 255 255 255)
                                , Paint.stop 1 (Color.rgb255 0 0 0)
                                ]
                            )
                        ]
                        { r = 40, center = ( 50, 50 ) }
                    ]
                    |> Query.fromHtml
                    |> Query.has [ Selector.containing [ Selector.tag "radialGradient" ] ]
        , test "gradient stops have correct attributes" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect
                        [ Evg.fill
                            (Paint.linearGradient ( 0, 0 )
                                ( 1, 0 )
                                [ Paint.stop 0 (Color.rgb255 255 0 0)
                                , Paint.stop 1 (Color.rgb255 0 0 255)
                                ]
                            )
                        ]
                        { x = 0, y = 0, width = 100, height = 100 }
                    ]
                    |> Query.fromHtml
                    |> Query.findAll [ Selector.tag "stop" ]
                    |> Query.count (Expect.equal 2)
        ]
