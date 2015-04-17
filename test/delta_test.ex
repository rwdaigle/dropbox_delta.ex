defmodule DeltaTest do
  use ExUnit.Case, async: false
  import Mock
  alias DropboxDelta.Delta
  alias Poison.Parser, as: JSON

  @timeout 250

  test "resolve" do
    {:ok, body} = File.read("test/fixtures/delta.json")
    {:ok, delta} = JSON.parse(body)
    # IO.puts inspect(Dict.get(delta, "entries"))
    # resolved = Delta.resolve(Dict.get(delta, "entries"))
  end
end

# {
#   "from_cursor": "AAGsh3R...",
#   "current_cursor": "AAGsh3R...",
#   "reset": false,
#   "current": [
#     {
#       "path": "/ryandaigle.com/index.html",
#       "directory": false,
#       "contents": "<html></html>"
#     }, {
#       "path": "/ryandaigle.com/files",
#       "directory": true
#     }
#   ],
#   "removed": [
#     {
#       "path": "/ryandaigle.com/old",
#       "directory": true
#     }, {
#       "path": "/ryandaigle.com/index-test.html",
#       "directory": false
#     }
#   ],
# }
