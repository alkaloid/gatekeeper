defmodule Gatekeeper.RfidTokenController do
  use Gatekeeper.Web, :controller

  alias Gatekeeper.Company
  alias Gatekeeper.Member
  alias Gatekeeper.RfidToken

  plug :scrub_params, "rfid_token" when action in [:create, :update]

  def index(conn, %{"company_id" => _company_id, "member_id" => member_id}) do
    member = Repo.get!(Member, member_id) |> Repo.preload(:company) |> Repo.preload(:rfid_tokens)
    render(conn, "index.html", member: member, company: member.company, rfid_tokens: member.rfid_tokens)
  end

  def new(conn, %{"company_id" => _company_id, "member_id" => member_id}) do
    member = Repo.get!(Member, member_id) |> Repo.preload(:company) |> Repo.preload(:rfid_tokens)
    changeset = RfidToken.changeset %RfidToken{}
    render(conn, "new.html", changeset: changeset, member: member)
  end

  def create(conn, %{"company_id" => _company_id, "member_id" => member_id, "rfid_token" => rfid_token_params}) do
    member = Repo.get!(Member, member_id) |> Repo.preload(:company) |> Repo.preload(:rfid_tokens)
    changeset = RfidToken.changeset(%RfidToken{member_id: String.to_integer(member_id)}, rfid_token_params)

    case Repo.insert(changeset) do
      {:ok, _rfid_token} ->
        conn
        |> put_flash(:info, "RFID Token created successfully.")
        |> redirect(to: company_member_path(conn, :show, member.company, member))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, member: member)
    end
  end

  def show(conn, %{"company_id" => _company_id, "member_id" => _member_id, "id" => id}) do
    rfid_token = Repo.get!(RfidToken, id) |> Repo.preload(:member)
    member = Repo.preload(rfid_token.member, :company)
    render(conn, "show.html", rfid_token: rfid_token, member: member)
  end

  def edit(conn, %{"company_id" => _company_id, "member_id" => _member_id, "id" => id}) do
    rfid_token = Repo.get!(RfidToken, id) |> Repo.preload(:member)
    member = Repo.preload(rfid_token.member, :company)
    changeset = RfidToken.changeset(rfid_token)
    render(conn, "edit.html", member: member, rfid_token: rfid_token, changeset: changeset)
  end

  def update(conn, %{"company_id" => _company_id, "member_id" => _member_id, "id" => id, "rfid_token" => rfid_token_params}) do
    rfid_token = Repo.get!(RfidToken, id) |> Repo.preload(:member)
    member = Repo.preload(rfid_token.member, :company)
    changeset = RfidToken.changeset(rfid_token, rfid_token_params)

    case Repo.update(changeset) do
      {:ok, _rfid_token} ->
        conn
        |> put_flash(:info, "RFID Token updated successfully.")
        |> redirect(to: company_member_path(conn, :show, member.company, member))
      {:error, changeset} ->
        render(conn, "edit.html", member: member, rfid_token: rfid_token, changeset: changeset)
    end
  end

  def delete(conn, %{"company_id" => company_id, "member_id" => member_id, "id" => id}) do
    company = Repo.get!(Company, company_id)
    member = Repo.get!(Member, member_id)
    rfid_token = Repo.get!(RfidToken, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(rfid_token)

    conn
    |> put_flash(:info, "RFID Token deleted successfully.")
    |> redirect(to: company_member_path(conn, :show, company, member))
  end
end

