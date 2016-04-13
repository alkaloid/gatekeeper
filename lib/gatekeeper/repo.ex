defmodule Gatekeeper.Repo do
  use Ecto.Repo, otp_app: :gatekeeper
  use Scrivener, page_size: 20
end
