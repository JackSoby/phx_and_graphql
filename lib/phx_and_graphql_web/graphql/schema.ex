defmodule PhxAndGraphqlWeb.Graphql.Schema do
    use Absinthe.Schema
    import_types Absinthe.Type.Custom
    import_types PhxAndGraphqlWeb.Schema.AccountTypes
    alias PhxAndGraphqlWeb.Resolvers


    query do
        field :all_users, non_null(list_of(non_null(:user))) do
        resolve &PhxAndGraphqlWeb.Graphql.Resolvers.Account.all_users/3
        end
    end    
end
  
