defmodule ElephantInTheRoom.Backup do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{working: false, 
            result: {:error, :nothing_done}}}
  end

  def handle_call(:do_backup, %{working: false} = state) do
     async_dump(self())
    {:reply, :ok, %{state | working: true}}
  end
  
  def handle_call(:do_backup, %{working: false} = state) do
    {:reply, :working, state}
  end

  def handle_call(:get_backup_result, %{result: result} = state) do
    {:reply, result, state}
  end

  def handle_info({:dump_done, dump_result}, state) do
    {:noreply, %{state | result: dump_result, working: false}}
  end

  defp async_dump(parent) do
    spawn_link(fn ->
      send parent, {:dump_done, dump()}
    end)
  end

  def dump do
    if check_if_pg_dump_is_installed() do
      call_pg_dump()
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
    try_call_pg_dump(%{
      :username => Keyword.fetch!(config, :username),
      :password => Keyword.fetch!(config, :password),
      :database => Keyword.fetch!(config, :database),
      :hostname => Keyword.fetch!(config, :hostname),
      :path => get_path_to_dump()
    })
  end

  defp try_call_pg_dump(map_data) do
    try do
      {:ok, call_pg_dump(map_data)}
    catch
      _ -> {:error, :error}
    end
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