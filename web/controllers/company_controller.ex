defmodule Gatekeeper.CompanyController do
  use Gatekeeper.Web, :controller

  alias Gatekeeper.Company
  alias Gatekeeper.DoorGroup
  alias Gatekeeper.DoorGroupCompany

  plug :scrub_params, "company" when action in [:create, :update]

  def blank_company do
    %Company{} |> Repo.preload([:members, :door_groups])
  end

  def index(conn, _params) do
    companies = Repo.all(Company) |> Repo.preload(:members)
    render(conn, "index.html", companies: companies)
  end

  def new(conn, _params) do
    company = blank_company
    changeset = Company.changeset(company)
    door_groups = Repo.all(DoorGroup)
    render(conn, "new.html", company: company, changeset: changeset, door_groups: door_groups)
  end

  def create(conn, %{"company" => company_params}) do
    door_groups = Repo.all(DoorGroup)
    changeset = Company.changeset(%Company{}, company_params)

    case Repo.insert(changeset) do
      {:ok, company} ->
        save_door_groups(company, company_params["door_groups"])
        conn
        |> put_flash(:info, "Company created successfully.")
        |> redirect(to: company_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", company: blank_company, changeset: changeset, door_groups: door_groups)
    end
  end

  def show(conn, %{"id" => id}) do
    daa_query = Gatekeeper.DoorAccessAttempt.ordered_preloaded
    company = Repo.get!(Company, id) |> Repo.preload([:members, :door_groups, [door_access_attempts: daa_query]])
    render(conn, "show.html", company: company)
  end

  def edit(conn, %{"id" => id}) do
    company = Repo.get!(Company, id) |> Repo.preload([:members, :door_groups])
    changeset = Company.changeset(company)
    door_groups = Repo.all(DoorGroup)
    render(conn, "edit.html", company: company, changeset: changeset, door_groups: door_groups)
  end

  def update(conn, %{"id" => id, "company" => company_params}) do
    company = Repo.get!(Company, id) |> Repo.preload([:members, :door_groups])
    door_groups = Repo.all(DoorGroup)
    changeset = Company.changeset(company, company_params)

    case Repo.update(changeset) do
      {:ok, company} ->
        save_door_groups(company, company_params["door_groups"])
        conn
        |> put_flash(:info, "Company updated successfully.")
        |> redirect(to: company_path(conn, :show, company))
      {:error, changeset} ->
        render(conn, "edit.html", company: company, changeset: changeset, door_groups: door_groups)
    end
  end

  def delete(conn, %{"id" => id}) do
    company = Repo.get!(Company, id) |> Repo.preload(:members)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(company)

    conn
    |> put_flash(:info, "Company deleted successfully.")
    |> redirect(to: company_path(conn, :index))
  end

  def save_door_groups(company, new_door_group_ids) do
    # Remove all existing door <-> door group associations
    Ecto.Query.from(door_group_company in DoorGroupCompany, where: door_group_company.company_id == ^company.id) |> Repo.delete_all

    # Insert new door <-> door group associations based on provided checkboxes
    if new_door_group_ids do # can be nil if no boxes were checked
      for {id, _val} <- new_door_group_ids do
        changeset = DoorGroupCompany.changeset(%DoorGroupCompany{}, %{company_id: company.id, door_group_id: id})
        {:ok, _} = Repo.insert(changeset)
      end
    end
  end
end
