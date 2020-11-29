defmodule Multichess.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MultichessWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Multichess.PubSub},
      # Start the Endpoint (http/https)
      MultichessWeb.Endpoint,
      MultichessWeb.GameLobby

      # Start a worker by calling: Multichess.Worker.start_link(arg)
      # {Multichess.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Multichess.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MultichessWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
