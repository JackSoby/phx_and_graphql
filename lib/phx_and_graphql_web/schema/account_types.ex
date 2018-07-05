defmodule PhxAndGraphqlWeb.Schema.AccountTypes do
  use Absinthe.Schema.Notation

  @desc "A user"
  object :user do
    # clients can get the user id
    field(:id, :id)
    # clients can also ask for the name field
    field(:name, :string)
  end

  @desc "Update params for user"
  input_object :update_user_params do
    field(:name, non_null(:string))
  end
end
