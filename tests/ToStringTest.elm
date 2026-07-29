module ToStringTest exposing (suite)

import Color
import Evg
import Evg.Advanced as Advanced
import Evg.Events as Events
import Evg.Filter as Filter
import Evg.Mask as Mask
import Evg.Paint as Paint
import Evg.Path exposing (Path(..), PathSegment(..))
import Evg.Performance as Performance
import Evg.Text as Text
import Evg.Transform as Transform
import Expect
import Html.Attributes
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Evg.toString"
        [ test "a simple circle" <|
            \_ ->
                Evg.toString []
                    { width = 100, height = 100 }
                    [ Evg.circle [ Evg.fillStr "red" ] { r = 40, center = ( 50, 50 ) } ]
                    |> Expect.equal
                        ("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 100 100\" width=\"100\" height=\"100\">"
                            ++ "<circle r=\"40\" cx=\"50\" cy=\"50\" fill=\"red\"/>"
                            ++ "</svg>"
                        )
        , test "nested groups with transforms" <|
            \_ ->
                Evg.toString []
                    { width = 10, height = 10 }
                    [ Evg.group [ Transform.translate 5 5 ]
                        [ Evg.rect [] { x = 0, y = 0, width = 2, height = 2 } ]
                    ]
                    |> Expect.equal
                        ("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 10 10\" width=\"10\" height=\"10\">"
                            ++ "<g transform=\"translate(5 5)\">"
                            ++ "<rect x=\"0\" y=\"0\" width=\"2\" height=\"2\"/>"
                            ++ "</g></svg>"
                        )
        , test "multiple transforms merge into one attribute" <|
            \_ ->
                Evg.toString []
                    { width = 10, height = 10 }
                    [ Evg.group
                        [ Transform.translate 5 5, Transform.rotate 45 ]
                        []
                    ]
                    |> String.contains "transform=\"translate(5 5) rotate(45)\""
                    |> Expect.equal True
        , test "text content is included and escaped" <|
            \_ ->
                Evg.toString []
                    { width = 100, height = 20 }
                    [ Evg.text []
                        { x = 0, y = 10, anchor = Evg.Start }
                        "a < b & c"
                    ]
                    |> String.contains ">a &lt; b &amp; c</text>"
                    |> Expect.equal True
        , test "attribute values are escaped" <|
            \_ ->
                Evg.toString []
                    { width = 10, height = 10 }
                    [ Evg.circle [ Evg.fillStr "\"><script>" ] { r = 1, center = ( 5, 5 ) } ]
                    |> String.contains "fill=\"&quot;&gt;&lt;script&gt;\""
                    |> Expect.equal True
        , test "gradients serialize into defs" <|
            \_ ->
                Evg.toString []
                    { width = 10, height = 10 }
                    [ Evg.rect
                        [ Evg.fill
                            (Paint.linearGradient ( 0, 0 )
                                ( 1, 0 )
                                [ Paint.stop 0 (Color.rgb 1 0 0)
                                , Paint.stop 1 (Color.rgb 0 0 1)
                                ]
                            )
                        ]
                        { x = 0, y = 0, width = 10, height = 10 }
                    ]
                    |> Expect.all
                        [ String.contains "<defs><linearGradient id=\""
                            >> Expect.equal True
                        , String.contains "<stop offset=\"0\""
                            >> Expect.equal True
                        , String.contains "fill=\"url(#"
                            >> Expect.equal True
                        ]
        , test "event handlers are dropped" <|
            \_ ->
                Evg.toString []
                    { width = 10, height = 10 }
                    [ Evg.circle
                        [ Events.onClick (\_ -> ()) ]
                        { r = 1, center = ( 5, 5 ) }
                    ]
                    |> Expect.equal
                        ("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 10 10\" width=\"10\" height=\"10\">"
                            ++ "<circle r=\"1\" cx=\"5\" cy=\"5\"/>"
                            ++ "</svg>"
                        )
        , test "lazy shapes are forced" <|
            \_ ->
                Evg.toString []
                    { width = 10, height = 10 }
                    [ Performance.lazy "probe"
                        (\r -> Evg.circle [] { r = r, center = ( 5, 5 ) })
                        3
                    ]
                    |> String.contains "<circle r=\"3\""
                    |> Expect.equal True
        , test "title makes it into the markup" <|
            \_ ->
                Evg.toString []
                    { width = 10, height = 10 }
                    [ Evg.circle [ Evg.title "spot" ] { r = 1, center = ( 5, 5 ) } ]
                    |> String.contains "<title>spot</title>"
                    |> Expect.equal True
        , consistencyTests
        ]


