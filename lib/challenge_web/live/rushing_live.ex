defmodule ChallengeWeb.RushingLive do
  @moduledoc """
    LiveView for NFL rushing statistics
  """
  use ChallengeWeb, :live_view

  alias Challenge.Stats
  alias ChallengeWeb.RushingView
  alias Numerator

  @defaults %{
    filters: [],
    page: 1,
    total_pages: nil,
    sort_by: :touchdowns,
    sort_order: :desc,
    rushing_stats: [],
    page_numbers: []
  }

  @keys Map.keys(@defaults)

  def mount(_params, _session, socket) do
    {:ok, update_socket(socket, @defaults)}
  end

  def render(assigns) do
    RushingView.render("index.html", assigns)
  end

  def handle_event("sort", %{"col" => column_string}, %{assigns: assigns} = socket) do
    sort_assigns = column_string |> String.to_existing_atom() |> get_sort_assigns(assigns)
    {:noreply, update_socket(socket, assigns, sort_assigns)}
  end

  def handle_event("player_search", %{"filter" => filter}, %{assigns: assigns} = socket) do
    filters = Keyword.put(assigns.filters, :player, filter)
    {:noreply, update_socket(socket, assigns, %{filters: filters})}
  end

  def handle_event("page", %{"page" => page_num}, %{assigns: assigns} = socket) do
    {:noreply, update_socket(socket, assigns, %{page: page_num})}
  end

  def handle_event("prev", _, %{assigns: assigns} = socket) do
    prev_page = Enum.max([1, assigns.page - 1])
    {:noreply, update_socket(socket, assigns, %{page: prev_page})}
  end

  def handle_event("next", _, %{assigns: assigns} = socket) do
    next_page = Enum.min([assigns.total_pages, assigns.page + 1])
    {:noreply, update_socket(socket, assigns, %{page: next_page})}
  end

  defp update_socket(socket, assigns, opts \\ %{}) do
    updated_params = assigns |> Map.take(@keys) |> Map.merge(opts)

    %{entries: entries, page_number: page, total_pages: total_pages} =
      Stats.paginate_rushing_stats(updated_params)

    page_numbers = Numerator.build(%{page: page, last: total_pages})

    assign(socket, %{
      updated_params
      | rushing_stats: entries,
        page: page,
        total_pages: total_pages,
        page_numbers: page_numbers
    })
  end

  defp get_sort_assigns(column, %{sort_by: sort_by, sort_order: sort_order})
       when column == sort_by,
       do: %{sort_by: sort_by, sort_order: reverse_order(sort_order)}

  defp get_sort_assigns(column, _assigns), do: %{sort_by: column, sort_order: :desc}

  defp reverse_order(:asc), do: :desc
  defp reverse_order(:desc), do: :asc
end
