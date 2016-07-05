defmodule Gatekeeper.WriteRepo do
  use Ecto.Repo, otp_app: :gatekeeper

  defmacro __using__(_) do
    if Mix.env == :test do
      quote do
        alias Gatekeeper.Repo, as: WriteRepo
      end
    else
      quote do
        alias Gatekeeper.WriteRepo
      end
    end
  end
end
