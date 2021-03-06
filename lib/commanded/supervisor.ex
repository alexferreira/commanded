defmodule Commanded.Supervisor do
  use Supervisor
  use Commanded.EventStore

  @registry_provider Application.get_env(:commanded, :registry_provider, Registry)

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    children = registry_supervision_tree(@registry_provider) ++ [
      supervisor(Task.Supervisor, [[name: Commanded.Commands.TaskDispatcher]]),
      supervisor(Commanded.Aggregates.Supervisor, []),
    ]

    supervise(children, strategy: :one_for_one)
  end

  defp registry_supervision_tree(Registry) do
    [supervisor(Registry, [:unique, :aggregate_registry])]
  end

  defp registry_supervision_tree(registry_provider) do
    import Logger

    Logger.warn("#{registry_provider} is not started or supervised by :commanded; be sure to add it to your supervision tree")
    []
  end
end
