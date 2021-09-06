defmodule BowlingServerWeb.GameController do
  
  use BowlingServerWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias BowlingServer.Bowling
  alias BowlingServer.Bowling.Game
  alias BowlingServer.Bowling.Play

  alias OpenApiSpex.Schema     

  action_fallback BowlingServerWeb.FallbackController


  operation :index,
  summary: "List of all games existing in the system",
  responses: [
      ok: {"GameDetails", "application/json",   BowlingServer.Schemas.GameDetailsJsonSchema} 
    ]   
  def index(conn, _params) do
    games = Bowling.list_games()
    render(conn, "index.json", games: games)
  end


  operation :create,
    summary: "Initiate a new bowling game, by creating a new Game",
    request_body:
      {"The necessary attributes needed to kick start a new bowling gmae", "application/json", BowlingServer.Schemas.GameJsonSchema, required: true},
    responses: [
      created: {"Game", "application/json",  %Schema{}} 
    ]   
  def create(conn, %{"game" => game_params}) do
    with {:ok, %Game{} = game} <- Bowling.create_game(game_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.game_path(conn, :show, game))
      |> render("show.json", game: game)
    end
  end

  operation :show,
  summary: "Get currnet game state",
  parameters: [
      id: [
        in: :path,
        type: %Schema{type: :integer, minimum: 1},
        description: "Game ID",
        example: 123,
        required: true
      ]
    ],
    responses: [
      ok: {"GameDetailsResponse", "application/json",   BowlingServer.Schemas.GameDetailsJsonResponseSchema} 
    ]   
  def show(conn, %{"id" => id}) do
    game = Bowling.get_game!(id)
    render(conn, "show.json", game: game)
  end

  operation :record_play,
    summary: "An instance of a players play",
    request_body:
      {"The necessary attributes needed to save a play of a player in the database", "application/json", BowlingServer.Schemas.NextPlayJsonSchema, required: true},
    responses: [
      created: {"Play", "application/json",  BowlingServer.Schemas.PlayJsonSchema} 
    ]   
  def record_play(conn, %{"play" => play_params}) do
    with {:ok, %Play{} = play} <- Bowling.create_play(play_params) do
      conn
      |> put_status(:created)
      |> render(BowlingServerWeb.PlayView, "show.json", play: play)
    end
  end

  operation :get_next,
    summary: "Creates content that is needed to facilitate the next play and returns the nessesary data to record next play, Has the side effext of creating a frame behnd the scene",
    parameters: [
      id: [
        in: :path,
        type: %Schema{type: :integer, minimum: 1},
        description: "Game ID",
        example: 123,
        required: true
      ]
    ],
    responses: [
      ok: {"NextPlay", "application/json",   BowlingServer.Schemas.NextPlayJsonSchema} 
    ]   
  def get_next(conn, %{"id" => id}) do
    game = Bowling.get_game!(id)
    case Bowling.gen_next_play_attrs_create_new_frame_if_needed(game) do
      {:game_ended, message} ->
        conn
        |> put_status(:bad_request)
        |> json(%{errors: [message]})

      {:ok, next_play} ->
        conn
        |> put_status(:ok)
        |> render("next_play.json", next_play: next_play)

      {:error, errors} ->
        conn
        |> put_status(:bad_request)
        |> render("error.json", errors: errors)
    end
  end

  operation :delete,
    summary: "Deletes a game",
    parameters: [
      id: [
        in: :path,
        type: %Schema{type: :integer, minimum: 1},
        description: "Game ID",
        example: 123,
        required: true
      ]
    ],
    responses: [
       no_content: {"", "application/json",   %Schema{}} 
    ]   

  def delete(conn, %{"id" => id}) do
    game = Bowling.get_game!(id)

    with {:ok, %Game{}} <- Bowling.delete_game(game) do
      send_resp(conn, :no_content, "")
    end
  end
end
