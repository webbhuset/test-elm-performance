module Main exposing (..)

import AnimationFrame
import Css
import Element exposing (Element)
import Html exposing (Html)
import Html.Attributes as Html
import Html.Events as Html
import Html.Keyed as Keyed
import Html.Lazy as Html
import Html.Styled as Styled
import Html.Styled.Attributes as StyledAttrs
import Time exposing (Time)

import Impl.HtmlCss
import Impl.HtmlInline
import Impl.StylishElephants
import Impl.ElmCss


type alias State =
    { open : Maybe Int
    , impl : Impl
    , count : Int
    , actions : List ( Int, Msg )
    , times : List Time
    , frameCount : Int
    , isRunning : Bool
    }


type alias Accordion =
    { heading : String
    , content : String
    }


accordion : Accordion
accordion =
    { heading = "Accorion Item (click to open)"
    , content = "Ipsum corrupti repudiandae hic deleniti ex aut adipisci ducimus et facere magni officiis? Ut debitis eius amet harum aliquam magnam perferendis dignissimos, quidem fugit quae soluta optio excepturi! Repellat cumque?"
    }


testCount : Int
testCount =
    30


type Impl
    = Impl_HtmlCss
    | Impl_HtmlInline
    | Impl_StylishElephants
    | Impl_ElmCss


type Msg
    = Open Int
    | StartTest
    | TickTest Time
    | SetImpl Impl
    | SetCount Int


main : Program Never State Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : ( State, Cmd Msg )
init =
    { open = Nothing
    , impl = Impl_HtmlCss
    , count = 64
    , actions = makeActions 100
    , times = []
    , frameCount = 0
    , isRunning = False
    }
        |> noCmd


makeActions : Int -> List ( Int, Msg )
makeActions count =
    List.range 0 (count - 1)
        |> List.map (\i -> ( i, Open i ))


update : Msg -> State -> ( State, Cmd Msg )
update msg state =
    case msg of
        Open idx ->
            { state
                | open =
                    case state.open of
                        Just i ->
                            if i == idx then
                                Nothing
                            else
                                Just idx

                        Nothing ->
                            Just idx
            }
                |> noCmd

        SetImpl impl ->
            { state | impl = impl }
                |> noCmd

        SetCount count ->
            { state
                | count = count
                , actions = makeActions count
            }
                |> noCmd

        StartTest ->
            ( { state
                | open = Nothing
                , times = []
                , isRunning = True
                , frameCount = 0
              }
            , Cmd.none
            )

        TickTest diff ->
            { state
                | times = diff :: state.times
                , frameCount = state.frameCount + 1
                , isRunning = state.frameCount < testCount
                , open = Just (state.frameCount % state.count)
            }
                |> noCmd


subscriptions : State -> Sub Msg
subscriptions state =
    if state.isRunning then
        AnimationFrame.diffs TickTest
    else
        Sub.none


noCmd : State -> ( State, Cmd Msg )
noCmd s =
    ( s, Cmd.none )



-- VIew


view : State -> Html Msg
view state =
    Html.div
        [ Html.class "page" ]
        [ Html.lazy heading 1
        , renderSummary state
        , Html.h2 [] [ Html.text <| "Implementation: " ++ implLabel state.impl ]
        , Html.p [] [ Html.text <| "Number of accordions: " ++ toString state.count ]
        , Keyed.node "div" [] [ renderAccordions state ]
        , Html.node "style" [] [ Html.text Impl.HtmlCss.css ]
        ]


