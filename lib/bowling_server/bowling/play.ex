defmodule BowlingServer.Bowling.Play do
  use Ecto.Schema
  import Ecto.Changeset

  alias BowlingServer.Bowling.Frame
  alias BowlingServer.Bowling.Player

  schema "plays" do
    field :knocked_pins, :integer
    field :score, :integer
    field :attempt, :integer

    belongs_to :frame, Frame
    belongs_to :player, Player

    timestamps()
  end

  @doc false
  def changeset(play, attrs) do
    play
    |> cast(attrs, [:knocked_pins, :score, :attempt, :frame_id, :player_id])
    |> validate_required([:knocked_pins, :frame_id, :player_id, :attempt])
  end
end
