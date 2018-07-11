module Main exposing (..)

import Data.User exposing (..)
import Data.UserList exposing (..)
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
    , editedUser : Maybe String
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : ( Model, Cmd Msg )
init =
    ( Model [] "" Nothing, returnAllUsers )


type Msg
    = GetUser (Result GraphQL.Client.Http.Error User)
    | FetchUserList (Result GraphQL.Client.Http.Error UserList)
    | DeleteUser String
    | CreateUser
    | TrackInput String
    | LoadAll (Result GraphQL.Client.Http.Error User)
    | EditUser String String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetUser response ->
            ( model, Cmd.none )

        FetchUserList (Ok response) ->
            ( Model response.users "" Nothing, Cmd.none )

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
            ( Model model.users "" Nothing, checkUserInput model.editedUser model.userInput )

        TrackInput string ->
            ( Model model.users string model.editedUser, Cmd.none )

        EditUser name id ->
            ( Model model.users name (Just id), Cmd.none )


view : Model -> Html Msg
view model =
    let
        users =
            model.users
                |> List.sortBy .id
                |> List.map (\user -> div [ class "user-holder" ] [ p [ class "user-name" ] [ text user.name ], div [ class "crud-holder" ] [ div [ onClick (EditUser user.name user.id), class "crud-button" ] [ text "Edit" ], div [ onClick (DeleteUser user.id), class "crud-button" ] [ text "X" ] ] ])
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


sendCreatededUser : String -> Cmd Msg
sendCreatededUser name =
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


editUser : String -> String -> Request Mutation User
editUser id name =
    let
        userID =
            Arg.variable (Var.required "userID" .userID Var.string)

        userName =
            Arg.variable (Var.required "name" .userName Var.string)

        userField =
            Builder.extract
                (field
                    "update_user"
                    [ ( "id", userID ), ( "name", userName ) ]
                    userSpec
                )

        params =
            { userID = id, userName = name }
    in
    userField
        |> Builder.mutationDocument
        |> Builder.request params


sendEditUser : String -> String -> Cmd Msg
sendEditUser id name =
    editUser id name
        |> GraphQL.Client.Http.sendMutation "/graphiql"
        |> Task.attempt LoadAll


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


checkUserInput : Maybe String -> String -> Cmd Msg
checkUserInput id name =
    case id of
        Nothing ->
            sendCreatededUser name

        Just val ->
            sendEditUser val name
