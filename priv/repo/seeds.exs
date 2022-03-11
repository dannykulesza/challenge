defmodule Challenge.Seeds do
  alias Challenge.Repo
  alias Challenge.Stats.RushingStat

  @rushing_file_name "./priv/data/rushing.json"

  @spec parse_lng_rush_yards(binary() | number()) :: {integer(), boolean()}
  def parse_lng_rush_yards(raw_value) when is_integer(raw_value), do: {raw_value, false}

  def parse_lng_rush_yards(raw_value) when is_binary(raw_value) do
    case String.split(raw_value, "T") do
      [yards, _] -> {parse_int(yards), true}
      [yards] -> {parse_int(yards), false}
    end
  end

  @spec parse_int(binary() | integer()) :: integer()
  def parse_int(raw_value) when is_binary(raw_value),
    do: raw_value |> String.replace(",", "") |> Integer.parse() |> elem(0)

  def parse_int(raw_value) when is_integer(raw_value), do: raw_value

  @spec parse_float(binary() | number()) :: float()
  def parse_float(raw_value) when is_number(raw_value),
    do: raw_value |> to_string() |> parse_float()

  def parse_float(raw_value) when is_binary(raw_value), do: raw_value |> Float.parse() |> elem(0)

  def schema_maps(raw_rushing_stats) do
    Enum.map(raw_rushing_stats, fn rushing_stat ->
      datetime = DateTime.utc_now()

      {longest_rush_yards, completed_longest_rush_td} = parse_lng_rush_yards(rushing_stat["Lng"])

      %{
        player: rushing_stat["Player"],
        team: rushing_stat["Team"],
        position: rushing_stat["Pos"],
        attempts: rushing_stat["Att"],
        attempts_per_game: parse_float(rushing_stat["Att/G"]),
        yards: parse_int(rushing_stat["Yds"]),
        average: parse_float(rushing_stat["Avg"]),
        yards_per_game: parse_float(rushing_stat["Yds/G"]),
        touchdowns: rushing_stat["TD"],
        longest_rush_yards: longest_rush_yards,
        completed_longest_rush_td: completed_longest_rush_td,
        first_downs: rushing_stat["1st"],
        first_down_percentage: parse_float(rushing_stat["1st%"]),
        plus_20_runs: rushing_stat["20+"],
        plus_40_runs: rushing_stat["40+"],
        fumbles: rushing_stat["FUM"],
        inserted_at: datetime,
        updated_at: datetime
      }
    end)
  end

  def run do
    raw_rushing_stats = @rushing_file_name |> File.read!() |> Jason.decode!()
    schema_maps = schema_maps(raw_rushing_stats)

    Repo.transaction(fn _ ->
      Repo.insert_all(RushingStat, schema_maps)
    end)
  end
end

Challenge.Seeds.run()
