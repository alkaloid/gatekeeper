defmodule Gatekeeper.Factory do

  use Gatekeeper.WriteRepo # allow for hacky override of WriteRepo for tests
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
    {date, _time} = :calendar.local_time()
    default_params = %{
      name: "Test Company",
      join_date: date,
      departure_date: nil,
    }
    params = Dict.merge(default_params, params)
    changeset = Company.changeset(%Company{}, params)
    {:ok, company} = WriteRepo.insert(changeset)

    if params[:door_group] do
      changeset = DoorGroupCompany.changeset(%DoorGroupCompany{}, %{company_id: company.id, door_group_id: params.door_group.id})
      WriteRepo.insert!(changeset)
    end

    company
  end

  def create_member(params \\ %{}) do
    default_params = %{
      name: "Test Member",
      email: "test@example.com",
      active: true,
      role: "none",
    }
    # :company is a required parameter
    default_params = Dict.merge(default_params, company_id: params[:company].id)

    params = Dict.merge(default_params, params)
    changeset = Member.changeset(%Member{}, params)
    {:ok, member} = WriteRepo.insert(changeset)

    if params[:door_group] do
      changeset = DoorGroupMember.changeset(%DoorGroupMember{}, %{member_id: member.id, door_group_id: params.door_group.id})
      WriteRepo.insert!(changeset)
    end

    member
  end

  def create_rfid_token(params \\ %{}) do
    default_params = %{
      identifier: "abcd1234",
      active: true,
    }
    default_params = if params[:member] do
      Dict.merge(default_params, member_id: params[:member].id)
    else
      default_params
    end

    params = Dict.merge(default_params, params)
    changeset = RfidToken.changeset(%RfidToken{}, params)
    {:ok, rfid_token} = WriteRepo.insert(changeset)
    rfid_token
  end

  def create_door_group(params \\ %{}) do
    default_params = %{
      name: "Test Dooor Group",
    }
    params = Dict.merge(default_params, params)
    changeset = DoorGroup.changeset(%DoorGroup{}, params)
    {:ok, door_group} = WriteRepo.insert(changeset)
    door_group
  end

  def create_door(params \\ %{}) do
    default_params = %{
      name: "Test Door",
    }
    params = Dict.merge(default_params, params)
    changeset = Door.changeset(%Door{}, params)
    {:ok, door} = WriteRepo.insert(changeset)

    if params[:door_group] do
      changeset = DoorGroupDoor.changeset(%DoorGroupDoor{}, %{door_id: door.id, door_group_id: params.door_group.id})
      WriteRepo.insert!(changeset)
    end

    door
  end

  def create_door_access_attempt(door, rfid_token, params \\ %{}) do
    params = Dict.merge(%{access_allowed: true, door_id: door.id, rfid_token_id: rfid_token.id, reason: "access_allowed"}, params)
    changeset = DoorAccessAttempt.changeset(%DoorAccessAttempt{}, params)
    {:ok, door_access_attempt} = WriteRepo.insert(changeset)
    door_access_attempt
  end
end
