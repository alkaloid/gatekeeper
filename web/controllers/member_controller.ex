defmodule Gatekeeper.MemberController do
  use Gatekeeper.Web, :controller

  alias Gatekeeper.Company
  alias Gatekeeper.Member
  alias Gatekeeper.DoorGroup
  alias Gatekeeper.DoorGroupMember

  plug :scrub_params, "member" when action in [:create, :update]

  def index(conn, %{"company_id" => company_id}) do
    company = Repo.get!(Company, company_id) |> Repo.preload(:members)
    render(conn, "index.html", company: company, members: company.members)
  end

  def new(conn, %{"company_id" => company_id}) do
    company = Repo.get!(Company, company_id)
    member = %Member{} |> Repo.preload([:door_groups])
    door_groups = Repo.all(DoorGroup)
    changeset = Member.changeset member

    render(conn, "new.html", changeset: changeset, company: company, member: member, door_groups: door_groups)
  end

  def create(conn, %{"company_id" => company_id, "member" => member_params}) do
    company = Repo.get!(Company, company_id)
    member = %Member{} |> Repo.preload([:door_groups])
    door_groups = Repo.all(DoorGroup)
    changeset = Member.changeset(%Member{company_id: String.to_integer(company_id)}, member_params)

    case Repo.insert(changeset) do
      {:ok, member} ->
        save_door_groups(member, member_params["door_groups"])
        conn
        |> put_flash(:info, "Member created successfully.")
        |> redirect(to: company_path(conn, :show, company))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, company: company, member: member, door_groups: door_groups)
    end
  end

  def show(conn, %{"company_id" => company_id, "id" => id}) do
    company = Repo.get!(Company, company_id)
    member = Repo.get!(Member, id) |> Repo.preload([:door_groups, :rfid_tokens, door_access_attempts: [:rfid_token, :door]])
    render(conn, "show.html", company: company, member: member)
  end

  def edit(conn, %{"company_id" => company_id, "id" => id}) do
    company = Repo.get!(Company, company_id)
    member = Repo.get!(Member, id) |> Repo.preload([:door_groups])
    door_groups = Repo.all(DoorGroup)
    changeset = Member.changeset(member)
    render(conn, "edit.html", company: company, member: member, changeset: changeset, door_groups: door_groups)
  end

  def update(conn, %{"company_id" => company_id, "id" => id, "member" => member_params}) do
    company = Repo.get!(Company, company_id)
    member = Repo.get!(Member, id) |> Repo.preload(:door_groups)
    door_groups = Repo.all(DoorGroup)
    changeset = Member.changeset(member, member_params)

    case Repo.update(changeset) do
      {:ok, member} ->
        save_door_groups(member, member_params["door_groups"])
        conn
        |> put_flash(:info, "Member updated successfully.")
        |> redirect(to: company_member_path(conn, :show, company, member))
      {:error, changeset} ->
        render(conn, "edit.html", company: company, member: member, changeset: changeset, door_groups: door_groups)
    end
  end

  def delete(conn, %{"company_id" => company_id, "id" => id}) do
    company = Repo.get!(Company, company_id)
    member = Repo.get!(Member, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(member)

    conn
    |> put_flash(:info, "Member deleted successfully.")
    |> redirect(to: company_path(conn, :show, company))
  end

  def save_door_groups(member, new_door_group_ids) do
    # Remove all existing door <-> door group associations
    Ecto.Query.from(door_group_member in DoorGroupMember, where: door_group_member.member_id == ^member.id) |> Repo.delete_all

    # Insert new door <-> door group associations based on provided checkboxes
    if new_door_group_ids do # can be nil if no boxes were checked
      for {id, _val} <- new_door_group_ids do
        changeset = DoorGroupMember.changeset(%DoorGroupMember{}, %{member_id: member.id, door_group_id: id})
        {:ok, _} = Repo.insert(changeset)
      end
    end
  end
end

