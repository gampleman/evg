module AlgebraEvg exposing (Model, Msg, init, subscriptions, update, view)

{-| An algebra playground, ported from Dragology's "animated algebra tree".

The expression is drawn as nested boxes: an operator, then its operands. Drag
any box and it offers every rewrite of the expression that the enabled rules
allow when _that_ part is the one being moved. Drag an operand of `+` past its
neighbour and they swap (commutativity); drag a sum out of a sum and the
brackets move (associativity); drag a factor over a bracket and it multiplies
out (distributivity).

The drag spec is short:

    Drag.closestWith { stickiness = 0, lockPast = Just 20 }
        (List.map (\rewritten -> Drag.between [ state, rewritten ]) (allRewrites state))
        |> Drag.withSnapRadius 1
        |> Drag.chain (dragTargets rules key)

  - every rewrite is a `between` from the current expression to the rewritten
    one, so the boxes slide, grow and shrink continuously as you drag;
  - `closest` follows whichever rewrite you are heading towards, and
    `lockPast` commits to it once you are clearly on the way;
  - `withSnapRadius` and `chain` let one gesture keep going: once you arrive
    at a rewritten expression, the drag carries on from there, so you can
    drag a term along a whole sum in one go.

All the rest is the rewriting engine (pattern matching on trees), which knows
nothing about dragging, and a view that draws boxes.

-}

import Dict exposing (Dict)
import Evg exposing (Evg)
import Evg.Advanced as Advanced
import Evg.Drag as Drag
import Evg.Transform as Transform
import Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Set exposing (Set)



-- EXPRESSIONS


type Tree
    = Tree { id : String, label : String, children : List Tree }


{-| The expression, plus a counter for naming the nodes that rewrites create.
-}
type alias State =
    { tree : Tree
    , nextId : Int
    }


node : String -> String -> List Tree -> Tree
node id label children =
    Tree { id = id, label = label, children = children }


leaf : String -> String -> Tree
leaf id label =
    node id label []


initialState : State
initialState =
    { tree =
        node "r"
            "+"
            [ node "r1"
                "+"
                [ node "r11" "+" [ leaf "r111" "⛅", node "r112" "-" [ leaf "r1121" "🍄" ] ]
                , leaf "r12" "🍄"
                ]
            , node "r2"
                "+"
                [ node "r21" "×" [ leaf "r211" "🎲", leaf "r212" "🦠" ]
                , node "r22" "×" [ leaf "r221" "🎲", leaf "r222" "🐝" ]
                ]
            ]
    , nextId = 0
    }



-- PATTERNS AND REWRITES


{-| A pattern is a tree that may contain wildcards (capital letters), which
match any subtree. Operators can carry a number (`+1`, `+2`) to tell apart two
operators of the same kind within one rule. A `#` marks a trigger: the rule
only applies when the dragged node is one that a trigger matched.
-}
type Pattern
    = Op { id : String, label : String, trigger : Bool, children : List Pattern }
    | Wildcard { id : String, trigger : Bool }


type alias Rewrite =
    { from : Pattern, to : Pattern }


{-| Parse a rule written like `"(+2 #(+1 A B) C)"`.
-}
parsePattern : String -> Maybe Pattern
parsePattern str =
    str
        |> String.replace "(" " ( "
        |> String.replace ")" " ) "
        |> String.replace "#" " # "
        |> String.words
        |> parseTokens
        |> Maybe.andThen
            (\( pattern, rest ) ->
                if List.isEmpty rest then
                    Just pattern

                else
                    Nothing
            )


parseTokens : List String -> Maybe ( Pattern, List String )
parseTokens tokens =
    case tokens of
        "#" :: rest ->
            parseTokens rest |> Maybe.map (Tuple.mapFirst markTrigger)

        "(" :: op :: rest ->
            parseChildren rest []
                |> Maybe.map
                    (\( children, remaining ) ->
                        ( Op { id = op, label = String.left 1 op, trigger = False, children = children }, remaining )
                    )

        word :: rest ->
            Just ( Wildcard { id = word, trigger = False }, rest )

        [] ->
            Nothing


