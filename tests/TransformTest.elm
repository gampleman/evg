module TransformTest exposing (suite)

import Evg
import Evg.Transform as Transform
import Html.Attributes
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Evg.Transform"
        [ test "translate adds transform attribute" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect [ Transform.translate 50 30 ]
                        { x = 0, y = 0, width = 20, height = 20 }
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "rect" ]
                    |> Query.has [ Selector.attribute (Html.Attributes.attribute "transform" "translate(50 30)") ]
        , test "rotate adds rotate transform" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect [ Transform.rotate 45 ]
                        { x = 0, y = 0, width = 20, height = 20 }
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "rect" ]
                    |> Query.has [ Selector.attribute (Html.Attributes.attribute "transform" "rotate(45)") ]
        , test "rotateAround includes center point" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect [ Transform.rotateAround 90 ( 50, 50 ) ]
                        { x = 0, y = 0, width = 100, height = 100 }
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "rect" ]
                    |> Query.has [ Selector.attribute (Html.Attributes.attribute "transform" "rotate(90 50 50)") ]
        , test "scale applies both factors" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect [ Transform.scale 2 0.5 ]
                        { x = 0, y = 0, width = 20, height = 20 }
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "rect" ]
                    |> Query.has [ Selector.attribute (Html.Attributes.attribute "transform" "scale(2 0.5)") ]
        , test "scaleUniform uses same factor for both axes" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect [ Transform.scaleUniform 3 ]
                        { x = 0, y = 0, width = 10, height = 10 }
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "rect" ]
                    |> Query.has [ Selector.attribute (Html.Attributes.attribute "transform" "scale(3 3)") ]
        , test "transforms combines multiple transforms" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect
                        [ Transform.translate 10 20
                        , Transform.rotate 45
                        ]
                        { x = 0, y = 0, width = 20, height = 20 }
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "rect" ]
                    |> Query.has [ Selector.attribute (Html.Attributes.attribute "transform" "translate(10 20) rotate(45)") ]
        , test "separate transform attributes compose into one" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect
                        [ Transform.translate 10 20
                        , Transform.rotate 45
                        , Transform.scaleUniform 2
                        ]
                        { x = 0, y = 0, width = 20, height = 20 }
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "rect" ]
                    |> Query.has [ Selector.attribute (Html.Attributes.attribute "transform" "translate(10 20) rotate(45) scale(2 2)") ]
        ]
