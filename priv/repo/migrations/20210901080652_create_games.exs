defmodule BowlingServer.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :title, :string

      timestamps()
    end

  end
end
