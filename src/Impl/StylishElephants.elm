module Impl.StylishElephants exposing (renderAccordion)

import Element exposing (Element)
import Element.Background as Bg
import Element.Border as Border
import Element.Events as Element
import Element.Font as Font
import Element.Region as Region
import Color


type alias Accordion =
    { heading : String
    , content : String
    }


renderAccordion : msg -> Bool -> Accordion -> Element msg
renderAccordion openMsg isOpen acc =
    Element.column
        accordionWrapperStyle
        [ Element.paragraph
            (Element.onClick openMsg
                :: accordionHeadingStyle
            )
            [ Element.text acc.heading
            ]
        , Element.paragraph
            (if isOpen then
                Element.height Element.shrink :: accordionContentStyle
             else
                Element.height (Element.px 0) :: accordionContentStyle
            )
            [ Element.text acc.content
            ]
        ]


accordionHeadingStyle : List (Element.Attribute msg)
accordionHeadingStyle =
    [ Element.pointer
    , Element.padding 8
    , Font.size 20
    , Font.color Color.black
    , Font.family [ Font.typeface "Arial", Font.sansSerif ]
    , Bg.color (Color.rgb 0xEE 0xEE 0xEE)
    , Element.width Element.fill
    , Border.color (Color.rgb 0xAA 0xAA 0xAA)
    , Border.solid
    , Border.width 1
    , Region.heading 4
    ]


accordionContentStyle : List (Element.Attribute msg)
accordionContentStyle =
    [ Element.clip
    , Element.width Element.fill
    , Font.family [ Font.typeface "Arial", Font.sansSerif ]
    , Font.size 16
    , Font.color Color.black
    ]


accordionWrapperStyle : List (Element.Attribute msg)
accordionWrapperStyle =
    [ Element.width Element.fill
    , Element.spacing 12
    ]
