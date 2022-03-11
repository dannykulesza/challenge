defmodule Challenge.Stats do
  @moduledoc """
  The Stats context.
  """

  alias Challenge.Repo
  alias Challenge.Stats.RushingStat
  alias Scrivener.Page

  import Ecto.Query, warn: false

  @page_size 15

  @spec page_size() :: integer()
  def page_size(), do: @page_size

  @spec create_rushing_stat(map()) :: {:ok, RushingStat.t()} | {:error, term()}
  def create_rushing_stat(attrs \\ %{}) do
    %RushingStat{}
    |> RushingStat.changeset(attrs)
    |> Repo.insert()
  end

  @spec paginate_rushing_stats(map()) :: Page.t()
  def paginate_rushing_stats(params) do
    page = Map.get(params, :page, 1)

    params
    |> rushing_stats_query()
    |> Repo.paginate(page: page)
  end

  @spec list_rushing_stats(map()) :: [RushingStat.t()]
  def list_rushing_stats(params) do
    params |> rushing_stats_query() |> Repo.all()
  end

  defp rushing_stats_query(params) do
    RushingStat
    |> where(^build_filter(params))
    |> order_by(^sort_fragment(params))
  end

  defp build_filter(%{filters: filters}), do: Enum.reduce(filters, dynamic(true), &add_filter_fragment/2)
  defp build_filter(_params), do: dynamic(true)

  defp add_filter_fragment({field, filter}, dynamic) do
    expression = "%#{filter}%"
    dynamic([r], ^dynamic and ilike(field(r, ^field), ^expression))
  end

  defp sort_fragment(%{sort_by: :lng, sort_order: sort_order}) do
    [{sort_order, :longest_rush_yards}, {sort_order, :completed_longest_rush_td}]
  end

  defp sort_fragment(%{sort_by: sort_by, sort_order: sort_order}), do: [{sort_order, sort_by}]
  defp sort_fragment(_params), do: []
end
