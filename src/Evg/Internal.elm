module Evg.Internal exposing
    ( Attribute(..)
    , BaseFilter
    , CoordinateSpace(..)
    , Def(..)
    , Evg(..)
    , Filter(..)
    , FilterPayload
    , Mat23
    , Paint(..)
    , Stop(..)
    , Supported
    , applyPoint
    , attrHash
    , collectDefs
    , composeMat
    , contentHash
    , coordinateSpaceAttrs
    , coordinateSpaceHash
    , element
    , filterElem
    , filterPrimitives
    , filterToEvg
    , hashStringToInt
    , identityMat
    , invertMat
    , mapEvg
    , mixColor
    , mixFloat
    , mixInt
    , mixString
    , renderDefs
    , svgAttributes
    , toNode
    , wrapNode
    )

import Bitwise
import Color exposing (Color)
import Dict exposing (Dict)
import Set
import Svg
import Svg.Attributes
import VirtualDom


type Supported
    = Supported Never


{-| A 2×3 affine transformation matrix, matching SVG's `matrix(a b c d e f)`.
It maps a point `(x, y)` to `(a*x + c*y + e, b*x + d*y + f)`.

We track these alongside the transform strings so that event handlers can
convert a decoded scene-space point into the local coordinate space of the
element they sit on, by inverting the accumulated root→element matrix. No
browser API can do this from a JSON decoder (it would need `getScreenCTM`),
but because we render every transform ourselves we can reconstruct it.

-}
type alias Mat23 =
    { a : Float
    , b : Float
    , c : Float
    , d : Float
    , e : Float
    , f : Float
    }


identityMat : Mat23
identityMat =
    { a = 1, b = 0, c = 0, d = 1, e = 0, f = 0 }


{-| Compose two matrices: `composeMat outer inner` is the matrix that applies
`inner` first, then `outer`. This matches how nested SVG `transform`
attributes stack (the parent's transform wraps the child's).
-}
composeMat : Mat23 -> Mat23 -> Mat23
composeMat m n =
    { a = m.a * n.a + m.c * n.b
    , b = m.b * n.a + m.d * n.b
    , c = m.a * n.c + m.c * n.d
    , d = m.b * n.c + m.d * n.d
    , e = m.a * n.e + m.c * n.f + m.e
    , f = m.b * n.e + m.d * n.f + m.f
    }


{-| Invert an affine matrix. Returns the identity for degenerate (non-invertible)
matrices such as `scale 0`, so callers get a harmless fallback rather than NaNs.
-}
invertMat : Mat23 -> Mat23
invertMat m =
    let
        det =
            m.a * m.d - m.b * m.c
    in
    if det == 0 then
        identityMat

    else
        let
            invDet =
                1 / det
        in
        { a = m.d * invDet
        , b = -m.b * invDet
        , c = -m.c * invDet
        , d = m.a * invDet
        , e = (m.c * m.f - m.d * m.e) * invDet
        , f = (m.b * m.e - m.a * m.f) * invDet
        }


applyPoint : Mat23 -> ( Float, Float ) -> ( Float, Float )
applyPoint m ( x, y ) =
    ( m.a * x + m.c * y + m.e
    , m.b * x + m.d * y + m.f
    )


{-| Defines the coordinate system for paint servers (gradients, patterns),
clip paths, and masks.

  - `ObjectBoundingBox`: coordinates are relative to the element's bounding box.
    `(0, 0)` is the top-left corner and `(1, 1)` is the bottom-right,
    regardless of the element's actual size or position.
  - `UserSpace`: coordinates use the same absolute coordinate system as the
    shapes themselves.

Both take a rect that defines the region where the effect is applied.

-}
type CoordinateSpace
    = ObjectBoundingBox { x : Float, y : Float, width : Float, height : Float }
    | UserSpace { x : Float, y : Float, width : Float, height : Float }


coordinateSpaceHash : CoordinateSpace -> Int
coordinateSpaceHash space =
    case space of
        ObjectBoundingBox { x, y, width, height } ->
            1 |> mixFloat x |> mixFloat y |> mixFloat width |> mixFloat height

        UserSpace { x, y, width, height } ->
            2 |> mixFloat x |> mixFloat y |> mixFloat width |> mixFloat height


