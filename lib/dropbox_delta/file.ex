defmodule DropboxDelta.File do

  alias HTTPotion.Response
  @dropbox_file_host "https://api-content.dropbox.com/1/files/auto"

  def contents(path, access_token) do
    file_url(path)
    |> HTTPotion.get([headers: headers(access_token)])
    |> handle_response
  end

  def handle_response(%Response{status_code: 200, body: body}), do: {:body, body}
  def handle_response(%Response{status_code: status, body: body}), do: {:error, status, :body, body}

  defp file_url(path) do
    @dropbox_file_host <> path
  end

  defp headers(access_token) do
    [:"User-Agent", "dropbox_delta.ex", :"Authorization", "Bearer " <> access_token]
  end
end
