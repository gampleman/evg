module ArmElmSvg exposing (Model, Msg, init, subscriptions, update, view)

{-| The same robot arm, by hand with `elm/svg`.

Drawing the arm is just as easy here. Dragging it is not: we have to solve
the inverse kinematics ourselves. Given where the pointer is, which joint
angles put the hand there? For two segments there is a closed form (the law
of cosines), but it needs care:

  - points out of reach have to be pulled back onto the reachable circle;
  - the elbow's range has to be enforced, and when the solution falls outside
    it, the elbow must be clamped and the shoulder re-solved for the clamped
    elbow, or the hand jumps away from the pointer;
  - the grab offset has to be remembered so the hand doesn't jump to the
    pointer when grabbed off-centre;
  - pointer coordinates have to be converted from window pixels to the arm's
    coordinate system (mouse only; touch would need separate handling).

A third segment, or a joint that slides instead of turning, and there would
be no formula at all.

-}

import Browser.Events
import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder)
import Svg exposing (Svg)
import Svg.Attributes as SA
import Svg.Events


type alias Model =
    { shoulder : Float
    , elbow : Float
    , drag : Maybe Drag
    }


type Joint
    = Hand
    | Elbow


{-| `origin` converts client pixels into the arm's coordinates (the shoulder
is at the origin), `grab` is where on the joint the pointer took hold.
-}
type alias Drag =
    { joint : Joint
    , origin : ( Float, Float )
    , grab : ( Float, Float )
    }


type Msg
    = Pressed Joint Pointer
    | Moved ( Float, Float )
    | Released


type alias Pointer =
    { offset : ( Float, Float )
    , client : ( Float, Float )
    }


upper : Float
upper =
    80


fore : Float
fore =
    70


init : Model
init =
    { shoulder = -60, elbow = 70, drag = Nothing }


update : Msg -> Model -> Model
update msg model =
    case msg of
        Pressed which pointer ->
            let
                ( ox, oy ) =
                    pointer.offset

                ( cx, cy ) =
                    pointer.client

                -- The svg's top-left in client pixels, then shifted to the
                -- shoulder at (150, 150).
                origin =
                    ( cx - ox + 150, cy - oy + 150 )

                ( jx, jy ) =
                    case which of
                        Hand ->
                            handPosition model

                        Elbow ->
                            elbowPosition model
            in
            { model | drag = Just { joint = which, origin = origin, grab = ( jx - (ox - 150), jy - (oy - 150) ) } }

        Moved ( cx, cy ) ->
            case model.drag of
                Just drag ->
                    let
                        target =
                            ( cx - Tuple.first drag.origin + Tuple.first drag.grab
                            , cy - Tuple.second drag.origin + Tuple.second drag.grab
                            )
                    in
                    case drag.joint of
                        Hand ->
                            solveHand target model

                        Elbow ->
                            { model | shoulder = angleTo target }

                Nothing ->
                    model

        Released ->
            { model | drag = Nothing }


{-| Two-link inverse kinematics, with the elbow limited to 0°–150°.
-}
solveHand : ( Float, Float ) -> Model -> Model
solveHand ( tx, ty ) model =
    let
        reach =
            clamp (abs (upper - fore) + 0.001) (upper + fore - 0.001) (sqrt (tx * tx + ty * ty))

        -- Law of cosines for the elbow angle.
        cosElbow =
            (reach * reach - upper * upper - fore * fore) / (2 * upper * fore)

        elbow =
            clamp 0 150 (toDegrees (acos (clamp -1 1 cosElbow)))

        -- With the elbow fixed, the hand lies at a known angle from the
        -- upper arm; turn the shoulder so that angle points at the target.
        er =
            degrees elbow

        offsetAngle =
            atan2 (fore * sin er) (upper + fore * cos er)
    in
    { model | elbow = elbow, shoulder = toDegrees (atan2 ty tx - offsetAngle) }


angleTo : ( Float, Float ) -> Float
angleTo ( x, y ) =
    toDegrees (atan2 y x)


toDegrees : Float -> Float
toDegrees r =
    r * 180 / pi


elbowPosition : Model -> ( Float, Float )
elbowPosition model =
    ( upper * cos (degrees model.shoulder), upper * sin (degrees model.shoulder) )


handPosition : Model -> ( Float, Float )
handPosition model =
    let
        ( ex, ey ) =
            elbowPosition model

        a =
            degrees (model.shoulder + model.elbow)
    in
    ( ex + fore * cos a, ey + fore * sin a )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.drag of
        Just _ ->
            Sub.batch
                [ Browser.Events.onMouseMove (Decode.map Moved (pair "clientX" "clientY"))
                , Browser.Events.onMouseUp (Decode.succeed Released)
                ]

        Nothing ->
            Sub.none


pair : String -> String -> Decoder ( Float, Float )
pair kx ky =
    Decode.map2 Tuple.pair (Decode.field kx Decode.float) (Decode.field ky Decode.float)


pointerDecoder : Decoder Pointer
pointerDecoder =
    Decode.map2 Pointer (pair "offsetX" "offsetY") (pair "clientX" "clientY")


view : Model -> Html Msg
view model =
    let
        rotate deg =
            "rotate(" ++ String.fromFloat deg ++ ")"
    in
    Svg.svg [ SA.width "300", SA.height "260", SA.viewBox "0 0 300 260" ]
        [ Svg.g [ SA.transform "translate(150 150)" ]
            [ Svg.rect [ SA.x "-30", SA.y "0", SA.width "60", SA.height "16", SA.rx "4", SA.fill "#495057" ] []
            , Svg.g [ SA.transform (rotate model.shoulder) ]
                [ segment upper
                , Svg.g [ SA.transform ("translate(80 0) " ++ rotate model.elbow) ]
                    [ segment fore
                    , joint Hand "#f08c00" 12 fore
                    ]
                , joint Elbow "#1c7ed6" 9 upper
                ]
            , Svg.circle [ SA.r "9", SA.fill "#343a40" ] []
            ]
        ]


segment : Float -> Svg msg
segment length =
    Svg.line [ SA.x2 (String.fromFloat length), SA.stroke "#adb5bd", SA.strokeWidth "14", SA.strokeLinecap "round" ] []


joint : Joint -> String -> Float -> Float -> Svg Msg
joint which color r x =
    Svg.circle
        [ SA.cx (String.fromFloat x)
        , SA.r (String.fromFloat r)
        , SA.fill color
        , SA.cursor "grab"
        , Svg.Events.on "pointerdown" (Decode.map (Pressed which) pointerDecoder)
        ]
        []
