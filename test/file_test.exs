defmodule FileTest do
  use ExUnit.Case, async: false
  import Mock
  alias DropboxDelta.File, as: DBFile

  @timeout 250

  test "GET file" do
    {:ok, body} = File.read("test/fixtures/file.html")
    with_mock HTTPotion, [get: fn(_, _) -> %HTTPotion.Response{status_code: 200, body: body} end] do
      assert {:body, body} == DBFile.contents("/test/path.html", "12ab")
      assert called HTTPotion.get("https://api-content.dropbox.com/1/files/auto/test/path.html",
        [headers: [:"User-Agent", "dropbox_delta.ex", :Authorization, "Bearer 12ab"]])
    end
  end

  test "GET file failed" do
    with_mock HTTPotion, [get: fn(_, _) -> %HTTPotion.Response{status_code: 404} end] do
      assert {:error, 404, :body, nil} == DBFile.contents("/test/path.html", "12ab")
      assert called HTTPotion.get("https://api-content.dropbox.com/1/files/auto/test/path.html",
        [headers: [:"User-Agent", "dropbox_delta.ex", :Authorization, "Bearer 12ab"]])
    end
  end
end

# {
#   "cursor": "AAGsh3R...",
#   "reset": false,
#   "updated": [
#     {
#       "path": "/ryandaigle.com/index.html",
#       "directory": false,
#       "contents": "<html></html>"
#     }
#   ],
#   "removed": ["/ryandaigle.com/old"]
# }
