module Main exposing (..)

import GraphQL.Client.Http
import GraphQL.Request.Builder as Builder exposing (..)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Html exposing (..)
import Task exposing (Task)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { users : List User
    }


type alias User =
    { name : String }


type alias UserList =
    { users : List User }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : ( Model, Cmd Msg )
init =
    ( Model [], returnAllUsers )


type Msg
    = GetUser (Result GraphQL.Client.Http.Error User)
    | FetchUserList (Result GraphQL.Client.Http.Error UserList)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetUser response ->
            ( model, Cmd.none )

        FetchUserList (Ok response) ->
            let
                log =
                    Debug.log "users " response.users
            in
            ( Model response.users, Cmd.none )

        FetchUserList (Err error) ->
            let
                log =
                    Debug.log "error " error
            in
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
            Builder.extract
                (field
                    "user"
                    [ ( "id", userID ) ]
                    userSpec
                )

        log =
            Debug.log "user " userField

        params =
            { userID = id }
    in
    userField
        |> Builder.queryDocument
        |> Builder.request params


fetchAllUsers : Request Query UserList
fetchAllUsers =
    let
        userField =
            Builder.extract
                (field
                    "users"
                    []
                    userListSpec
                )

        params =
            {}
    in
    userField
        |> Builder.queryDocument
        |> Builder.request params


returnUser : Int -> Cmd Msg
returnUser id =
    id
        |> fetchUser
        |> GraphQL.Client.Http.sendQuery "/graphiql"
        |> Task.attempt GetUser


returnAllUsers : Cmd Msg
returnAllUsers =
    fetchAllUsers
        |> GraphQL.Client.Http.sendQuery "/graphiql"
        |> Task.attempt FetchUserList


sendQueryRequest : Request Query a -> Task GraphQL.Client.Http.Error a
sendQueryRequest request =
    GraphQL.Client.Http.sendQuery "/" request


userSpec : ValueSpec NonNull ObjectType User vars
userSpec =
    User
        |> Builder.object
        |> with (field "name" [] string)


userListSpec : ValueSpec NonNull ObjectType UserList vars
userListSpec =
    let
        user =
            userSpec
    in
    UserList
        |> Builder.object
        |> with (field "users" [] (list user))
