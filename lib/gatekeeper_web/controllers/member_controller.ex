defmodule GatekeeperWeb.MemberController do
  use GatekeeperWeb, :controller

  alias Gatekeeper.Company
  alias Gatekeeper.Member
  alias Gatekeeper.DoorAccessAttempt

  plug :scrub_params, "member" when action in [:create, :update]

  def index(conn, %{"company_id" => company_id}) do
    company = Repo.get!(Company, company_id) |> Repo.preload(:members)
    render(conn, "index.html", company: company, members: company.members)
  end

  def new(conn, %{"company_id" => company_id}) do
    company = Repo.get!(Company, company_id)
    member = %Member{}
    changeset = Member.changeset member

    render(conn, "new.html", changeset: changeset, company: company, member: member)
  end

  def create(conn, %{"company_id" => company_id, "member" => member_params}) do
    company = Repo.get!(Company, company_id)
    member = %Member{}
    changeset = Member.changeset(%Member{company_id: String.to_integer(company_id)}, member_params)

    case WriteRepo.insert(changeset) do
      {:ok, _member} ->
        conn
        |> put_flash(:info, "Member created successfully.")
        |> redirect(to: company_path(conn, :show, company))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, company: company, member: member)
    end
  end

  def show(conn, params = %{"company_id" => _company_id, "id" => id}) do
    member = Repo.get!(Member, id) |> Repo.preload([:company, :rfid_tokens, [door_access_attempts: DoorAccessAttempt.ordered_preloaded]])
    member_rfid_tokens = Enum.reduce member.rfid_tokens, [], fn(rfid_token, acc) ->
      acc ++ [rfid_token.id]
    end

    query = from daa in DoorAccessAttempt.ordered_preloaded, where: daa.rfid_token_id in ^member_rfid_tokens
    page = Repo.paginate(query, params)
    render(conn, "show.html", member: member, door_access_attempts_page: page)
  end

  def edit(conn, %{"company_id" => company_id, "id" => id}) do
    company = Repo.get!(Company, company_id)
    member = Repo.get!(Member, id)
    changeset = Member.changeset(member)
    render(conn, "edit.html", company: company, member: member, changeset: changeset)
  end

  def update(conn, %{"company_id" => company_id, "id" => id, "member" => member_params}) do
    company = Repo.get!(Company, company_id)
    member = Repo.get!(Member, id)
    changeset = Member.changeset(member, member_params)

    case WriteRepo.update(changeset) do
      {:ok, member} ->
        conn
        |> put_flash(:info, "Member updated successfully.")
        |> redirect(to: company_member_path(conn, :show, company, member))
      {:error, changeset} ->
        render(conn, "edit.html", company: company, member: member, changeset: changeset)
    end
  end

  def delete(conn, %{"company_id" => company_id, "id" => id}) do
    company = Repo.get!(Company, company_id)
    member = Repo.get!(Member, id)

    changeset = Member.changeset(member, %{active: false})
    WriteRepo.update!(changeset)

    conn
    |> put_flash(:info, "Member successfully deactivated")
    |> redirect(to: company_path(conn, :show, company))
  end
end

