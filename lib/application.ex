defmodule Logman.Application do
  @moduledoc """
  Documentation for `Logman`.
  """
  use Application

  @impl true
  def start(_type, _args) do
    topologies = [
      default: [
        strategy: Cluster.Strategy.Gossip
      ]
    ]

    children = [
      {Cluster.Supervisor, [topologies, [name: Logman.ClusterSupervisor]]},
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Logman.Endpoint,
        options: [port: Application.get_env(:logman, :port)]
      ),
      {Task.Supervisor, name: Logman.Tasks},
    ]
    opts = [strategy: :one_for_one, name: Logman.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
