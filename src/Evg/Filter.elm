module Evg.Filter exposing
    ( Filter
    , withinRelative
    , sourceAlpha
    , floodStr
    , gaussianBlur, gaussianBlurXY
    , componentTransfer, RemappingFunction, identity, table, discrete, linear, gamma
    )

{-|


# Basics

@docs Filter


### Modifying filters

@docs withinRelative


# Filters


## Sources

These represent ways to get the input image into the filter pipeline:

@docs sourceAlpha


## Flood

@docs floodStr


## Gaussian blur

@docs gaussianBlur, gaussianBlurXY


## Component transfer

@docs componentTransfer, RemappingFunction, identity, table, discrete, linear, gamma

-}

import Dict exposing (Dict)
import VirtualDom



-- TODO: extract somewhere else


type alias Rect =
    { x : Float, y : Float, width : Float, height : Float }


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


{-| -}
type Filter
    = Filter FilterPayload
    | Virtual String



-- Helpers


f0 : String -> List ( String, String ) -> Filter
f0 name args =
    Filter
        { name = name
        , id = name ++ String.join "-" (List.map (\( a, b ) -> a ++ "_" ++ b) args)
        , args = args
        , defs = Dict.empty
        , children = []
        }


f1 : String -> List ( String, String ) -> Filter -> Filter
f1 name args inFilter =
    let
        id =
            toId inFilter

        args2 =
            ( "in", id ) :: args
    in
    Filter
        { name = name
        , id = name ++ String.join "-" (List.map (\( a, b ) -> a ++ "_" ++ b) args2)
        , args = args2
        , children = []
        , defs = makeDefs inFilter
        }


f2 : String -> List ( String, String ) -> Filter -> Filter -> Filter
f2 name args inFilter1 inFilter2 =
    let
        id1 =
            toId inFilter1

        id2 =
            toId inFilter2

        args2 =
            ( "in", id1 ) :: ( "in2", id2 ) :: args
    in
    Filter
        { name = name
        , id = name ++ String.join "-" (List.map (\( a, b ) -> a ++ "_" ++ b) args2)
        , args = args2
        , children = []
        , defs = makeDefs inFilter1 |> Dict.union (makeDefs inFilter2)
        }



-- Filters


{-| Represents the graphics elements that were the original input into the _filter_. The alpha channel of this image captures any anti-aliasing used.
`sourceAlpha` only captures the alpha channel. The input image is an RGBA image consisting of implicitly black color values for the RGB channels.

`sourceAlpha` is useful for creating a mask that can be used to control the visibility of the input image. It is also useful for creating a mask that can be used to control the visibility of the output image.

-}
sourceAlpha : Filter
sourceAlpha =
    Virtual "SourceAlpha"


{-| Creates a rectangle filled with the color value passed (as a string, such as `"#FA32CA"`).
-}
floodStr : String -> Filter
floodStr str =
    f0 "feFlood" [ ( "flood-color", str ) ]


{-| Performs a Gaussian blur on the input image by using a standard deviation in both axis.
-}
gaussianBlur : Float -> Filter -> Filter
gaussianBlur r =
    f1 "feGaussianBlur" [ ( "stdDeviation", String.fromFloat r ) ]


{-| Performs a Gaussian blur on the input image by using a different standard deviation in both axis.
-}
gaussianBlurXY : Float -> Float -> Filter -> Filter
gaussianBlurXY rx ry =
    f1 "feGaussianBlur" [ ( "stdDeviation", String.fromFloat rx ++ " " ++ String.fromFloat ry ) ]


fractalNoise : { baseFrequency : Float, numOctaves : Int, seed : Int } -> Filter
fractalNoise { baseFrequency, numOctaves, seed } =
    f0 "feTurbulence"
        [ ( "baseFrequency", String.fromFloat baseFrequency )
        , ( "numOctaves", String.fromInt numOctaves )
        , ( "seed", String.fromInt seed )
        , ( "type", "fractalNoise" )
        ]


displacementMap : List ( String, String ) -> { scale : Float } -> Filter -> Filter -> Filter
displacementMap extraArgs { scale } inFilter1 inFilter2 =
    f2 "feDisplacementMap"
        ([ ( "scale", String.fromFloat scale ) ] ++ extraArgs)
        inFilter1
        inFilter2


