module Main exposing (..)

import Html exposing (Html)
import Html.Keyed as Keyed
import Html.Events as Html
import Html.Attributes as Html
import Html.Lazy as Html
import Color
import Element exposing (Element)
import Element.Events as Element
import Element.Background as Bg
import Element.Border as Border
import Element.Font as Font
import Element.Region as Region


type alias State =
    { open : Maybe Int
    , impl : Impl
    , count : Int
    , actions : List (Int, Msg)
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


type Impl
    = Impl_HtmlCss
    | Impl_HtmlInline
    | Impl_SE


type Msg
    = Open Int
    | SetImpl Impl
    | SetCount Int


main =
    Html.beginnerProgram
        { model = init
        , update = update
        , view = view
        }


init : State
init =
    { open = Nothing
    , impl = Impl_HtmlCss
    , count = 100
    , actions = makeActions 100
    }


makeActions : Int -> List (Int, Msg)
makeActions count =
    List.range 1 count
        |> List.map (\i -> (i, Open i))


update : Msg -> State -> State
update msg state =
    case msg of
        Open idx ->
            { state
                | open =
                    case state.open of
                        Just i ->
                            if i == idx then Nothing else Just idx

                        Nothing ->
                            Just idx
            }

        SetImpl impl ->
            { state | impl = impl }

        SetCount count ->
            { state
                | count = count
                , actions = makeActions count
            }


view : State -> Html Msg
view state =
    Html.div
        [ Html.class "page" ]
        [ Html.lazy heading 1
        , Html.h2 [] [ Html.text <| "Implementation: " ++ (implLabel state.impl) ]
        , Html.p [] [ Html.text <| "Number of accordions: " ++ (toString state.count) ]
        , Keyed.node "div" [] [ renderAccordions state ]
        , Html.node "style" [] [ Html.text css ]
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
            [ Html.button [ Html.onClick (SetImpl Impl_HtmlCss ) ] [ Html.text "HTML / CSS" ]
            , Html.button [ Html.onClick (SetImpl Impl_HtmlInline ) ] [ Html.text "HTML Inline" ]
            , Html.button [ Html.onClick (SetImpl Impl_SE ) ] [ Html.text "Stylish Elephants" ]
            ]
        , Html.p [] [ Html.text "Repeat the accordion this many times:" ]
        , Html.div [ Html.class "header-button-row" ]
            [ Html.button [ Html.onClick (SetCount 10) ] [ Html.text "10" ]
            , Html.button [ Html.onClick (SetCount 50) ] [ Html.text "50" ]
            , Html.button [ Html.onClick (SetCount 100) ] [ Html.text "100" ]
            , Html.button [ Html.onClick (SetCount 500) ] [ Html.text "500" ]
            , Html.button [ Html.onClick (SetCount 1000) ] [ Html.text "1 000" ]
            , Html.button [ Html.onClick (SetCount 5000) ] [ Html.text "5 000" ]
            , Html.button [ Html.onClick (SetCount 10000) ] [ Html.text "10 000" ]
            ]
        , Html.hr [] []
        ]


implLabel : Impl -> String
implLabel impl =
    case impl of
        Impl_HtmlCss ->
            "HTML / CSS"

        Impl_HtmlInline ->
            "HTML with inline style"

        Impl_SE ->
            "Stylish Elephants (6.0.2)"


renderAccordions : State -> (String, Html Msg)
renderAccordions state =
    case state.impl of
        Impl_HtmlCss ->
            state.actions
                |> List.map (\(idx, openMsg) -> accordionHtmlCss openMsg (Just idx == state.open) accordion)
                |> Html.div [ Html.class "wrapper" ]
                |> (,) "html-css"

        Impl_HtmlInline ->
            state.actions
                |> List.map (\(idx, openMsg) -> accordionHtmlInline openMsg (Just idx == state.open) accordion)
                |> Html.div
                    [ Html.style
                        [ ( "padding", "32px" )
                        ]
                    ]
                |> (,) "html-inline"

        Impl_SE ->
            state.actions
                |> List.map (\(idx, openMsg) -> accordionSE openMsg (Just idx == state.open) accordion)
                |> Element.column [ Element.padding 32, Element.spacing 16 ]
                |> Element.layout []
                |> (,) "style-elements"


-- HTML / CSS

accordionHtmlCss : msg -> Bool -> Accordion -> Html msg
accordionHtmlCss openMsg isOpen acc =
    Html.div
        [ Html.class "accordion" ]
        [ Html.h4
            [ Html.onClick openMsg
            , Html.class "header"
            ]
            [ Html.text acc.heading
            ]
        , Html.p
            [ Html.class "content"
            , Html.classList
                [ ("open", isOpen )
                ]
            ]
            [ Html.text acc.content
            ]
        ]

css : String
css =
    """
.page {
    padding: 12px;
}
.header-button-row {
    margin: 8px 0;
}

.header-button-row button {
    margin: 0 4px;
}
.wrapper {
    padding: 32px;
}
.accordion .header {
    cursor: pointer;
    margin: 0;
    font-family: Arial, sans-serif;
    font-weight: 400;
    border: solid 1px #aaa;
    background: #eee;
    padding: 8px;
    font-size: 20px;
    line-height: 20px;
}
.accordion .header:hover {
    border-color: #666;
}

.accordion .content {
    overflow: hidden;
    height: 0;
    font-family: Arial, sans-serif;
    margin: 12px 0;
    line-height: 21px;
}

.accordion .content.open {
    height: auto;
}
"""

-- HTML with inline style

accordionHtmlInline : msg -> Bool -> Accordion -> Html msg
accordionHtmlInline openMsg isOpen acc =
    Html.div
        []
        [ Html.h4
            [ Html.onClick openMsg
            , Html.style
                [ ( "margin", "0" )
                , ( "cursor", "pointer" )
                , ( "font-family", "Arial, sans-serif" )
                , ( "background", "#eee" )
                , ( "padding", "8px" )
                , ( "font-weight", "400" )
                , ( "font-size", "20px" )
                , ( "border", "solid 1px #aaa" )
                , ( "line-height", "20px" )
                ]
            ]
            [ Html.text acc.heading
            ]
        , Html.p
            [ Html.style
                [ if isOpen then ( "height", "auto" ) else ( "height", "0" )
                , ( "overflow", "hidden" )
                , ( "font-family", "Arial, sans-serif" )
                , ( "margin", "12px 0" )
                , ( "line-height", "21px" )
                ]
            ]
            [ Html.text acc.content
            ]
        ]


-- Stylish Elephants

accordionSE : msg -> Bool -> Accordion -> Element msg
accordionSE openMsg isOpen acc =
    Element.column
        [ Element.width Element.fill
        , Element.spacing 12
        ]
        [ Element.paragraph
            [ Element.onClick openMsg
            , Element.pointer
            , Element.padding 8
            , Font.size 20
            , Font.color (Color.black)
            , Font.family [ Font.typeface "Arial", Font.sansSerif ]
            , Bg.color (Color.rgb 0xEE 0xEE 0xEE)
            , Element.width Element.fill
            , Border.color (Color.rgb 0xAA 0xAA 0xAA)
            , Border.solid
            , Border.width 1
            , Region.heading 4
            ]
            [ Element.text acc.heading
            ]
        , Element.paragraph
            [ if isOpen then Element.height Element.shrink else Element.height (Element.px 0)
            , Element.clip
            , Element.width Element.fill
            , Font.family [ Font.typeface "Arial", Font.sansSerif ]
            , Font.size 16
            , Font.color (Color.black)
            ]
            [ Element.text acc.content
            ]
        ]
