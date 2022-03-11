defmodule ChallengeWeb.RushingControllerTest do
  use ChallengeWeb.ConnCase, async: true

  alias ChallengeWeb.RushingView
  import Challenge.StatsFixtures

  @csv_url "/rushing/csv"

  describe "download_csv/2" do
    test "should return csv for given filter and sort params", %{conn: conn} do
      stats_1 = rushing_stat_fixture(%{player: "Dan", touchdowns: 5})
      stats_2 = rushing_stat_fixture(%{player: "Adam", touchdowns: 2})
      _stats_3 = rushing_stat_fixture(%{player: "Kyle", touchdowns: 2})

      resp_conn =
        conn
        |> get(@csv_url, %{
          "sort_by" => "touchdowns",
          "sort_order" => "asc",
          "filters" => %{"player" => "DA"}
        })

      raw_csv = response(resp_conn, 200)

      expected_csv =
        "rushing_stats.csv"
        |> RushingView.render(%{rushing_stats: [stats_2, stats_1]})
        |> Enum.join()

      assert get_resp_header(resp_conn, "content-type") == ["text/csv; charset=utf-8"]

      assert get_resp_header(resp_conn, "content-disposition") == [
               "attachment; filename=\"rushing_stats.csv\""
             ]

      assert raw_csv == expected_csv
    end
  end

    test "should return csv for empty filter param", %{conn: conn} do
      stats_1 = rushing_stat_fixture(%{player: "Dan", touchdowns: 5})
      stats_2 = rushing_stat_fixture(%{player: "Adam", touchdowns: 2})
      stats_3 = rushing_stat_fixture(%{player: "Kyle", touchdowns: 10})

      resp_conn =
        conn
        |> get(@csv_url, %{
          "sort_by" => "touchdowns",
          "sort_order" => "asc"
        })

      raw_csv = response(resp_conn, 200)

      expected_csv =
        "rushing_stats.csv"
        |> RushingView.render(%{rushing_stats: [stats_2, stats_1, stats_3]})
        |> Enum.join()


      assert get_resp_header(resp_conn, "content-type") == ["text/csv; charset=utf-8"]

      assert get_resp_header(resp_conn, "content-disposition") == [
               "attachment; filename=\"rushing_stats.csv\""
             ]
      assert raw_csv == expected_csv
    end

    test "return 400 with invalid parameters", %{conn: conn} do
        conn
        |> get(@csv_url, %{"Invalid" => "invalid"})
        |> json_response(400)
    end
end
