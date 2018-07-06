defmodule PhxAndGraphqlWeb.Graphql.Resolvers.Account do
  require IEx
  alias PhxAndGraphql.Account
  alias PhxAndGraphql.Account.Schema.User

  def all_users(_root, _args, _info) do
    users = Account.list_users()

 
    {:ok, %{users: users}}
  end

  def create_users(_root, args, _info) do
    Account.create_user(args)
    {:ok, args}
  end

  def get_user(_root, args, _info) do
    user = Account.get_user!(args.id)
    {:ok, user}
  end

  def delete_user(_root, args, _info) do
    user = Account.get_user!(args.id)
    dead_user = Account.delete_user(user)
    {:ok, user}
  end

  def update_user(_root, args, _info) do
    user = Account.get_user!(args.id)

    with {:ok, %User{} = user} <- Account.update_user(user, args.params) do
      {:ok, user}
    end
  end
end
