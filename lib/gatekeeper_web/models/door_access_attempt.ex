defmodule Gatekeeper.DoorAccessAttempt do
  use GatekeeperWeb, :model

  alias Gatekeeper.RfidToken
  alias Gatekeeper.Member
  alias Gatekeeper.Door

  schema "door_access_attempts" do
    belongs_to :rfid_token, RfidToken
    belongs_to :door, Door
    belongs_to :member, Member
    field :access_allowed, :boolean, default: false
    field :reason, :string

    timestamps()
  end

  @required_fields [:door_id, :rfid_token_id, :access_allowed, :reason]
  @optional_fields [:member_id]

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def ordered_preloaded do
    # I could not find a simpler way to preload all the associations while
    # still providing an order to the access_attempts query
    from attempt in Gatekeeper.DoorAccessAttempt,
      order_by: [desc: attempt.inserted_at],
      preload:  [:door, :rfid_token, [member: :company]]
  end

end