parseChildren : List String -> List Pattern -> Maybe ( List Pattern, List String )
parseChildren tokens acc =
    case tokens of
        ")" :: rest ->
            Just ( List.reverse acc, rest )

        [] ->
            Nothing

        _ ->
            parseTokens tokens
                |> Maybe.andThen (\( child, rest ) -> parseChildren rest (child :: acc))


markTrigger : Pattern -> Pattern
markTrigger pattern =
    case pattern of
        Op p ->
            Op { p | trigger = True }

        Wildcard w ->
            Wildcard { w | trigger = True }


rewrite : String -> String -> List Rewrite
rewrite from to =
    case ( parsePattern from, parsePattern to ) of
        ( Just f, Just t ) ->
            [ { from = f, to = t } ]

        _ ->
            []


type alias RuleSet =
    { title : String
    , subtitle : String
    , example : String
    , rewrites : List Rewrite
    , enabled : Bool
    }


ruleSets : List RuleSet
ruleSets =
    [ { title = "Identity", subtitle = "", example = "0 + A → A", enabled = True, rewrites = rewrite "(+ (0) #A)" "A" ++ rewrite "(+ #A (0))" "A" }
    , { title = "Identity", subtitle = "(reverse)", example = "A → 0 + A", enabled = True, rewrites = rewrite "#A" "(+ (0) A)" }
    , { title = "Commutativity", subtitle = "", example = "A + B → B + A", enabled = True, rewrites = rewrite "(+ #A #B)" "(+ B A)" ++ rewrite "(× #A #B)" "(× B A)" }
    , { title = "Associativity"
      , subtitle = "pull up op"
      , example = "(A + B) + C → A + (B + C)"
      , enabled = False
      , rewrites =
            rewrite "(+2 #(+1 A B) C)" "(+1 A (+2 B C))"
                ++ rewrite "(+1 A #(+2 B C))" "(+2 (+1 A B) C)"
                ++ rewrite "(×2 #(×1 A B) C)" "(×1 A (×2 B C))"
                ++ rewrite "(×1 A #(×2 B C))" "(×2 (×1 A B) C)"
      }
    , { title = "Associativity"
      , subtitle = "pull down op"
      , example = "A + (B + C) → (A + B) + C"
      , enabled = False
      , rewrites =
            rewrite "#(+1 A (+2 B C))" "(+2 (+1 A B) C)"
                ++ rewrite "#(+2 (+1 A B) C)" "(+1 A (+2 B C))"
                ++ rewrite "#(×1 A (×2 B C))" "(×2 (×1 A B) C)"
                ++ rewrite "#(×2 (×1 A B) C)" "(×1 A (×2 B C))"
      }
    , { title = "Associativity"
      , subtitle = "pull up operand"
      , example = "(A + B) + C → A + (B + C)"
      , enabled = False
      , rewrites =
            rewrite "(+2 (+1 #A B) C)" "(+1 A (+2 B C))"
                ++ rewrite "(+1 A (+2 B #C))" "(+2 (+1 A B) C)"
                ++ rewrite "(×2 (×1 #A B) C)" "(×1 A (×2 B C))"
                ++ rewrite "(×1 A (×2 B #C))" "(×2 (×1 A B) C)"
      }
    , { title = "Associativity"
      , subtitle = "pull down operand"
      , example = "A + (B + C) → (A + B) + C"
      , enabled = False
      , rewrites =
            rewrite "(+1 #A (+2 B C))" "(+2 (+1 A B) C)"
                ++ rewrite "(+2 (+1 A B) #C)" "(+1 A (+2 B C))"
                ++ rewrite "(×1 #A (×2 B C))" "(×2 (×1 A B) C)"
                ++ rewrite "(×2 (×1 A B) #C)" "(×1 A (×2 B C))"
      }
    , { title = "Distributivity"
      , subtitle = "distribute (drag +)"
      , example = "A × (B + C) → A × B + A × C"
      , enabled = False
      , rewrites = rewrite "(× A #(+ B C))" "(+ (× A B) (× A C))" ++ rewrite "(× #(+ B C) A)" "(+ (× B A) (× C A))"
      }
    , { title = "Distributivity"
      , subtitle = "distribute (drag operand)"
      , example = "A × (B + C) → A × B + A × C"
      , enabled = False
      , rewrites = rewrite "(× #A (+ B C))" "(+ (× A B) (× A C))" ++ rewrite "(× (+ B C) #A)" "(+ (× B A) (× C A))"
      }
    , { title = "Distributivity"
      , subtitle = "factor (drag +)"
      , example = "A × B + A × C → A × (B + C)"
      , enabled = False
      , rewrites = rewrite "#(+ (× A B) (× A C))" "(× A (+ B C))" ++ rewrite "#(+ (× B A) (× C A))" "(× A (+ B C))"
      }
    , { title = "Distributivity"
      , subtitle = "factor (drag operand)"
      , example = "A × B + A × C → A × (B + C)"
      , enabled = False
      , rewrites =
            rewrite "(+ (× #A B) (× A C))" "(× A (+ B C))"
                ++ rewrite "(+ (× A B) (× #A C))" "(× A (+ B C))"
                ++ rewrite "(+ (× B #A) (× C A))" "(× A (+ B C))"
                ++ rewrite "(+ (× B A) (× C #A))" "(× A (+ B C))"
      }
    ]



