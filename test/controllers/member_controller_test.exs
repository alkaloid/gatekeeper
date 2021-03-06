defmodule Gatekeeper.MemberControllerTest do
  use GatekeeperWeb.ConnCase

  import Gatekeeper.Factory
  import Guardian.TestHelper

  alias Gatekeeper.Member

  @valid_attrs %{name: "Test Person",  email: "tperson@example.com", active: true, role: "none"}
  @invalid_attrs %{name: "", company_id: nil}

  setup do
    admin = create_member role: "admin", email: "admin@example.com", company: create_company()
    conn = build_conn()
    |> conn_with_fetched_session
    |> Guardian.Plug.sign_in(admin)
    {:ok, conn: conn}
  end

  test "redirects unauthenticated requests" do
    company = create_company()
    conn = build_conn()
    conn = get conn, company_member_path(conn, :index, company)
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "lists all entries on index", %{conn: conn} do
    company = create_company()
    conn = get conn, company_member_path(conn, :index, company)
    assert html_response(conn, 200) =~ ~r/Listing members for .*#{company.name}/
  end

  test "renders form for new resources", %{conn: conn} do
    company = create_company()
    conn = get conn, company_member_path(conn, :new, company)
    assert html_response(conn, 200) =~ ~r/New member of .*#{company.name}/
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    company = create_company()
    conn = post conn, company_member_path(conn, :create, company), member: @valid_attrs
    assert redirected_to(conn) == company_path(conn, :show, company)
    assert Repo.get_by(Member, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    company = create_company()
    conn = post conn, company_member_path(conn, :create, company), member: @invalid_attrs
    assert html_response(conn, 200) =~ "New member"
  end

  test "shows chosen resource", %{conn: conn} do
    company = create_company()
    member = create_member company: company
    conn = get conn, company_member_path(conn, :show, company, member)
    assert html_response(conn, 200) =~ "<h2>#{member.name}</h2>"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    company = create_company()
    assert_raise Ecto.NoResultsError, fn ->
      get conn, company_member_path(conn, :show, company, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    company = create_company()
    member = create_member company: company
    conn = get conn, company_member_path(conn, :edit, company, member)
    assert html_response(conn, 200) =~ "Edit member"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    company = create_company()
    member = create_member company: company
    conn = put conn, company_member_path(conn, :update, company, member), member: Map.merge(@valid_attrs, %{company_id: company.id})
    assert redirected_to(conn) == company_member_path(conn, :show, company, member)
    assert Repo.get_by(Member, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    company = create_company()
    member = create_member company: company
    conn = put conn, company_member_path(conn, :update, company, member), member: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit member"
  end

  test "deactivates chosen resource", %{conn: conn} do
    company = create_company()
    member = create_member company: company
    assert %{active: true} = Repo.get(Member, member.id)
    conn = delete conn, company_member_path(conn, :delete, company, member)
    assert redirected_to(conn) == company_path(conn, :show, company)
    assert %{active: false} = Repo.get(Member, member.id)
  end
end
