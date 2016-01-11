defmodule Todo.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    children = [
      worker(Todo.ProcessRegistry, []),
      supervisor(Todo.SystemSupervisor, []),
    ]
    opts = [strategy: :rest_for_one]
    supervise(children, opts)
  end
end
