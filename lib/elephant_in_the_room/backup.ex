defmodule ElephantInTheRoom.Backup do
  
  def dump do
    if check_if_pg_dump_is_installed() do
      {:ok, call_pg_dump()}
    else
      {:error, :no_pg_tools}
    end
  end

  defp get_path_to_dump do
    directory = "/tmp/elephant/ecto_dump/"
    time = DateTime.utc_now() |> DateTime.to_string |> String.replace(" ", "_")
    "#{directory}dump_#{time}"
  end

  defp check_if_pg_dump_is_installed do
    try do
      System.cmd("pg_dump", ["--version"]) 
      true
    catch
      :error, :enoent -> 
        false
    end
  end

  defp call_pg_dump() do
    config = Application.get_env(:elephant_in_the_room, ElephantInTheRoom.Repo)
    call_pg_dump(%{
      :username => Keyword.fetch!(config, :username),
      :password => Keyword.fetch!(config, :password),
      :database => Keyword.fetch!(config, :database),
      :hostname => Keyword.fetch!(config, :hostname),
      :path => get_path_to_dump()
    })
  end

  defp call_pg_dump(%{:username => username, :password => password, :database => database,
                     :hostname => hostname, :path => path}) do
    file = "#{path}.sql"
    env = [{"PGPASSWORD", password}]
    command = ["-U", username, "-F", "p", "-f", file, "-h", hostname, database]
    System.cmd("pg_dump", command, env: env)
    file
  end

end