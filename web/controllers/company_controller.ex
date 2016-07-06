defmodule Gatekeeper.CompanyController do
  use Gatekeeper.Web, :controller

  alias Gatekeeper.Company
  alias Gatekeeper.DoorGroup
  alias Gatekeeper.DoorGroupCompany
  alias Gatekeeper.DoorAccessAttempt

  plug :scrub_params, "company" when action in [:create, :update]

  def blank_company do
    %Company{} |> Repo.preload([:members, :door_groups])
  end

  def index(conn, _params) do
    companies = Repo.all(from c in Company, order_by: :name)
    |> Repo.preload(:members)
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

    case WriteRepo.insert(changeset) do
      {:ok, company} ->
        save_door_groups(company, company_params["door_groups"])
        conn
        |> put_flash(:info, "Company created successfully.")
        |> redirect(to: company_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", company: blank_company, changeset: changeset, door_groups: door_groups)
    end
  end

  def show(conn, params = %{"id" => id}) do
    company = Repo.get!(Company, id) |> Repo.preload([[members: :rfid_tokens], :door_groups])
    company_rfid_tokens = Enum.reduce company.members, [], fn(member, acc) ->
      acc ++ Enum.reduce member.rfid_tokens, acc, fn(rfid_token, acc) ->
        acc ++ [rfid_token.id]
      end
    end

    query = from daa in DoorAccessAttempt.ordered_preloaded, where: daa.rfid_token_id in ^company_rfid_tokens
    page = Repo.paginate(query, params)
    render(conn, "show.html", company: company, door_access_attempts_page: page)
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

    case WriteRepo.update(changeset) do
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

    # Here we use update! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    {date, _time} = :calendar.local_time()
    changeset = Company.changeset(company, %{departure_date: date})
    WriteRepo.update!(changeset)

    conn
    |> put_flash(:info, "Company deleted successfully.")
    |> redirect(to: company_path(conn, :index))
  end

  def save_door_groups(company, new_door_group_ids) do
    # Remove all existing door <-> door group associations
    # TODO: Make this a transaction
    Ecto.Query.from(door_group_company in DoorGroupCompany, where: door_group_company.company_id == ^company.id) |> WriteRepo.delete_all

    # Insert new door <-> door group associations based on provided checkboxes
    if new_door_group_ids do # can be nil if no boxes were checked
      for {id, _val} <- new_door_group_ids do
        changeset = DoorGroupCompany.changeset(%DoorGroupCompany{}, %{company_id: company.id, door_group_id: id})
        {:ok, _} = WriteRepo.insert(changeset)
      end
    end
  end
end
