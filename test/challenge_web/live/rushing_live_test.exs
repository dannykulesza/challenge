defmodule ChallengeWeb.Live.RushingLiveTest do
  use ChallengeWeb.ConnCase

  alias Challenge.Stats
  alias ChallengeWeb.RushingLive
  alias Phoenix.LiveView

  import Challenge.StatsFixtures
  import Phoenix.LiveViewTest
  import Phoenix.LiveView

  @page_size Stats.page_size()

  defp init_socket do
    {:ok, socket} = RushingLive.mount(%{}, %{}, %LiveView.Socket{})
    socket
  end

  defp assert_assigns(assigns, expected_assigns) do
    Enum.each(expected_assigns, fn {key, expected_value} ->
      assert Map.get(assigns, key) == expected_value
    end)
  end

  describe "mount" do
    test "disconnected and connected mount", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "NFL Rushing Statistics"

      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "NFL Rushing Statistics"
    end

    test "should mount with valid socket assigns" do
      stat = rushing_stat_fixture(%{player: "Adam"})

      {:ok, %{assigns: assigns}} = RushingLive.mount(%{}, %{}, %LiveView.Socket{})

      assert_assigns(assigns, %{
        rushing_stats: [stat],
        page: 1,
        total_pages: 1,
        filters: [],
        page_numbers: [%{page: 1, type: :current}],
        sort_by: :touchdowns,
        sort_order: :desc
      })
    end
  end

  describe "handle_event/3" do
    test "player_search event should update filter and refine stats list" do
      stat_1 = rushing_stat_fixture(%{player: "Adam", touchdowns: 5})
      stat_2 = rushing_stat_fixture(%{player: "Daniel", touchdowns: 10})
      _stat_3 = rushing_stat_fixture(%{player: "Kyle"})
      socket = init_socket()

      {:noreply, %{assigns: assigns}} =
        RushingLive.handle_event("player_search", %{"filter" => "Da"}, socket)

      assert_assigns(assigns, %{
        rushing_stats: [stat_2, stat_1],
        page: 1,
        total_pages: 1,
        filters: [player: "Da"]
      })
    end

    test "sort event should update sort params and stats list" do
      stat_1 = rushing_stat_fixture(%{player: "Adam", yards: 5})
      stat_2 = rushing_stat_fixture(%{player: "Daniel", yards: 20})
      stat_3 = rushing_stat_fixture(%{player: "Kyle", yards: 6})
      socket = init_socket()

      {:noreply, %{assigns: assigns}} =
        RushingLive.handle_event("sort", %{"col" => "yards"}, socket)

      assert_assigns(assigns, %{
        rushing_stats: [stat_2, stat_3, stat_1],
        sort_by: :yards,
        sort_order: :desc
      })
    end

    test "sort event should update sort params and stats list, same column" do
      stat_1 = rushing_stat_fixture(%{player: "Adam", touchdowns: 5})
      stat_2 = rushing_stat_fixture(%{player: "Daniel", touchdowns: 10})
      stat_3 = rushing_stat_fixture(%{player: "Kyle", touchdowns: 6})
      socket = init_socket()

      {:noreply, %{assigns: assigns}} =
        RushingLive.handle_event("sort", %{"col" => "touchdowns"}, socket)

      assert_assigns(assigns, %{
        rushing_stats: [stat_1, stat_3, stat_2],
        sort_by: :touchdowns,
        sort_order: :asc
      })
    end

    test "page event should update to selected page and update results" do
      [lowest | _] = Enum.map(1..(@page_size + 1), &rushing_stat_fixture(%{touchdowns: &1}))
      socket = init_socket()

      {:noreply, %{assigns: assigns}} = RushingLive.handle_event("page", %{"page" => "2"}, socket)

      assert_assigns(assigns, %{
        rushing_stats: [lowest],
        page: 2,
        total_pages: 2,
        page_numbers: [
          %{page: 1, type: :prev},
          %{page: 1, type: :page},
          %{page: 2, type: :current}
        ]
      })
    end

    test "prev event should decrement page and update results" do
      [_ | stats] = Enum.map(1..(@page_size + 1), &rushing_stat_fixture(%{touchdowns: &1}))
      socket = init_socket() |> assign(page: 2)

      {:noreply, %{assigns: assigns}} = RushingLive.handle_event("prev", %{}, socket)

      assert_assigns(assigns, %{
        rushing_stats: Enum.reverse(stats),
        page: 1,
        total_pages: 2,
        page_numbers: [
          %{page: 1, type: :current},
          %{page: 2, type: :page},
          %{page: 2, type: :next}
        ]
      })
    end

    test "prev event should not decrement page < 1" do
      [_ | stats] = Enum.map(1..(@page_size + 1), &rushing_stat_fixture(%{touchdowns: &1}))
      socket = init_socket()

      {:noreply, %{assigns: assigns}} = RushingLive.handle_event("prev", %{}, socket)

      assert_assigns(assigns, %{
        rushing_stats: Enum.reverse(stats),
        page: 1,
        total_pages: 2,
        page_numbers: [
          %{page: 1, type: :current},
          %{page: 2, type: :page},
          %{page: 2, type: :next}
        ]
      })
    end

    test "next event should increment page and update results" do
      [stat | _] = Enum.map(1..(@page_size + 1), &rushing_stat_fixture(%{touchdowns: &1}))
      socket = init_socket()

      {:noreply, %{assigns: assigns}} = RushingLive.handle_event("next", %{}, socket)

      assert_assigns(assigns, %{
        rushing_stats: [stat],
        page: 2,
        total_pages: 2,
        page_numbers: [
          %{page: 1, type: :prev},
          %{page: 1, type: :page},
          %{page: 2, type: :current}
        ]
      })
    end

    test "next even should not increment page past total_pages" do
      [stat | _] = Enum.map(1..(@page_size + 1), &rushing_stat_fixture(%{touchdowns: &1}))
      socket = init_socket() |> assign(page: 2)

      {:noreply, %{assigns: assigns}} = RushingLive.handle_event("next", %{}, socket)

      assert_assigns(assigns, %{
        rushing_stats: [stat],
        page: 2,
        total_pages: 2,
        page_numbers: [
          %{page: 1, type: :prev},
          %{page: 1, type: :page},
          %{page: 2, type: :current}
        ]
      })
    end
  end
end
