defmodule GatekeeperWeb.AuthenticationController do
  use GatekeeperWeb, :controller
  plug Ueberauth

  alias Gatekeeper.Repo
  alias Gatekeeper.Member

  if Application.get_env(:gatekeeper, Gatekeeper.Features)[:automatic_auth] do
    def automatic(conn, _params) do
      admin = Repo.all(from member in Member, where: member.role == "admin") |> hd
      conn
      |> Guardian.Plug.sign_in(admin)
      |> put_flash(:info, "Automatically logged in as #{admin.name}")
      |> redirect(to: door_access_attempt_path(conn, :index))
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out.")
    |> Guardian.Plug.sign_out
    |> redirect(to: "/")
  end

  def callback(%{ assigns: %{ ueberauth_failure: fails } } = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate: #{inspect fails}")
    |> redirect(to: "/")
  end

  def callback(%{ assigns: %{ ueberauth_auth: auth } } = conn, _params) do
    case Repo.get_by(Member, email: auth.info.email) do
      %Member{role: "admin"} = member ->
        conn
        |> put_flash(:info, "Successfully logged in as #{member.name}.")
        |> Guardian.Plug.sign_in(member)
        |> redirect(to: door_access_attempt_path(conn, :index))
      %Member{} ->
        conn
        |> put_flash(:error, "You must be an admin to continue.")
        |> redirect(to: "/")
      nil ->
        conn
        |> put_flash(:error, "Access Denied.")
        |> redirect(to: "/")
    end
  end
end
