defmodule BowlingServerWeb.GameUtilsTest do
  use BowlingServer.DataCase

  alias BowlingServer.Bowling
  alias BowlingServer.Bowling.Game
  alias BowlingServer.Bowling.Frame

  alias BowlingServer.GameUtils
  

  @game_attrs %{
    title: "some title", players: ["Tatyos Efendi", "cemil bey", "Sokratis Sinopoulos", "Jean Guien Queyras"]
  }

  describe "test get_next_play" do

    test "With a new empty frame first user gets first attempt" do
      {:ok, %Game{} = game} = Bowling.create_game(@game_attrs)
      {:ok, %Frame{} = frame} = Bowling.create_frame(%{game_id: game.id, order: 1})
      result = GameUtils.get_next_play(frame, game.players) 
      assert result.player_name == "Tatyos Efendi"
      assert result.attempt == 1
    end

    test "If a player has one shot in the frame seccond attempt should be returned"do
      {:ok, %Game{} = game} = Bowling.create_game(@game_attrs)
      {:ok, %Frame{} = frame} = Bowling.create_frame(%{game_id: game.id, order: 1})
      {:ok, _play} = Bowling.create_play(%{player_id: 1, attempt: 1, knocked_pins: 5, frame_id: frame.id })
      result = GameUtils.get_next_play(frame, game.players)

      assert result.player_name == "Tatyos Efendi"
      assert result.attempt == 2
    end

    test "If a player has one shot and it's strik in the frame the next players second attempt should be returned"do
      {:ok, %Game{} = game} = Bowling.create_game(@game_attrs)
      {:ok, %Frame{} = frame} = Bowling.create_frame(%{game_id: game.id, order: 1})
      {:ok, _play} = Bowling.create_play(%{player_id: 1, attempt: 1, knocked_pins: 10, frame_id: frame.id })
      result = GameUtils.get_next_play(frame, game.players)

      assert result.player_name == "cemil bey"
      assert result.attempt == 1
    end

    test "If the order of the frame is 10 then the player should have 3 attempts if he scores strike in the first attempt"do
      {:ok, %Game{} = game} = Bowling.create_game(@game_attrs)
      {:ok, %Frame{} = frame} = Bowling.create_frame(%{game_id: game.id, order: 10})
      {:ok, _play} = Bowling.create_play(%{player_id: 1, attempt: 1, knocked_pins: 10, frame_id: frame.id })
       
      result = GameUtils.get_next_play(frame, game.players)
      assert result.player_name == "Tatyos Efendi"
      assert result.attempt == 2

      {:ok, _play} = Bowling.create_play(%{player_id: 1, attempt: 2, knocked_pins: 10, frame_id: frame.id })
      result = GameUtils.get_next_play(frame, game.players)
      assert result.player_name == "Tatyos Efendi"
      assert result.attempt == 3
 
      {:ok, _play} = Bowling.create_play(%{player_id: 1, attempt: 3, knocked_pins: 10, frame_id: frame.id })
      result = GameUtils.get_next_play(frame, game.players)
      assert result.player_name == "cemil bey"
      assert result.attempt == 1
    end

    test "If the order of the frame is 10 then the player should have 3 attempts if he scores spare in the second attempt"do
      {:ok, %Game{} = game} = Bowling.create_game(@game_attrs)
      {:ok, %Frame{} = frame} = Bowling.create_frame(%{game_id: game.id, order: 10})
      {:ok, _play} = Bowling.create_play(%{player_id: 1, attempt: 1, knocked_pins: 5, frame_id: frame.id })
       
      result = GameUtils.get_next_play(frame, game.players)
      assert result.player_name == "Tatyos Efendi"
      assert result.attempt == 2

      {:ok, _play} = Bowling.create_play(%{player_id: 1, attempt: 2, knocked_pins: 5, frame_id: frame.id })
      result = GameUtils.get_next_play(frame, game.players)
      assert result.player_name == "Tatyos Efendi"
      assert result.attempt == 3
 
      {:ok, _play} = Bowling.create_play(%{player_id: 1, attempt: 3, knocked_pins: 10, frame_id: frame.id })
      result = GameUtils.get_next_play(frame, game.players)
      assert result.player_name == "cemil bey"
      assert result.attempt == 1
    end

    test "If the order of the frame is 10 if the user does not have scored a spare or a strike only two tries should be possible"do
      {:ok, %Game{} = game} = Bowling.create_game(@game_attrs)
      {:ok, %Frame{} = frame} = Bowling.create_frame(%{game_id: game.id, order: 10})
      {:ok, _play} = Bowling.create_play(%{player_id: 1, attempt: 1, knocked_pins: 5, frame_id: frame.id })
       
      result = GameUtils.get_next_play(frame, game.players)
      assert result.player_name == "Tatyos Efendi"
      assert result.attempt == 2

      {:ok, _play} = Bowling.create_play(%{player_id: 1, attempt: 2, knocked_pins: 2, frame_id: frame.id })
      result = GameUtils.get_next_play(frame, game.players)
      assert result.player_name == "cemil bey"
      assert result.attempt == 1
    end
 
  end

end
