module ToggleElmSvg exposing (Model, Msg, init, subscriptions, update, view)

{-| The same toggle switch, by hand with `elm/svg`.

What we have to do ourselves:

  - decode pointer events, and track the mouse on the window so the drag
    survives leaving the knob (touch would need separate handling on the
    element; see `InteractiveElmSvg`);
  - turn pointer movement into a knob position, clamped to the track;
  - work out the track colour mid-drag by blending the two colours ourselves;
  - decide on release which side to snap to;
  - animate the snap. We cheat with a CSS transition with an overshooting
    curve, switched off while dragging so the knob doesn't lag behind the
    pointer.

-}

import Browser.Events
import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder)
import Svg
import Svg.Attributes as SA
import Svg.Events


type alias Model =
    { on : Bool
    , drag : Maybe Drag
    }


{-| Where the drag started (client pixels) and where the knob was then.
-}
type alias Drag =
    { startX : Float
    , startKnob : Float
    , knob : Float
    }


type Msg
    = Pressed Float
    | Moved Float
    | Released


init : Model
init =
    { on = False, drag = Nothing }


offX : Float
offX =
    30


onX : Float
onX =
    90


update : Msg -> Model -> Model
update msg model =
    case msg of
        Pressed x ->
            let
                knob =
                    knobX model
            in
            { model | drag = Just { startX = x, startKnob = knob, knob = knob } }

        Moved x ->
            case model.drag of
                Just drag ->
                    { model | drag = Just { drag | knob = clamp offX onX (drag.startKnob + x - drag.startX) } }

                Nothing ->
                    model

        Released ->
            case model.drag of
                Just drag ->
                    { on = drag.knob > (offX + onX) / 2, drag = Nothing }

                Nothing ->
                    model


knobX : Model -> Float
knobX model =
    case model.drag of
        Just drag ->
            drag.knob

        Nothing ->
            if model.on then
                onX

            else
                offX


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.drag of
        Just _ ->
            Sub.batch
                [ Browser.Events.onMouseMove (Decode.map Moved clientX)
                , Browser.Events.onMouseUp (Decode.succeed Released)
                ]

        Nothing ->
            Sub.none


clientX : Decoder Float
clientX =
    Decode.field "clientX" Decode.float


view : Model -> Html Msg
view model =
    let
        knob =
            knobX model

        -- How far "on" the knob is, from 0 to 1, for the track colour.
        progress =
            (knob - offX) / (onX - offX)

        mix a b =
            String.fromFloat (a + (b - a) * progress)

        trackColor =
            "rgb(" ++ mix 206 64 ++ "," ++ mix 212 192 ++ "," ++ mix 218 87 ++ ")"

        transition =
            case model.drag of
                Just _ ->
                    "none"

                Nothing ->
                    "cx 0.6s cubic-bezier(.3,1.8,.5,1), fill 0.3s"
    in
    Svg.svg [ SA.width "300", SA.height "120", SA.viewBox "0 0 300 120" ]
        [ Svg.g [ SA.transform "translate(90 30)" ]
            [ Svg.rect
                [ SA.width "120"
                , SA.height "60"
                , SA.rx "30"
                , SA.fill trackColor
                , SA.style ("transition: " ++ transition)
                ]
                []
            , Svg.circle
                [ SA.cx (String.fromFloat knob)
                , SA.cy "30"
                , SA.r "26"
                , SA.fill "white"
                , SA.stroke "#868e96"
                , SA.cursor "grab"
                , SA.style ("transition: " ++ transition)
                , Svg.Events.on "pointerdown" (Decode.map Pressed clientX)
                ]
                []
            ]
        ]