heading : a -> Html Msg
heading _ =
    Html.div []
        [ Html.p []
            [ Html.text "This is an attempt to compare the rendering performance of the Virtual Dom with three different implementations for style."
            , Html.ul []
                [ Html.li [] [ Html.text "HTML with CSS classes (only CSS classes handled by VDOM)" ]
                , Html.li [] [ Html.text "HTML with inline style (all style is handled by VDOM)" ]
                , Html.li [] [ Html.text "Style Elements (stylish elephants)" ]
                , Html.li [] [ Html.text "elm-css (rtfeldman/elm-css with inline styles)" ]
                ]
            , Html.text "The rendering times are logged to the console and performance timeline (Chrome)."
            , Html.br [] []
            , Html.text "Three different metrics are logged:"
            , Html.ul []
                [ Html.li [] [ Html.text "Build VDOM: This is the view function in the Elm program." ]
                , Html.li [] [ Html.text "Diff: The diffing of VDOM" ]
                , Html.li [] [ Html.text "Apply: Applying the diff to the \"real\" DOM." ]
                ]
            ]
        , Html.p [] [ Html.text "Use implementation:" ]
        , Html.div [ Html.class "header-button-row" ]
            [ Html.button [ Html.onClick (SetImpl Impl_HtmlCss) ] [ Html.text "HTML / CSS" ]
            , Html.button [ Html.onClick (SetImpl Impl_HtmlInline) ] [ Html.text "HTML Inline" ]
            , Html.button [ Html.onClick (SetImpl Impl_StylishElephants) ] [ Html.text "Stylish Elephants" ]
            , Html.button [ Html.onClick (SetImpl Impl_ElmCss) ] [ Html.text "elm-css" ]
            ]
        , Html.p [] [ Html.text "Repeat the accordion this many times:" ]
        , Html.div [ Html.class "header-button-row" ]
            [ Html.button [ Html.onClick (SetCount 64) ] [ Html.text "64" ]
            , Html.button [ Html.onClick (SetCount 128) ] [ Html.text "128" ]
            , Html.button [ Html.onClick (SetCount 256) ] [ Html.text "256" ]
            , Html.button [ Html.onClick (SetCount 512) ] [ Html.text "512" ]
            , Html.button [ Html.onClick (SetCount 1024) ] [ Html.text "1024" ]
            , Html.button [ Html.onClick (SetCount 2048) ] [ Html.text "2048" ]
            , Html.button [ Html.onClick (SetCount 4096) ] [ Html.text "4096" ]
            , Html.button [ Html.onClick (SetCount 8192) ] [ Html.text "8192" ]
            ]
        , Html.p []
            [ Html.text <| "This will render " ++ toString testCount ++ " frames and measure the time between each animation frame. "
            , Html.text <| "On each frame the next accordion is opened."
            ]
        , Html.button [ Html.onClick StartTest ] [ Html.text "Run Test" ]
        , Html.hr [] []
        ]


renderSummary : State -> Html Msg
renderSummary state =
    if state.isRunning then
        Html.div [] [ Html.text "Wait for test to complete" ]
    else if List.length state.times == 0 then
        Html.div [] [ Html.text "Hit start to run test" ]
    else
        let
            testSum =
                List.sum state.times

            avg =
                testSum / (toFloat <| List.length state.times)
        in
        Html.div []
            [ Html.text <| "Total time: " ++ (toString <| round testSum) ++ "ms | "
            , Html.text <| "Avg time / frame: " ++ (toString <| round avg) ++ "ms | "
            , Html.text <| "Avg frame rate: " ++ (toString <| round (1000 / avg)) ++ " frames / sec"
            ]


implLabel : Impl -> String
implLabel impl =
    case impl of
        Impl_HtmlCss ->
            "HTML / CSS"

        Impl_HtmlInline ->
            "HTML with inline style"

        Impl_StylishElephants ->
            "Stylish Elephants (6.0.2)"

        Impl_ElmCss ->
            "elm-css (14.0.0)"


renderAccordions : State -> ( String, Html Msg )
renderAccordions state =
    case state.impl of
        Impl_HtmlCss ->
            state.actions
                |> List.map
                    (\( idx, openMsg ) ->
                        Impl.HtmlCss.renderAccordion
                            openMsg
                            (Just idx == state.open)
                            accordion
                    )
                |> Html.div [ Html.class "wrapper" ]
                |> (,) "html-css"

        Impl_HtmlInline ->
            state.actions
                |> List.map
                    (\( idx, openMsg ) ->
                        Impl.HtmlInline.renderAccordion
                            openMsg
                            (Just idx == state.open)
                            accordion
                    )
                |> Html.div
                    [ Html.style
                        [ ( "padding", "32px" )
                        ]
                    ]
                |> (,) "html-inline"

        Impl_StylishElephants ->
            state.actions
                |> List.map
                    (\( idx, openMsg ) ->
                        Impl.StylishElephants.renderAccordion
                        openMsg
                        (Just idx == state.open)
                        accordion
                    )
                |> Element.column [ Element.padding 32, Element.spacing 16 ]
                |> Element.layout []
                |> (,) "style-elements"

        Impl_ElmCss ->
            state.actions
                |> List.map
                    (\( idx, openMsg ) ->
                        Impl.ElmCss.renderAccordion
                            openMsg
                            (Just idx == state.open)
                            accordion
                    )
                |> Styled.div
                    [ StyledAttrs.css
                        [ Css.padding (Css.px 32)
                        ]
                    ]
                |> Styled.toUnstyled
                |> (,) "elm-css"




