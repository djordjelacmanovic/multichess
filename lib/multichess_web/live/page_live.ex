defmodule MultichessWeb.PageLive do
  use MultichessWeb, :live_view
  alias Multichess.Game
  alias Multichess.Game.Position
  alias MultichessWeb.Util.Convert
  alias MultichessWeb.GameServer

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket, state: Game.initial(), selected_pos: nil)
      |> assign_current_time()
      |> assign(black_time: 5 * 60)
      |> assign(white_time: 5 * 60)

    {:ok,
     if connected?(socket) do
       {:ok, pid} = GenServer.start_link(GameServer, {self(), socket.assigns.state})

       socket
       |> assign(pid: pid)
     else
       socket
     end}
  end

  @impl true
  def handle_event("select_sq", %{"pos" => pos}, socket) do
    with {:ok, pos} <-
           Position.parse(pos) do
      case socket.assigns.selected_pos do
        ^pos ->
          {:noreply,
           socket
           |> assign(selected_pos: nil)}

        _ ->
          case socket.assigns.selected_pos do
            nil ->
              {:noreply, socket |> assign(selected_pos: pos)}

            from_p ->
              with {:ok, state} <- GenServer.call(socket.assigns.pid, {:move, from_p, pos}) do
                {:noreply, assign(socket, state: state, selected_pos: nil)}
              else
                {:error, msg} ->
                  {:noreply, socket |> put_flash(:error, msg)}
              end
          end
      end
    else
      {:error, msg} -> {:noreply, socket |> put_flash(:error, msg)}
    end
  end

  @impl true
  def handle_cast({:new_state, state}, socket) do
    {:noreply, socket |> assign(state: state)}
  end

  @impl true
  def handle_cast({:new_time, time}, socket) do
    {:noreply, socket |> assign_current_time |> assign_player_time(time)}
  end

  def assign_player_time(socket, %{white: white_time, black: black_time}) do
    socket |> assign(white_time: white_time) |> assign(black_time: black_time)
  end

  def assign_current_time(socket) do
    now =
      Time.utc_now()
      |> Time.to_string()
      |> String.split(".")
      |> hd

    assign(socket, now: now)
  end

  def pos_to_s({c, r}) do
    "#{c},#{r}"
  end

  def pos_to_s(nil), do: nil

  def piece_to_unicode(nil), do: nil

  def piece_to_unicode(%{type: piece, colour: :white}) do
    case piece do
      :pawn -> "♙"
      :knight -> "♘"
      :bishop -> "♗"
      :rook -> "♖"
      :queen -> "♕"
      :king -> "♔"
    end
  end

  def piece_to_unicode(%{type: piece, colour: :black}) do
    case piece do
      :pawn -> "♟"
      :knight -> "♞"
      :bishop -> "♝"
      :rook -> "♜"
      :queen -> "♛"
      :king -> "♚"
    end
  end

  def sq_colour({c, r}) do
    case rem(c + r, 2) do
      0 -> :dark
      1 -> :white
    end
  end

  def seconds_to_str(sec) do
    Convert.sec_to_str(sec)
  end

  def outcome(%{outcome: :out_of_time, turn: turn}), do: "#{turn} lost, ran out of time!"
  def outcome(%{outcome: :checkmate, turn: turn}), do: "#{turn} lost, checkmate!"

  def outcome(%{outcome: :stalemate}), do: "Tie by stalemate!"

  def outcome(_), do: nil
end
