module Impl.HtmlCss exposing (renderAccordion, css)

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
                [ ( "open", isOpen )
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
