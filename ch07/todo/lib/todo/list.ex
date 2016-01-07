defmodule Todo.List do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %__MODULE__{},
      &add_entry(&2, &1)
    )
  end

  def add_entry(
    %__MODULE__{entries: entries, auto_id: auto_id} = todo_list,
    entry
  ) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = Map.put(entries, auto_id, entry)

    %__MODULE__{todo_list |
      entries: new_entries,
      auto_id: auto_id + 1
    }
  end

  def entries(%__MODULE__{entries: entries}, date) do
    entries
    |> Stream.filter(fn({_, entry}) ->
         entry.date == date
       end)

    |> Enum.map(fn({_, entry}) ->
         entry
       end)
  end


  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn(_) -> new_entry end)
  end

  def update_entry(
    %__MODULE__{entries: entries} = todo_list,
    entry_id,
    updater_fun
  ) do
    case entries[entry_id] do
      nil -> todo_list

      old_entry ->
        new_entry = updater_fun.(old_entry)
        new_entries = Map.put(entries, new_entry.id, new_entry)
        %__MODULE__{todo_list | entries: new_entries}
    end
  end


  def delete_entry(
    %__MODULE__{entries: entries} = todo_list,
    entry_id
  ) do
    %__MODULE__{todo_list | entries: Map.delete(entries, entry_id)}
  end
end