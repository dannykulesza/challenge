defmodule ChallengeWeb.RushingView do
  use ChallengeWeb, :view
  alias Plug.Conn.Query

  alias Challenge.Stats.RushingStat

  def render("rushing_stats.csv", %{rushing_stats: rushing_stats}) do
    rows =
      Enum.map(rushing_stats, fn stat ->
        [
          stat.player,
          stat.team,
          stat.position,
          stat.attempts,
          stat.attempts_per_game,
          stat.yards,
          stat.average,
          stat.yards_per_game,
          stat.touchdowns,
          render_lng(stat),
          stat.first_downs,
          stat.first_down_percentage,
          stat.plus_20_runs,
          stat.plus_40_runs,
          stat.fumbles
        ]
      end)

    [RushingStat.csv_headers() | rows]
    |> CSV.encode()
    |> Enum.to_list()
  end

  defp build_csv_download_link(filters, sort_by, sort_order) do
    url = Application.get_env(:challenge, :url)
    query_params = Query.encode(%{filters: filters, sort_by: sort_by, sort_order: sort_order})

    url
    |> URI.parse()
    |> Map.put(:query, query_params)
    |> Map.put(:path, "/rushing/csv")
    |> URI.to_string()
  end

  defp render_lng(%{completed_longest_rush_td: true, longest_rush_yards: lng}), do: "#{lng}T"
  defp render_lng(%{completed_longest_rush_td: false, longest_rush_yards: lng}), do: "#{lng}"

  defp get_search_value(filters, :player), do: Keyword.get(filters, :player, "")
end
