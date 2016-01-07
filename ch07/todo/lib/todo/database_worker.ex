defmodule Todo.DatabaseWorker do
  use GenServer

  # Interface functions
  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder)
  end

  def store(worker_pid, key, data) do
    # IO.puts "#{:erlang.pid_to_list(self)}: storing #{key}"
    GenServer.cast(worker_pid, {:store, key, data})
  end

  def get(worker_pid, key) do
    # IO.puts "#{:erlang.pid_to_list(self)}: retrieving #{key}"
    GenServer.call(worker_pid, {:get, key})
  end

  # Callback functions
  def init(db_folder) do
    File.mkdir_p(db_folder)
    {:ok, db_folder}
  end

  def handle_cast({:store, key, data}, db_folder) do
    db_folder
    |> Path.join(key)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, db_folder}
  end

  def handle_call({:get, key}, _, db_folder) do
    data =
      case File.read(Path.join(db_folder, key)) do
        {:ok, content} -> :erlang.binary_to_term(content)
        _ -> nil
      end

    {:reply, data, db_folder}
  end
end