coordinateSpaceAttrs : (String -> VirtualDom.Attribute msg) -> CoordinateSpace -> List (VirtualDom.Attribute msg)
coordinateSpaceAttrs unitsAttr space =
    case space of
        ObjectBoundingBox { x, y, width, height } ->
            [ unitsAttr "objectBoundingBox"
            , Svg.Attributes.x (String.fromFloat x)
            , Svg.Attributes.y (String.fromFloat y)
            , Svg.Attributes.width (String.fromFloat width)
            , Svg.Attributes.height (String.fromFloat height)
            ]

        UserSpace { x, y, width, height } ->
            [ unitsAttr "userSpaceOnUse"
            , Svg.Attributes.x (String.fromFloat x)
            , Svg.Attributes.y (String.fromFloat y)
            , Svg.Attributes.width (String.fromFloat width)
            , Svg.Attributes.height (String.fromFloat height)
            ]


type Paint
    = PaintNone
    | PaintSolid Color
    | PaintStr String
    | PaintContextFill
    | PaintContextStroke
    | PaintLinearGradient ( Float, Float ) ( Float, Float ) (List Stop)
    | PaintLinearGradientCS CoordinateSpace ( Float, Float ) ( Float, Float ) (List Stop)
    | PaintRadialGradient ( Float, Float ) Float (List Stop)
    | PaintRadialGradientCS CoordinateSpace ( Float, Float ) Float (List Stop)
    | PaintPattern (List (Attribute {} Never)) { width : Float, height : Float } (List (Evg Never))
    | PaintPatternCS (List (Attribute {} Never)) CoordinateSpace (List (Evg Never))


type Stop
    = ColorStop Float Color Float
    | StrStop Float String Float


type Evg msg
    = Evg
        { render : Mat23 -> List (VirtualDom.Node msg) -> VirtualDom.Node msg
        , ownMatrix : Mat23
        , children : List (Evg msg)
        , hash : Int
        , defs : List (Def msg)
        , attrs : List ( String, String )
        }


toNode : Evg msg -> VirtualDom.Node msg
toNode =
    toNodeWith identityMat


{-| Render a node given the accumulated root→parent transform matrix. Each
element composes its own transform onto that accumulator and hands the result
both to its own renderer (so event handlers can invert it to recover local
coordinates) and to its children.
-}
toNodeWith : Mat23 -> Evg msg -> VirtualDom.Node msg
toNodeWith parentAccum (Evg { render, ownMatrix, children }) =
    -- IGNORE TCO: tree recursion over children cannot be tail-call optimized
    let
        accum =
            composeMat parentAccum ownMatrix
    in
    render accum (List.map (toNodeWith accum) children)


wrapNode : VirtualDom.Node msg -> Evg msg
wrapNode node =
    Evg { render = \_ _ -> node, ownMatrix = identityMat, children = [], hash = 0, defs = [], attrs = [] }


mapEvg : (a -> b) -> Evg a -> Evg b
mapEvg fn evg =
    wrapNode (VirtualDom.map fn (toNode evg))


type Def msg
    = Def String (Evg msg)


type Attribute constraints msg
    = Attr Int String String (VirtualDom.Attribute msg)
    | DefAttr Int String String (VirtualDom.Attribute msg) (Def msg)
    | AccessibilityChild Int (VirtualDom.Node msg)
    | TransformAttr Int String Mat23
    | EventAttr Int (Mat23 -> VirtualDom.Attribute msg)
    | Batch (List (Attribute constraints msg))
    | TextPathChild Int String (Def msg)


element :
    (List (VirtualDom.Attribute msg) -> List (VirtualDom.Node msg) -> VirtualDom.Node msg)
    -> Int
    -> List (VirtualDom.Attribute msg)
    -> List (Mat23 -> VirtualDom.Attribute msg)
    -> Mat23
    -> List ( String, String )
    -> List (Evg msg)
    -> List (Def msg)
    -> Evg msg
