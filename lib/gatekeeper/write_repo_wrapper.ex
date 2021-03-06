defmodule Gatekeeper.WriteRepoWrapper do
  require Logger

  use GenServer

  alias Gatekeeper.DoorAccessAttempt
  use Gatekeeper.WriteRepo # allow for hacky override of WriteRepo for tests

  @doc """
    Wraps accesses to the Write Repo in an actor
    This allows the application to ignore write failures, which is useful
    for allowing door access attempts even when the master DB is not reachable
  """
  def start_link() do
    GenServer.start_link(__MODULE__, [], name: :write_repo)
  end

  def create_access_attempt(attempt_info, async \\ true) do
    if async do
      GenServer.cast(:write_repo, {:create_access_attempt, attempt_info})
    else
      GenServer.call(:write_repo, {:create_access_attempt, attempt_info})
    end
  end

  def handle_cast({:create_access_attempt, attempt_info}, _) do
    save_attempt attempt_info
    {:noreply, nil}
  end

  def handle_call({:create_access_attempt, attempt_info}, _, _) do
    save_attempt attempt_info
    {:reply, nil, nil}
  end

  def save_attempt(attempt_info) do
    DoorAccessAttempt.changeset(%DoorAccessAttempt{}, attempt_info)
    |> WriteRepo.insert!

    Logger.debug("Door access attempt written to Write Repo")
  end
end
