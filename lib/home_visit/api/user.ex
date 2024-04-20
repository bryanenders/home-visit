defmodule HomeVisit.Api.User do
  @moduledoc """
  A User struct and functions within the API bounded context.

  The following fields are public:

    * `:first_name` - the first name of the user
    * `:last_name` - the last name of the user
    * `:email` - the email of the user
    * `:balance` - the number of minutes which are currently available for
      requesting visits
    * `:registered_at` - the datetime when the user was registered
    * `:id` - the primary key of the user in the database
    * `:inserted_at` - the datetime when the user was inserted into the
      database
    * `:updated_at` - the datetime when the user was last updated in the
      database

  The remaining fields are private and should not be accessed.
  """
  use Ecto.Schema

  alias HomeVisit.Api
  import Ecto.Changeset

  @type balance :: non_neg_integer
  @type t :: %__MODULE__{
          balance: balance,
          registered_at: NaiveDateTime.t()
        }

  @required_fields [:first_name, :last_name, :email, :balance]

  schema "users" do
    field :first_name
    field :last_name
    field :email
    field :balance, :integer, default: 0
    field :registered_at, :naive_datetime

    timestamps()
  end

  @doc """
  Creates a changeset for a `user` with the given `params`.
  """
  @spec changeset(t, Api.params()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{balance: balance, registered_at: %NaiveDateTime{}} = user, params)
      when is_integer(balance) and balance >= 0 and is_map(params),
      do:
        user
        |> cast(params, @required_fields)
        |> validate_required(@required_fields)
        |> validate_number(:balance, greater_than_or_equal_to: 0, message: "can't be negative")
        |> unique_constraint(:email)
end