element renderFn hash vdomAttrs eventBuilders ownMatrix inspectableAttrs children ownDefs =
    Evg
        { render =
            \accum childNodes ->
                renderFn (vdomAttrs ++ List.map (\build -> build accum) eventBuilders) childNodes
        , ownMatrix = ownMatrix
        , children = children

        -- Children's hashes must contribute: content hashes name defs (clip
        -- paths, masks, symbols), and two same-attribute containers with
        -- different children would otherwise collide and dedupe wrongly.
        , hash = List.foldl (\(Evg child) acc -> Bitwise.xor (acc * 33) child.hash) hash children
        , defs = ownDefs ++ collectDefs children
        , attrs = inspectableAttrs
        }


svgAttributes :
    List (Attribute constraints msg)
    ->
        { vdomAttrs : List (VirtualDom.Attribute msg)
        , eventBuilders : List (Mat23 -> VirtualDom.Attribute msg)
        , ownMatrix : Mat23
        , defs : List (Def msg)
        , a11yChildren : List (VirtualDom.Node msg)
        , inspectable : List ( String, String )
        , textPath : Maybe ( String, Def msg )
        }
svgAttributes attrs =
    let
        go remaining accAttrs accEvents accMatrices accDefs accChildren accTransforms accInspectable accTextPath =
            case remaining of
                [] ->
                    let
                        finalAttrs =
                            case accTransforms of
                                [] ->
                                    List.reverse accAttrs

                                _ ->
                                    Svg.Attributes.transform (String.join " " (List.reverse accTransforms)) :: List.reverse accAttrs
                    in
                    { vdomAttrs = finalAttrs
                    , eventBuilders = List.reverse accEvents
                    , ownMatrix = List.foldl composeMat identityMat accMatrices
                    , defs = List.reverse accDefs
                    , a11yChildren = List.reverse accChildren
                    , inspectable = List.reverse accInspectable
                    , textPath = accTextPath
                    }

                (Attr _ key value a) :: rest ->
                    go rest (a :: accAttrs) accEvents accMatrices accDefs accChildren accTransforms (( key, value ) :: accInspectable) accTextPath

                (DefAttr _ key value a def) :: rest ->
                    go rest (a :: accAttrs) accEvents accMatrices (def :: accDefs) accChildren accTransforms (( key, value ) :: accInspectable) accTextPath

                (AccessibilityChild _ child) :: rest ->
                    go rest accAttrs accEvents accMatrices accDefs (child :: accChildren) accTransforms accInspectable accTextPath

                (TransformAttr _ str mat) :: rest ->
                    go rest accAttrs accEvents (mat :: accMatrices) accDefs accChildren (str :: accTransforms) (( "transform", str ) :: accInspectable) accTextPath

                (EventAttr _ build) :: rest ->
                    go rest accAttrs (build :: accEvents) accMatrices accDefs accChildren accTransforms accInspectable accTextPath

                (Batch batchAttrs) :: rest ->
                    go (batchAttrs ++ rest) accAttrs accEvents accMatrices accDefs accChildren accTransforms accInspectable accTextPath

                (TextPathChild _ href def) :: rest ->
                    go rest accAttrs accEvents accMatrices (def :: accDefs) accChildren accTransforms accInspectable (Just ( href, def ))
    in
    go attrs [] [] [] [] [] [] [] Nothing


attrHash : List (Attribute constraints msg) -> Int
attrHash attrs =
    -- IGNORE TCO: recursion into nested Batch attributes cannot be tail-call optimized
    List.foldl
        (\attr acc ->
            let
                h =
                    case attr of
                        Attr hash _ _ _ ->
                            hash

                        DefAttr hash _ _ _ _ ->
                            hash

                        AccessibilityChild hash _ ->
                            hash

                        TransformAttr hash _ _ ->
                            hash

                        EventAttr hash _ ->
                            hash

                        Batch batchAttrs ->
                            attrHash batchAttrs

                        TextPathChild hash _ _ ->
                            hash
            in
            Bitwise.xor (acc * 31) h
        )
        5381
        attrs


collectDefs : List (Evg msg) -> List (Def msg)
collectDefs children =
    List.concatMap (\(Evg { defs }) -> defs) children


