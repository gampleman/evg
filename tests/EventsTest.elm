module EventsTest exposing (suite)

import Evg
import Evg.Events as Events
import Evg.Transform as Transform
import Json.Encode as Encode
import Test exposing (Test, describe, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector


{-| Build a synthetic pointer event payload. `currentTarget` carries the SVG
root geometry the decoder reads to convert offset pixels into scene coordinates.
-}
pointerEvent :
    { offsetX : Float
    , offsetY : Float
    , clientX : Float
    , clientY : Float
    , viewBox : { x : Float, y : Float, width : Float, height : Float }
    , clientWidth : Float
    , clientHeight : Float
    }
    -> Encode.Value
pointerEvent e =
    Encode.object
        [ ( "offsetX", Encode.float e.offsetX )
        , ( "offsetY", Encode.float e.offsetY )
        , ( "clientX", Encode.float e.clientX )
        , ( "clientY", Encode.float e.clientY )
        , ( "pointerType", Encode.string "mouse" )
        , ( "pointerId", Encode.int 1 )
        , ( "isPrimary", Encode.bool True )
        , ( "button", Encode.int 0 )
        , ( "shiftKey", Encode.bool False )
        , ( "ctrlKey", Encode.bool False )
        , ( "altKey", Encode.bool False )
        , ( "metaKey", Encode.bool False )
        , ( "currentTarget"
          , Encode.object
                [ ( "clientWidth", Encode.float e.clientWidth )
                , ( "clientHeight", Encode.float e.clientHeight )
                , ( "viewBox"
                  , Encode.object
                        [ ( "baseVal"
                          , Encode.object
                                [ ( "x", Encode.float e.viewBox.x )
                                , ( "y", Encode.float e.viewBox.y )
                                , ( "width", Encode.float e.viewBox.width )
                                , ( "height", Encode.float e.viewBox.height )
                                ]
                          )
                        ]
                  )
                ]
          )
        ]


suite : Test
suite =
    describe "Evg.Events coordinate conversion"
        [ test "handler on the root svg reports scene coordinates when unscaled" <|
            \_ ->
                Evg.svg [ Events.onClick identity ]
                    { width = 100, height = 100 }
                    []
                    |> Query.fromHtml
                    |> Event.simulate
                        (Event.custom "click"
                            (pointerEvent
                                { offsetX = 30
                                , offsetY = 40
                                , clientX = 30
                                , clientY = 40
                                , viewBox = { x = 0, y = 0, width = 100, height = 100 }
                                , clientWidth = 100
                                , clientHeight = 100
                                }
                            )
                        )
                    |> Event.expect ( 30, 40 )
        , test "CSS-scaled svg: offset pixels are converted back to scene units" <|
            -- The element is rendered at 200x200 CSS px but its viewBox is
            -- 100x100, so an offset of (60, 60) is scene (30, 30).
            \_ ->
                Evg.svg [ Events.onClick identity ]
                    { width = 100, height = 100 }
                    []
                    |> Query.fromHtml
                    |> Event.simulate
                        (Event.custom "click"
                            (pointerEvent
                                { offsetX = 60
                                , offsetY = 60
                                , clientX = 60
                                , clientY = 60
                                , viewBox = { x = 0, y = 0, width = 100, height = 100 }
                                , clientWidth = 200
                                , clientHeight = 200
                                }
                            )
                        )
                    |> Event.expect ( 30, 30 )
        , test "non-zero viewBox origin is added to the scene coordinate" <|
            \_ ->
                Evg.svg [ Events.onClick identity ]
                    { width = 100, height = 100 }
                    []
                    |> Query.fromHtml
                    |> Event.simulate
                        (Event.custom "click"
                            (pointerEvent
                                { offsetX = 10
                                , offsetY = 10
                                , clientX = 10
                                , clientY = 10
                                , viewBox = { x = 50, y = 20, width = 100, height = 100 }
                                , clientWidth = 100
                                , clientHeight = 100
                                }
                            )
                        )
                    |> Event.expect ( 60, 30 )
        , test "local coordinates undo a translate on the handler's group" <|
            -- The circle sits inside a group translated by (50, 50). A click at
            -- scene (60, 70) should report local (10, 20). We route the
            -- Pointer's `.local` field through as the message tuple so we can
            -- assert on it without comparing the opaque Frame.
            \_ ->
                Evg.svg []
                    { width = 200, height = 200 }
                    [ Evg.group [ Transform.translate 50 50 ]
                        [ Evg.circle [ Events.onClickWith .local ]
                            { r = 100, center = ( 10, 20 ) }
                        ]
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "circle" ]
                    |> Event.simulate
                        (Event.custom "click"
                            (pointerEvent
                                { offsetX = 60
                                , offsetY = 70
                                , clientX = 60
                                , clientY = 70
                                , viewBox = { x = 0, y = 0, width = 200, height = 200 }
                                , clientWidth = 200
                                , clientHeight = 200
                                }
                            )
                        )
                    |> Event.expect ( 10, 20 )
        , test "local coordinates undo a uniform scale on the handler's group" <|
            -- Group scaled 2x: scene (60, 80) is local (30, 40).
            \_ ->
                Evg.svg []
                    { width = 200, height = 200 }
                    [ Evg.group [ Transform.scaleUniform 2 ]
                        [ Evg.circle [ Events.onClickWith .local ]
                            { r = 100, center = ( 30, 40 ) }
                        ]
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "circle" ]
                    |> Event.simulate
                        (Event.custom "click"
                            (pointerEvent
                                { offsetX = 60
                                , offsetY = 80
                                , clientX = 60
                                , clientY = 80
                                , viewBox = { x = 0, y = 0, width = 200, height = 200 }
                                , clientWidth = 200
                                , clientHeight = 200
                                }
                            )
                        )
                    |> Event.expect ( 30, 40 )
        , test "scene coordinate is reported under a transform, alongside local" <|
            -- Same 2x-scaled group: the same click reports scene (60, 80).
            \_ ->
                Evg.svg []
                    { width = 200, height = 200 }
                    [ Evg.group [ Transform.scaleUniform 2 ]
                        [ Evg.circle [ Events.onClickWith .scene ]
                            { r = 100, center = ( 30, 40 ) }
                        ]
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "circle" ]
                    |> Event.simulate
                        (Event.custom "click"
                            (pointerEvent
                                { offsetX = 60
                                , offsetY = 80
                                , clientX = 60
                                , clientY = 80
                                , viewBox = { x = 0, y = 0, width = 200, height = 200 }
                                , clientWidth = 200
                                , clientHeight = 200
                                }
                            )
                        )
                    |> Event.expect ( 60, 80 )
        ]
