defmodule ChallengeWeb.Router do
  use ChallengeWeb, :router

  @secure_browser_headers %{
    "content-security-policy" =>
      "default-src 'self';" <>
        "style-src-elem 'self' cdn.jsdelivr.net;" <>
        "img-src www.thescore.com;"
  }

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ChallengeWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers, @secure_browser_headers
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
