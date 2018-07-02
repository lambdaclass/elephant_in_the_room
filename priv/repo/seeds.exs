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
alias ElephantInTheRoom.Auth.Role
alias ElephantInTheRoom.Repo
alias ElephantInTheRoom.Sites

case Repo.get_by(Role, name: "admin") do
  nil ->
    IO.puts("Creating admin role")
    Auth.create_role(%{name: "admin"})

  _admin_role ->
    IO.puts("admin role already created!")
end

case Repo.get_by(Role, name: "user") do
  nil ->
    IO.puts("Creating user role")
    Auth.create_role(%{name: "user"})

  _user_role ->
    IO.puts("user role already created!")
end

# case length(Sites.list_sites()) == 0 do
#   false ->
#     # do nothing
#     IO.puts("No need to create a new site")

#   true ->
#     # create a site 
#     IO.puts("Creating a new site!")
#     Sites.create_site(%{name: "default site", host: "default-site.com"})
# end