{-| These guard against `toString` and `toNode` drifting apart. Each renders
the same drawing both ways and checks that an attribute present in the live
DOM is also present in the serialized string. The attrs data field feeds
serialization while the baked attributes feed rendering, so a constructor
that populates one but not the other would pass the plain string tests above
yet fail here.
-}
consistencyTests : Test
consistencyTests =
    describe "toString agrees with toNode"
        [ test "multi-primitive filter chain keeps its in/result wiring" <|
            \_ ->
                let
                    fltr =
                        Filter.sourceGraphic
                            |> Filter.gaussianBlur 3
                            |> Filter.offset 4 4

                    scene =
                        [ Evg.rect [ Evg.filter fltr ]
                            { x = 0, y = 0, width = 50, height = 50 }
                        ]

                    str =
                        Evg.toString [] { width = 50, height = 50 } scene

                    blurResult =
                        attrValue "result" "feGaussianBlur" str
                in
                Expect.all
                    [ -- The serialized feOffset's `in` equals the blur's
                      -- `result`, so the string keeps the chain intact.
                      \_ ->
                        ( blurResult, attrValue "in" "feOffset" str )
                            |> (\( r, i ) -> r /= Nothing && r == i)
                            |> Expect.equal True

                    -- The live DOM wires the feOffset to that same id, so the
                    -- two representations agree, not merely each look plausible.
                    , \_ ->
                        Evg.svg [] { width = 50, height = 50 } scene
                            |> Query.fromHtml
                            |> Query.find [ Selector.tag "feOffset" ]
                            |> Query.has
                                [ Selector.attribute
                                    (Html.Attributes.attribute "in"
                                        (Maybe.withDefault "MISSING" blurResult)
                                    )
                                ]
                    ]
                    ()
        , test "tspan colors survive serialization" <|
            \_ ->
                let
                    scene =
                        [ Text.richText [ Evg.fontSize 16 ]
                            { x = 5, y = 20, anchor = Evg.Start }
                            [ Text.tspan [ Evg.fillStr "red" ] "A"
                            , Text.tspan [ Evg.fillStr "blue" ] "B"
                            ]
                        ]

                    str =
                        Evg.toString [] { width = 100, height = 30 } scene
                in
                Expect.all
                    [ \_ ->
                        Evg.svg [] { width = 100, height = 30 } scene
                            |> Query.fromHtml
                            |> Query.findAll [ Selector.tag "tspan" ]
                            |> Query.first
                            |> Query.has [ Selector.attribute (Html.Attributes.attribute "fill" "red") ]
                    , \_ ->
                        String.contains "fill=\"red\"" str
                            && String.contains "fill=\"blue\"" str
                            |> Expect.equal True
                    ]
                    ()
        , test "a gradient nested inside a mask is emitted, both ways" <|
            \_ ->
                let
                    grad =
                        Paint.radialGradient ( 0.5, 0.5 )
                            0.5
                            [ Paint.stop 0 Color.white
                            , Paint.stop 1 Color.black
                            ]

                    scene =
                        [ Evg.rect
                            [ Mask.alpha
                                (Evg.circle [ Evg.fill grad ]
                                    { r = 20, center = ( 25, 25 ) }
                                )
                            , Evg.fillStr "red"
                            ]
                            { x = 0, y = 0, width = 50, height = 50 }
                        ]
                in
                Expect.all
                    [ \_ ->
                        Evg.svg [] { width = 50, height = 50 } scene
                            |> Query.fromHtml
                            |> Query.findAll [ Selector.tag "radialGradient" ]
                            |> Query.count (Expect.equal 1)
                    , \_ ->
                        Evg.toString [] { width = 50, height = 50 } scene
                            |> String.contains "<radialGradient"
                            |> Expect.equal True
                    ]
                    ()
        , test "a pattern keeps its units in the serialized markup" <|
            \_ ->
                Evg.toString []
                    { width = 30, height = 30 }
                    [ Evg.rect
                        [ Evg.fill
                            (Paint.pattern []
                                { width = 10, height = 10 }
                                [ Evg.circle [ Evg.fillStr "red" ]
                                    { r = 3, center = ( 5, 5 ) }
                                ]
                            )
                        ]
                        { x = 0, y = 0, width = 30, height = 30 }
                    ]
                    |> String.contains "patternUnits=\"userSpaceOnUse\""
                    |> Expect.equal True
        , test "xmlns:xlink is declared only when an xlink:href is present" <|
            \_ ->
                let
                    withXlink =
                        Evg.toString []
                            { width = 100, height = 30 }
                            [ Text.richText
                                [ Text.onPath [ M ( 0, 20 ) [ L ( 100, 20 ) ] ] ]
                                { x = 0, y = 20, anchor = Evg.Start }
                                [ Text.tspan [] "hi" ]
                            ]

                    withoutXlink =
                        Evg.toString []
                            { width = 30, height = 30 }
                            [ Evg.circle [] { r = 5, center = ( 15, 15 ) } ]
                in
                Expect.all
                    [ \_ ->
                        String.contains "xmlns:xlink" withXlink
                            |> Expect.equal True
                    , \_ ->
                        String.contains "xmlns:xlink" withoutXlink
                            |> Expect.equal False
                    ]
                    ()
        , test "a nested viewport keeps its viewBox and other attributes" <|
            \_ ->
                let
                    scene =
                        [ Advanced.nestedSvg
                            [ Advanced.viewBox 0 0 1000 500
                            , Advanced.preserveAspectRatio
                                Advanced.XMidYMid
                                Advanced.Slice
                            , Evg.class "panel"
                            ]
                            { x = 10, y = 10, width = 50, height = 50 }
                            [ Evg.circle [] { r = 5, center = ( 25, 25 ) } ]
                        ]

                    str =
                        Evg.toString [] { width = 200, height = 100 } scene
                in
                Expect.all
                    [ \_ ->
                        Evg.svg [] { width = 200, height = 100 } scene
                            |> Query.fromHtml
                            |> Query.find [ Selector.tag "svg" ]
                            |> Query.has
                                [ Selector.attribute (Html.Attributes.attribute "viewBox" "0 0 1000 500") ]
                    , \_ ->
                        String.contains "viewBox=\"0 0 1000 500\"" str
                            && String.contains "preserveAspectRatio=\"xMidYMid slice\"" str
                            && String.contains "class=\"panel\"" str
                            |> Expect.equal True
                    ]
                    ()
        ]


{-| Pull the value of `attr` out of the first `<tag ...>` in the serialized
markup, or Nothing if the tag or attribute isn't there. A small string parse
kept deliberately dumb: the tests only feed it markup they construct.
-}
attrValue : String -> String -> String -> Maybe String
attrValue attr tag markup =
    case String.split ("<" ++ tag) markup of
        _ :: afterTag :: _ ->
            case String.split (" " ++ attr ++ "=\"") (openTag afterTag) of
                _ :: afterAttr :: _ ->
                    afterAttr
                        |> String.split "\""
                        |> List.head

                _ ->
                    Nothing

        _ ->
            Nothing


{-| The remainder of a start tag up to its closing `>`, so attribute parsing
never reads into the element's content or later siblings.
-}
openTag : String -> String
openTag rest =
    case String.split ">" rest of
        first :: _ ->
            first

        [] ->
            rest
