defmodule Gatekeeper.DoorControllerTest do
  use Gatekeeper.ConnCase

  alias Gatekeeper.Door
  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, door_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing doors"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, door_path(conn, :new)
    assert html_response(conn, 200) =~ "New door"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, door_path(conn, :create), door: @valid_attrs
    assert redirected_to(conn) == door_path(conn, :index)
    assert Repo.get_by(Door, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, door_path(conn, :create), door: @invalid_attrs
    assert html_response(conn, 200) =~ "New door"
  end

  test "shows chosen resource", %{conn: conn} do
    door = Repo.insert! %Door{}
    conn = get conn, door_path(conn, :show, door)
    assert html_response(conn, 200) =~ "Show door"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, door_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    door = Repo.insert! %Door{}
    conn = get conn, door_path(conn, :edit, door)
    assert html_response(conn, 200) =~ "Edit door"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    door = Repo.insert! %Door{}
    conn = put conn, door_path(conn, :update, door), door: @valid_attrs
    assert redirected_to(conn) == door_path(conn, :show, door)
    assert Repo.get_by(Door, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    door = Repo.insert! %Door{}
    conn = put conn, door_path(conn, :update, door), door: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit door"
  end

  test "deletes chosen resource", %{conn: conn} do
    door = Repo.insert! %Door{}
    conn = delete conn, door_path(conn, :delete, door)
    assert redirected_to(conn) == door_path(conn, :index)
    refute Repo.get(Door, door.id)
  end
end
