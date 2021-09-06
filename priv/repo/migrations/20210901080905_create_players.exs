defmodule BowlingServer.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :nick_name, :string
      add :game_id, references(:games, on_delete: :delete_all)

      timestamps()
    end

    create index(:players, [:game_id])
  end
end
