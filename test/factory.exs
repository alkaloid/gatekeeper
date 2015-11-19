defmodule Gatekeeper.Factory do

  alias Gatekeeper.Repo
  alias Gatekeeper.Company
  alias Gatekeeper.Member
  alias Gatekeeper.RfidToken
  alias Gatekeeper.Door
  alias Gatekeeper.DoorGroup
  alias Gatekeeper.DoorGroupDoor
  alias Gatekeeper.DoorGroupMember
  alias Gatekeeper.DoorGroupCompany
  alias Gatekeeper.DoorAccessAttempt

  def create_company(params \\ %{}) do
    default_params = %{
      name: "Test Company",
      join_date: :calendar.local_time(),
      departure_date: nil,
    }
    params = Dict.merge(default_params, params)
    changeset = Company.changeset(%Company{}, params)
    {:ok, company} = Repo.insert(changeset)

    if params[:door_group] do
      changeset = DoorGroupCompany.changeset(%DoorGroupCompany{}, %{company_id: company.id, door_group_id: params.door_group.id})
      Repo.insert!(changeset)
    end

    company
  end

  def create_member(params \\ %{}) do
    default_params = %{
      name: "Test Member",
      email: "test@example.com",
      active: true,
    }
    # :company is a required parameter
    default_params = Dict.merge(default_params, company_id: params[:company].id)

    params = Dict.merge(default_params, params)
    changeset = Member.changeset(%Member{}, params)
    {:ok, member} = Repo.insert(changeset)

    if params[:door_group] do
      changeset = DoorGroupMember.changeset(%DoorGroupMember{}, %{member_id: member.id, door_group_id: params.door_group.id})
      Repo.insert!(changeset)
    end

    member
  end

  def create_rfid_token(params \\ %{}) do
    default_params = %{
      identifier: "abcd1234",
      active: true,
    }
    if params[:member] do
      default_params = Dict.merge(default_params, member_id: params[:member].id)
    end

    params = Dict.merge(default_params, params)
    changeset = RfidToken.changeset(%RfidToken{}, params)
    {:ok, rfid_token} = Repo.insert(changeset)
    rfid_token
  end

  def create_door_group(params \\ %{}) do
    default_params = %{
      name: "Test Dooor Group",
    }
    params = Dict.merge(default_params, params)
    changeset = DoorGroup.changeset(%DoorGroup{}, params)
    {:ok, door_group} = Repo.insert(changeset)
    door_group
  end

  def create_door(params \\ %{}) do
    default_params = %{
      name: "Test Door",
    }
    params = Dict.merge(default_params, params)
    changeset = Door.changeset(%Door{}, params)
    {:ok, door} = Repo.insert(changeset)

    if params[:door_group] do
      changeset = DoorGroupDoor.changeset(%DoorGroupDoor{}, %{door_id: door.id, door_group_id: params.door_group.id})
      Repo.insert!(changeset)
    end

    door
  end

  def create_door_access_attempt(door, rfid_token, params \\ %{}) do
    params = Dict.merge(%{access_allowed: true, door_id: door.id, rfid_token_id: rfid_token.id}, params)
    changeset = DoorAccessAttempt.changeset(%DoorAccessAttempt{}, params)
    {:ok, door_access_attempt} = Repo.insert(changeset)
    door_access_attempt
  end
end
