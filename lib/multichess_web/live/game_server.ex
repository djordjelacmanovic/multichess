defmodule MultichessWeb.GameServer do
  use GenServer
  alias Multichess.Game

  @impl true
  def handle_call({:move, from_p, to_p}, _from, server_state) do
    with {:ok, state} <- Game.move(server_state |> Map.get(:state), from_p, to_p) do
      {:reply, {:ok, state}, Map.put(server_state, :state, state)}
    else
      {:error, msg} -> {:reply, {:error, msg}, server_state}
    end
  end

  @impl true
  def handle_info(:tick, server_state) do
    %{ppid: ppid, state: %{turn: turn}, time: time} = server_state

    with 0 <- time[turn] - 1 do
      %{state: game_state} = server_state
      game_state = game_state |> Map.put(:outcome, :out_of_time)
      GenServer.cast(ppid, {:new_time, time |> Map.put(turn, 0)})
      GenServer.cast(ppid, {:new_state, game_state})

      {:noreply,
       server_state |> Map.put(:time, Map.put(time, turn, 0)) |> Map.put(:state, game_state)}
    else
      t when t < 0 ->
        {:noreply, server_state}

      p_time_left ->
        new_time = time |> Map.put(turn, p_time_left)
        GenServer.cast(ppid, {:new_time, new_time})
        {:noreply, server_state |> Map.put(:time, new_time)}
    end
  end

  @impl true
  def init({pid, init_state}) do
    :timer.send_interval(1000, self(), :tick)
    {:ok, %{ppid: pid, state: init_state, time: %{white: 5 * 2, black: 5 * 2}}}
  end
end
