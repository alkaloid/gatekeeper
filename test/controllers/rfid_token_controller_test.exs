defmodule Gatekeeper.RfidTokenControllerTest do
  use Gatekeeper.ConnCase
  use Gatekeeper.WriteRepo # allow for hacky override of WriteRepo for tests

  import Gatekeeper.Factory
  import Guardian.TestHelper

  alias Gatekeeper.RfidToken

  @valid_attrs %{identifier: "a_very_different_identifier",  active: true}
  @invalid_attrs %{identifier: "", active: "foo"}

  setup do
    admin = create_member role: "admin", email: "admin@example.com", company: create_company
    conn = conn()
    |> conn_with_fetched_session
    |> Guardian.Plug.sign_in(admin)
    {:ok, conn: conn}
  end

  test "redirects unauthenticated requests" do
    conn = get conn, rfid_token_path(conn, :index)
    assert redirected_to(conn) == page_path(conn, :index)
  end

  ## Tokens associated with Members
  test "lists all entries on index", %{conn: conn} do
    company = create_company
    member = create_member company: company
    rfid_token = create_rfid_token member: member
    conn = get conn, company_member_rfid_token_path(conn, :index, company, member)
    assert html_response(conn, 200) =~ rfid_token.identifier
  end

  test "renders form for new resources", %{conn: conn} do
    company = create_company
    member = create_member company: company
    conn = get conn, company_member_rfid_token_path(conn, :new, company, member)
    assert html_response(conn, 200) =~ "New RFID Token"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    company = create_company
    member = create_member company: company
    conn = post conn, company_member_rfid_token_path(conn, :create, company, member), rfid_token: @valid_attrs
    assert redirected_to(conn) == company_member_path(conn, :show, company, member)
    assert Repo.get_by(RfidToken, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    company = create_company
    member = create_member company: company
    conn = post conn, company_member_rfid_token_path(conn, :create, company, member), rfid_token: @invalid_attrs
    assert html_response(conn, 200) =~ "Oops, something went wrong!"
  end

  test "shows chosen resource", %{conn: conn} do
    company = create_company
    member = create_member company: company
    rfid_token = create_rfid_token member: member
    conn = get conn, company_member_rfid_token_path(conn, :show, company, member, rfid_token)
    assert html_response(conn, 200) =~ "RFID Token #{rfid_token.identifier}"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    company = create_company
    member = create_member company: company
    assert_raise Ecto.NoResultsError, fn ->
      get conn, company_member_rfid_token_path(conn, :show, company, member, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    company = create_company
    member = create_member company: company
    rfid_token = create_rfid_token member: member
    conn = get conn, company_member_rfid_token_path(conn, :edit, company, member, rfid_token)
    assert html_response(conn, 200) =~ "Edit RFID token"
  end

  # FIXME: You can't change the identifier, so what should this test do?
  #test "updates chosen resource and redirects when data is valid", %{conn: conn} do
  #  company = create_company
  #  member = create_member company: company
  #  rfid_token = create_rfid_token member: member
  #  conn = put conn, company_member_rfid_token_path(conn, :update, company, member, rfid_token), rfid_token: Dict.merge(@valid_attrs, company_id: company.id, member_id: member.id, id: rfid_token.id)
  #  assert redirected_to(conn) == company_member_path(conn, :show, company, member)
  #  assert Repo.get_by(RfidToken, @valid_attrs)
  #end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    company = create_company
    member = create_member company: company
    rfid_token = create_rfid_token member: member
    conn = put conn, company_member_rfid_token_path(conn, :update, company, member, rfid_token), rfid_token: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit RFID token"
  end

  test "deletes chosen resource on the full company/member/rfid_token path", %{conn: conn} do
    company = create_company
    member = create_member company: company
    rfid_token = create_rfid_token member: member
    assert %{active: true} = Repo.get(RfidToken, rfid_token.id)
    conn = delete conn, company_member_rfid_token_path(conn, :delete, company, member, rfid_token)
    assert redirected_to(conn) == company_member_path(conn, :show, company, member)
    assert %{active: false} = Repo.get(RfidToken, rfid_token.id)
  end

  test "deletes chosen resource on the short rfid_token path", %{conn: conn} do
    company = create_company
    member = create_member company: company
    rfid_token = create_rfid_token member: member
    assert %{active: true} = Repo.get(RfidToken, rfid_token.id)
    conn = delete conn, rfid_token_path(conn, :delete, rfid_token)
    assert redirected_to(conn) == company_member_path(conn, :show, company, member)
    assert %{active: false} = Repo.get(RfidToken, rfid_token.id)
  end

  test "allows changing the member assigned to a given RFID token", %{conn: conn} do
    company = create_company
    member1 = create_member company: company
    member2 = create_member company: company

    # Ensure proper creation
    rfid_token = create_rfid_token member: member1
    rfid_token = Repo.get!(RfidToken, rfid_token.id)
    assert rfid_token.member_id == member1.id

    # Ensure proper re-assignment
    put conn, rfid_token_path(conn, :update, rfid_token), rfid_token: Dict.merge(@valid_attrs, member_id: member2.id, id: rfid_token.id)
    rfid_token = Repo.get!(RfidToken, rfid_token.id)
    assert rfid_token.member_id == member2.id
  end
end
