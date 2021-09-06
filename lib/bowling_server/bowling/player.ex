defmodule BowlingServer.Bowling.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :nick_name, :string
    field :game_id, :id

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:nick_name, :game_id])
    |> validate_required([:nick_name])
  end
end
