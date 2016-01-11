defmodule Todo.Server do
  use GenServer

  # Interface functions
  def start_link(name) do
    IO.puts "Starting to-do server for #{name}"
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  defp via_tuple(name) do
    {:via, Todo.ProcessRegistry, {:todo_server, name}}
  end

  def whereis(name) do
    Todo.ProcessRegistry.whereis_name({:todo_server, name})
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date \\ nil) do
    GenServer.call(todo_server, {:entries, date})
  end

  # Callback functions
  def init(name) do
    {:ok, {name, Todo.Database.get(name) || Todo.List.new}}
  end

  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  def handle_call({:entries, nil}, _, {name, todo_list}) do
    {:reply, todo_list, {name, todo_list}}
  end

  def handle_call({:entries, date}, _, {name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {name, todo_list}}
  end
end
