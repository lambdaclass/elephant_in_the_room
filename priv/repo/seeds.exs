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

alias ElephantInTheRoom.{Sites, Repo, Auth, Auth.Role}

case Repo.get_by(Role, name: "admin") do
  nil ->
    IO.puts("Creating admin role")
    Auth.create_role(%{name: "admin"})

  _admin_role ->
    IO.puts("admin role already created!")
end

admin_role_id = Repo.get_by(Role, name: "admin").id

case Repo.get_by(Role, name: "user") do
  nil ->
    IO.puts("Creating user role")
    Auth.create_role(%{name: "user"})

  _user_role ->
    IO.puts("user role already created!")
end

create_admin_user_data = fn ->
  %{
    username: "admin",
    password: to_string(Kernel.trunc(:rand.uniform() * 1_000_000_000)),
    firstname: "admin",
    lastname: "1",
    email: "admin@lambdaclass.com",
    role_id: admin_role_id
  }
end

if length(Sites.list_sites()) == 0 do
  admin = create_admin_user_data.()
  Auth.create_user(admin)
  inform_str = "user: #{admin.username}\npassword: #{admin.password}\n"
  file_name = "admin_data.txt"
  File.write!(file_name, inform_str, [:write])
  IO.puts("Administration account data is inside #{file_name}, check it for logging")
end