renderDefs : List (Def msg) -> VirtualDom.Node msg
renderDefs defs =
    case defs of
        [] ->
            VirtualDom.text ""

        _ ->
            let
                dedup =
                    List.foldl
                        (\(Def id evg) acc ->
                            if Dict.member id acc then
                                acc

                            else
                                Dict.insert id (toNode evg) acc
                        )
                        Dict.empty
                        defs
            in
            Svg.defs [] (Dict.values dedup)


contentHash : Evg msg -> String
contentHash (Evg { hash }) =
    String.fromInt hash


hashStringToInt : String -> Int
hashStringToInt str =
    String.foldl (\c acc -> Bitwise.xor (acc * 31) (Char.toCode c)) 5381 str


mixFloat : Float -> Int -> Int
mixFloat value acc =
    Bitwise.xor (acc * 31) (round (value * 1000))


mixColor : Color -> Int -> Int
mixColor color acc =
    let
        { red, green, blue, alpha } =
            Color.toRgba color
    in
    acc
        |> mixFloat red
        |> mixFloat green
        |> mixFloat blue
        |> mixFloat alpha


mixString : String -> Int -> Int
mixString str acc =
    String.foldl (\c a -> Bitwise.xor (a * 31) (Char.toCode c)) acc str


mixInt : Int -> Int -> Int
mixInt value acc =
    Bitwise.xor (acc * 31) value



-- Filter types and rendering


type alias BaseFilter a =
    { a
        | name : String
        , id : String
        , args : List ( String, String )
        , children : List ( String, List ( String, String ) )
    }


type alias FilterPayload =
    BaseFilter
        { defs : Dict String (BaseFilter {})
        }


type Filter
    = Filter FilterPayload
    | Virtual String


filterPrimitives : Filter -> ( String, List (VirtualDom.Node msg) )
filterPrimitives filter =
    case filter of
        Filter args ->
            let
                outputPrimitive =
                    { name = args.name, id = args.id, args = args.args, children = args.children }

                depPrimitives =
                    Dict.values args.defs

                sorted =
                    topologicalSort depPrimitives
            in
            ( args.id, List.map filterToNode sorted ++ [ filterToNode outputPrimitive ] )

        Virtual _ ->
            ( "", [] )


filterElem : Filter -> ( String, VirtualDom.Node msg )
filterElem filter =
    case filter of
        Filter args ->
            let
                outputPrimitive =
                    { name = args.name, id = args.id, args = args.args, children = args.children }

                depPrimitives =
                    Dict.values args.defs

                sorted =
                    topologicalSort depPrimitives
            in
            ( args.id
            , Svg.filter
                [ Svg.Attributes.id args.id ]
                (List.map filterToNode sorted ++ [ filterToNode outputPrimitive ])
            )

        Virtual _ ->
            ( "", VirtualDom.text "" )


filterToEvg : String -> Filter -> Evg msg
filterToEvg id filter =
    case filter of
        Filter args ->
            let
                outputPrimitive =
                    { name = args.name, id = args.id, args = args.args, children = args.children }

                depPrimitives =
                    Dict.values args.defs

                sorted =
                    topologicalSort depPrimitives

                allPrimitives =
                    sorted ++ [ outputPrimitive ]

                primitiveChildren =
                    List.map primitiveToEvg allPrimitives
            in
            Evg
                { render = \_ -> Svg.filter [ Svg.Attributes.id id ]
                , ownMatrix = identityMat
                , children = primitiveChildren
                , hash = 0
                , defs = []
                , attrs = []
                }

        Virtual _ ->
            wrapNode (VirtualDom.text "")


primitiveToEvg : BaseFilter a -> Evg msg
primitiveToEvg prim =
    let
        childNodes =
            List.map
                (\( childName, attrs ) ->
                    Svg.node childName (List.map filterAttr attrs) []
                )
                prim.children
    in
    Evg
        { render =
            \_ animChildren ->
                Svg.node prim.name
                    (Svg.Attributes.result prim.id :: List.map filterAttr prim.args)
                    (childNodes ++ animChildren)
        , ownMatrix = identityMat
        , children = []
        , hash = 0
        , defs = []
        , attrs = List.filter (\( k, _ ) -> k /= "in" && k /= "in2") prim.args
        }


