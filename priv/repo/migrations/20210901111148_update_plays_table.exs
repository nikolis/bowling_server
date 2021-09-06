defmodule BowlingServer.Repo.Migrations.UpdatePlaysTable do
  use Ecto.Migration

  def change do
    alter table(:plays) do
       add :score, :integer
    end
  end
end
