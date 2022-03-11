defmodule ChallengeWeb.RushingController do
  use ChallengeWeb, :controller

  alias Challenge.Stats

  def download_csv(conn, %{"sort_by" => sort_by_param, "sort_order" => sort_order_param} = params) do
    filter_param = Map.get(params, "filters", %{})

    sort_by = String.to_existing_atom(sort_by_param)
    sort_order = String.to_existing_atom(sort_order_param)
    filters = Enum.map(filter_param, fn {k, v} -> {String.to_existing_atom(k), v} end)

    rushing_stats =
      Stats.list_rushing_stats(%{filters: filters, sort_by: sort_by, sort_order: sort_order})

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("cache-control", "max-age=120, public")
    |> put_resp_header("content-disposition", "attachment; filename=\"rushing_stats.csv\"")
    |> put_status(200)
    |> render("rushing_stats.csv", %{rushing_stats: rushing_stats})
  end

  def download_csv(conn, _params),
    do: put_status(conn, 400) |> json(%{message: "invalid parameters"})
end
