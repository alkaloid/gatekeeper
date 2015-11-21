defmodule Gatekeeper.RfidTokenControllerTest do
  use Gatekeeper.ConnCase

  import Gatekeeper.Factory

  alias Gatekeeper.RfidToken

  @valid_attrs %{identifier: "a_very_different_identifier",  active: true}
  @invalid_attrs %{identifier: "", active: "foo"}

  setup do
    conn = conn()
    {:ok, conn: conn}
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

  test "deletes chosen resource", %{conn: conn} do
    company = create_company
    member = create_member company: company
    rfid_token = create_rfid_token member: member
    assert %{active: true} = Repo.get(RfidToken, rfid_token.id)
    conn = delete conn, company_member_rfid_token_path(conn, :delete, company, member, rfid_token)
    assert redirected_to(conn) == company_member_path(conn, :show, company, member)
    assert %{active: false} = Repo.get(RfidToken, rfid_token.id)
  end

  ## Tokens NOT associated with Members
end
