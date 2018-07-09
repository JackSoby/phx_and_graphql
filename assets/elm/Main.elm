module Main exposing (..)

import GraphQL.Client.Http
import GraphQL.Request.Builder as Builder exposing (..)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Html exposing (..)
import Html.Attributes exposing (class, id, placeholder, value)
import Html.Events exposing (..)
import Json.Decode as Json
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
    , userInput : String
    }


type alias User =
    { name : String
    , id : String
    }


type alias UserList =
    { users : List User }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : ( Model, Cmd Msg )
init =
    ( Model [] "", returnAllUsers )


type Msg
    = GetUser (Result GraphQL.Client.Http.Error User)
    | FetchUserList (Result GraphQL.Client.Http.Error UserList)
    | DeleteUser String
    | CreateUser
    | TrackInput String
    | LoadAll (Result GraphQL.Client.Http.Error User)


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
            ( Model response.users "", Cmd.none )

        FetchUserList (Err error) ->
            let
                log =
                    Debug.log "error " error
            in
            ( model, Cmd.none )

        DeleteUser id ->
            ( model, sendDeleteUser id )

        LoadAll response ->
            ( model, returnAllUsers )

        CreateUser ->
            ( Model model.users "", sendCreatedeUser model.userInput )

        TrackInput string ->
            ( Model model.users string, Cmd.none )


view : Model -> Html Msg
view model =
    let
        users =
            model.users
                |> List.map (\user -> div [ class "user-holder" ] [ p [] [ text user.name ], div [ onClick (DeleteUser user.id), class "delete-button" ] [ text "X" ] ])
    in
    div [ class "user-wrapper" ] [ inputView model.userInput, div [ class "user-wrapper" ] users ]


inputView : String -> Html Msg
inputView input =
    div [ class "input-wrapper" ] [ Html.input [ onInput TrackInput, value input, onEnter CreateUser, placeholder "New User..", class "input" ] [] ]


onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.succeed msg
            else
                Json.fail "not ENTER"
    in
    on "keydown" (Json.andThen isEnter keyCode)


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

        params =
            { userID = id }
    in
    userField
        |> Builder.queryDocument
        |> Builder.request params


createNewUser : String -> Request Mutation User
createNewUser userName =
    let
        name =
            Arg.variable (Var.required "name" .name Var.string)

        userField =
            Builder.extract
                (field
                    "create_user"
                    [ ( "name", name ) ]
                    userSpec
                )

        params =
            { name = userName }
    in
    userField
        |> Builder.mutationDocument
        |> Builder.request params


sendCreatedeUser : String -> Cmd Msg
sendCreatedeUser name =
    name
        |> createNewUser
        |> GraphQL.Client.Http.sendMutation "/graphiql"
        |> Task.attempt LoadAll


deleteUser : String -> Request Mutation User
deleteUser id =
    let
        userID =
            Arg.variable (Var.required "userID" .userID Var.string)

        userField =
            Builder.extract
                (field
                    "delete_user"
                    [ ( "id", userID ) ]
                    userSpec
                )

        params =
            { userID = id }
    in
    userField
        |> Builder.mutationDocument
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


sendDeleteUser : String -> Cmd Msg
sendDeleteUser id =
    id
        |> deleteUser
        |> GraphQL.Client.Http.sendMutation "/graphiql"
        |> Task.attempt LoadAll


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
        |> with (field "id" [] string)


userListSpec : ValueSpec NonNull ObjectType UserList vars
userListSpec =
    let
        user =
            userSpec
    in
    UserList
        |> Builder.object
        |> with (field "users" [] (list user))
