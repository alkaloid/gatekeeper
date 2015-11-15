defmodule Gatekeeper.DoorGroupController do
  use Gatekeeper.Web, :controller
  import Ecto.Query

  alias Gatekeeper.DoorGroup
  alias Gatekeeper.Door
  alias Gatekeeper.DoorGroupDoor

  plug :scrub_params, "door_group" when action in [:create, :update]

  def blank_door_group do
    %DoorGroup{} |> Repo.preload(:doors)
  end

  def index(conn, _params) do
    door_groups = Repo.all(DoorGroup)
    render(conn, "index.html", door_groups: door_groups)
  end

  def new(conn, _params) do
    changeset = DoorGroup.changeset(blank_door_group)
    doors = Repo.all(Door)
    render(conn, "new.html", doors: doors, door_group: blank_door_group, changeset: changeset)
  end

  def create(conn, %{"door_group" => door_group_params}) do
    changeset = DoorGroup.changeset(%DoorGroup{}, door_group_params)
    doors = Repo.all(Door)

    case Repo.insert(changeset) do
      {:ok, door_group} ->
        save_door_groups door_group, door_group_params
        conn
        |> put_flash(:info, "Door group created successfully.")
        |> redirect(to: door_group_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", doors: doors, door_group: blank_door_group, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    door_group = Repo.get!(DoorGroup, id) |> Repo.preload [:doors, :companies]
    render(conn, "show.html", door_group: door_group)
  end

  def edit(conn, %{"id" => id}) do
    door_group = Repo.get!(DoorGroup, id) |> Repo.preload :doors
    changeset = DoorGroup.changeset(door_group)
    doors = Repo.all(Door)
    render(conn, "edit.html", door_group: door_group, doors: doors, changeset: changeset)
  end

  def update(conn, %{"id" => id, "door_group" => door_group_params}) do
    door_group = Repo.get!(DoorGroup, id) |> Repo.preload :doors
    doors = Repo.all(Door)
    changeset = DoorGroup.changeset(door_group, door_group_params)

    case Repo.update(changeset) do
      {:ok, door_group} ->
        save_door_groups door_group, door_group_params
        conn
        |> put_flash(:info, "Door group updated successfully.")
        |> redirect(to: door_group_path(conn, :show, door_group))
      {:error, changeset} ->
        render(conn, "edit.html", doors: doors, door_group: door_group, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    door_group = Repo.get!(DoorGroup, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(door_group)

    conn
    |> put_flash(:info, "Door group deleted successfully.")
    |> redirect(to: door_group_path(conn, :index))
  end

  def save_door_groups(door_group, new_door_group_params) do
    # Remove all existing door <-> door group associations
    Ecto.Query.from(door_group_door in DoorGroupDoor, where: door_group_door.door_group_id == ^door_group.id) |> Repo.delete_all

    # Insert new door <-> door group associations based on provided checkboxes
    if new_door_group_params["doors"] do # can be nil if no boxes were checked
      for {id, _door_params} <- new_door_group_params["doors"] do
        changeset = DoorGroupDoor.changeset(%DoorGroupDoor{}, %{door_group_id: door_group.id, door_id: id})
        {:ok, _} = Repo.insert(changeset)
      end
    end
  end
end
