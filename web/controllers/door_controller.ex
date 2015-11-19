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

    case Repo.insert(changeset) do
      {:ok, _door} ->
        conn
        |> put_flash(:info, "Door created successfully.")
        |> redirect(to: door_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    # I could not find a simpler way to preload all the associations while
    # still providing an order to the access_attempts query
    access_attempts_query = DoorAccessAttempt.ordered_preloaded
    door_query = from d in Door, preload: [:door_groups, [access_attempts: ^access_attempts_query]]
    door = Repo.get! door_query, id
    render(conn, "show.html", door: door)
  end

  def edit(conn, %{"id" => id}) do
    door = Repo.get!(Door, id)
    changeset = Door.changeset(door)
    render(conn, "edit.html", door: door, changeset: changeset)
  end

  def update(conn, %{"id" => id, "door" => door_params}) do
    door = Repo.get!(Door, id)
    changeset = Door.changeset(door, door_params)

    case Repo.update(changeset) do
      {:ok, door} ->
        conn
        |> put_flash(:info, "Door updated successfully.")
        |> redirect(to: door_path(conn, :show, door))
      {:error, changeset} ->
        render(conn, "edit.html", door: door, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    conn
    |> put_flash(:error, "Doors may not be deleted.")
    |> redirect(to: door_path(conn, :index))
  end
end
