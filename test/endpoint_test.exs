defmodule LogmanEndpointTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Logman.Endpoint.init([])

  test "it returns 200 for successful request" do
    conn = conn(:post, "/event", "some message")
    conn = Logman.Endpoint.call(conn, @opts)

    assert conn.status == 200
    assert conn.resp_body == ""
  end

  test "it returns 404 for unknown path" do
    conn = conn(:post, "/some-path", "some message")
    conn = Logman.Endpoint.call(conn, @opts)

    assert conn.status == 404
  end
end
