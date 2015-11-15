defmodule Gatekeeper.DoorGroupControllerTest do
  use Gatekeeper.ConnCase

  alias Gatekeeper.DoorGroup
  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, door_group_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing door groups"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, door_group_path(conn, :new)
    assert html_response(conn, 200) =~ "New door group"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, door_group_path(conn, :create), door_group: @valid_attrs
    assert redirected_to(conn) == door_group_path(conn, :index)
    assert Repo.get_by(DoorGroup, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, door_group_path(conn, :create), door_group: @invalid_attrs
    assert html_response(conn, 200) =~ "New door group"
  end

  test "shows chosen resource", %{conn: conn} do
    door_group = Repo.insert! %DoorGroup{name: "Test DG"}
    conn = get conn, door_group_path(conn, :show, door_group)
    assert html_response(conn, 200) =~ "Door Group: #{door_group.name}"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, door_group_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    door_group = Repo.insert! %DoorGroup{}
    conn = get conn, door_group_path(conn, :edit, door_group)
    assert html_response(conn, 200) =~ "Edit door group"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    door_group = Repo.insert! %DoorGroup{}
    conn = put conn, door_group_path(conn, :update, door_group), door_group: @valid_attrs
    assert redirected_to(conn) == door_group_path(conn, :show, door_group)
    assert Repo.get_by(DoorGroup, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    door_group = Repo.insert! %DoorGroup{}
    conn = put conn, door_group_path(conn, :update, door_group), door_group: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit door group"
  end

  test "deletes chosen resource", %{conn: conn} do
    door_group = Repo.insert! %DoorGroup{}
    conn = delete conn, door_group_path(conn, :delete, door_group)
    assert redirected_to(conn) == door_group_path(conn, :index)
    refute Repo.get(DoorGroup, door_group.id)
  end
end
