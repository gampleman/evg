module PerformanceTest exposing (suite)

import Color
import Evg
import Evg.Clip as Clip
import Evg.Paint as Paint
import Evg.Performance as Performance
import Expect
import Html.Attributes
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


gradientRect : Evg.Evg msg
gradientRect =
    Evg.rect
        [ Evg.fill
            (Paint.linearGradient
                ( 0, 0 )
                ( 1, 0 )
                [ Paint.stop 0 (Color.rgb 1 0 0)
                , Paint.stop 1 (Color.rgb 0 0 1)
                ]
            )
        ]
        { x = 0, y = 0, width = 100, height = 100 }


suite : Test
suite =
    describe "Evg.Performance"
        [ test "defs inside a lazy subtree are rendered" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Performance.lazy "chart" (\_ -> gradientRect) () ]
                    |> Query.fromHtml
                    |> Query.findAll [ Selector.tag "linearGradient" ]
                    |> Query.count (Expect.equal 1)
        , test "differently-keyed lazy clip stencils get distinct clipPath defs" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect
                        [ Clip.clip
                            (Performance.lazy "hole-circle"
                                (\_ -> Evg.circle [] { r = 10, center = ( 10, 10 ) })
                                ()
                            )
                        ]
                        { x = 0, y = 0, width = 50, height = 50 }
                    , Evg.rect
                        [ Clip.clip
                            (Performance.lazy "hole-square"
                                (\_ -> Evg.rect [] { x = 0, y = 0, width = 5, height = 5 })
                                ()
                            )
                        ]
                        { x = 50, y = 0, width = 50, height = 50 }
                    ]
                    |> Query.fromHtml
                    |> Query.findAll [ Selector.tag "clipPath" ]
                    |> Query.count (Expect.equal 2)
        , test "asDef stamps render a symbol def plus use references with per-stamp attributes" <|
            \_ ->
                let
                    useIcon =
                        Performance.asDef
                            (Evg.circle [] { r = 10, center = ( 12, 12 ) })
                in
                Evg.svg []
                    { width = 100, height = 100 }
                    [ useIcon [] { x = 10, y = 10, width = 24, height = 24 }
                    , useIcon
                        [ Evg.opacity 0.5 ]
                        { x = 50, y = 10, width = 24, height = 24 }
                    ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.findAll [ Selector.tag "symbol" ]
                            >> Query.count (Expect.equal 1)
                        , Query.findAll [ Selector.tag "use" ]
                            >> Query.count (Expect.equal 2)
                        , Query.findAll
                            [ Selector.tag "use"
                            , Selector.attribute (Html.Attributes.attribute "opacity" "0.5")
                            ]
                            >> Query.count (Expect.equal 1)
                        ]
        , test "groups with same attributes but different children get distinct clipPath defs" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect
                        [ Clip.clip
                            (Evg.group []
                                [ Evg.circle [] { r = 10, center = ( 10, 10 ) } ]
                            )
                        ]
                        { x = 0, y = 0, width = 50, height = 50 }
                    , Evg.rect
                        [ Clip.clip
                            (Evg.group []
                                [ Evg.rect [] { x = 0, y = 0, width = 5, height = 5 } ]
                            )
                        ]
                        { x = 50, y = 0, width = 50, height = 50 }
                    ]
                    |> Query.fromHtml
                    |> Query.findAll [ Selector.tag "clipPath" ]
                    |> Query.count (Expect.equal 2)
        ]
