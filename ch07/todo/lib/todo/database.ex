defmodule Todo.Database do
  use GenServer

  # Interface functions
  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder, name: :database_server)
  end

  def store(key, data) do
    :database_server
    |> GenServer.call({:get_worker, key})
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    :database_server
    |> GenServer.call({:get_worker, key})
    |> Todo.DatabaseWorker.get(key)
  end

  # Callback functions
  def init(db_folder) do
    worker_pids =
      Enum.reduce(0..2, %{}, fn(key, acc) ->
        {:ok, worker_pid} = Todo.DatabaseWorker.start(db_folder)
        Map.put(acc, key, worker_pid)
      end)

    {:ok, worker_pids}
  end

  def handle_call({:get_worker, key}, _, worker_pids) do
    {:reply, Map.get(worker_pids, :erlang.phash2(key, 3)), worker_pids}
  end
end