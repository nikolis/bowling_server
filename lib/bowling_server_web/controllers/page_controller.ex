defmodule BowlingServerWeb.PageController do
  use BowlingServerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
