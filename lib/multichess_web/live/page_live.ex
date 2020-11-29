defmodule MultichessWeb.PageLive do
  use MultichessWeb, :live_view
  alias Multichess.Game
  alias Multichess.Game.Position

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
    end

    {:ok, assign(socket, state: Game.initial(), selected_pos: nil) |> assign_current_time()}
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
              with {:ok, state} <-
                     Game.move(socket.assigns.state, from_p, pos) do
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
  def handle_event("incr", _, socket) do
    {:noreply, socket |> assign(counter: socket.assigns[:counter] + 1)}
  end

  @impl true
  def handle_info(:tick, socket) do
    socket = assign_current_time(socket)

    {:noreply, socket}
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

  def outcome(%{outcome: :checkmate, turn: turn}), do: "#{turn} lost, checkmate!"

  def outcome(%{outcome: :stalemate}), do: "Tie by stalemate!"

  def outcome(_), do: nil
end