topologicalSort : List (BaseFilter {}) -> List (BaseFilter {})
topologicalSort primitives =
    let
        idSet =
            List.map .id primitives |> Set.fromList

        getDeps prim =
            let
                argDeps =
                    prim.args
                        |> List.filterMap
                            (\( k, v ) ->
                                if (k == "in" || k == "in2") && Set.member v idSet then
                                    Just v

                                else
                                    Nothing
                            )

                childDeps =
                    prim.children
                        |> List.concatMap
                            (\( _, childAttrs ) ->
                                List.filterMap
                                    (\( k, v ) ->
                                        if (k == "in" || k == "in2") && Set.member v idSet then
                                            Just v

                                        else
                                            Nothing
                                    )
                                    childAttrs
                            )
            in
            argDeps ++ childDeps

        go remaining emitted result =
            case remaining of
                [] ->
                    List.reverse result

                _ ->
                    let
                        ( ready, blocked ) =
                            List.partition
                                (\prim ->
                                    List.all (\dep -> Set.member dep emitted) (getDeps prim)
                                )
                                remaining
                    in
                    case ready of
                        [] ->
                            List.reverse result ++ remaining

                        _ ->
                            let
                                newEmitted =
                                    List.foldl (\prim acc -> Set.insert prim.id acc) emitted ready
                            in
                            go blocked newEmitted (List.reverse ready ++ result)
    in
    go primitives Set.empty []


filterToNode : BaseFilter a -> VirtualDom.Node msg
filterToNode args =
    Svg.node args.name
        (Svg.Attributes.result args.id
            :: List.map filterAttr args.args
        )
        (List.map
            (\( childName, attrs ) ->
                Svg.node childName
                    (List.map filterAttr attrs)
                    []
            )
            args.children
        )


filterAttr : ( String, String ) -> VirtualDom.Attribute msg
filterAttr ( key, value ) =
    case key of
        "in" ->
            Svg.Attributes.in_ value

        "in2" ->
            Svg.Attributes.in2 value

        "stdDeviation" ->
            Svg.Attributes.stdDeviation value

        "baseFrequency" ->
            Svg.Attributes.baseFrequency value

        "numOctaves" ->
            Svg.Attributes.numOctaves value

        "seed" ->
            Svg.Attributes.seed value

        "type" ->
            Svg.Attributes.type_ value

        "scale" ->
            Svg.Attributes.scale value

        "operator" ->
            Svg.Attributes.operator value

        "k1" ->
            Svg.Attributes.k1 value

        "k2" ->
            Svg.Attributes.k2 value

        "k3" ->
            Svg.Attributes.k3 value

        "k4" ->
            Svg.Attributes.k4 value

        "mode" ->
            Svg.Attributes.mode value

        "dx" ->
            Svg.Attributes.dx value

        "dy" ->
            Svg.Attributes.dy value

        "radius" ->
            Svg.Attributes.radius value

        "flood-color" ->
            Svg.Attributes.floodColor value

        "surfaceScale" ->
            Svg.Attributes.surfaceScale value

        "specularConstant" ->
            Svg.Attributes.specularConstant value

        "specularExponent" ->
            Svg.Attributes.specularExponent value

        "diffuseConstant" ->
            Svg.Attributes.diffuseConstant value

        "lighting-color" ->
            Svg.Attributes.lightingColor value

        "x" ->
            Svg.Attributes.x value

        "y" ->
            Svg.Attributes.y value

        "z" ->
            Svg.Attributes.z value

        "azimuth" ->
            Svg.Attributes.azimuth value

        "elevation" ->
            Svg.Attributes.elevation value

        "pointsAtX" ->
            Svg.Attributes.pointsAtX value

        "pointsAtY" ->
            Svg.Attributes.pointsAtY value

        "pointsAtZ" ->
            Svg.Attributes.pointsAtZ value

        "limitingConeAngle" ->
            Svg.Attributes.limitingConeAngle value

        _ ->
            VirtualDom.attribute key value
