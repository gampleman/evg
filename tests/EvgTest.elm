module EvgTest exposing (accessibilityTests, pathTests, shapeTests, suite)

import Evg
import Evg.Path exposing (Path(..), PathSegment(..))
import Expect
import Html.Attributes
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Evg"
        [ accessibilityTests
        , shapeTests
        , pathTests
        ]



-- Accessibility


accessibilityTests : Test
accessibilityTests =
    describe "Accessibility"
        [ test "title is rendered as a <title> child element" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.circle [ Evg.title "A red circle" ] { r = 50, center = ( 50, 50 ) }
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "circle" ]
                    |> Query.has [ Selector.containing [ Selector.tag "title", Selector.text "A red circle" ] ]
        , test "desc is rendered as a <desc> child element" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect [ Evg.desc "A decorative rectangle" ] { x = 0, y = 0, width = 100, height = 100 }
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "rect" ]
                    |> Query.has [ Selector.containing [ Selector.tag "desc", Selector.text "A decorative rectangle" ] ]
        , test "title and desc can be used together" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.circle
                        [ Evg.title "Circle"
                        , Evg.desc "A circle used for decoration"
                        ]
                        { r = 50, center = ( 50, 50 ) }
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "circle" ]
                    |> Query.has
                        [ Selector.containing [ Selector.tag "title", Selector.text "Circle" ]
                        , Selector.containing [ Selector.tag "desc", Selector.text "A circle used for decoration" ]
                        ]
        , test "title works on groups" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.group [ Evg.title "Group of shapes" ]
                        [ Evg.circle [] { r = 10, center = ( 50, 50 ) }
                        ]
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "g" ]
                    |> Query.has [ Selector.containing [ Selector.tag "title", Selector.text "Group of shapes" ] ]
        , test "title works on lines" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.line [ Evg.title "A diagonal" ] ( 0, 0 ) ( 100, 100 )
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "line" ]
                    |> Query.has [ Selector.containing [ Selector.tag "title", Selector.text "A diagonal" ] ]
        , test "title works on paths" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.path [ Evg.title "A curve" ] [ M ( 0, 0 ) [ L ( 100, 100 ) ] ]
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "path" ]
                    |> Query.has [ Selector.containing [ Selector.tag "title", Selector.text "A curve" ] ]
        ]



-- Basic Shapes


