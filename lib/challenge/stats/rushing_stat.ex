defmodule Challenge.Stats.RushingStat do
  @moduledoc "NFL rushing statistics Ecto schema"
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  @csv_headers ~w[
     Player
     Team
     Position
     Att
     Att/G
     Yds
     Avg
     Yds/G
     TD
     Lng
     1st
     1st%
     20+
     40+
     FUM
  ]

  @fields [
    :player,
    :team,
    :position,
    :attempts,
    :attempts_per_game,
    :yards,
    :average,
    :yards_per_game,
    :touchdowns,
    :longest_rush_yards,
    :completed_longest_rush_td,
    :first_downs,
    :first_down_percentage,
    :plus_20_runs,
    :plus_40_runs,
    :fumbles
  ]

  schema "rushing_stats" do
    field :attempts, :integer
    field :attempts_per_game, :float
    field :average, :float
    field :completed_longest_rush_td, :boolean, default: false
    field :first_down_percentage, :float
    field :first_downs, :integer
    field :fumbles, :integer
    field :longest_rush_yards, :integer
    field :player, :string
    field :plus_20_runs, :integer
    field :plus_40_runs, :integer
    field :position, :string
    field :team, :string
    field :touchdowns, :integer
    field :yards, :integer
    field :yards_per_game, :float

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(rushing_stat, attrs) do
    rushing_stat
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end

  @spec csv_headers() :: [String.t()]
  def csv_headers, do: @csv_headers
end
