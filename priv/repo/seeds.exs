# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PhxAndGraphql.Repo.insert!(%PhxAndGraphql.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.


alias PhxAndGraphql.Account.Schema.User
alias PhxAndGraphql.Repo


%User{name: "Bob"} |> Repo.insert!
%User{name: "Jack"} |> Repo.insert!
%User{name: "James"} |> Repo.insert!