{-| This filter applies a matrix transformation:

    | R' |     | a00 a01 a02 a03 a04 |   | R |
    | G' |     | a10 a11 a12 a13 a14 |   | G |
    | B' |  =  | a20 a21 a22 a23 a24 | * | B |
    | A' |     | a30 a31 a32 a33 a34 |   | A |
    | 1  |     |  0   0   0   0   1  |   | 1 |

on the RGBA color and alpha values of every pixel on the input graphics to produce a result with a new set of RGBA color and alpha values.

The calculations are performed on non-premultiplied color values.

The input here is the above matrix in row order `[[ a00, a01, ...], [ a10, a11, ...], ...]`. This is a 4x5 list of lists. Extra values will be ignored and missing values will be substituted for the identity matrix. So

    Filter.colorMatrix [ [ 0.12 ], [ 0, 0.12 ], [ 1, 0, 0, 0, 0, 0.12 ] ]

is equivalent to:

    Filter.colorMatrix
        [ [ 0.12, 0, 0, 0, 0 ]
        , [ 0, 0.12, 0, 0, 0 ]
        , [ 1, 0, 0, 0, 0 ]
        , [ 0, 0, 0, 1, 0 ]
        , [ 0, 0, 0, 0, 1 ]
        ]

-}
colorMatrix : List (List Float) -> Filter -> Filter
colorMatrix matrix inFilter =
    let
        values =
            matrix
                |> defaultMatrix
                |> List.concatMap (\row -> List.map String.fromFloat row)
                |> String.join " "
    in
    f1 "feColorMatrix" [ ( "type", "matrix" ), ( "values", values ) ] inFilter


identityMatrix : List (List Float)
identityMatrix =
    [ [ 1, 0, 0, 0, 0 ]
    , [ 0, 1, 0, 0, 0 ]
    , [ 0, 0, 1, 0, 0 ]
    , [ 0, 0, 0, 1, 0 ]
    , [ 0, 0, 0, 0, 1 ]
    ]


defaultMatrix : List (List Float) -> List (List Float)
defaultMatrix input =
    List.map2 (mergeWithTemplate []) (mergeWithTemplate [] input identityMatrix) identityMatrix


mergeWithTemplate : List a -> List a -> List a -> List a
mergeWithTemplate result input template =
    case input of
        [] ->
            List.reverse result ++ template

        i :: is ->
            case template of
                [] ->
                    List.reverse result

                _ :: ts ->
                    mergeWithTemplate (i :: result) is ts


{-| This filter performs component-wise remapping of data using the remapping functions provided.
It allows operations like brightness adjustment, contrast adjustment, color balance or thresholding.
The calculations are performed on non-premultiplied color values.
-}
componentTransfer :
    { r : RemappingFunction
    , g : RemappingFunction
    , b : RemappingFunction
    , a : RemappingFunction
    }
    -> Filter
    -> Filter
componentTransfer { r, g, b, a } inFilter =
    let
        remappingToChild remapping channel =
            case remapping of
                Identity ->
                    Nothing

                Table values ->
                    Just
                        ( channel
                        , [ ( "type", "table" )
                          , ( "tableValues", String.join " " (List.map String.fromFloat values) )
                          ]
                        )

                Discrete values ->
                    Just
                        ( channel
                        , [ ( "type", "discrete" )
                          , ( "tableValues", String.join " " (List.map String.fromFloat values) )
                          ]
                        )

                Linear slope intercept ->
                    Just
                        ( channel
                        , [ ( "type", "linear" )
                          , ( "slope", String.fromFloat slope )
                          , ( "intercept", String.fromFloat intercept )
                          ]
                        )

                Gamma amplitude exponent offset ->
                    Just
                        ( channel
                        , [ ( "type", "gamma" )
                          , ( "amplitude", String.fromFloat amplitude )
                          , ( "exponent", String.fromFloat exponent )
                          , ( "offset", String.fromFloat offset )
                          ]
                        )

        id =
            toId inFilter

        children =
            List.filterMap Basics.identity
                [ remappingToChild r "feFuncR"
                , remappingToChild g "feFuncG"
                , remappingToChild b "feFuncB"
                , remappingToChild a "feFuncA"
                ]
    in
    Filter
        { name = "feComponentTransfer"
        , id = "feComponentTransfer-" ++ id ++ String.join "-" (List.map (\( aa, bs ) -> aa ++ "_" ++ (List.map (\( bk, bv ) -> bk ++ "_" ++ bv) bs |> String.join "-")) children)
        , args = [ ( "in", id ) ]
        , children =
            List.filterMap Basics.identity
                [ remappingToChild r "feFuncR"
                , remappingToChild g "feFuncG"
                , remappingToChild b "feFuncB"
                , remappingToChild a "feFuncA"
                ]
        , defs = makeDefs inFilter
        }


{-| A component wise remamapping function.
-}
type RemappingFunction
    = Identity
    | Table (List Float)
    | Discrete (List Float)
    | Linear Float Float
    | Gamma Float Float Float


{-| The identity function - does not change the channel at all.
-}
identity : RemappingFunction
identity =
    Identity


