defmodule GatekeeperWeb.DoorAccessAttemptController do
  use GatekeeperWeb, :controller

  alias Gatekeeper.DoorAccessAttempt

  plug :scrub_params, "door_access_attempt" when action in [:create, :update]

  def index(conn, params) do
    page = DoorAccessAttempt.ordered_preloaded |> Gatekeeper.Repo.paginate(params)
    render conn, "index.html", page: page
  end

  def new(conn, _params) do
    changeset = DoorAccessAttempt.changeset(%DoorAccessAttempt{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"door_access_attempt" => door_access_attempt_params}) do
    changeset = DoorAccessAttempt.changeset(%DoorAccessAttempt{}, door_access_attempt_params)

    case WriteRepo.insert(changeset) do
      {:ok, _door_access_attempt} ->
        conn
        |> put_flash(:info, "Door access attempt created successfully.")
        |> redirect(to: door_access_attempt_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    door_access_attempt = Repo.get!(DoorAccessAttempt, id)
    render(conn, "show.html", door_access_attempt: door_access_attempt)
  end

  def edit(conn, %{"id" => id}) do
    door_access_attempt = Repo.get!(DoorAccessAttempt, id)
    changeset = DoorAccessAttempt.changeset(door_access_attempt)
    render(conn, "edit.html", door_access_attempt: door_access_attempt, changeset: changeset)
  end

  def update(conn, %{"id" => id, "door_access_attempt" => door_access_attempt_params}) do
    door_access_attempt = Repo.get!(DoorAccessAttempt, id)
    changeset = DoorAccessAttempt.changeset(door_access_attempt, door_access_attempt_params)

    case WriteRepo.update(changeset) do
      {:ok, door_access_attempt} ->
        conn
        |> put_flash(:info, "Door access attempt updated successfully.")
        |> redirect(to: door_access_attempt_path(conn, :show, door_access_attempt))
      {:error, changeset} ->
        render(conn, "edit.html", door_access_attempt: door_access_attempt, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    door_access_attempt = Repo.get!(DoorAccessAttempt, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    WriteRepo.delete!(door_access_attempt)

    conn
    |> put_flash(:info, "Door access attempt deleted successfully.")
    |> redirect(to: door_access_attempt_path(conn, :index))
  end
end
