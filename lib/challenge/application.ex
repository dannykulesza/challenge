defmodule Challenge.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Challenge.Repo,
      # Start the Telemetry supervisor
      ChallengeWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Challenge.PubSub},
      # Start the Endpoint (http/https)
      ChallengeWeb.Endpoint
      # Start a worker by calling: Challenge.Worker.start_link(arg)
      # {Challenge.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Challenge.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChallengeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
