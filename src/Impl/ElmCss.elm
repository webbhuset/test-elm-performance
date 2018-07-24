module Impl.ElmCss exposing (renderAccordion)

import Html.Styled as Styled
import Html.Styled.Attributes as StyledAttrs
import Html.Styled.Events as StyledEvents
import Css


type alias Accordion =
    { heading : String
    , content : String
    }


renderAccordion : msg -> Bool -> Accordion -> Styled.Html msg
renderAccordion openMsg isOpen acc =
    Styled.div
        []
        [ Styled.h4
            [ StyledEvents.onClick openMsg
            , StyledAttrs.css
                [ Css.margin Css.zero
                , Css.cursor Css.pointer
                , Css.fontFamilies [ "Arial", .value Css.sansSerif ]
                , Css.backgroundColor (Css.hex "eee")
                , Css.padding (Css.px 8)
                , Css.fontWeight (Css.int 400)
                , Css.fontSize (Css.px 20)
                , Css.border3 (Css.px 1) Css.solid (Css.hex "aaa")
                , Css.lineHeight (Css.px 20)
                ]
            ]
            [ Styled.text acc.heading
            ]
        , Styled.p
            [ StyledAttrs.css
                [ if isOpen then
                    Css.height Css.auto
                  else
                    Css.height Css.zero
                , Css.overflow Css.hidden
                , Css.fontFamilies [ "Arial", .value Css.sansSerif ]
                , Css.margin2 (Css.px 12) Css.zero
                , Css.lineHeight (Css.px 21)
                ]
            ]
            [ Styled.text acc.content
            ]
        ]
