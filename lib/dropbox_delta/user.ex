defmodule DropboxDelta.User do

  alias HTTPotion.Response
  alias DropboxDelta.Delta
  alias DropboxDelta.File, as: DBFile
  alias Poison.Parser, as: JSON

  @dropbox_delta_url Application.get_env(:dropbox, :api_host) <> Application.get_env(:dropbox, :delta_base)

  def delta([access_token: token]), do: delta([access_token: token, cursor: nil])
  def delta([access_token: token, cursor: cursor]) do
    @dropbox_delta_url
    |> HTTPotion.post([body: body(cursor), headers: headers(token)])
    |> parse_response
    |> normalize_delta
    |> add_contents(token)
  end

  defp add_contents(delta, token) do
    updated = Dict.get(delta, :updated)
    |> Enum.map(fn(entry) -> if(Dict.fetch!(entry, :dir)) do
      entry else Dict.put(entry, :contents, file_contents(path: Dict.fetch!(entry, :path), access_token: token)) end
    end)
    Dict.put(delta, :updated, updated)
  end

  defp file_contents([path: path, access_token: token]) do
    DBFile.contents(path, token) |> get_file_contents
  end

  defp get_file_contents({:ok, contents}), do: contents
  defp get_file_contents({:error, _}), do: raise "Could not get file from Dropbox"

  defp normalize_delta({:ok, body}), do: body |> Delta.collect
  defp normalize_delta({:error, message}), do: raise message

  defp headers(access_token) do
    ["User-Agent": "dropbox_delta.ex", "Authorization": "Bearer #{access_token}"]
  end

  defp body(nil), do: nil
  defp body(cursor), do: "cursor=#{cursor}"

  defp parse_response(%Response{status_code: 200, body: body}), do: JSON.parse(body)
  defp parse_response(%Response{status_code: status_code}), do: raise "Dropbox API error #{status_code}"
end
