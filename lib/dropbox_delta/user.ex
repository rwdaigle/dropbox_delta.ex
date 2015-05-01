defmodule DropboxDelta.User do

  alias HTTPotion.Response
  alias DropboxDelta.Delta
  alias DropboxDelta.File, as: DBFile
  alias Poison.Parser, as: JSON

  @dropbox_delta_url Application.get_env(:dropbox, :api_host) <> Application.get_env(:dropbox, :delta_base)

  def delta([access_token: token]), do: delta([access_token: token, cursor: nil])
  def delta([access_token: token, cursor: _cursor]) do
    # Need to add start cursor
    @dropbox_delta_url
    |> HTTPotion.post([headers: headers(token)])
    |> parse_delta_body
    |> normalize_delta
    |> add_contents(token)
  end

  defp add_contents(delta, token) do
    new_updated = Dict.get(delta, :updated)
    # |> Enum.filter(fn(entry) -> !Dict.fetch!(entry, :dir) end)
    |> Enum.map(fn(entry) -> if(Dict.fetch!(entry, :dir)) do
        entry else Dict.put(entry, :contents, file_contents(path: Dict.fetch!(entry, :path), access_token: token)) end
      end)
    # |> Enum.map(&Dict.put(&1, :contents, file_contents(path: Dict.fetch!(&1, :path), access_token: token)))
    Dict.put(delta, :updated, new_updated)
  end

  defp file_contents([path: path, access_token: token]) do
    DBFile.contents(path, token) |> get_file_contents
  end

  defp get_file_contents({:body, contents}), do: contents
  defp get_file_contents({:error, _}), do: raise "Could not get file from Dropbox"

  defp normalize_delta({:body, body}), do: body |> Delta.collect
  defp normalize_delta({:error, message}), do: message

  defp headers(access_token) do
    ["User-Agent": "dropbox_delta.ex", "Authorization": "Bearer #{access_token}"]
  end

  defp parse_delta_body(%Response{status_code: 200, body: body}), do: JSON.parse(body) |> get_parsed_body
  defp parse_delta_body(%Response{status_code: status_code}) do
    {:error, "Dropbox API error #{status_code}"}
  end

  defp get_parsed_body({:ok, body}), do: {:body, body}
  defp get_parsed_body({status, _}), do: {:error, "JSON parsing failed: #{status}"}
end
