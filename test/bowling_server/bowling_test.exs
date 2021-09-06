defmodule BowlingServer.BowlingTest do
  use BowlingServer.DataCase

  alias BowlingServer.Bowling

  describe "games" do
    alias BowlingServer.Bowling.Game

    @valid_attrs %{title: "some title", players: ["cemil bay"]}
    @update_attrs %{title: "some updated title", players: ["Tatyos Effendi"]}
    @invalid_attrs %{title: nil}

    def game_fixture(attrs \\ %{}) do
      {:ok, game} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Bowling.create_game()

      game
    end

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert Bowling.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      game = BowlingServer.Repo.preload(game, :frames)
      assert Bowling.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      assert {:ok, %Game{} = game} = Bowling.create_game(@valid_attrs)
      assert game.title == "some title"
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bowling.create_game(@invalid_attrs)
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      game = BowlingServer.Repo.preload(game, :frames)
      assert {:error, %Ecto.Changeset{}} = Bowling.update_game(game, @invalid_attrs)
      assert game == Bowling.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = Bowling.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Bowling.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Bowling.change_game(game)
    end
  end

  describe "players" do
    alias BowlingServer.Bowling.Player

    @valid_attrs %{nick_name: "some nick_name"}
    @update_attrs %{nick_name: "some updated nick_name"}
    @invalid_attrs %{nick_name: nil}

    def player_fixture(attrs \\ %{}) do
      {:ok, player} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Bowling.create_player()

      player
    end

    test "list_players/0 returns all players" do
      player = player_fixture()
      assert Bowling.list_players() == [player]
    end

    test "get_player!/1 returns the player with given id" do
      player = player_fixture()
      assert Bowling.get_player!(player.id) == player
    end

    test "create_player/1 with valid data creates a player" do
      assert {:ok, %Player{} = player} = Bowling.create_player(@valid_attrs)
      assert player.nick_name == "some nick_name"
    end

    test "create_player/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bowling.create_player(@invalid_attrs)
    end

    test "update_player/2 with valid data updates the player" do
      player = player_fixture()
      assert {:ok, %Player{} = player} = Bowling.update_player(player, @update_attrs)
      assert player.nick_name == "some updated nick_name"
    end

    test "update_player/2 with invalid data returns error changeset" do
      player = player_fixture()
      assert {:error, %Ecto.Changeset{}} = Bowling.update_player(player, @invalid_attrs)
      assert player == Bowling.get_player!(player.id)
    end

    test "delete_player/1 deletes the player" do
      player = player_fixture()
      assert {:ok, %Player{}} = Bowling.delete_player(player)
      assert_raise Ecto.NoResultsError, fn -> Bowling.get_player!(player.id) end
    end

    test "change_player/1 returns a player changeset" do
      player = player_fixture()
      assert %Ecto.Changeset{} = Bowling.change_player(player)
    end
  end

  describe "frames" do
    alias BowlingServer.Bowling.Frame

    @valid_attrs %{order: 42}
    @update_attrs %{order: 43}
    @invalid_attrs %{order: nil}


    def frame_fixture(attrs \\ %{}) do
      game = game_fixture()
      {:ok, frame} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Enum.into(%{game_id: game.id})
        |> Bowling.create_frame()

      frame
    end

    test "list_frames/0 returns all frames" do
      frame = frame_fixture()
      assert Bowling.list_frames() == [frame]
    end

    test "get_frame!/1 returns the frame with given id" do
      frame = frame_fixture()
      assert Bowling.get_frame!(frame.id) == frame
    end

    test "create_frame/1 with valid data creates a frame" do
      game = game_fixture()
      attrs = 
        @valid_attrs
        |> Enum.into(%{game_id: game.id})
      assert {:ok, %Frame{} = frame} = Bowling.create_frame(attrs)
      assert frame.order == 42
    end

    test "create_frame/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bowling.create_frame(@invalid_attrs)
    end

    test "update_frame/2 with valid data updates the frame" do
      frame = frame_fixture()
      assert {:ok, %Frame{} = frame} = Bowling.update_frame(frame, @update_attrs)
      assert frame.order == 43
    end

    test "update_frame/2 with invalid data returns error changeset" do
      frame = frame_fixture()
      assert {:error, %Ecto.Changeset{}} = Bowling.update_frame(frame, @invalid_attrs)
      assert frame == Bowling.get_frame!(frame.id)
    end

    test "delete_frame/1 deletes the frame" do
      frame = frame_fixture()
      assert {:ok, %Frame{}} = Bowling.delete_frame(frame)
      assert_raise Ecto.NoResultsError, fn -> Bowling.get_frame!(frame.id) end
    end

    test "change_frame/1 returns a frame changeset" do
      frame = frame_fixture()
      assert %Ecto.Changeset{} = Bowling.change_frame(frame)
    end
  end

  describe "plays" do
    alias BowlingServer.Bowling.Play

    @valid_attrs %{knocked_pins: 42, attempt: 1}
    @update_attrs %{knocked_pins: 43, attempt: 2}
    @invalid_attrs %{knocked_pins: nil}

    def play_fixture(attrs \\ %{}) do
      game = game_fixture()
      frame = frame_fixture(%{game_id: game.id})
      player = player_fixture()
      {:ok, play} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Enum.into(%{player_id: player.id, frame_id: frame.id})
        |> Bowling.create_play()

      play
    end

    test "list_plays/0 returns all plays" do
      play = play_fixture()
      assert Bowling.list_plays() == [play]
    end

    test "get_play!/1 returns the play with given id" do
      play = play_fixture()
      play = BowlingServer.Repo.preload(play, :frame)
      assert Bowling.get_play!(play.id) == play
    end

    test "create_play/1 with valid data creates a play" do
      game = game_fixture()
      frame = frame_fixture(%{game_id: game.id})
      player = player_fixture()

      assert {:ok, %Play{} = play} = Bowling.create_play(%{knocked_pins: 42, attempt: 1, frame_id: frame.id, player_id: player.id})
      assert play.knocked_pins == 42
    end

    test "create_play/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bowling.create_play(@invalid_attrs)
    end

    test "update_play/2 with valid data updates the play" do
      play = play_fixture()
      assert {:ok, %Play{} = play} = Bowling.update_play(play, @update_attrs)
      assert play.knocked_pins == 43
    end

    test "update_play/2 with invalid data returns error changeset" do
      play = play_fixture()
      assert {:error, %Ecto.Changeset{}} = Bowling.update_play(play, @invalid_attrs)
      assert play.id == Bowling.get_play!(play.id).id
    end

    test "delete_play/1 deletes the play" do
      play = play_fixture()
      assert {:ok, %Play{}} = Bowling.delete_play(play)
      assert_raise Ecto.NoResultsError, fn -> Bowling.get_play!(play.id) end
    end

    test "change_play/1 returns a play changeset" do
      play = play_fixture()
      assert %Ecto.Changeset{} = Bowling.change_play(play)
    end
  end
end
