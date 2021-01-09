defmodule MultichessWeb.GameLobby do
  use GenServer
  alias Phoenix.PubSub

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: MultichessWeb.GameLobby)
  end

  def handle_info({:leave, pid}, pids) do
    IO.puts("Lobby handle disconnect")
    IO.inspect(pid)
    {:noreply, Enum.reject(pids, &(&1 == pid))}
  end

  def handle_call(:pop, {from_pid, _}, []) do
    {:reply, {:empty}, [from_pid]}
  end

  def handle_call(:pop, {from_pid, _}, [first | rest]) do
    {:ok, pid} = MultichessWeb.GameServer.create([first, from_pid])
    GenServer.cast(first, {:join_game, pid})
    {:reply, {:ok, pid}, rest}
  end

  def init(sockets \\ []) do
    :ok = PubSub.subscribe(Multichess.PubSub, "connections")
    {:ok, sockets}
  end
end
