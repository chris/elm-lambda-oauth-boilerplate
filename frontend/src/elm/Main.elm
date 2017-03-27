port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (id, class, href, src, style, title)
import Html.Events exposing (onClick)
import Json.Decode exposing (field, int, map3, string, Decoder)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Jwt exposing (decodeToken, JwtError(..))
import Debug exposing (log)


port logout : String -> Cmd msg


type alias JwtData =
    { athleteName : String
    , accessToken : String
    , iat : Int
    }


jwtDecoder : Decoder JwtData
jwtDecoder =
    decode JwtData
        |> required "athleteName" string
        |> required "accessToken" string
        |> required "iat" int



-- APP


main : Program String Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = (\_ -> Sub.none)
        }


init : String -> ( Model, Cmd Msg )
init flags =
    case flags of
        "" ->
            ( initialModel, Cmd.none )

        _ ->
            case decodeToken jwtDecoder flags of
                Err msg ->
                    log (toString msg) ( initialModel, Cmd.none )

                Ok jwtData ->
                    ( { initialModel | jwt = Just flags, athlete = Athlete jwtData.athleteName }, Cmd.none )



-- MODEL


type alias Athlete =
    { name : String }


type alias Model =
    { jwt : Maybe String
    , athlete : Athlete
    }


initialModel : Model
initialModel =
    { jwt = Nothing
    , athlete = { name = "" }
    }



-- UPDATE


type Msg
    = NoOp
    | FetchFreeStats
    | Logout


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        FetchFreeStats ->
            ( model, Cmd.none )

        Logout ->
            ( initialModel, logout "" )



-- VIEW
-- Html is defined as: elem [ attribs ][ children ]
-- CSS can be applied via class names or inline style attrib


oauthRedirectUrl : String
oauthRedirectUrl =
    "YOUR_LAMBDA_FUNCTIONS_URL_HERE/dev/oauth/callback"


stravaOauthUrl : String
stravaOauthUrl =
    "https://www.strava.com/oauth/authorize?client_id=YOUR_STRAVA_CLIENT_ID_HERE&response_type=code&scope=view_private&redirect_uri=" ++ oauthRedirectUrl


view : Model -> Html Msg
view model =
    div [ class "container", style [ ( "margin-top", "30px" ), ( "text-align", "center" ) ] ]
        [ -- inline CSS (literal)
          div
            [ class "row" ]
            [ div [ class "col-xs-12" ]
                [ case model.jwt of
                    Just jwt ->
                        viewLoggedIn jwt model.athlete.name

                    Nothing ->
                        viewNotLoggedIn
                ]
            ]
        ]


viewNotLoggedIn : Html Msg
viewNotLoggedIn =
    div [ class "jumbotron" ]
        [ p [] [ text ("Elm Lambda OAuth Boilerplate") ]
        , a [ href stravaOauthUrl ] [ text "Login with Strava" ]
        ]


viewLoggedIn : String -> String -> Html Msg
viewLoggedIn jwt name =
    div [ class "jumbotron" ]
        [ p [] [ text ("Elm Lambda OAuth Boilerplate") ]
        , p [] [ text ("Thanks for logging in " ++ name ++ "!") ]
        , button
            [ class "btn btn-primary"
            , onClick (Logout)
            ]
            [ text "Logout" ]
        ]



-- CSS STYLES


styles : { img : List ( String, String ) }
styles =
    { img =
        [ ( "width", "33%" )
        , ( "border", "4px solid #337AB7" )
        ]
    }
