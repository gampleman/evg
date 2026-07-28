module FilterTest exposing (suite)

import Evg
import Evg.Filter as Filter
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Evg.Filter"
        [ test "toAttribute creates a filter def and references it" <|
            \_ ->
                let
                    blur =
                        Filter.sourceGraphic
                            |> Filter.gaussianBlur 3
                in
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.circle [ Evg.filter blur ]
                        { r = 50, center = ( 50, 50 ) }
                    ]
                    |> Query.fromHtml
                    |> Query.has [ Selector.containing [ Selector.tag "filter" ] ]
        , test "filter def contains the expected primitives" <|
            \_ ->
                let
                    blur =
                        Filter.sourceGraphic
                            |> Filter.gaussianBlur 5
                in
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect [ Evg.filter blur ]
                        { x = 0, y = 0, width = 100, height = 100 }
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "filter" ]
                    |> Query.has [ Selector.containing [ Selector.tag "feGaussianBlur" ] ]
        , test "element references the filter with a url(#...) attribute" <|
            \_ ->
                let
                    blur =
                        Filter.sourceGraphic
                            |> Filter.gaussianBlur 3

                    html =
                        Evg.svg []
                            { width = 100, height = 100 }
                            [ Evg.circle [ Evg.filter blur ]
                                { r = 50, center = ( 50, 50 ) }
                            ]
                in
                html
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.containing [ Selector.tag "circle" ]
                        , Selector.containing [ Selector.tag "filter" ]
                        ]
        , test "compositeOver produces feComposite with over operator" <|
            \_ ->
                let
                    shadow =
                        Filter.sourceAlpha
                            |> Filter.gaussianBlur 2
                            |> Filter.offset 2 2
                            |> Filter.compositeOver Filter.sourceGraphic
                in
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect [ Evg.filter shadow ]
                        { x = 10, y = 10, width = 80, height = 80 }
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "filter" ]
                    |> Query.has
                        [ Selector.containing [ Selector.tag "feGaussianBlur" ]
                        , Selector.containing [ Selector.tag "feOffset" ]
                        , Selector.containing [ Selector.tag "feComposite" ]
                        ]
        , test "merge produces feMerge with child nodes" <|
            \_ ->
                let
                    merged =
                        Filter.merge
                            [ Filter.sourceAlpha |> Filter.gaussianBlur 3
                            , Filter.sourceGraphic
                            ]
                in
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect [ Evg.filter merged ]
                        { x = 0, y = 0, width = 100, height = 100 }
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "filter" ]
                    |> Query.has
                        [ Selector.containing [ Selector.tag "feMerge" ]
                        , Selector.containing [ Selector.tag "feMergeNode" ]
                        ]
        ]
