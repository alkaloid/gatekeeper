defmodule Gatekeeper.DoorGroup do
  use GatekeeperWeb, :model

  schema "door_groups" do
    field :name, :string
    has_many :door_group_doors, Gatekeeper.DoorGroupDoor
    has_many :doors, through: [:door_group_doors, :door]

    has_many :door_group_companies, Gatekeeper.DoorGroupCompany
    has_many :companies, through: [:door_group_companies, :company]

    has_many :door_group_schedules, Gatekeeper.DoorGroupSchedule, on_replace: :delete

    timestamps()
  end

  @required_fields [:name]
  @optional_fields []

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> cast_assoc(:door_group_schedules)
    |> validate_required(@required_fields)
  end
end
