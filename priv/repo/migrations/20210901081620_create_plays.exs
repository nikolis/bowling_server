defmodule BowlingServer.Repo.Migrations.CreatePlays do
  use Ecto.Migration

  def change do
    create table(:plays) do
      add :knocked_pins, :integer
      add :player_id, references(:players, on_delete: :delete_all)
      add :frame_id, references(:frames, on_delete: :delete_all)

      timestamps()
    end

    create index(:plays, [:player_id])
    create index(:plays, [:frame_id])
  end
end
