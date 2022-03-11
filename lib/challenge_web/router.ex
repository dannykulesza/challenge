defmodule ChallengeWeb.Router do
  use ChallengeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ChallengeWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ChallengeWeb do
    pipe_through :browser

    live "/", RushingLive
    get "/rushing/csv", RushingController, :download_csv
  end
end
