defmodule Todo.Database do
  use GenServer

  # Interface functions
  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder, name: :database_server)
  end

  def store(key, data) do
    GenServer.cast(:database_server, {:store, key, data})
  end

  def get(key) do
    GenServer.call(:database_server, {:get, key})
  end

  # Callback functions
  def init(db_folder) do
    File.mkdir_p(db_folder)
    {:ok, db_folder}
  end

  def handle_cast({:store, key, data}, db_folder) do
    spawn(fn ->
      db_folder
      |> Path.join(key)
      |> File.write!(:erlang.term_to_binary(data))
    end)

    {:noreply, db_folder}
  end

  def handle_call({:get, key}, caller, db_folder) do
    spawn(fn ->
      data =
        case File.read(Path.join(db_folder, key)) do
          {:ok, content} -> :erlang.binary_to_term(content)
          _ -> nil
        end

        GenServer.reply(caller, data)
    end)

    {:noreply, db_folder}
  end
end