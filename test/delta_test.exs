defmodule DeltaTest do
  use ExUnit.Case, async: true
  alias DropboxDelta.Delta
  alias Poison.Parser, as: JSON

  @timeout 250

  doctest DropboxDelta.Delta

  setup do
    {:ok, body} = File.read("test/fixtures/delta.json")
    {:ok, json} = JSON.parse(body)
    {:ok,
      body: body,
      json: json,
      removed: ["/ryandaigle.com/old", "/ryandaigle.com/index-test.html"],
      updated: [
        [path: "/ryandaigle.com", revision: 11, dir: true],
        [path: "/ryandaigle.com/index.html", revision: 12, dir: false]
      ]
    }
  end

  test "collect", context do
    expected = %{current_cursor: context[:json]["cursor"], reset: context[:json]["reset"],
    removed: context[:removed], updated: context[:updated]}
    assert Delta.collect(context[:json]) == expected
  end

  # test "removed", context do
  #   entries = Dict.get(context[:json], "entries")
  #   assert Delta.removed(entries) == context[:removed]
  # end
  #
  # test "updated", context do
  #   entries = Dict.get(context[:json], "entries")
  #   assert Delta.updated(entries) == context[:updated]
  # end
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
