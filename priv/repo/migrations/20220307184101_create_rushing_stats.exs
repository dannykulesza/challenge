defmodule Challenge.Repo.Migrations.CreateRushingStats do
  use Ecto.Migration

  def change do
    create table(:rushing_stats, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :player, :string
      add :team, :string
      add :position, :string
      add :attempts, :integer
      add :attempts_per_game, :float
      add :yards, :integer
      add :average, :float
      add :yards_per_game, :float
      add :touchdowns, :integer
      add :longest_rush_yards, :integer
      add :completed_longest_rush_td, :boolean, default: false, null: false
      add :first_downs, :integer
      add :first_down_percentage, :float
      add :plus_20_runs, :integer
      add :plus_40_runs, :integer
      add :fumbles, :integer

      timestamps(type: :utc_datetime_usec)
    end

    create index(:rushing_stats, [:player])
  end
end
