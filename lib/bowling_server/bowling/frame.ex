defmodule BowlingServer.Bowling.Frame do
  use Ecto.Schema
  import Ecto.Changeset

  alias BowlingServer.Bowling.Play
  alias BowlingServer.Bowling.Game

  schema "frames" do
    field :order, :integer

    has_many :plays, Play
    belongs_to :game, Game

    timestamps()
  end

  @doc false
  def changeset(frame, attrs) do
    frame
    |> cast(attrs, [:order, :game_id])
    |> validate_required([:order, :game_id])
  end
end
