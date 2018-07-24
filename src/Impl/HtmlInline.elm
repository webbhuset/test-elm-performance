module Impl.HtmlInline exposing (renderAccordion)

import Html exposing (Html)
import Html.Attributes as Html
import Html.Events as Html


type alias Accordion =
    { heading : String
    , content : String
    }


renderAccordion : msg -> Bool -> Accordion -> Html msg
renderAccordion openMsg isOpen acc =
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
                [ if isOpen then
                    ( "height", "auto" )
                  else
                    ( "height", "0" )
                , ( "overflow", "hidden" )
                , ( "font-family", "Arial, sans-serif" )
                , ( "margin", "12px 0" )
                , ( "line-height", "21px" )
                ]
            ]
            [ Html.text acc.content
            ]
        ]
