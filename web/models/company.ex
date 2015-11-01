defmodule Gatekeeper.Company do
  use Gatekeeper.Web, :model

  schema "companies" do
    field :name, :string
    field :join_date, Ecto.DateTime
    field :departure_date, Ecto.DateTime
    has_many :members, Gatekeeper.Member, on_delete: :fetch_and_delete

    timestamps
  end

  @required_fields ~w(name join_date)
  @optional_fields ~w(departure_date members)

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
