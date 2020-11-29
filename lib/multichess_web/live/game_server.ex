defmodule MultichessWeb.GameServer do
  use GenServer
  alias Multichess.Game

  def create(sockets) do
    GenServer.start_link(__MODULE__, {sockets, Game.initial()})
  end

  @impl true
  def handle_call({:move, from_p, to_p}, {from_pid, _}, server_state) do
    with true <- is_correct_turn?(server_state, from_pid),
         {:ok, state} <- Game.move(server_state |> Map.get(:state), from_p, to_p) do
      server_state.pids
      |> Enum.filter(&(&1 != from_pid))
      |> Enum.each(&GenServer.cast(&1, {:new_state, state}))

      {:reply, {:ok, state}, Map.put(server_state, :state, state)}
    else
      false -> {:reply, {:error, "not your turn "}, server_state}
      {:error, msg} -> {:reply, {:error, msg}, server_state}
    end
  end

  defp is_correct_turn?(%{state: %{turn: :white}, pids: pids}, from) do
    [first | _] = pids
    first == from
  end

  defp is_correct_turn?(%{state: %{turn: :black}, pids: pids}, from) do
    List.last(pids) == from
  end

  @impl true
  def handle_info(:tick, server_state) do
    %{pids: pids, state: %{turn: turn}, time: time} = server_state

    with 0 <- time[turn] - 1 do
      %{state: game_state} = server_state
      game_state = game_state |> Map.put(:outcome, :out_of_time)
      pids |> Enum.each(&GenServer.cast(&1, {:new_time, time |> Map.put(turn, 0)}))
      pids |> Enum.each(&GenServer.cast(&1, {:new_state, game_state}))

      {:noreply,
       server_state |> Map.put(:time, Map.put(time, turn, 0)) |> Map.put(:state, game_state)}
    else
      t when t < 0 ->
        {:noreply, server_state}

      p_time_left ->
        new_time = time |> Map.put(turn, p_time_left)
        pids |> Enum.each(&GenServer.cast(&1, {:new_time, new_time}))
        {:noreply, server_state |> Map.put(:time, new_time)}
    end
  end

  @impl true
  def init({pids, init_state}) do
    :timer.send_interval(1000, self(), :tick)
    {:ok, %{pids: pids, state: init_state, time: %{white: 5 * 60, black: 5 * 60}}}
  end
end
