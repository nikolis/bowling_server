defmodule BowlingServerWeb.GameControllerTest do
  use BowlingServerWeb.ConnCase

  alias BowlingServer.Bowling

  import OpenApiSpex.TestAssertions

  @create_attrs %{
    title: "some title", players: ["Cemil Bay", "Tountas"]
  }
  
  @invalid_attrs %{title: nil}

  def fixture(:game) do
    {:ok, game} = Bowling.create_game(@create_attrs)
    game
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
    %{conn: conn, spec: BowlingServerWeb.ApiSpec.spec()}
  end

  describe "index" do
    test "lists all games", %{conn: conn} do
      conn = get(conn, Routes.game_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create game" do
    test "renders game when data is valid", %{conn: conn} do
      conn = post(conn, Routes.game_path(conn, :create), game: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.game_path(conn, :show, id))

      assert %{
               "id" => _id,
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.game_path(conn, :create), game: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "get next" do
    test "returns first player when a game is created/Should have the side effect of creating a frame", %{conn: conn, spec: spec} do
      game = fixture(:game)
      conn = get(conn, Routes.game_path(conn, :get_next, game.id))
      response = json_response(conn, 200)["data"]
      assert_schema(response, "NextPlay", spec)
    end  
  end

  describe "record_play" do
    test "with values got from get_net_play_attrs should record a players play in the game", %{conn: conn, spec: spec} do
      game = fixture(:game)
      {:ok, next_play} = Bowling.gen_next_play_attrs_create_new_frame_if_needed(game)
      attrs = 
        next_play
        |> Enum.into(%{knocked_pins: 5})

      conn = post(conn, Routes.game_path(conn, :record_play), play: attrs)
      assert response = json_response(conn, 201)["data"]
      assert_schema(response, "Play", spec)
    end
  end

  describe "retrieve/show game" do
    test "renders all details of a game", %{conn: conn, spec: spec} do
      game = fixture(:game)
      conn = get(conn, Routes.game_path(conn, :show, game.id))
      _response = json_response(conn, 200)["data"]

      #Arrange
      game = Bowling.get_game!(game.id)

      {:ok, next_play} = Bowling.gen_next_play_attrs_create_new_frame_if_needed(game)
      attrs = 
        next_play
        |> Enum.into(%{knocked_pins: 5})
      {:ok, _play} = Bowling.create_play(attrs)
      
      {:ok, next_play} = Bowling.gen_next_play_attrs_create_new_frame_if_needed(game)
      attrs = 
        next_play
        |> Enum.into(%{knocked_pins: 5})
      {:ok, _play} = Bowling.create_play(attrs)

      {:ok, next_play} = Bowling.gen_next_play_attrs_create_new_frame_if_needed(game)
      attrs = 
        next_play
        |> Enum.into(%{knocked_pins: 5})
      {:ok, _play} = Bowling.create_play(attrs)
      
      {:ok, next_play} = Bowling.gen_next_play_attrs_create_new_frame_if_needed(game)
      attrs = 
        next_play
        |> Enum.into(%{knocked_pins: 5})
      {:ok, _play} = Bowling.create_play(attrs)

      {:ok, next_play} = Bowling.gen_next_play_attrs_create_new_frame_if_needed(game)
      attrs = 
        next_play
        |> Enum.into(%{knocked_pins: 5})
      {:ok, _play} = Bowling.create_play(attrs)
      
      {:ok, next_play} = Bowling.gen_next_play_attrs_create_new_frame_if_needed(game)
      attrs = 
        next_play
        |> Enum.into(%{knocked_pins: 5})
      {:ok, _play} = Bowling.create_play(attrs)


      #Assert
      conn = get(conn, Routes.game_path(conn, :show, game.id))
      response = json_response(conn, 200)
      assert_schema(response, "GameDetailsResponse", spec)
    end  
  end

  describe "delete game" do
    setup [:create_game]

    test "deletes chosen game", %{conn: conn, game: game} do
      conn = delete(conn, Routes.game_path(conn, :delete, game))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.game_path(conn, :show, game))
      end
    end
  end

  defp create_game(_) do
    game = fixture(:game)
    %{game: game}
  end
end
