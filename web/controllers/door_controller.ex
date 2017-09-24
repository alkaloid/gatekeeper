defmodule Gatekeeper.DoorController do
  use Gatekeeper.Web, :controller

  alias Gatekeeper.Door
  alias Gatekeeper.DoorAccessAttempt
  alias Gatekeeper.DoorLock

  plug :scrub_params, "door" when action in [:create, :update]

  def index(conn, _params) do
    # doors and door_statuses provided globally via plug
    render(conn, "index.html")
  end

  def new(conn, _params) do
    changeset = Door.changeset(%Door{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"door" => door_params}) do
    changeset = Door.changeset(%Door{}, door_params)

    case WriteRepo.insert(changeset) do
      {:ok, _door} ->
        conn
        |> put_flash(:info, "Door created successfully.")
        |> redirect(to: door_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, params = %{"id" => id}) do
    # I could not find a simpler way to preload all the associations while
    # still providing an order to the access_attempts query
    door = Repo.get!(Door, id) |> Repo.preload(:door_groups)
    daa = from daa in DoorAccessAttempt.ordered_preloaded, where: daa.door_id == ^id
    page = Repo.paginate(daa, params)
    render(conn, "show.html", door: door, door_access_attempts_page: page)
  end

  def edit(conn, %{"id" => id}) do
    door = Repo.get!(Door, id)
    changeset = Door.changeset(door)
    render(conn, "edit.html", door: door, changeset: changeset)
  end

  def update(conn, %{"id" => id, "door" => door_params}) do
    door = Repo.get!(Door, id)
    changeset = Door.changeset(door, door_params)

    case WriteRepo.update(changeset) do
      {:ok, door} ->
        conn
        |> put_flash(:info, "Door updated successfully.")
        |> redirect(to: door_path(conn, :show, door))
      {:error, changeset} ->
        render(conn, "edit.html", door: door, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => _id}) do
    conn
    |> put_flash(:error, "Doors may not be deleted.")
    |> redirect(to: door_path(conn, :index))
  end

  def flipflop(conn, %{"door_id" => door_id}) do
    member = Guardian.Plug.current_resource(conn) |> Repo.preload(:rfid_tokens)
    # FIXME: This RFID token ID is a lie! And it can fail if the admin has no token
    access_attempt_params = %{
      access_allowed: true,
      member_id: member.id,
      rfid_token_id: hd(member.rfid_tokens).id,
      door_id: door_id,
      reason: "admin_web_access"
    }
    access_attempt = DoorAccessAttempt.changeset(%DoorAccessAttempt{}, access_attempt_params)
    case WriteRepo.insert(access_attempt) do
      {:ok, _} ->
        case DoorLock.pidof(door_id) do
          :undefined ->
            # Unable to find a door process
            conn
            |> redirect(to: door_path(conn, :index))
          pid ->
            DoorLock.flipflop(pid)
            conn
            |> redirect(to: door_path(conn, :index))
        end
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Unable to log door access attempt")
        |> redirect(to: door_path(conn, :index))
    end
  end
end
