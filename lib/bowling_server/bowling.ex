defmodule BowlingServer.Bowling do
  @moduledoc """
  The Bowling context.
  """

  import Ecto.Query, warn: false
  alias BowlingServer.Repo

  alias BowlingServer.Bowling.Game
  alias BowlingServer.GameUtils 

  @doc """
  Returns the list of games.

  ## Examples

      iex> list_games()
      [%Game{}, ...]

  """
  def list_games do
    Repo.all(Game)
    |> Repo.preload(:players)
  end

  @doc """
  Gets a single game.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game!(123)
      %Game{}

      iex> get_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game!(id) do
    Repo.get!(Game, id)
    |> Repo.preload([:players, :frames])
  end

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(attrs \\ %{}) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a game.

  ## Examples

      iex> update_game(game, %{field: new_value})
      {:ok, %Game{}}

      iex> update_game(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a game.

  ## Examples

      iex> delete_game(game)
      {:ok, %Game{}}

      iex> delete_game(game)
      {:error, %Ecto.Changeset{}}

  """
  def delete_game(%Game{} = game) do
    Repo.delete(game)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(game)
      %Ecto.Changeset{data: %Game{}}

  """
  def change_game(%Game{} = game, attrs \\ %{}) do
    Game.changeset(game, attrs)
  end

  alias BowlingServer.Bowling.Player

  @doc """
  Returns the list of players.

  ## Examples

      iex> list_players()
      [%Player{}, ...]

  """
  def list_players do
    Repo.all(Player)
  end

  @doc """
  Gets a single player.

  Raises `Ecto.NoResultsError` if the Player does not exist.

  ## Examples

      iex> get_player!(123)
      %Player{}

      iex> get_player!(456)
      ** (Ecto.NoResultsError)

  """
  def get_player!(id) do
    Repo.get!(Player, id)
  end

  @doc """
  Creates a player.

  ## Examples

      iex> create_player(%{field: value})
      {:ok, %Player{}}

      iex> create_player(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_player(attrs \\ %{}) do
    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a player.

  ## Examples

      iex> update_player(player, %{field: new_value})
      {:ok, %Player{}}

      iex> update_player(player, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_player(%Player{} = player, attrs) do
    player
    |> Player.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a player.

  ## Examples

      iex> delete_player(player)
      {:ok, %Player{}}

      iex> delete_player(player)
      {:error, %Ecto.Changeset{}}

  """
  def delete_player(%Player{} = player) do
    Repo.delete(player)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking player changes.

  ## Examples

      iex> change_player(player)
      %Ecto.Changeset{data: %Player{}}

  """
  def change_player(%Player{} = player, attrs \\ %{}) do
    Player.changeset(player, attrs)
  end

  alias BowlingServer.Bowling.Frame

  @doc """
  Returns the list of frames.

  ## Examples

      iex> list_frames()
      [%Frame{}, ...]

  """
  def list_frames do
    Repo.all(Frame)
  end

  def list_game_frames(game_id) do
    (from fr in Frame,
      where: fr.game_id == ^game_id)
    |> Repo.all()
    |> Repo.preload(:plays)
  end

  @doc """
  Gets a single frame.

  Raises `Ecto.NoResultsError` if the Frame does not exist.

  ## Examples

      iex> get_frame!(123)
      %Frame{}

      iex> get_frame!(456)
      ** (Ecto.NoResultsError)

  """
  def get_frame!(id) do
    Repo.get!(Frame, id)
  end

  def gen_next_play_attrs_create_new_frame_if_needed(game) do
    game_frames = list_game_frames(game.id)
    case Enum.empty?(game_frames) do
      true ->
        create_new_frame(1, game)
      false ->
        frame = List.last(Enum.sort_by(game_frames, fn x -> x.order end))
        next_play = GameUtils.get_next_play(frame, game.players)
        handle_next_play(next_play, frame.order, game)
    end
  end

  def handle_next_play(nil, frame_order, game) do
    if frame_order == 10 do
      {:game_ended, "This game is finished"}
    else
      create_new_frame(frame_order+1, game)
    end
  end
  def handle_next_play(next_play, _, _), do: {:ok, next_play}

  def create_new_frame(order, game) do
    case create_frame(%{game_id: game.id, order: order}) do
      {:ok, frame} ->
        {:ok, GameUtils.get_next_play(frame, game.players)}
      {:error, errors} ->
        {:error, errors}
    end
  end

  @doc """
  Creates a frame.

  ## Examples

      iex> create_frame(%{field: value})
      {:ok, %Frame{}}

      iex> create_frame(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_frame(attrs \\ %{}) do
    %Frame{}
    |> Frame.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a frame.

  ## Examples

      iex> update_frame(frame, %{field: new_value})
      {:ok, %Frame{}}

      iex> update_frame(frame, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_frame(%Frame{} = frame, attrs) do
    frame
    |> Frame.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a frame.

  ## Examples

      iex> delete_frame(frame)
      {:ok, %Frame{}}

      iex> delete_frame(frame)
      {:error, %Ecto.Changeset{}}

  """
  def delete_frame(%Frame{} = frame) do
    Repo.delete(frame)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking frame changes.

  ## Examples

      iex> change_frame(frame)
      %Ecto.Changeset{data: %Frame{}}

  """
  def change_frame(%Frame{} = frame, attrs \\ %{}) do
    Frame.changeset(frame, attrs)
  end

  alias BowlingServer.Bowling.Play

  @doc """
  Returns the list of plays.

  ## Examples

      iex> list_plays()
      [%Play{}, ...]

  """
  def list_plays do
    Repo.all(Play)
  end

  @doc """
  Gets a single play.

  Raises `Ecto.NoResultsError` if the Play does not exist.

  ## Examples

      iex> get_play!(123)
      %Play{}

      iex> get_play!(456)
      ** (Ecto.NoResultsError)

  """
  def get_play!(id) do
    Repo.get!(Play, id)
    |> Repo.preload([:frame])
  end
  

  def list_players_plays(player_id) do
    query = 
      from pl in Play,
      where: pl.player_id == ^player_id
    query
    |> Repo.all()
    |> Repo.preload([:frame])
  end

  @doc """
  Creates a play.

  ## Examples

      iex> create_play(%{field: value})
      {:ok, %Play{}}

      iex> create_play(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_play(attrs \\ %{}) do
    attrs = calculate_score_if_valid(attrs)
    %Play{}
    |> Play.changeset(attrs)
    |> Repo.insert()
  end

  def calculate_score_if_valid(play_attrs) do
    changeset = Play.changeset(%Play{}, play_attrs)
    case changeset.valid? do
      false ->
        play_attrs
      true ->
        calculate_score(play_attrs, changeset)
    end
  end

  def calculate_score(play_attrs, changeset) do
    changes = changeset.changes 
    current_frame = get_frame!(changes.frame_id)
    previous_frame = get_previous_frame(current_frame.id)
    strike_frame = had_strike_in_frame(previous_frame, changes.player_id)
    spare_frame =  had_spare_in_frame(previous_frame, changes.player_id)

    case strike_frame do
      nil ->
          if changes.attempt == 1 do
            add_to_last_frame_score(spare_frame, changes.player_id, changes.knocked_pins)
          else
            nil
          end
      str_frame ->
        add_to_last_frame_score(str_frame, changes.player_id, changes.knocked_pins)
    end
    current_score = calculate_current_score(changes, current_frame)
    put_apropriate_score(play_attrs, current_score)
  end


  def add_to_last_frame_score(nil, _, _), do: nil
  def add_to_last_frame_score(frame, player_id, additional_score) do
    plays = Enum.filter(frame.plays, fn x -> x.player_id == player_id end)
    plays = Enum.sort_by(plays, fn x -> x.attempt end)
    case Enum.count(plays) do
      1 ->
        play = Enum.at(plays, 0)
        update_play(play, %{score: play.score + additional_score})
      2 ->
        play = Enum.at(plays, 1)
        update_play(play, %{score: play.score + additional_score})
      3 ->
        play = Enum.at(plays, 2)
        update_play(play, %{score: play.score + additional_score})
      _ ->
        nil
    end  
  end


  def put_apropriate_score(%{attempt: _attempt} = play_attrs, current_score) do
    Map.put(play_attrs, :score, current_score)
  end

  def put_apropriate_score(%{"attempt" => _attempt} = play_attrs, current_score) do
    Map.put(play_attrs, "score", current_score)
  end



  def calculate_current_score(changes, %{order: 10} = frame) do
     case changes.attempt do
       1 ->
         changes.knocked_pins
       2 ->
         previous_play = find_play(frame, 1, changes.player_id) 
         if previous_play.knocked_pins == 10  do
           update_play(previous_play, %{score: previous_play.score +  changes.player_id})
           changes.knocked_pins
         else
            changes.knocked_pins
         end
       3 ->
         first_play = find_play(frame, 1, changes.player_id)
         second_play = find_play(frame, 2, changes.player_id)
         if first_play.knocked_pins == 10 do
           update_play(first_play, %{score: first_play.score +  changes.knocked_pins})
           changes.knocked_pins
         else
           if first_play.knocked_pins + second_play.knocked_pins == 10 do
             update_play(second_play, %{score: second_play.score +  changes.knocked_pins})
             changes.knocked_pins
           else
             changes.knocked_pins
           end
         end 
     end
  end
  def calculate_current_score(changes, _), do:  changes.knocked_pins


  def find_play(frame, attempt, player_id) do
    frame = Repo.preload(frame, :plays)
    Enum.find(frame.plays, fn x -> x.attempt == attempt and x.player_id == player_id end)
  end



  def had_strike_in_frame(nil, _), do: nil
  def had_strike_in_frame(frame, player_id) do
    frame = Repo.preload(frame, :plays)
    result = Enum.find(frame.plays, fn pl -> pl.player_id == player_id and pl.knocked_pins == 10 and pl.attempt == 1 end)
    case result do
      nil ->
        nil
      _ ->
        frame
    end
  end

  def had_spare_in_frame(nil, _), do: nil 
  def had_spare_in_frame(frame, player_id) do
    frame = Repo.preload(frame, :plays)
    relevant_plays = Enum.filter(frame.plays, fn pl -> pl.player_id == player_id end)

    total =  Enum.reduce(relevant_plays, 0, fn x, acc -> 
      case x.attempt == 1 and x.knocked_pins == 10 do
        true ->
          acc 

        false ->
          acc + x.knocked_pins
      end
    end)
    if total == 10 do
      frame
    else
      nil
    end
  end

  def get_players_plays(frame, player_id) do
    Enum.filter(frame.plays, fn pl -> pl.player_id == player_id end)
  end

  def get_previous_frame(frame_id) do
    current_frame = get_frame!(frame_id)
    current_frame = Repo.preload(current_frame, :plays)
    game =  get_game!(current_frame.game_id)
    all_frames = game.frames

    case current_frame.order > 1 do
      true ->
        previous_order = current_frame.order - 1
        Enum.find(all_frames, fn fr -> fr.order == previous_order end )
      false ->
        nil
    end
  end 


  @doc """
  Updates a play.

  ## Examples

      iex> update_play(play, %{field: new_value})
      {:ok, %Play{}}

      iex> update_play(play, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_play(%Play{} = play, attrs) do
    play
    |> Play.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a play.

  ## Examples

      iex> delete_play(play)
      {:ok, %Play{}}

      iex> delete_play(play)
      {:error, %Ecto.Changeset{}}

  """
  def delete_play(%Play{} = play) do
    Repo.delete(play)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking play changes.

  ## Examples

      iex> change_play(play)
      %Ecto.Changeset{data: %Play{}}

  """
  def change_play(%Play{} = play, attrs \\ %{}) do
    Play.changeset(play, attrs)
  end
end
