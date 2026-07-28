module AnimateTest exposing (suite)

import Evg
import Evg.Animate as Animate
import Evg.Path as Path
import Expect
import Html.Attributes
import Json.Encode as Encode
import Test exposing (Test, describe, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Evg.Animate"
        [ test "animate adds an <animate> child element" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.circle [ Evg.fillStr "red" ] { r = 20, center = ( 50, 50 ) }
                        |> Animate.animate [ Animate.repeatIndefinite ]
                            "r"
                            [ ( 0.5, Animate.easeInOut, "40" )
                            , ( 1.0, Animate.easeLinear, "20" )
                            ]
                    ]
                    |> Query.fromHtml
                    |> Query.has [ Selector.containing [ Selector.tag "animate" ] ]
        , test "animate element has correct attributeName" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect [ Evg.fillStr "blue" ] { x = 0, y = 0, width = 100, height = 100 }
                        |> Animate.animate []
                            "width"
                            [ ( 1.0, Animate.easeLinear, "200" )
                            , ( 2.0, Animate.easeLinear, "100" )
                            ]
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "animate" ]
                    |> Query.has
                        [ Selector.attribute (Html.Attributes.attribute "attributeName" "width") ]
        , test "animate with repeatIndefinite has correct repeatCount" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.circle [ Evg.fillStr "red" ] { r = 10, center = ( 50, 50 ) }
                        |> Animate.animate [ Animate.repeatIndefinite ]
                            "r"
                            [ ( 1.0, Animate.easeLinear, "30" )
                            ]
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "animate" ]
                    |> Query.has
                        [ Selector.attribute (Html.Attributes.attribute "repeatCount" "indefinite") ]
        , test "animate preserves the element's other children" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.circle [ Evg.fillStr "red", Evg.title "My circle" ]
                        { r = 20, center = ( 50, 50 ) }
                        |> Animate.animate [ Animate.repeatIndefinite ]
                            "r"
                            [ ( 1.0, Animate.easeLinear, "40" ) ]
                    ]
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.containing [ Selector.tag "title" ]
                        , Selector.containing [ Selector.tag "animate" ]
                        ]
        , test "keyframes generates animate elements for changing attrs" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Animate.keyframes [ Animate.repeatIndefinite ]
                        [ ( 0.0, Evg.circle [ Evg.fillStr "red" ] { r = 10, center = ( 50, 50 ) } )
                        , ( 1.0, Evg.circle [ Evg.fillStr "blue" ] { r = 40, center = ( 50, 50 ) } )
                        , ( 2.0, Evg.circle [ Evg.fillStr "red" ] { r = 10, center = ( 50, 50 ) } )
                        ]
                    ]
                    |> Query.fromHtml
                    |> Query.has [ Selector.containing [ Selector.tag "animate" ] ]
        , test "keyframes only animates attributes that change" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Animate.keyframes []
                        [ ( 0.0, Evg.circle [ Evg.fillStr "red" ] { r = 10, center = ( 50, 50 ) } )
                        , ( 1.0, Evg.circle [ Evg.fillStr "red" ] { r = 40, center = ( 50, 50 ) } )
                        ]
                    ]
                    |> Query.fromHtml
                    |> Query.findAll [ Selector.tag "animate" ]
                    |> Query.count (Expect.atLeast 1)
        , test "keyframes with incompatible frames uses visibility switching" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Animate.keyframes []
                        [ ( 0.0, Evg.circle [ Evg.fillStr "red" ] { r = 10, center = ( 50, 50 ) } )
                        , ( 1.0, Evg.rect [ Evg.fillStr "blue" ] { x = 0, y = 0, width = 50, height = 50 } )
                        ]
                    ]
                    |> Query.fromHtml
                    |> Query.has [ Selector.containing [ Selector.tag "animate" ] ]
        , test "segmented runs: circle-circle-rect-rect interpolates within runs" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Animate.keyframes []
                        [ ( 0.0, Evg.circle [ Evg.fillStr "red" ] { r = 10, center = ( 50, 50 ) } )
                        , ( 1.0, Evg.circle [ Evg.fillStr "blue" ] { r = 30, center = ( 50, 50 ) } )
                        , ( 2.0, Evg.rect [ Evg.fillStr "green" ] { x = 10, y = 10, width = 80, height = 80 } )
                        , ( 3.0, Evg.rect [ Evg.fillStr "yellow" ] { x = 20, y = 20, width = 60, height = 60 } )
                        ]
                    ]
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.containing [ Selector.tag "animate" ]
                        , Selector.containing [ Selector.tag "animate" ]
                        ]
        , test "all-compatible frames produce no visibility switching" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Animate.keyframes []
                        [ ( 0.0, Evg.circle [ Evg.fillStr "red" ] { r = 10, center = ( 50, 50 ) } )
                        , ( 1.0, Evg.circle [ Evg.fillStr "blue" ] { r = 40, center = ( 50, 50 ) } )
                        , ( 2.0, Evg.circle [ Evg.fillStr "green" ] { r = 20, center = ( 50, 50 ) } )
                        ]
                    ]
                    |> Query.fromHtml
                    |> Query.findAll [ Selector.tag "set" ]
                    |> Query.count (Expect.equal 0)
        , test "keyframes with groups animate group attrs" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Animate.keyframes [ Animate.repeatIndefinite ]
                        [ ( 0.0, Evg.group [ Evg.opacity 1 ] [ Evg.circle [] { r = 10, center = ( 50, 50 ) } ] )
                        , ( 1.0, Evg.group [ Evg.opacity 0.5 ] [ Evg.circle [] { r = 10, center = ( 50, 50 ) } ] )
                        ]
                    ]
                    |> Query.fromHtml
                    |> Query.has [ Selector.containing [ Selector.tag "animate" ] ]
        , test "keyframes recursively animates group children" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Animate.keyframes [ Animate.repeatIndefinite ]
                        [ ( 0.0
                          , Evg.group []
                                [ Evg.circle [ Evg.fillStr "red" ] { r = 10, center = ( 20, 50 ) }
                                , Evg.rect [ Evg.fillStr "blue" ] { x = 60, y = 40, width = 20, height = 20 }
                                ]
                          )
                        , ( 1.0
                          , Evg.group []
                                [ Evg.circle [ Evg.fillStr "blue" ] { r = 30, center = ( 20, 50 ) }
                                , Evg.rect [ Evg.fillStr "red" ] { x = 50, y = 30, width = 40, height = 40 }
                                ]
                          )
                        ]
                    ]
                    |> Query.fromHtml
                    |> Query.findAll [ Selector.tag "animate" ]
                    |> Query.count (Expect.atLeast 2)
        , test "set produces a <set> element with attributeName and to" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.circle [ Evg.fillStr "gray" ] { r = 20, center = ( 50, 50 ) }
                        |> Animate.set [ Animate.beginOn Animate.click ] "fill" "red"
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "set" ]
                    |> Query.has
                        [ Selector.attribute (Html.Attributes.attribute "attributeName" "fill")
                        , Selector.attribute (Html.Attributes.attribute "to" "red")
                        , Selector.attribute (Html.Attributes.attribute "begin" "click")
                        ]
        , test "rotate emits animateTransform type=rotate additive=sum" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect [ Evg.fillStr "teal" ] { x = 40, y = 40, width = 20, height = 20 }
                        |> Animate.rotate [ Animate.repeatIndefinite ] [ ( 2, Animate.easeLinear, 360 ) ]
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "animateTransform" ]
                    |> Query.has
                        [ Selector.attribute (Html.Attributes.attribute "type" "rotate")
                        , Selector.attribute (Html.Attributes.attribute "additive" "sum")
                        , Selector.attribute (Html.Attributes.attribute "attributeName" "transform")
                        , Selector.attribute (Html.Attributes.attribute "values" "0;360")
                        ]
        , test "rotateAround emits values with center point and identity start" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect [ Evg.fillStr "teal" ] { x = 40, y = 40, width = 20, height = 20 }
                        |> Animate.rotateAround [] ( 50, 50 ) [ ( 1, Animate.easeLinear, 180 ) ]
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "animateTransform" ]
                    |> Query.has
                        [ Selector.attribute (Html.Attributes.attribute "type" "rotate")
                        , Selector.attribute (Html.Attributes.attribute "values" "0 50 50;180 50 50")
                        , Selector.attribute (Html.Attributes.attribute "additive" "sum")
                        ]
        , test "scale emits type=scale with identity start of 1" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.circle [ Evg.fillStr "crimson" ] { r = 20, center = ( 50, 50 ) }
                        |> Animate.scale [] [ ( 1, Animate.easeInOut, 1.5 ) ]
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "animateTransform" ]
                    |> Query.has
                        [ Selector.attribute (Html.Attributes.attribute "type" "scale")
                        , Selector.attribute (Html.Attributes.attribute "values" "1;1.5")
                        , Selector.attribute (Html.Attributes.attribute "additive" "sum")
                        ]
        , test "scaleXY emits type=scale with pair values" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect [ Evg.fillStr "teal" ] { x = 40, y = 40, width = 20, height = 20 }
                        |> Animate.scaleXY [] [ ( 1, Animate.easeInOut, ( 2, 0.5 ) ) ]
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "animateTransform" ]
                    |> Query.has
                        [ Selector.attribute (Html.Attributes.attribute "type" "scale")
                        , Selector.attribute (Html.Attributes.attribute "values" "1 1;2 0.5")
                        ]
        , test "translate emits type=translate with pair values" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.circle [ Evg.fillStr "orange" ] { r = 10, center = ( 20, 50 ) }
                        |> Animate.translate [] [ ( 1, Animate.easeInOut, ( 100, 0 ) ) ]
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "animateTransform" ]
                    |> Query.has
                        [ Selector.attribute (Html.Attributes.attribute "type" "translate")
                        , Selector.attribute (Html.Attributes.attribute "values" "0 0;100 0")
                        , Selector.attribute (Html.Attributes.attribute "additive" "sum")
                        ]
        , test "skewX emits type=skewX" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect [ Evg.fillStr "teal" ] { x = 40, y = 40, width = 20, height = 20 }
                        |> Animate.skewX [] [ ( 1, Animate.easeLinear, 20 ) ]
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "animateTransform" ]
                    |> Query.has [ Selector.attribute (Html.Attributes.attribute "type" "skewX") ]
        , test "skewY emits type=skewY" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect [ Evg.fillStr "teal" ] { x = 40, y = 40, width = 20, height = 20 }
                        |> Animate.skewY [] [ ( 1, Animate.easeLinear, 10 ) ]
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "animateTransform" ]
                    |> Query.has [ Selector.attribute (Html.Attributes.attribute "type" "skewY") ]
        , test "stepped uses calcMode discrete and emits no keySplines" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.circle [ Evg.fillStr "red" ] { r = 10, center = ( 50, 50 ) }
                        |> Animate.animate [ Animate.stepped ]
                            "r"
                            [ ( 1, Animate.easeLinear, "30" )
                            , ( 2, Animate.easeLinear, "10" )
                            ]
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "animate" ]
                    |> Expect.all
                        [ Query.has [ Selector.attribute (Html.Attributes.attribute "calcMode" "discrete") ]
                        , Query.hasNot [ Selector.attribute (Html.Attributes.attribute "keySplines" "") ]
                        ]
        , test "paced uses calcMode paced" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.circle [ Evg.fillStr "red" ] { r = 10, center = ( 50, 50 ) }
                        |> Animate.animate [ Animate.paced ]
                            "r"
                            [ ( 1, Animate.easeLinear, "30" )
                            , ( 2, Animate.easeLinear, "10" )
                            ]
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "animate" ]
                    |> Query.has [ Selector.attribute (Html.Attributes.attribute "calcMode" "paced") ]
        , test "beginOn click emits begin=click" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.circle [ Evg.fillStr "red" ] { r = 10, center = ( 50, 50 ) }
                        |> Animate.animate [ Animate.beginOn Animate.click ]
                            "r"
                            [ ( 0.5, Animate.easeOut, "30" ) ]
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "animate" ]
                    |> Query.has [ Selector.attribute (Html.Attributes.attribute "begin" "click") ]
        , test "onEnd installs a handler on the animation element" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.circle [ Evg.fillStr "red" ] { r = 10, center = ( 50, 50 ) }
                        |> Animate.animate [ Animate.onEnd Ended ]
                            "r"
                            [ ( 0.5, Animate.easeOut, "30" ) ]
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "animate" ]
                    |> Event.simulate (Event.custom "endEvent" (Encode.object []))
                    |> Event.expect Ended
        , test "time-based sequence emits begin offsets and no id attributes" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.rect [ Evg.fillStr "teal" ] { x = 40, y = 40, width = 20, height = 20 }
                        |> Animate.sequence []
                            [ Animate.stepTranslate [ Animate.duration 1 ] [ ( 1, Animate.easeOut, ( 40, 0 ) ) ]
                            , Animate.stepRotateAround [ Animate.duration 1 ] ( 50, 50 ) [ ( 1, Animate.easeInOut, 180 ) ]
                            ]
                    ]
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.findAll [ Selector.tag "animateTransform" ]
                            >> Query.count (Expect.equal 2)
                        , Query.has [ Selector.attribute (Html.Attributes.attribute "begin" "0s") ]
                        , Query.has [ Selector.attribute (Html.Attributes.attribute "begin" "1s") ]
                        , Query.findAll [ Selector.attribute (Html.Attributes.id "e") ]
                            >> Query.count (Expect.equal 0)
                        ]
        , test "event-triggered sequence emits hashed ids and syncbase begins" <|
            \_ ->
                let
                    ids =
                        Evg.svg []
                            { width = 100, height = 100 }
                            [ Evg.rect [ Evg.fillStr "teal" ] { x = 40, y = 40, width = 20, height = 20 }
                                |> Animate.sequence [ Animate.beginOn Animate.click ]
                                    [ Animate.stepTranslate [ Animate.duration 1 ] [ ( 1, Animate.easeOut, ( 40, 0 ) ) ]
                                    , Animate.stepScale [ Animate.duration 1 ] [ ( 1, Animate.easeInOut, 2 ) ]
                                    ]
                            ]
                            |> Query.fromHtml
                in
                ids
                    |> Expect.all
                        [ Query.find [ Selector.tag "animateTransform", Selector.attribute (Html.Attributes.attribute "type" "translate") ]
                            >> Query.has [ Selector.attribute (Html.Attributes.attribute "begin" "click") ]
                        , Query.findAll [ Selector.attribute (Html.Attributes.attribute "type" "scale") ]
                            >> Query.count (Expect.equal 1)
                        ]
        , test "motion with upright emits rotate=0" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.circle [ Evg.fillStr "red" ] { r = 5, center = ( 0, 0 ) }
                        |> Animate.motion [ Animate.upright, Animate.duration 3 ]
                            [ Path.M ( 10, 80 ) [ Path.L ( 90, 80 ) ] ]
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "animateMotion" ]
                    |> Query.has [ Selector.attribute (Html.Attributes.attribute "rotate" "0") ]
        , test "motion with easing emits keySplines" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.circle [ Evg.fillStr "red" ] { r = 5, center = ( 0, 0 ) }
                        |> Animate.motion [ Animate.easing Animate.easeInOut, Animate.duration 3 ]
                            [ Path.M ( 10, 80 ) [ Path.L ( 90, 80 ) ] ]
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "animateMotion" ]
                    |> Query.has [ Selector.attribute (Html.Attributes.attribute "keySplines" ".5 0 .5 1") ]
        , test "motionKeyframes emits matching-length keyPoints and keyTimes" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Evg.circle [ Evg.fillStr "red" ] { r = 5, center = ( 0, 0 ) }
                        |> Animate.motionKeyframes [ Animate.duration 4 ]
                            [ Path.M ( 10, 80 ) [ Path.L ( 90, 80 ) ] ]
                            [ ( 2, Animate.easeInOut, 0.5 )
                            , ( 4, Animate.easeInOut, 1 )
                            ]
                    ]
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "animateMotion" ]
                    |> Query.has
                        [ Selector.attribute (Html.Attributes.attribute "keyPoints" "0.5;0.5;1")
                        , Selector.attribute (Html.Attributes.attribute "keyTimes" "0;0.5;1")
                        ]
        , test "sampled produces animated output, not just the first frame" <|
            \_ ->
                Evg.svg []
                    { width = 100, height = 100 }
                    [ Animate.sampled [ Animate.repeatIndefinite ]
                        { samples = 8, duration = 3 }
                        (\progress ->
                            Evg.rect [ Evg.fillStr "green" ]
                                { x = 0, y = 40, width = progress * 200, height = 20 }
                        )
                    ]
                    |> Query.fromHtml
                    |> Query.has [ Selector.containing [ Selector.tag "animate" ] ]
        ]


type Msg
    = Ended
