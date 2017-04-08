defmodule Gatekeeper.DoorControllerTest do
  use Gatekeeper.ConnCase

  import Gatekeeper.Factory
  import Guardian.TestHelper

  alias Gatekeeper.Door
  alias Gatekeeper.DoorGroup

  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  setup do
    admin = create_member role: "admin", email: "admin@example.com", company: create_company
    conn = build_conn()
    |> conn_with_fetched_session
    |> Guardian.Plug.sign_in(admin)
    {:ok, conn: conn}
  end

  test "redirects unauthenticated requests" do
    conn = build_conn()
    conn = get conn, door_path(conn, :index)
    assert redirected_to(conn) == page_path(conn, :index)
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
    door = WriteRepo.insert! %Door{}
    conn = get conn, door_path(conn, :show, door)
    assert html_response(conn, 200) =~ "<h1>#{door.name}</h1>"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, door_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    door = WriteRepo.insert! %Door{}
    conn = get conn, door_path(conn, :edit, door)
    assert html_response(conn, 200) =~ "Edit door"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    door = WriteRepo.insert! %Door{}
    conn = put conn, door_path(conn, :update, door), door: @valid_attrs
    assert redirected_to(conn) == door_path(conn, :show, door)
    assert Repo.get_by(Door, @valid_attrs)
  end

  test "updates door group with associated doors and redirects when data is valid", %{conn: conn} do
    door_group = create_door_group
    door = create_door
    # We can't dynamically construct a map with a variable without this
    # See: http://stackoverflow.com/questions/29837103/how-to-put-key-value-pair-into-map-with-variable-key-name
    # "Note that variables cannot be used as keys to add items to a map:"
    # See: http://elixir-lang.org/getting-started/maps-and-dicts.html#maps
    doors_param = Map.put(%{}, "#{door.id}", "on")
    conn = put conn, door_group_path(conn, :update, door_group), door_group: Dict.merge(@valid_attrs, %{doors: doors_param })
    assert redirected_to(conn) == door_group_path(conn, :show, door_group)
    door_group = Repo.get_by(DoorGroup, @valid_attrs) |> Repo.preload(:doors)
    assert door_group
    assert [door.id] == Enum.map(door_group.doors, &(&1.id))
  end

  test "removes unchecked associated door groups from a company", %{conn: conn} do
    door_group = create_door_group
    door = create_door
    WriteRepo.insert! %Gatekeeper.DoorGroupDoor{door_id: door.id, door_group_id: door_group.id}

    conn = put conn, door_group_path(conn, :update, door_group), door_group: Dict.merge(@valid_attrs, id: door_group.id)
    assert redirected_to(conn) == door_group_path(conn, :show, door_group)
    door_group = Repo.get!(DoorGroup, door_group.id) |> Repo.preload(:doors)
    assert door_group
    assert [] == Enum.map(door_group.doors, &(&1.id))
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    door = WriteRepo.insert! %Door{}
    conn = put conn, door_path(conn, :update, door), door: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit door"
  end

  test "does not delete chosen resource", %{conn: conn} do
    door = WriteRepo.insert! %Door{}
    conn = delete conn, door_path(conn, :delete, door)
    assert redirected_to(conn) == door_path(conn, :index)
    assert Repo.get(Door, door.id)
  end
end
