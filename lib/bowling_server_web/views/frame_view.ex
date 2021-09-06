defmodule BowlingServerWeb.FrameView do
  use BowlingServerWeb, :view
  alias BowlingServerWeb.FrameView

  def render("index.json", %{frames: frames}) do
    %{data: render_many(frames, FrameView, "frame.json")}
  end

  def render("show.json", %{frame: frame}) do
    %{data: render_one(frame, FrameView, "frame.json")}
  end

  def render("frame.json", %{frame: frame}) do
    frame = BowlingServer.Repo.preload(frame, :plays)
    %{
      order: frame.order,
      plays: render_many(frame.plays, BowlingServerWeb.PlayView, "play.json")
    }
  end
end
