defmodule BowlingServer.Repo do
  use Ecto.Repo,
    otp_app: :bowling_server,
    adapter: Ecto.Adapters.SQLite3
end
