defmodule Gatekeeper.DoorController do
  use Gatekeeper.Web, :controller

  alias Gatekeeper.Door
  alias Gatekeeper.DoorAccessAttempt

  plug :scrub_params, "door" when action in [:create, :update]

  def index(conn, _params) do
    doors = Repo.all(Door)
    render(conn, "index.html", doors: doors)
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
    door = Repo.get!(Door, id) |> Repo.preload :door_groups
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
end
