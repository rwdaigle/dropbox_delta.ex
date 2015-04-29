defmodule DropboxDelta.Delta do

  def collect(%{"cursor" => cursor, "reset" => reset, "entries" => entries}) do
    %{current_cursor: cursor, reset: reset}
    |> add_removed(entries)
    |> add_updated(entries)
  end

  defp add_removed(acc, entries) do
    Dict.put(acc, :removed, removed(entries))
  end

  defp add_updated(acc, entries) do
    Dict.put(acc, :updated, updated(entries))
  end

  defp removed(entries) do
    entries
    |> Enum.filter(fn([_path, meta]) -> is_nil(meta) end)
    |> Enum.map(fn([path, _]) -> path end)
  end

  defp updated(entries) do
    entries
    |> Enum.filter(fn([_path, meta]) -> meta end)
    |> Enum.map(fn([path, meta]) -> [path: path, revision: meta["revision"], dir: meta["is_dir"]] end)
  end
end
