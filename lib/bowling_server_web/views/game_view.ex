defmodule BowlingServerWeb.GameView do
  use BowlingServerWeb, :view
  
  alias BowlingServerWeb.GameView
  alias BowlingServerWeb.FrameView

  alias BowlingServer.Bowling

  def render("index.json", %{games: games}) do
    %{data: render_many(games, GameView, "game.json")}
  end

  def render("show.json", %{game: game}) do
    %{data: render_one(game, GameView, "game.json")}
  end

  def render("game.json", %{game: game}) do
    %{id: game.id,
      title: game.title,
      scores: 
      (if Ecto.assoc_loaded?(game.players) do
        Enum.reduce(game.players, %{}, fn x, acc -> Map.put(acc, x.nick_name, calculate_score(x.id)) end)
          #        Enum.map(game.players, fn pl -> %{pl.nick_name => calculate_score(pl.id)} end)
      else
        []
      end),
      score_board: 
      if Ecto.assoc_loaded?(game.frames) do 
        render_many(game.frames, FrameView, "frame.json") 
       else []
       end
     }
  end

  def render("next_play.json", %{next_play: next_play}) do
    %{data:
      %{frame_order: next_play.frame_order,
      frame_id: next_play.frame_id,
      attempt: next_play.attempt,
      player_id: next_play.player_id,
      player_name: next_play.player_name
      }
    }
  end

  def calculate_score(player_id) do
    total = 0
    plays = Bowling.list_players_plays(player_id)
    Enum.reduce(plays, total, fn x, acc -> x.score + acc end) 
  end

end