shapeTests : Test
shapeTests =
    describe "Shapes"
        [ test "line renders with default black stroke" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.line [] ( 10, 20 ) ( 90, 80 ) ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "line" ]
                    |> Query.has
                        [ Selector.attribute (Html.Attributes.attribute "x1" "10")
                        , Selector.attribute (Html.Attributes.attribute "y1" "20")
                        , Selector.attribute (Html.Attributes.attribute "x2" "90")
                        , Selector.attribute (Html.Attributes.attribute "y2" "80")
                        , Selector.attribute (Html.Attributes.attribute "stroke" "black")
                        ]
        , test "line stroke can be overridden" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.line [ Evg.strokeStr "red" ] ( 0, 0 ) ( 100, 100 ) ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "line" ]
                    |> Query.has [ Selector.attribute (Html.Attributes.attribute "stroke" "red") ]
        , test "rect renders with position and dimensions" <|
            \_ ->
                Evg.svg []
                    { width = 200, height = 200 }
                    [ Evg.rect [ Evg.fillStr "blue" ] { x = 10, y = 20, width = 80, height = 60 } ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "rect" ]
                    |> Query.has
                        [ Selector.attribute (Html.Attributes.attribute "x" "10")
                        , Selector.attribute (Html.Attributes.attribute "y" "20")
                        , Selector.attribute (Html.Attributes.attribute "width" "80")
                        , Selector.attribute (Html.Attributes.attribute "height" "60")
                        , Selector.attribute (Html.Attributes.attribute "fill" "blue")
                        ]
        , test "circle renders with radius and center" <|
            \_ ->
                Evg.svg []
                    { width = 200, height = 200 }
                    [ Evg.circle [ Evg.fillStr "red" ] { r = 30, center = ( 100, 100 ) } ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "circle" ]
                    |> Query.has
                        [ Selector.attribute (Html.Attributes.attribute "r" "30")
                        , Selector.attribute (Html.Attributes.attribute "cx" "100")
                        , Selector.attribute (Html.Attributes.attribute "cy" "100")
                        , Selector.attribute (Html.Attributes.attribute "fill" "red")
                        ]
        , test "polygon renders points" <|
            \_ ->
                Evg.svg []
                    { width = 200, height = 200 }
                    [ Evg.polygon [ Evg.fillStr "green" ] [ ( 50, 0 ), ( 100, 100 ), ( 0, 100 ) ] ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "polygon" ]
                    |> Query.has
                        [ Selector.attribute (Html.Attributes.attribute "points" "50,0 100,100 0,100")
                        , Selector.attribute (Html.Attributes.attribute "fill" "green")
                        ]
        , test "text renders with content and position" <|
            \_ ->
                Evg.svg []
                    { width = 200, height = 200 }
                    [ Evg.text [ Evg.fillStr "black" ] { x = 10, y = 50, anchor = Evg.Middle } "Hello" ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "text" ]
                    |> Query.has
                        [ Selector.text "Hello"
                        , Selector.attribute (Html.Attributes.attribute "text-anchor" "middle")
                        ]
        , test "svg sets viewBox and dimensions" <|
            \_ ->
                Evg.svg [] { width = 300, height = 200 } []
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.attribute (Html.Attributes.attribute "viewBox" "0 0 300 200")
                        , Selector.attribute (Html.Attributes.attribute "width" "300")
                        , Selector.attribute (Html.Attributes.attribute "height" "200")
                        ]
        ]



-- Paths


pathTests : Test
pathTests =
    describe "Evg.Path"
        [ test "toString produces correct M L output" <|
            \_ ->
                M ( 10, 20 ) [ L ( 30, 40 ) ]
                    |> Evg.Path.toString
                    |> Expect.equal "M10 20L30 40"
        , test "toString handles all segment types" <|
            \_ ->
                M ( 0, 0 )
                    [ H 50
                    , V 50
                    , C ( 10, 10 ) ( 20, 20 ) ( 30, 30 )
                    , S ( 40, 40 ) ( 50, 50 )
                    , Q ( 60, 60 ) ( 70, 70 )
                    , T ( 80, 80 )
                    , A 10 10 0 True False ( 90, 90 )
                    , Z
                    ]
                    |> Evg.Path.toString
                    |> Expect.equal "M0 0H50V50C10 10 20 20 30 30S40 40 50 50Q60 60 70 70T80 80A10 10 0 1 0 90 90Z"
        , test "endPoint returns last point" <|
            \_ ->
                [ M ( 0, 0 ) [ L ( 50, 60 ), L ( 100, 200 ) ] ]
                    |> Evg.Path.endPoint
                    |> Expect.equal ( 100, 200 )
        , test "endPoint follows H and V" <|
            \_ ->
                [ M ( 10, 20 ) [ H 50, V 80 ] ]
                    |> Evg.Path.endPoint
                    |> Expect.equal ( 50, 80 )
        , test "startPoint returns move point" <|
            \_ ->
                [ M ( 15, 25 ) [ L ( 50, 60 ) ] ]
                    |> Evg.Path.startPoint
                    |> Expect.equal ( 15, 25 )
        , test "close appends Z" <|
            \_ ->
                [ M ( 0, 0 ) [ L ( 100, 0 ), L ( 100, 100 ) ] ]
                    |> Evg.Path.close
                    |> List.map Evg.Path.toString
                    |> String.concat
                    |> Expect.equal "M0 0L100 0L100 100Z"
        ]
