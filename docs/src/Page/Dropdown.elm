module Page.Dropdown
    exposing
        ( view
        , State
        , initialState
        , subscriptions
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Bootstrap.Dropdown as Dropdown
import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Util


type alias State =
    { basicState : Dropdown.State
    , customizedState : Dropdown.State
    , splitState : Dropdown.State
    , menuState : Dropdown.State
    , options : Options
    }


initialState : State
initialState =
    { basicState = Dropdown.initialState
    , customizedState = Dropdown.initialState
    , splitState = Dropdown.initialState
    , menuState = Dropdown.initialState
    , options = defaultOptions
    }


type alias Options =
    { coloring : Coloring
    , size : Size
    , dropUp : Bool
    , menuRight : Bool
    }


type Coloring
    = Primary
    | Secondary
    | Info
    | Warning
    | Danger
    | OutlinePrimary
    | OutlineSecondary
    | OutlineInfo
    | OutlineWarning
    | OutlineDanger


type Size
    = Small
    | Medium
    | Large


defaultOptions : Options
defaultOptions =
    { coloring = Primary
    , size = Medium
    , dropUp = False
    , menuRight = False
    }


subscriptions : State -> (State -> msg) -> Sub msg
subscriptions state toMsg =
    Sub.batch
        [ Dropdown.subscriptions state.basicState (\dd -> toMsg { state | basicState = dd })
        , Dropdown.subscriptions state.customizedState (\dd -> toMsg { state | customizedState = dd })
        , Dropdown.subscriptions state.splitState (\dd -> toMsg { state | splitState = dd })
        , Dropdown.subscriptions state.menuState (\dd -> toMsg { state | menuState = dd })
        ]


view : State -> (State -> msg) -> List (Html msg)
view state toMsg =
    [ Util.simplePageHeader
        "Dropdown"
        """Dropdowns are toggleable, contextual overlays for displaying lists of links and more.
           They’re made interactive with a little bit of Elm. They’re toggled by clicking."""
    , Util.pageContent
        (basic state toMsg
            ++ customized state toMsg
            ++ split state toMsg
            ++ menu state toMsg
        )
    ]


basic : State -> (State -> msg) -> List (Html msg)
basic state toMsg =
    [ h2 [] [ text "Basic example" ]
    , p [] [ text "Since dropdowns are interactive, we need to do a little bit of wiring to use them." ]
    , Util.example
        [ Dropdown.dropdown
            state.basicState
            { options = []
            , toggleMsg = (\dd -> toMsg { state | basicState = dd })
            , toggleButton =
                Dropdown.toggle [ Button.outlinePrimary ] [ text "My dropdown" ]
            , items =
                [ Dropdown.buttonItem [] [ text "Item 1" ]
                , Dropdown.buttonItem [] [ text "Item 2" ]
                ]
            }
        ]
    , Util.code basicCode
    ]


basicCode : Html msg
basicCode =
    Util.toMarkdownElm """

-- Dropdowns depends on view state to keep track of whether it is (/should be) open or not
type alias Model =
    { myDrop1State : Dropdown.State }


-- init

init : (Model, Cmd Msg )
init =
    ( { myDrop1State = Dropdown.initialState} -- initially closed
    , Cmd.none
    )


-- Msg

type Msg
    = MyDrop1Msg Dropdown.State


-- In your update function you will to handle messages coming from the dropdown

update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        MyDrop1Msg state ->
            ( { model | myDrop1State = state }
            , Cmd.none
            )


-- Dropdowns relies on subscriptions to automatically close any open when clicking outside them

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Dropdown.subscriptions model.myDrop1State MyDrop1Msg ]


-- Specify config and how the dropdown should look in your view (or view helper) function

view : Model -> Html Msg
view model =
    div []
        [ Dropdown.dropdown
            model.myDrop1State
            { options = [ ]
            , toggleMsg = MyDrop1Msg
            , toggleButton =
                Dropdown.toggle [ Button.primary ] [ text "My dropdown" ]
            , items =
                [ Dropdown.buttonItem [ onClick Item1Msg ] [ text "Item 1" ]
                , Dropdown.buttonItem [ onClick Item2Msg ] [ text "Item 2" ]
                ]
            }

        -- etc
        ]

"""


customized : State -> (State -> msg) -> List (Html msg)
customized state toMsg =
    [ h2 [] [ text "Customization" ]
    , p [] [ text "You can do quite a lot of customization on the dropdown and the dropdown button." ]
    , Util.example <|
        [ Dropdown.dropdown
            state.customizedState
            { options = customizedDropOptions state
            , toggleMsg = (\dd -> toMsg { state | customizedState = dd })
            , toggleButton =
                Dropdown.toggle (customizedButtonOptions state) [ text "My dropdown" ]
            , items =
                [ Dropdown.buttonItem [] [ text "Item 1" ]
                , Dropdown.buttonItem [] [ text "Item 2" ]
                ]
            }
        ]
            ++ customizeForm state toMsg
    ]


customizeForm : State -> (State -> msg) -> List (Html msg)
customizeForm ({ options } as state) toMsg =
    let
        coloringAttrs opt =
            [ Form.radioAttr <| checked <| opt == options.coloring
            , Form.radioAttr <| onClick <| toMsg { state | options = { options | coloring = opt } }
            ]

        sizeAttrs opt =
            [ Form.radioInline
            , Form.radioAttr <| checked <| opt == options.size
            , Form.radioAttr <| onClick <| toMsg { state | options = { options | size = opt } }
            ]
    in
        [ h4 [ class "mt-3" ] [ text "Dropdown customization" ]
        , Form.form []
            [ Form.checkbox
                [ Form.checkInline
                , Form.checkAttr <| checked options.dropUp
                , Form.checkAttr <| onClick <| toMsg { state | options = { options | dropUp = not options.dropUp } }
                ]
                "Dropdown.dropUp"
              -- TODO: Not working currently
              {- , Form.checkbox
                 [ Form.checkInline
                 , Form.checkAttr <| checked options.menuRight
                 , Form.checkAttr <| onClick <| toMsg { state | options = { options | menuRight = not options.menuRight }}
                 ]
                 "Dropdown.alignMenuRight"
              -}
            ]
        , div [ class "row" ]
            [ div [ class "col" ]
                [ Form.form []
                    [ Form.radioGroup
                        { label =
                            Form.label
                                [ Form.labelAttr <| style [ ( "font-weight", "bold" ) ] ]
                                [ text "Button coloring" ]
                        , name = "coloring"
                        , radios =
                            [ Form.radio (coloringAttrs Primary) "Button.primary"
                            , Form.radio (coloringAttrs Secondary) "Button.secondary"
                            , Form.radio (coloringAttrs Info) "Button.info"
                            , Form.radio (coloringAttrs Warning) "Button.warning"
                            , Form.radio (coloringAttrs Danger) "Button.danger"
                            ]
                        }
                    ]
                ]
            , div [ class "col" ]
                [ Form.form []
                    [ Form.radioGroup
                        { label = Form.label [] [ text "" ]
                        , name = "coloringoutl"
                        , radios =
                            [ Form.radio (coloringAttrs OutlinePrimary) "Button.outlinePrimary"
                            , Form.radio (coloringAttrs OutlineSecondary) "Button.outlineSecondary"
                            , Form.radio (coloringAttrs OutlineInfo) "Button.outlineInfo"
                            , Form.radio (coloringAttrs OutlineWarning) "Button.outlineWarning"
                            , Form.radio (coloringAttrs OutlineDanger) "Button.outlineDanger"
                            ]
                        }
                    ]
                ]
            ]
        , Form.form []
            [ Form.radioGroup
                { label =
                    Form.label
                        [ Form.labelAttr <| style [ ( "font-weight", "bold" ) ] ]
                        [ text "Button sizes" ]
                , name = "size"
                , radios =
                    [ Form.radio (sizeAttrs Small) "Button.small"
                    , Form.radio (sizeAttrs Medium) "Default"
                    , Form.radio (sizeAttrs Large) "Button.large"
                    ]
                }
            ]
        ]


customizedDropOptions : State -> List Dropdown.DropdownOption
customizedDropOptions { options } =
    (if options.dropUp then
        [ Dropdown.dropUp ]
     else
        []
    )
        ++ (if options.menuRight then
                [ Dropdown.alignMenuRight ]
            else
                []
           )


customizedButtonOptions : State -> List (Button.Option msg)
customizedButtonOptions { options } =
    (case options.coloring of
        Primary ->
            [ Button.primary ]

        Secondary ->
            [ Button.secondary ]

        Info ->
            [ Button.info ]

        Warning ->
            [ Button.warning ]

        Danger ->
            [ Button.danger ]

        OutlinePrimary ->
            [ Button.outlinePrimary ]

        OutlineSecondary ->
            [ Button.outlineSecondary ]

        OutlineInfo ->
            [ Button.outlineInfo ]

        OutlineWarning ->
            [ Button.outlineWarning ]

        OutlineDanger ->
            [ Button.outlineDanger ]
    )
        ++ (case options.size of
                Small ->
                    [ Button.small ]

                Medium ->
                    []

                Large ->
                    [ Button.large ]
           )


split : State -> (State -> msg) -> List (Html msg)
split state toMsg =
    [ h2 [] [ text "Split button dropdowns" ]
    , p [] [ text "You can also create split button dropdowns. The left button has a normal button action, whilst the right (caret) button toggles the dropdown menu." ]
    , Util.example
        [ Dropdown.splitDropdown
            state.splitState
            { options = []
            , toggleMsg = (\dd -> toMsg { state | splitState = dd })
            , toggleButton =
                Dropdown.splitToggle
                    { options = [ Button.secondary ]
                    , togglerOptions = [ Button.secondary ]
                    , children = [ text "My split dropdown" ]
                    }
            , items =
                [ Dropdown.buttonItem [] [ text "Item 1" ]
                , Dropdown.buttonItem [] [ text "Item 2" ]
                ]
            }
        ]
    , Util.code splitCode
    ]


splitCode : Html msg
splitCode =
    Util.toMarkdownElm """
Dropdown.splitDropdown
    model.mySplitDropdownState
    { options = []
    , toggleMsg = MySplitDropdownMsg
    , toggleButton =
        Dropdown.splitToggle
            { options = [ Button.secondary]
            , togglerOptions = [ Button.secondary ]
            , children = [ text "My split dropdown" ]
            }
    , items =
        [ Dropdown.buttonItem [] [ text "Item 1" ]
        , Dropdown.buttonItem [] [ text "Item 2" ]
        ]
    }
"""


menu : State -> (State -> msg) -> List (Html msg)
menu state toMsg =
    [ h2 [] [ text "Menu headers and dividers" ]
    , p [] [ text "You may use menu header and divder elements to organize your dropdown items." ]
    , Util.example
        [ Dropdown.dropdown
            state.menuState
            { options = []
            , toggleMsg = (\dd -> toMsg { state | menuState = dd })
            , toggleButton =
                Dropdown.toggle [ Button.warning ] [ text "My dropdown" ]
            , items =
                [ Dropdown.header [ text "Header" ]
                , Dropdown.buttonItem [] [ text "Item 1" ]
                , Dropdown.buttonItem [] [ text "Item 2" ]
                , Dropdown.divider
                , Dropdown.header [ text "Another heading" ]
                , Dropdown.buttonItem [] [ text "Item 3" ]
                , Dropdown.buttonItem [] [ text "Item 4" ]
                ]
            }
        ]
    , Util.code menuCode
    ]


menuCode : Html msg
menuCode =
    Util.toMarkdownElm """

Dropdown.dropdown
    model.myDropdownState
    { options = []
    , toggleMsg = MyDropdownMsg
    , toggleButton =
        Dropdown.toggle [ Button.warning ] [ text "My dropdown" ]
    , items =
        [ Dropdown.header [ text "Header"]
        , Dropdown.buttonItem [] [ text "Item 1" ]
        , Dropdown.buttonItem [] [ text "Item 2" ]
        , Dropdown.divider
        , Dropdown.header [ text "Another heading" ]
        , Dropdown.buttonItem [] [ text "Item 3" ]
        , Dropdown.buttonItem [] [ text "Item 4" ]
        ]
    }
"""