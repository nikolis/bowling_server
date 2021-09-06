defmodule BowlingServerWeb.PlayView do
  use BowlingServerWeb, :view
  alias BowlingServerWeb.PlayView

  def render("index.json", %{plays: plays}) do
    %{data: render_many(plays, PlayView, "play.json")}
  end

  def render("show.json", %{play: play}) do
    %{data: render_one(play, PlayView, "play.json")}
  end

  def render("play.json", %{play: play}) do
    play = BowlingServer.Repo.preload(play, :player)
    %{
      knocked_pins: play.knocked_pins,
      score: play.score,
      attempt: play.attempt,
      player: play.player.nick_name
     }
  end
end
