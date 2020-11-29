defmodule MultichessWeb.GameLobby do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: MultichessWeb.GameLobby)
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
    {:ok, sockets}
  end
end
