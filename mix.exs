defmodule ElephantInTheRoom.Mixfile do
  use Mix.Project

  def project do
    [
      app: :elephant_in_the_room,
      version: "0.0.1",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      elixirc_options: [warnings_as_errors: true],
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ElephantInTheRoom.Application, []},
      extra_applications: [:logger, :runtime_tools, :scrivener_ecto, :arc_ecto, :redix, :elixir_make, :parse_trans]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},

      # releases
      {:distillery, "~> 2.0.0-rc.11", runtime: false},

      # added deps
      {:guardian, "~> 1.0.1"},
      {:comeonin, "~> 4.0"},
      {:bcrypt_elixir, "~> 0.12"},
      {:redix, "~> 0.7.1"},

      # markdown
      {:cmark, "~> 0.7"},
      {:faker, "~> 0.9"},

      # pagination
      {:scrivener_ecto, "~> 1.0"},
      {:scrivener_list, "~> 1.0"},

      # image uploads
      {:arc, "~> 0.8.0"},
      {:arc_ecto, "~> 0.7.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
