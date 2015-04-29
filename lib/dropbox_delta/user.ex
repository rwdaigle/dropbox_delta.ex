defmodule DropboxDelta.User do

  alias HTTPotion.Response
  alias DropboxDelta.Delta
  alias Poison.Parser, as: JSON

  @dropbox_delta_url Application.get_env(:dropbox, :api_host) <> Application.get_env(:dropbox, :delta_base)

  def delta([access_token: token]), do: delta([access_token: token, cursor: nil])
  def delta([access_token: token, cursor: _cursor]) do
    # Need to add start cursor
    @dropbox_delta_url
    |> HTTPotion.post([headers: headers(token)])
    |> parse_delta_body
    |> normalize_delta
  end

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
