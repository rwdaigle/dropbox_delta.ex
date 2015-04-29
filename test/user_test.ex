defmodule UserTest do

  import Mock
  use ExUnit.Case, async: false
  alias DropboxDelta.User

  @timeout 250

  doctest DropboxDelta.User

  test "delta" do
    {:ok, body} = File.read("test/fixtures/delta.json")
    with_mock HTTPotion, [post: fn(_, _) -> %HTTPotion.Response{status_code: 200, body: body} end] do
      assert User.delta(access_token: "12ab") == expected_delta
      assert called HTTPotion.post(delta_url, [headers: headers("12ab")])
    end
  end

  defp delta_url, do: "https://api.dropbox.com/1/delta"
  defp headers(access_token) do
    ["User-Agent": "dropbox_delta.ex", "Authorization": "Bearer #{access_token}"]
  end
  defp expected_delta do
    {:ok, body} = File.read("test/fixtures/file.html")
    %{
      reset: true,
      current_cursor: "AAGsh3Rp...",
      removed: ["/ryandaigle.com/old", "/ryandaigle.com/index-test.html"],
      updated: [
        [path: "/ryandaigle.com", revision: 11, dir: true],
        [path: "/ryandaigle.com/index.html", revision: 12, dir: false, contents: body]
      ]
    }
  end
end

# {
#   "current_cursor": "AAGsh3R...",
#   "reset": false,
#   "updated": [
#     {
#       "path": "/ryandaigle.com/index.html",
#       "directory": false,
#       "revision": 12,
#       "contents": "<html></html>"
#     }, {
#       "path": "/ryandaigle.com/files",
#       "directory": true,
#       "revision": 11
#     }
#   ],
#   "removed": ["/ryandaigle.com/old", "/ryandaigle.com/index-test.html"],
# }