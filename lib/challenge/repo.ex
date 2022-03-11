defmodule Challenge.Repo do
  use Ecto.Repo,
    otp_app: :challenge,
    adapter: Ecto.Adapters.Postgres
  use Scrivener, page_size: 15
end