{-| For table, the function is defined by linear interpolation between the values given. The table has n+1 values (i.e., v0 to vn) specifying the start and end values for n evenly sized interpolation regions.

Let's look at an example:

    Filter.table [ 0, 0.6, 0.8, 1 ]

In this case we have 4 values, so we have 3 equal regions:

    0.0 - 0.33 ==> 0.0 - 0.6

    0.33 - 0.66 ==> 0.6 - 0.8

    0.66 - 1.0 ==> 0.8 - 1.0

So for instance if I get a color value of 0.5, this falls in the middle of the second region, and so will get remapped to the middle of the output region, which is 0.7.

-}
table : List Float -> RemappingFunction
table =
    Table


{-| For discrete, the function is defined by the step function defined by the values given, which provides a list of n values (i.e., v0 to vn-1) in order to identify a step function consisting of n steps.

Let's look at an example:

    Filter.discrete [ 0, 0.6, 0.8, 1 ]

In this case we have 4 values, so we have 4 equal regions:

    0.0 - 0.25 ==> 0.0

    0.25 - 0.5 ==> 0.6

    0.5 - 0.75 ==> 0.8

    0.75 - 1.0 ==> 1

So for instance if I get a color value of 0.6, this falls in the third region, and so will get remapped to the third value, which is 0.8.

-}
discrete : List Float -> RemappingFunction
discrete =
    Discrete


{-| For linear, the function is defined by the following linear equation:

    C' = slope * C + intercept

Where C is the input value and C' is the output value.

-}
linear : { slope : Float, intercept : Float } -> RemappingFunction
linear { slope, intercept } =
    Linear slope intercept


{-| For gamma, the function is defined by the following exponential function:

    C' = amplitude * C  ^ exponent + offset

Where C is the input value and C' is the output value.

-}
gamma : { amplitude : Float, exponent : Float, offset : Float } -> RemappingFunction
gamma { amplitude, exponent, offset } =
    Gamma amplitude exponent offset



--


rectToRelative : Rect -> List ( String, String )
rectToRelative rect =
    [ ( "x", String.fromFloat (rect.x * 100) ++ "%" )
    , ( "y", String.fromFloat (rect.y * 100) ++ "%" )
    , ( "width", String.fromFloat (rect.width * 100) ++ "%" )
    , ( "height", String.fromFloat (rect.height * 100) ++ "%" )
    ]


{-| Restricts the filter to a subregion which restricts calculation and rendering of the given filter primitive.

This is specified in relative units (i.e. generally 1 is the whole size of the filter region in the relevant dimension).

**Note:** this is not recursive, but only applies to the top level filter. So:

    Filter.floodStr "blue"
        |> Filter.gaussianBlur 3.5
        |> Filter.withinRelative { x = 0.25, y = 0.25, width = 0.5, height = 0.5 }

is **not** the same as:

    Filter.floodStr "blue"
        |> Filter.withinRelative { x = 0.25, y = 0.25, width = 0.5, height = 0.5 }
        |> Filter.gaussianBlur 3.5
        |> Filter.withinRelative { x = 0.25, y = 0.25, width = 0.5, height = 0.5 }

-}
withinRelative : Rect -> Filter -> Filter
withinRelative rect f =
    case f of
        Filter filt ->
            Filter { filt | args = rectToRelative rect ++ filt.args }

        Virtual _ ->
            f



-- Implementation details


toId : Filter -> String
toId filter =
    case filter of
        Filter args ->
            args.id

        Virtual str ->
            str


makeDefs : Filter -> Dict String (BaseFilter {})
makeDefs filter_ =
    case filter_ of
        Filter args ->
            Dict.insert args.id { name = args.name, id = args.id, args = args.args, children = args.children } args.defs

        Virtual _ ->
            Dict.empty


node =
    VirtualDom.nodeNS "http://www.w3.org/2000/svg"


attribute =
    VirtualDom.attributeNS "http://www.w3.org/2000/svg"


filterElem : Filter -> ( String, VirtualDom.Node msg )
filterElem filter =
    case filter of
        Filter args ->
            ( args.id
            , node "filter"
                [ attribute "id" args.id ]
                (List.map (\def -> filterToNode def) (Dict.values args.defs)
                    ++ [ filterToNode args ]
                )
            )

        Virtual str ->
            ( "", VirtualDom.text "" )


filterToNode : BaseFilter a -> VirtualDom.Node msg
filterToNode args =
    node args.name
        (attribute "result" args.id
            :: List.map (\( k, v ) -> attribute k v) args.args
        )
        (List.map
            (\( name, attrs ) ->
                node name
                    (List.map (\( k, v ) -> attribute k v) attrs)
                    []
            )
            args.children
        )
