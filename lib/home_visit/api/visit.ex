defmodule HomeVisit.Api.Visit do
  @moduledoc """
  A Visit struct and functions within the API bounded context.

  The following fields are public:

    * `:member` - the user who requested the visit
    * `:date` - the date of the visit
    * `:minutes` - the duration of the visit, in minutes
    * `:tasks` - a descriptions of the tasks to be performed during the visit
    * `:requested_at` - the datetime when the visit was requested
    * `:id` - the primary key of the visit in the database
    * `:member_id` - the foreign key of the user who requested the visit in the
      database
    * `:inserted_at` - the datetime when the visit was inserted into the
      database
    * `:updated_at` - the datetime when the visit was last updated in the
      database

  The remaining fields are private and should not be accessed.
  """
  use Ecto.Schema

  alias HomeVisit.Api
  import Ecto.Changeset

  @type t :: %__MODULE__{
          member_id: pos_integer,
          requested_at: NaiveDateTime.t()
        }

  @required_fields [:date, :minutes, :tasks]

  schema "visits" do
    field :date, :date
    field :minutes, :integer
    field :tasks
    field :requested_at, :naive_datetime

    belongs_to :member, Api.User

    timestamps()
  end

  @doc """
  Creates a changeset for a `visit` with the given `params`.
  """
  @spec changeset(t, Api.User.balance(), Api.params()) :: Ecto.Changeset.t()
  def changeset(
        %__MODULE__{member_id: member_id, requested_at: %NaiveDateTime{}} = visit,
        member_balance,
        params
      )
      when is_integer(member_id) and
             member_id > 0 and
             is_integer(member_balance) and
             is_map(params),
      do:
        visit
        |> cast(params, @required_fields)
        |> validate_required(@required_fields)
        |> validate_number(:minutes, greater_than: 0)
        |> validate_number(:minutes,
          less_than_or_equal_to: member_balance,
          message: "can't exceed member balance"
        )
end
