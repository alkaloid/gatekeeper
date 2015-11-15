defmodule Gatekeeper.DoorGroup do
  use Gatekeeper.Web, :model

  schema "door_groups" do
    field :name, :string
    has_many :door_group_doors, Gatekeeper.DoorGroupDoor
    has_many :doors, through: [:door_group_doors, :door]

    has_many :door_group_companies, Gatekeeper.DoorGroupCompany
    has_many :companies, through: [:door_group_companies, :company]

    has_many :door_group_members, Gatekeeper.DoorGroupMember
    has_many :members, through: [:door_group_members, :member]

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
