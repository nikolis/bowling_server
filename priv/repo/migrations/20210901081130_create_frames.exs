defmodule BowlingServer.Repo.Migrations.CreateFrames do
  use Ecto.Migration

  def change do
    create table(:frames) do
      add :order, :integer
      add :game_id, references(:games, on_delete: :delete_all)

      timestamps()
    end

    create index(:frames, [:game_id])
  end
end
