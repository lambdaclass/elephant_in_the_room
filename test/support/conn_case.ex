defmodule ElephantInTheRoomWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate
  alias Ecto.Adapters.SQL.Sandbox
  alias ElephantInTheRoom.Auth
  alias ElephantInTheRoom.Auth.User
  alias ElephantInTheRoom.Repo
  alias ElephantInTheRoom.Sites

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import ElephantInTheRoomWeb.Router.Helpers

      # The default endpoint for testing
      @endpoint ElephantInTheRoomWeb.Endpoint
    end
  end

  setup tags do
    :ok = Sandbox.checkout(ElephantInTheRoom.Repo)

    unless tags[:async] do
      Sandbox.mode(ElephantInTheRoom.Repo, {:shared, self()})
    end

    conn =
      Phoenix.ConnTest.build_conn()
      # :admin
      |> may_log_as_administrator(tags)

    {:ok, conn: conn, site: ensure_default_site_exists()}
  end

  defp may_log_as_administrator(conn, tags) do
    case tags[:admin] do
      true ->
        user = ensure_default_administrator_exists()
        set_administrator_session(conn, user)

      _ ->
        conn
    end
  end

  defp set_administrator_session(conn, admin) do
    {:ok, conn, _} = Auth.sign_in_user(conn, admin)
    conn
  end

  defp ensure_default_administrator_exists do
    %User{email: email} = admin = default_administrator_user()

    case Repo.get_by(User, email: email) do
      nil -> Repo.insert!(admin)
      _ -> admin
    end
  end

  defp default_administrator_user do
    %User{
      email: "admin@elephant.com",
      firstname: "administrtor",
      lastname: "administrator",
      password: "password",
      role: "admin"
    }
  end

  def ensure_default_site_exists do
    case get_default_site_from_db() do
      {:ok, site} ->
        site

      {:error, :not_found} ->
        Sites.create_site(default_site())
        {:ok, site} = get_default_site_from_db()
        site
    end
  end

  def get_default_site_from_db do
    Sites.get_site_by_name(default_site().name)
  end

  def default_site do
    %{name: "default_site", categories: [], posts: [], tags: []}
  end
end
