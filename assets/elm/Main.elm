module Main exposing (..)
import GraphQL.Request.Builder exposing (..)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Html exposing (..)
import GraphQL.Client.Http 
import Task exposing (Task)
import GraphQL.Request.Builder as Builder
    exposing
        ( NonNull
        , ObjectType
        , Query
        , Request
        , ValueSpec
        , field
        , int
        , object
        , string
        , with
        )


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { 
    }


type alias User =
    { name : String }





subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
    
init : ( Model, Cmd Msg )
init =
    ( Model, returnUser 3 )



type Msg
    = GetUser (Result GraphQL.Client.Http.Error User)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetUser response ->
            ( model, Cmd.none )

view : Model -> Html Msg
view model =
    div [] [ text "yo world" ]


fetchUser : Int -> Request Query User
fetchUser id =
    let
        userID =
            Arg.variable (Var.required "userID" .userID Var.int)

        userField =
            GraphQL.Request.Builder.extract
                (field
                    "user"
                    [ ( "id", userID ) ]
                    userSpec
                )

        params =
            { userID = id }
    in
        userField
            |> GraphQL.Request.Builder.queryDocument
            |> GraphQL.Request.Builder.request params


returnUser : Int -> Cmd Msg
returnUser id =
    id
        |> fetchUser
        |> GraphQL.Client.Http.sendQuery "/graphiql"
        |> Task.attempt GetUser


sendQueryRequest : Request Query a -> Task GraphQL.Client.Http.Error a
sendQueryRequest request =
    GraphQL.Client.Http.sendQuery "/" request




userSpec : ValueSpec NonNull ObjectType User vars
userSpec =
    User
        |> GraphQL.Request.Builder.object
        |> with (field "name" [] string)







