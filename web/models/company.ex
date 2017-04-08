defmodule Gatekeeper.Company do
  use Gatekeeper.Web, :model

  schema "companies" do
    field :name, :string
    field :join_date, Ecto.Date
    field :departure_date, Ecto.Date
    has_many :members, Gatekeeper.Member, on_delete: :delete_all
    has_many :door_group_companies, Gatekeeper.DoorGroupCompany, on_delete: :delete_all
    has_many :door_groups, through: [:door_group_companies, :door_group]
    has_many :door_access_attempts, through: [:members, :door_access_attempts]

    timestamps
  end

  @required_fields ~w(name join_date)
  @optional_fields ~w(departure_date)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_assoc(:members)
  end

  def active?(company) do
    is_nil company.departure_date
  end

  def active do
    from company in Gatekeeper.Company,
      where: is_nil(company.departure_date),
      order_by: :name
  end
end
