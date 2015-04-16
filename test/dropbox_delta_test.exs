defmodule DropboxDeltaTest do
  use ExUnit.Case
  alias DropboxDelta.User

  test "the truth" do
    assert 1 == 1
    # DropboxDelta.changes(user_id, cursor)
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
