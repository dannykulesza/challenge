defmodule Challenge.StatsTest do
  use Challenge.DataCase

  alias Challenge.Stats
  alias Challenge.Stats.RushingStat

  import Challenge.StatsFixtures

  @page_size Stats.page_size()

  describe "rushing_stats" do
    test "create_rushing_stat/1 with valid data creates a rushing_stat" do
      datetime = DateTime.utc_now()

      assert {:ok, %RushingStat{} = rushing_stat} =
               Stats.create_rushing_stat(%{
                 player: "Test",
                 team: "OKC",
                 position: "WR",
                 attempts: 12,
                 attempts_per_game: 12,
                 yards: 5,
                 average: 3.0,
                 yards_per_game: 12.3,
                 touchdowns: 12,
                 longest_rush_yards: 123,
                 completed_longest_rush_td: true,
                 first_downs: 5,
                 first_down_percentage: 7.0,
                 plus_20_runs: 1,
                 plus_40_runs: 1,
                 fumbles: 3,
                 inserted_at: datetime,
                 updated_at: datetime
               })

      assert rushing_stat.player == "Test"
    end

    test "create_rushing_stat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stats.create_rushing_stat(%{})
    end

    test "paginate_rushing_stats/1 with no filter returns all entries" do
      rushing_stat_1 = rushing_stat_fixture()
      rushing_stat_2 = rushing_stat_fixture()

      %{entries: entries, page_number: page_number, total_pages: total_pages} =
        Stats.paginate_rushing_stats(%{})

      assert MapSet.new(entries) == MapSet.new([rushing_stat_1, rushing_stat_2])
      assert page_number == 1
      assert total_pages == 1
    end

    test "paginate_rushing_stats/1 with empty filter returns all entries" do
      rushing_stat_1 = rushing_stat_fixture()
      rushing_stat_2 = rushing_stat_fixture()

      %{entries: entries, page_number: page_number, total_pages: total_pages} =
        Stats.paginate_rushing_stats(%{filters: []})

      assert MapSet.new(entries) == MapSet.new([rushing_stat_1, rushing_stat_2])
      assert page_number == 1
      assert total_pages == 1
    end

    test "paginate_rushing_stats/1 with filter returns filtered entries, case-insensitive" do
      rushing_stat_1 = rushing_stat_fixture(%{player: "Dan"})
      rushing_stat_2 = rushing_stat_fixture(%{player: "adam"})
      _rushing_stat_3 = rushing_stat_fixture(%{player: "kyle"})

      %{entries: entries, page_number: page_number, total_pages: total_pages} =
        Stats.paginate_rushing_stats(%{filters: [player: "da"]})

      assert MapSet.new(entries) == MapSet.new([rushing_stat_1, rushing_stat_2])
      assert page_number == 1
      assert total_pages == 1
    end

    test "paginate_rushing_stats/1 with sort params returns sorted entries" do
      rushing_stat_1 = rushing_stat_fixture(%{player: "Dan", touchdowns: 10})
      rushing_stat_2 = rushing_stat_fixture(%{player: "adam", touchdowns: 12})
      _rushing_stat_3 = rushing_stat_fixture(%{player: "kyle", touchdowns: 4})

      %{entries: entries, page_number: page_number, total_pages: total_pages} =
        Stats.paginate_rushing_stats(%{
          filters: [player: "da"],
          sort_by: :touchdowns,
          sort_order: :desc
        })

      assert entries == [rushing_stat_2, rushing_stat_1]
      assert page_number == 1
      assert total_pages == 1
    end

    test "paginate_rushing_stats/1 with `lng` sort params returns sorted entries (touchdowns take priority)" do
      rushing_stat_1 =
        rushing_stat_fixture(%{
          player: "Dan",
          completed_longest_rush_td: true,
          longest_rush_yards: 20
        })

      rushing_stat_2 =
        rushing_stat_fixture(%{
          player: "adam",
          completed_longest_rush_td: false,
          longest_rush_yards: 20
        })

      rushing_stat_3 = rushing_stat_fixture(%{player: "kyle", longest_rush_yards: 5})

      %{entries: entries, page_number: page_number, total_pages: total_pages} =
        Stats.paginate_rushing_stats(%{sort_by: :lng, sort_order: :desc})

      assert entries == [rushing_stat_1, rushing_stat_2, rushing_stat_3]
      assert page_number == 1
      assert total_pages == 1
    end

    test "paginate_rushing_stats/1 with page param return page of entries specified" do
      Enum.each(1..(@page_size + 1), &rushing_stat_fixture(%{touchdowns: &1}))

      %{entries: [entry], page_number: page_number, total_pages: total_pages} =
        Stats.paginate_rushing_stats(%{sort_by: :touchdowns, sort_order: :asc, page: 2})

      assert entry.touchdowns == @page_size + 1
      assert page_number == 2
      assert total_pages == 2
    end

    test "list_rushing_stats/1 returns all filtered and ordered by given params" do
      expected_stats = Enum.map(1..(@page_size + 1), &rushing_stat_fixture(%{touchdowns: &1}))

      [top_player | _] =
        stats = Stats.list_rushing_stats(%{sort_by: :touchdowns, sort_order: :desc, page: 2})

      assert MapSet.new(stats) == MapSet.new(expected_stats)
      assert top_player.touchdowns == @page_size + 1
    end

    test "list_rushing_stats/1 returns all given multiple filters" do
      rushing_stat_1 = rushing_stat_fixture(%{player: "Dan", team: "Team1", touchdowns: 10})
      _rushing_stat_2 = rushing_stat_fixture(%{player: "adam", team: "Team2", touchdowns: 12})
      rushing_stat_3 = rushing_stat_fixture(%{player: "david", team: "Team1", touchdowns: 4})

      stats = Stats.list_rushing_stats(%{filters: [player: "da", team: "1"]})

      assert MapSet.new(stats) == MapSet.new([rushing_stat_1, rushing_stat_3])
    end
  end
end