-- MATCHING


type alias Match =
    { wildcards : Dict String Tree
    , ops : Dict String Tree
    , triggered : Bool
    }


treeId : Tree -> String
treeId (Tree t) =
    t.id


{-| Same shape and labels, ignoring ids. A wildcard used twice in a rule must
match equal subtrees.
-}
sameShape : Tree -> Tree -> Bool
sameShape (Tree a) (Tree b) =
    a.label == b.label && List.length a.children == List.length b.children && List.all identity (List.map2 sameShape a.children b.children)


matchPattern : String -> Pattern -> Tree -> Maybe Match
matchPattern triggerId pattern ((Tree t) as tree) =
    case pattern of
        Wildcard w ->
            Just { wildcards = Dict.singleton w.id tree, ops = Dict.empty, triggered = w.trigger && t.id == triggerId }

        Op p ->
            if p.label /= t.label || List.length p.children /= List.length t.children then
                Nothing

            else
                List.map2 (matchPattern triggerId) p.children t.children
                    |> List.foldl
                        (\childMatch acc ->
                            Maybe.map2 merge acc childMatch |> Maybe.andThen identity
                        )
                        (Just { wildcards = Dict.empty, ops = Dict.empty, triggered = p.trigger && t.id == triggerId })
                    |> Maybe.map (\m -> { m | ops = Dict.insert p.id tree m.ops })


{-| Combine the bindings of two sibling matches.
-}
merge : Match -> Match -> Maybe Match
merge acc child =
    Dict.foldl
        (\k v maybeAcc ->
            maybeAcc
                |> Maybe.andThen
                    (\m ->
                        case Dict.get k m.wildcards of
                            Just existing ->
                                if sameShape existing v then
                                    Just m

                                else
                                    Nothing

                            Nothing ->
                                Just { m | wildcards = Dict.insert k v m.wildcards }
                    )
        )
        (Just { acc | ops = Dict.union acc.ops child.ops, triggered = acc.triggered || child.triggered })
        child.wildcards


{-| Build the right-hand side of a rule. Matched subtrees keep their ids, so
they glide to their new places; nodes the rule creates get fresh ids, so they
fade in. A wildcard or operator used a second time is copied with fresh ids.
-}
build : Match -> Int -> Pattern -> ( Tree, Int, Set String )
build m counter pattern =
    buildHelp m pattern ( counter, Set.empty )
        |> (\( tree, ( c, used ) ) -> ( tree, c, used ))


