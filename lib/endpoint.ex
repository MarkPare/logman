defmodule Logman.Endpoint do
  @moduledoc """
  A Plug responsible for logging request info,
  matching routes, and dispatching responses.
  """
  use Plug.Router
  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  post "/event" do
    # TODO: handle malformed requests
    {:ok, message, _conn} = read_body(conn)
    # TODO: handle share_log failure
    Logman.Handler.share_log(message)
    send_resp(conn, 200, "")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

end
