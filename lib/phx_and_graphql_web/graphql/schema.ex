defmodule PhxAndGraphqlWeb.Graphql.Schema do
  use Absinthe.Schema
  import_types(Absinthe.Type.Custom)
  import_types(PhxAndGraphqlWeb.Schema.AccountTypes)

  require IEx

  query do
    # field :all_users, non_null(list_of(non_null(:user))) do
    #   resolve(&PhxAndGraphqlWeb.Graphql.Resolvers.Account.all_users/3)
    # end

    field :user, type: :user do
      @desc "The contact ID"
      arg(:id, non_null(:id))

      resolve(&PhxAndGraphqlWeb.Graphql.Resolvers.Account.get_user/3)
    end

    field :users, type: :user_list do
      resolve(&PhxAndGraphqlWeb.Graphql.Resolvers.Account.all_users/3)
    end
  end

  mutation do
    field :create_user, :user do
      arg(:name, non_null(:string))

      resolve(&PhxAndGraphqlWeb.Graphql.Resolvers.Account.create_users/3)
    end

    field :delete_user, :user do
      arg(:id, non_null(:string))

      resolve(&PhxAndGraphqlWeb.Graphql.Resolvers.Account.delete_user/3)
    end

    field :update_user, :user do
      arg(:id, non_null(:string))
      arg(:name, non_null(:string))

      resolve(&PhxAndGraphqlWeb.Graphql.Resolvers.Account.update_user/3)
    end
  end
end
