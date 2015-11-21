defmodule Gatekeeper.DoorAccessAttemptControllerTest do
  use Gatekeeper.ConnCase

  import Gatekeeper.Factory

  alias Gatekeeper.DoorAccessAttempt

  @valid_attrs %{access_allowed: true, reason: "access_allowed"}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, door_access_attempt_path(conn, :index)
    assert html_response(conn, 200) =~ "Access Log"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, door_access_attempt_path(conn, :new)
    assert html_response(conn, 200) =~ "New door access attempt"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    rfid_token = create_rfid_token
    door = create_door
    attrs = Dict.merge(@valid_attrs, %{rfid_token_id: rfid_token.id, door_id: door.id})
    conn = post conn, door_access_attempt_path(conn, :create), door_access_attempt: attrs
    assert redirected_to(conn) == door_access_attempt_path(conn, :index)
    assert Repo.get_by(DoorAccessAttempt, attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, door_access_attempt_path(conn, :create), door_access_attempt: @invalid_attrs
    assert html_response(conn, 200) =~ "New door access attempt"
  end

  test "shows chosen resource", %{conn: conn} do
    door_access_attempt = create_door_access_attempt create_door, create_rfid_token
    conn = get conn, door_access_attempt_path(conn, :show, door_access_attempt)
    assert html_response(conn, 200) =~ "Show door access attempt"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, door_access_attempt_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    door_access_attempt = Repo.insert! %DoorAccessAttempt{}
    conn = get conn, door_access_attempt_path(conn, :edit, door_access_attempt)
    assert html_response(conn, 200) =~ "Edit door access attempt"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    door_access_attempt = create_door_access_attempt create_door, create_rfid_token
    conn = put conn, door_access_attempt_path(conn, :update, door_access_attempt), door_access_attempt: @valid_attrs
    assert redirected_to(conn) == door_access_attempt_path(conn, :show, door_access_attempt)
    assert Repo.get_by(DoorAccessAttempt, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    door_access_attempt = Repo.insert! %DoorAccessAttempt{}
    conn = put conn, door_access_attempt_path(conn, :update, door_access_attempt), door_access_attempt: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit door access attempt"
  end

  test "deletes chosen resource", %{conn: conn} do
    door_access_attempt = Repo.insert! %DoorAccessAttempt{}
    conn = delete conn, door_access_attempt_path(conn, :delete, door_access_attempt)
    assert redirected_to(conn) == door_access_attempt_path(conn, :index)
    refute Repo.get(DoorAccessAttempt, door_access_attempt.id)
  end
end