buildHelp : Match -> Pattern -> ( Int, Set String ) -> ( Tree, ( Int, Set String ) )
buildHelp m pattern ( counter, used ) =
    case pattern of
        Wildcard w ->
            case Dict.get w.id m.wildcards of
                Just subtree ->
                    if Set.member w.id used then
                        copyFresh subtree counter |> Tuple.mapSecond (\c -> ( c, used ))

                    else
                        ( subtree, ( counter, Set.insert w.id used ) )

                Nothing ->
                    ( leaf ("missing" ++ String.fromInt counter) "?", ( counter + 1, used ) )

        Op p ->
            let
                ( id, ( counter2, used2 ) ) =
                    case Dict.get p.id m.ops of
                        Just matched ->
                            if Set.member ("op:" ++ p.id) used then
                                ( fresh counter, ( counter + 1, used ) )

                            else
                                ( treeId matched, ( counter, Set.insert ("op:" ++ p.id) used ) )

                        Nothing ->
                            ( fresh counter, ( counter + 1, used ) )

                ( children, finalState ) =
                    List.foldl
                        (\child ( acc, st ) ->
                            let
                                ( built, st2 ) =
                                    buildHelp m child st
                            in
                            ( built :: acc, st2 )
                        )
                        ( [], ( counter2, used2 ) )
                        p.children
            in
            ( node id p.label (List.reverse children), finalState )


fresh : Int -> String
fresh counter =
    "n" ++ String.fromInt counter


copyFresh : Tree -> Int -> ( Tree, Int )
copyFresh (Tree t) counter =
    let
        ( children, next ) =
            List.foldl
                (\child ( acc, c ) ->
                    let
                        ( copied, c2 ) =
                            copyFresh child c
                    in
                    ( copied :: acc, c2 )
                )
                ( [], counter + 1 )
                t.children
    in
    ( node (fresh counter) t.label (List.reverse children), next )


{-| Every expression reachable by applying one rule somewhere in the tree,
with the dragged node as the trigger.
-}
allRewrites : List Rewrite -> String -> State -> List State
allRewrites rules triggerId state =
    rewritesAt rules triggerId state.nextId state.tree
        |> List.map (\( tree, next ) -> { tree = tree, nextId = next })


rewritesAt : List Rewrite -> String -> Int -> Tree -> List ( Tree, Int )
rewritesAt rules triggerId counter ((Tree t) as tree) =
    let
        here =
            List.filterMap
                (\rule ->
                    matchPattern triggerId rule.from tree
                        |> Maybe.andThen
                            (\m ->
                                if m.triggered then
                                    let
                                        ( built, next, _ ) =
                                            build m counter rule.to
                                    in
                                    Just ( built, next )

                                else
                                    Nothing
                            )
                )
                rules

        inChildren =
            List.indexedMap
                (\i child ->
                    rewritesAt rules triggerId counter child
                        |> List.map
                            (\( newChild, next ) ->
                                ( node t.id
                                    t.label
                                    (List.indexedMap
                                        (\j c ->
                                            if i == j then
                                                newChild

                                            else
                                                c
                                        )
                                        t.children
                                    )
                                , next
                                )
                            )
                )
                t.children
                |> List.concat
    in
    here ++ inChildren



-- DRAGGING


dragTargets : List Rewrite -> String -> State -> Drag.Spec State
dragTargets rules key state =
    case allRewrites rules key state of
        [] ->
            Drag.between [ state ]

        rewritten ->
            Drag.closestWith { stickiness = 0, lockPast = Just 20 }
                (List.map (\r -> Drag.between [ state, r ]) rewritten)
                |> Drag.withSnapRadius 1
                |> Drag.chain (dragTargets rules key)



-- DRAWING


type alias Drawn =
    { element : Evg Msg, width : Float, height : Float }


expression : List Rewrite -> Drag.View State Msg
expression rules ctx state =
    Evg.group [ Transform.translate 10 10 ]
        [ (drawTree rules ctx state 0 state.tree).element ]


