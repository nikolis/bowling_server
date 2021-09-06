defmodule BowlingServer.Bowling.Game do
  use Ecto.Schema
  import Ecto.Changeset

  alias BowlingServer.Bowling.Player
  alias BowlingServer.Bowling.Frame

  schema "games" do
    field :title, :string

    has_many :players, Player
    has_many :frames, Frame
    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    attrs = transform_players_data(attrs)
    game
    |> cast(attrs, [:title])
    |> cast_assoc(:players, with: &BowlingServer.Bowling.Player.changeset/2)
    |> validate_required([:title])
  end


  def transform_players_data(%{players: players} = attrs) do
    case attrs[:players] do
      nil ->
        attrs
      _ ->
        players = Enum.map(attrs[:players], fn pl -> %{nick_name: pl} end)
        Dict.put(attrs, :players, players) 
    end
  end
  def transform_players_data(%{"players" => players} = attrs) do
    case attrs["players"] do
      nil ->
        attrs
      _ ->
        players = Enum.map(attrs["players"], fn pl -> %{nick_name: pl} end)
        Dict.put(attrs, "players", players) 
    end
  end
  def transform_players_data(whatever) do
    whatever
  end

end
