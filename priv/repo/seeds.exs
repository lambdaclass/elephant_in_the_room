# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ElephantInTheRoom.Repo.insert!(%ElephantInTheRoom.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ElephantInTheRoom.Auth

IO.puts("Creating admin and user roles")

{:ok, admin_role} = Auth.create_role(%{name: "admin"})

{:ok, user_role} = Auth.create_role(%{name: "user"})