drawTree : List Rewrite -> Drag.Context State Msg -> State -> Int -> Tree -> Drawn
drawTree rules ctx state depth (Tree t) =
    let
        gap =
            10

        padding =
            5

        labelWidth =
            20

        drawnChildren =
            List.map (drawTree rules ctx state (depth + 1)) t.children

        ( placedChildren, childrenHeight ) =
            List.foldl
                (\child ( acc, y ) ->
                    ( Evg.group [ Transform.translate 0 y ] [ child.element ] :: acc, y + child.height + gap )
                )
                ( [], 0 )
                drawnChildren
                |> Tuple.mapBoth List.reverse (\y -> max 20 (y - gap))

        innerWidth =
            labelWidth
                + (case List.maximum (List.map .width drawnChildren) of
                    Just widest ->
                        gap + widest

                    Nothing ->
                        0
                  )

        width =
            innerWidth + padding * 2

        height =
            childrenHeight + padding * 2

        shade =
            toFloat depth
    in
    { width = width
    , height = height
    , element =
        Evg.group [ Drag.onDrag ctx t.id (\() -> dragTargets rules t.id state) ]
            (Evg.rect
                [ Evg.cornerRadius (min 14 (0.3 * min width height))
                , Evg.fillStr ("rgba(180, 170, 150, " ++ String.fromFloat (min 0.15 (0.02 + shade * 0.03)) ++ ")")
                , Evg.strokeStr ("rgba(140, 130, 115, " ++ String.fromFloat (min 0.5 (0.25 + shade * 0.08)) ++ ")")
                , Evg.strokeWidth 0.75
                ]
                { x = 0, y = 0, width = width, height = height }
                :: Evg.text
                    [ Evg.fontSize 18
                    , Evg.fillStr "#3a3a38"
                    , Advanced.customAttribute "dominant-baseline" "middle"
                    ]
                    { x = padding + labelWidth / 2, y = padding + childrenHeight / 2, anchor = Evg.Middle }
                    t.label
                :: (if List.isEmpty placedChildren then
                        []

                    else
                        [ Evg.group [ Transform.translate (padding + labelWidth + gap) padding ] placedChildren ]
                   )
            )
    }



-- PROGRAM


type alias Model =
    { drag : Drag.Model State
    , enabled : List Bool
    }


type Msg
    = DragMsg (Drag.Msg State)
    | Toggled Int Bool


init : Model
init =
    { drag = Drag.init initialState
    , enabled = List.map .enabled ruleSets
    }


activeRules : Model -> List Rewrite
activeRules model =
    List.map2
        (\set on ->
            if on then
                set.rewrites

            else
                []
        )
        ruleSets
        model.enabled
        |> List.concat


update : Msg -> Model -> Model
update msg model =
    case msg of
        DragMsg dragMsg ->
            { model | drag = Drag.update (expression (activeRules model)) dragMsg model.drag }

        Toggled index on ->
            { model
                | enabled =
                    List.indexedMap
                        (\i e ->
                            if i == index then
                                on

                            else
                                e
                        )
                        model.enabled
            }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map DragMsg (Drag.subscriptions model.drag)


view : Model -> Html Msg
view model =
    Html.div [ HA.style "display" "flex", HA.style "gap" "16px", HA.style "flex-wrap" "wrap" ]
        [ Evg.svg [] { width = 320, height = 380 } [ Drag.view DragMsg (expression (activeRules model)) model.drag ]
        , Html.div [ HA.style "font-size" "13px", HA.style "line-height" "1.4" ]
            (Html.div [ HA.style "font-weight" "bold", HA.style "margin-bottom" "6px" ] [ Html.text "Rewrite rules" ]
                :: List.indexedMap (viewRuleSet model) ruleSets
            )
        ]


viewRuleSet : Model -> Int -> RuleSet -> Html Msg
viewRuleSet model index set =
    Html.label [ HA.style "display" "block", HA.style "margin-bottom" "6px", HA.style "cursor" "pointer" ]
        [ Html.input
            [ HA.type_ "checkbox"
            , HA.checked (List.drop index model.enabled |> List.head |> Maybe.withDefault False)
            , HE.onCheck (Toggled index)
            ]
            []
        , Html.b [] [ Html.text (" " ++ set.title) ]
        , Html.text
            (if String.isEmpty set.subtitle then
                ""

             else
                " (" ++ set.subtitle ++ ")"
            )
        , Html.br [] []
        , Html.span [ HA.style "color" "#666", HA.style "margin-left" "20px" ] [ Html.text set.example ]
        ]
