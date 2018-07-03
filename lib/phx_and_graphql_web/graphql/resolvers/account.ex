
defmodule PhxAndGraphqlWeb.Graphql.Resolvers.Account do 
    require IEx 
   alias PhxAndGraphql.Account

    def all_users(_root, _args, _info) do
        users = Account.list_users
        {:ok, users}
    end
  end