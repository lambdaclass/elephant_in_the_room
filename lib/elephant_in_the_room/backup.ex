defmodule ElephantInTheRoom.Backup do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_status, do: GenServer.call(__MODULE__, :get_status)
  def run_backup_now, do: GenServer.call(__MODULE__, :do_backup)
  def set_inverval(interval), do: GenServer.call(__MODULE__, {:set_interval, interval})

  def init(_) do
    {:ok, %{working: false,
            interval: 0,
            result: {:error, :nothing_done}}}
  end

  def handle_call(:do_backup, _from, %{working: false} = state) do
     async_dump(self())
    {:reply, :ok, %{state | working: true}}
  end
  def handle_call(:do_backup, _from, state), do: {:reply, :working, state}

  def handle_call(:get_backup_result, _from, %{result: result} = state) do
    {:reply, result, state}
  end

  def handle_call({:set_interval, interval}, _from, state) do
    {:reply, :ok, %{state | interval: interval}}
  end
  
  def handle_call(:get_status, _from, %{result: result} = state) do
    r = %{
      activated: true,
      will_run_at: 231321,
      status: status_string(state)
    }
    {:reply, r, state}
  end

  def handle_info({:dump_done, dump_result}, state) do
    IO.inspect("IO DUMP DONE!!!")
    {:noreply, %{state | result: dump_result, working: false}}
  end

  defp async_dump(parent) do
    spawn_link(fn ->
      send parent, {:dump_done, dump()}
    end)
  end

  defp status_string(%{working: true}), do: "working"
  defp status_string(_), do: "idle"

  def dump do
    if check_if_pg_dump_is_installed() do
      call_pg_dump()
    else
      {:error, :no_pg_tools}
    end
  end

  defp get_path_to_dump do
    directory = "/tmp/elephant/ecto_dump/"
    File.mkdir_p(directory)
    time = DateTime.utc_now() |> DateTime.to_string |> String.replace(" ", "_")
    "#{directory}dump_#{time}"
  end

  defp check_if_pg_dump_is_installed do
    try do
      System.cmd("pg_dump", ["--version"]) 
      true
    catch
      _, _ -> false
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
      call_pg_dump(map_data)
    catch
      _ -> {:error, :error}
    end
  end

  defp call_pg_dump(%{:username => username, :password => password, :database => database,
                     :hostname => hostname, :path => path}) do
    file = "#{path}.sql"
    env = [{"PGPASSWORD", password}]
    command = ["-U", username, "-F", "p", "-f", file, "-h", hostname, database]
    {_, status_code} = System.cmd("pg_dump", command, env: env)
    case status_code do
      0 -> {:ok, file}
      _ -> {:error, {:exit_code, status_code}}
    end
  end

end