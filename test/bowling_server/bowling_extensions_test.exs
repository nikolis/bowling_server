defmodule BowlingServer.BowlingExtensionsTest do
  use BowlingServer.DataCase

  alias BowlingServer.Bowling
  alias BowlingServer.Bowling.Game
  alias BowlingServer.Bowling.Frame
  alias BowlingServer.Bowling.Play

  @game_attrs %{
    title: "some title", players: ["Tatyos Efendi", "cemil bey", "Sokratis Sinopoulos", "Jean Guien Queyras"]
  }
  @game_attrs_signle_player %{
    title: "some title", players: ["Tatyos Efendi"]
  }


  describe "gen_next_play_attrs_create_new_frame_if_needed" do

    test "Create a new frame and play for first user if game is empty" do
      {:ok, %Game{} = game} = Bowling.create_game(@game_attrs)
      assert {:ok, result} = Bowling.gen_next_play_attrs_create_new_frame_if_needed(game) 
      assert result.attempt == 1
      assert result.player_name == "Tatyos Efendi"
      assert Enum.count(Bowling.list_frames()) == 1
    end

    test "Dont create new frame if there are plays left" do
      {:ok, %Game{} = game} = Bowling.create_game(@game_attrs)
      {:ok, %Frame{} = _frame} = Bowling.create_frame(%{game_id: game.id, order: 1}) 
      assert {:ok, result} = Bowling.gen_next_play_attrs_create_new_frame_if_needed(game) 
      assert result.attempt == 1
      assert result.player_name == "Tatyos Efendi"
      assert Enum.count(Bowling.list_frames()) == 1
    end

  end

  describe "create_play/calculate_actuall_score " do

    test "every score should be first graded by the knocked pins" do 
      {:ok, %Game{} = game} = Bowling.create_game(@game_attrs_signle_player)
      game = Bowling.get_game!(game.id)
      [player] = game.players
      assert {:ok, result} = Bowling.gen_next_play_attrs_create_new_frame_if_needed(game)
      {:ok, %Play{} = play} = Bowling.create_play(%{frame_id: result[:frame_id], player_id: player.id, knocked_pins: 5, attempt: 1}) 
      assert play.score == 5
    end

    test "if a strike is scored then the play should be regraded after  the next two balls" do 
      {:ok, %Game{} = game} = Bowling.create_game(@game_attrs_signle_player)
      game = Bowling.get_game!(game.id)
      [player] = game.players

      assert {:ok, result} = Bowling.gen_next_play_attrs_create_new_frame_if_needed(game)
      {:ok, %Play{} = play} = Bowling.create_play(%{frame_id: result[:frame_id], player_id: player.id, knocked_pins: 10, attempt: 1}) 
      assert play.score == 10

      assert {:ok, result} = Bowling.gen_next_play_attrs_create_new_frame_if_needed(game)
      {:ok, %Play{} = play_2} = Bowling.create_play(%{frame_id: result[:frame_id], player_id: player.id, knocked_pins: 5, attempt: 1}) 

      play = Bowling.get_play!(play.id)
      assert play.score == 15
      assert play_2.score == 5

      assert {:ok, result} = Bowling.gen_next_play_attrs_create_new_frame_if_needed(game)
      {:ok, %Play{} = play_3} = Bowling.create_play(%{frame_id: result[:frame_id], player_id: player.id, knocked_pins: 5, attempt: 2}) 

      play = Bowling.get_play!(play.id)
      assert play.score == 20
      assert play_3.score == 5

    end

    test "if 2 plays in a frame constite a spare then the last play should re graded adding the next ball's knocked pins" do 
      {:ok, %Game{} = game} = Bowling.create_game(@game_attrs_signle_player)
      game = Bowling.get_game!(game.id)
      [player] = game.players

      assert {:ok, result} = Bowling.gen_next_play_attrs_create_new_frame_if_needed(game)
      {:ok, %Play{} = play} = Bowling.create_play(%{frame_id: result[:frame_id], player_id: player.id, knocked_pins: 5, attempt: 1}) 
      assert play.score == 5

      {:ok, %Play{} = play_2} = Bowling.create_play(%{frame_id: result[:frame_id], player_id: player.id, knocked_pins: 5, attempt: 2}) 
      assert play_2.score == 5

      assert {:ok, result} = Bowling.gen_next_play_attrs_create_new_frame_if_needed(game)
      {:ok, %Play{} = play_3} = Bowling.create_play(%{frame_id: result[:frame_id], player_id: player.id, knocked_pins: 5, attempt: 1}) 

      play_2 = Bowling.get_play!(play_2.id)
      assert play_2.score == 10
      assert play_3.score == 5
    end

  end

end
