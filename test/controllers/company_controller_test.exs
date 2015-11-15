defmodule Gatekeeper.CompanyControllerTest do
  use Gatekeeper.ConnCase

  import Gatekeeper.Factory

  alias Gatekeeper.Company
  @valid_attrs %{departure_date: "2010-04-17 14:00:00", join_date: "2010-04-17 14:00:00", name: "some content"}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, company_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing companies"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, company_path(conn, :new)
    assert html_response(conn, 200) =~ "New company"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, company_path(conn, :create), company: @valid_attrs
    assert redirected_to(conn) == company_path(conn, :index)
    assert Repo.get_by(Company, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, company_path(conn, :create), company: @invalid_attrs
    assert html_response(conn, 200) =~ "New company"
  end

  test "shows chosen resource", %{conn: conn} do
    company = Repo.insert! %Company{name: "Company XYZ"}
    conn = get conn, company_path(conn, :show, company)
    assert html_response(conn, 200) =~ "<h2>Company XYZ</h2>"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, company_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    company = Repo.insert! %Company{}
    conn = get conn, company_path(conn, :edit, company)
    assert html_response(conn, 200) =~ "Edit company"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    company = Repo.insert! %Company{}
    conn = put conn, company_path(conn, :update, company), company: @valid_attrs
    assert redirected_to(conn) == company_path(conn, :show, company)
    assert Repo.get_by(Company, @valid_attrs)
  end

  test "updates company with associated door groups and redirects when data is valid", %{conn: conn} do
    door_group = create_door_group
    company = Repo.insert! %Company{}
    # We can't dynamically construct a map with a variable without this
    # See: http://stackoverflow.com/questions/29837103/how-to-put-key-value-pair-into-map-with-variable-key-name
    # "Note that variables cannot be used as keys to add items to a map:"
    # See: http://elixir-lang.org/getting-started/maps-and-dicts.html#maps
    door_group_param = Map.put(%{}, "#{door_group.id}", "on")
    conn = put conn, company_path(conn, :update, company), company: Dict.merge(@valid_attrs, %{door_groups: door_group_param })
    assert redirected_to(conn) == company_path(conn, :show, company)
    company = Repo.get_by(Company, @valid_attrs) |> Repo.preload :door_groups
    assert company
    assert [door_group.id] == Enum.map(company.door_groups, &(&1.id))
  end

  test "removes unchecked associated door groups from a company", %{conn: conn} do
    door_group = create_door_group
    company = create_company
    door_group_company = Repo.insert! %Gatekeeper.DoorGroupCompany{company_id: company.id, door_group_id: door_group.id}

    conn = put conn, company_path(conn, :update, company), company: Dict.merge(@valid_attrs, id: company.id)
    assert redirected_to(conn) == company_path(conn, :show, company)
    company = Repo.get!(Company, company.id) |> Repo.preload :door_groups
    assert company
    assert [] == Enum.map(company.door_groups, &(&1.id))
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    company = Repo.insert! %Company{}
    conn = put conn, company_path(conn, :update, company), company: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit company"
  end

  test "deletes chosen resource", %{conn: conn} do
    company = Repo.insert! %Company{}
    conn = delete conn, company_path(conn, :delete, company)
    assert redirected_to(conn) == company_path(conn, :index)
    refute Repo.get(Company, company.id)
  end
end
