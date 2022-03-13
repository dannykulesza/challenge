defmodule ChallengeWeb.RushingController do
  use ChallengeWeb, :controller

  alias Challenge.Stats

  @sort_bys [
    "lng",
    "touchdowns",
    "yards"
  ]

  @sort_orders [
    "asc",
    "desc"
  ]

  @filters [
    "player",
    "team",
    "position"
  ]

  def download_csv(conn, %{"sort_by" => sort_by_param, "sort_order" => sort_order_param} = params) do
    filters_param = Map.get(params, "filters", %{})

    with {:ok, sort_by} <- parse_param(:sort_by, sort_by_param),
         {:ok, sort_order} <- parse_param(:sort_order, sort_order_param),
         {:ok, filters} <- parse_param(:filters, filters_param) do
      rushing_stats =
        Stats.list_rushing_stats(%{filters: filters, sort_by: sort_by, sort_order: sort_order})

      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header("content-disposition", "attachment; filename=\"rushing_stats.csv\"")
      |> put_status(200)
      |> render("rushing_stats.csv", %{rushing_stats: rushing_stats})
    else
      {:error, message} -> send_error_response(conn, message)
    end
  end

  def download_csv(conn, _params),
    do: send_error_response(conn, "invalid parameters")

  defp parse_param(:sort_by, param) when param in @sort_bys and is_binary(param),
    do: {:ok, String.to_existing_atom(param)}

  defp parse_param(:sort_by, _param), do: {:error, "invalid parameter: sort_by"}

  defp parse_param(:sort_order, param) when param in @sort_orders and is_binary(param),
    do: {:ok, String.to_existing_atom(param)}

  defp parse_param(:sort_order, _param), do: {:error, "invalid parameter: sort_order"}

  defp parse_param(:filters, param) when is_map(param),
    do: Enum.reduce_while(param, {:ok, []}, &parse_filter/2)

  defp parse_param(:filters, _param), do: {:error, "invalid parameter: filters"}

  def parse_filter({key, value}, {:ok, filters}) when key in @filters and is_binary(value) do
    parsed_key = String.to_existing_atom(key)
    updated_filters = [{parsed_key, value} | filters]
    {:cont, {:ok, updated_filters}}
  end

  def parse_filter({key, _value}, _filters), do: {:halt, {:error, "invalid filter: #{key}"}}

  defp send_error_response(conn, message),
    do: conn |> put_status(400) |> json(%{message: message})
end
