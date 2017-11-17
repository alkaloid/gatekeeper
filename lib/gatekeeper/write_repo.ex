defmodule Gatekeeper.WriteRepo do
  use Ecto.Repo, otp_app: :gatekeeper

  defmacro __using__(_) do
    if Application.get_env(:gatekeeper, Gatekeeper.Features)[:split_reads] do
      quote do
        alias Gatekeeper.WriteRepo
      end
    else
      quote do
        alias Gatekeeper.Repo, as: WriteRepo
      end
    end
  end
end
