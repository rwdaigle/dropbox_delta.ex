defmodule FileTest do

  import Mock
  use ExUnit.Case, async: false
  alias DropboxDelta.File, as: DBFile

  @timeout 250

  doctest DropboxDelta.File

  test "GET file" do
    {:ok, body} = File.read("test/fixtures/file.html")
    with_mock HTTPotion, [get: fn(_, _) -> %HTTPotion.Response{status_code: 200, body: body} end] do
      assert {:ok, ^body} = DBFile.contents("/test/path.html", "12ab")
      assert called HTTPotion.get(file_url("/test/path.html"), [headers: headers("12ab")])
    end
  end

  test "GET file failed" do
    with_mock HTTPotion, [get: fn(_, _) -> %HTTPotion.Response{status_code: 404} end] do
      assert {:error, 404, :body, nil} == DBFile.contents("/test/path.html", "12ab")
      assert called HTTPotion.get(file_url("/test/path.html"), [headers: headers("12ab")])
    end
  end

  defp file_url(path) do
    "https://api-content.dropbox.com/1/files/auto" <> path
  end

  defp headers(access_token) do
    ["User-Agent": "dropbox_delta.ex", "Authorization": "Bearer " <> access_token]
  end
end
