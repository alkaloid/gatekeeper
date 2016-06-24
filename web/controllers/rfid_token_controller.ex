defmodule Gatekeeper.RfidTokenController do
  use Gatekeeper.Web, :controller

  alias Gatekeeper.Company
  alias Gatekeeper.Member
  alias Gatekeeper.RfidToken
  alias Gatekeeper.DoorAccessAttempt

  plug :scrub_params, "rfid_token" when action in [:create, :update]

  def index(conn, %{"company_id" => _company_id, "member_id" => member_id}) do
    member = Repo.get!(Member, member_id) |> Repo.preload([:rfid_tokens, :company])
    rfid_tokens = member.rfid_tokens |> Repo.preload([:door_access_attempts, [member: :company]])
    render(conn, "index.html", rfid_tokens: rfid_tokens, member: member)
  end

  def index(conn, _params) do
    rfid_tokens = Repo.all(RfidToken) |> Repo.preload([:door_access_attempts, [member: :company]])
    render(conn, "index.html", rfid_tokens: rfid_tokens, member: nil)
  end

  def new(conn, %{"company_id" => _company_id, "member_id" => member_id}) do
    member = Repo.get!(Member, member_id) |> Repo.preload(:company) |> Repo.preload(:rfid_tokens)
    changeset = RfidToken.changeset %RfidToken{}
    render(conn, "new.html", changeset: changeset, member: member, members: Member.all_active)
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
        render(conn, "new.html", changeset: changeset, member: member, members: Member.all_active)
    end
  end

  def show(conn, params = %{"id" => id}) do
    rfid_token = Repo.get!(RfidToken, id) |> Repo.preload [member: :company]
    query = from daa in DoorAccessAttempt.ordered_preloaded, where: daa.rfid_token_id == ^rfid_token.id
    page = Repo.paginate(query, params)
    render conn, "show.html", rfid_token: rfid_token, member: rfid_token.member, door_access_attempts_page: page
  end

  def edit(conn, %{"company_id" => _company_id, "member_id" => _member_id, "id" => id}) do
    rfid_token = Repo.get!(RfidToken, id) |> Repo.preload(:member)
    member = Repo.preload(rfid_token.member, :company)

    changeset = RfidToken.changeset(rfid_token)
    render(conn, "edit.html", member: member, members: nil, rfid_token: rfid_token, changeset: changeset)
  end

  def edit(conn, %{"id" => id}) do
    rfid_token = Repo.get!(RfidToken, id) |> Repo.preload(member: :company)
    changeset = RfidToken.changeset(rfid_token)

    render(conn, "edit.html", member: nil, members: Member.all_active, rfid_token: rfid_token, changeset: changeset)
  end

  def update(conn, %{"id" => id, "rfid_token" => rfid_token_params}) do
    rfid_token = Repo.get!(RfidToken, id) |> Repo.preload(:member)
    if rfid_token.member do
      member = Repo.preload(rfid_token.member, :company)
    else
      member = nil
    end

    # FIXME: Validation, instead of coercion, to ensure the identifier does not change
    rfid_token_params = Dict.merge(rfid_token_params, %{"identifier" => rfid_token.identifier})

    changeset = RfidToken.changeset(rfid_token, rfid_token_params)

    case Repo.update(changeset) do
      {:ok, _rfid_token} ->
        if member do
          destination = company_member_path(conn, :show, member.company, member)
        else
          destination = rfid_token_path(conn, :show, rfid_token)
        end
        conn
        |> put_flash(:info, "RFID Token updated successfully.")
        |> redirect(to: destination)
      {:error, changeset} ->
        render(conn, "edit.html", member: member, rfid_token: rfid_token, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    rfid_token = Repo.get!(RfidToken, id) |> Repo.preload(member: :company)
    member = rfid_token.member
    company = member.company

    # Here we use update! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    changeset = RfidToken.changeset(rfid_token, %{active: false})
    Repo.update!(changeset)

    conn
    |> put_flash(:info, "RFID Token deactivated successfully.")
    |> redirect(to: company_member_path(conn, :show, company, member))
  end
end

