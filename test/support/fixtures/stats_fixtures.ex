defmodule Challenge.StatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Challenge.Stats` context.
  """

  alias Challenge.Stats

  @doc """
  Generate a rushing_stat.
  """
  def rushing_stat_fixture(attrs \\ %{}) do
    datetime = DateTime.utc_now()

    {:ok, rushing_stat} =
      attrs
      |> Enum.into(%{
        player: random_string(),
        team: random_string(2),
        position: random_string(2),
        attempts: random_int(),
        attempts_per_game: random_float(),
        yards: random_int(),
        average: random_float(),
        yards_per_game: random_float(),
        touchdowns: random_int(),
        longest_rush_yards: random_int(),
        completed_longest_rush_td: random_boolean(),
        first_downs: random_int(),
        first_down_percentage: random_float(),
        plus_20_runs: random_int(),
        plus_40_runs: random_int(),
        fumbles: random_int(),
        inserted_at: datetime,
        updated_at: datetime
      })
      |> Stats.create_rushing_stat()

    rushing_stat
  end

  defp random_string(length \\ 8) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
    |> String.trim_leading("+")
    |> binary_part(0, length)
  end

  defp random_int(length \\ 100), do: :rand.uniform(length)
  defp random_float(length \\ 50), do: :rand.uniform() * length
  defp random_boolean, do: Enum.random([true, false])
end
