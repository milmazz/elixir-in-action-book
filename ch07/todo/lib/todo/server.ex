defmodule Todo.Server do
  use GenServer

  # Interface functions
  def start do
    GenServer.start(__MODULE__, nil)
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date \\ nil) do
    GenServer.call(todo_server, {:entries, date})
  end

  # Callback functions
  def init(_) do
    {:ok, Todo.List.new}
  end

  def handle_cast({:add_entry, new_entry}, todo_list) do
    {:noreply, Todo.List.add_entry(todo_list, new_entry)}
  end

  def handle_call({:entries, nil}, _, todo_list) do
    {:reply, todo_list, todo_list}
  end

  def handle_call({:entries, date}, _, todo_list) do
    {:reply, Todo.List.entries(todo_list, date), todo_list}
  end
end