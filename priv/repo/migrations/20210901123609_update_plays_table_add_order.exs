defmodule BowlingServer.Repo.Migrations.UpdatePlaysTableAddOrder do
  use Ecto.Migration

  def change do
    alter table(:plays) do
       add :attempt, :integer
    end

  end
end
