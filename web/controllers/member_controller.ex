defmodule Gatekeeper.MemberController do
  use Gatekeeper.Web, :controller

  alias Gatekeeper.Company
  alias Gatekeeper.Member

  plug :scrub_params, "member" when action in [:create, :update]

  def index(conn, %{"company_id" => company_id}) do
    company = Repo.get!(Company, company_id) |> Repo.preload(:members)
    render(conn, "index.html", company: company, members: company.members)
  end

  def new(conn, %{"company_id" => company_id}) do
    company = Repo.get!(Company, company_id)
    changeset = Member.changeset %Member{}
    render(conn, "new.html", changeset: changeset, company: company)
  end

  def create(conn, %{"company_id" => company_id, "member" => member_params}) do
    company = Repo.get!(Company, company_id)
    changeset = Member.changeset(%Member{company_id: String.to_integer(company_id)}, member_params)

    case Repo.insert(changeset) do
      {:ok, _member} ->
        conn
        |> put_flash(:info, "Member created successfully.")
        |> redirect(to: company_path(conn, :show, company))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, company: company)
    end
  end

  def show(conn, %{"company_id" => company_id, "id" => id}) do
    company = Repo.get!(Company, company_id)
    member = Repo.get!(Member, id)
    render(conn, "show.html", company: company, member: member)
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

    case Repo.update(changeset) do
      {:ok, company} ->
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

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(member)

    conn
    |> put_flash(:info, "Member deleted successfully.")
    |> redirect(to: company_path(conn, :show, company))
  end
end

