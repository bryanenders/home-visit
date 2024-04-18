defmodule HomeVisit.Api.User do
  @moduledoc """
  A User struct within the API bounded context.

  The following fields are public:

    * `:first_name` - the first name of the user
    * `:last_name` - the last name of the user
    * `:email` - the email of the user
    * `:registered_at` - the datetime when the user was registered
    * `:id` - the primary key of the user in the database
    * `:inserted_at` - the datetime when the user was inserted into the
      database
    * `:updated_at` - the datetime when the user was last updated in the
      database

  The remaining fields are private and should not be accessed.
  """
  use Ecto.Schema

  @type t :: %__MODULE__{
          registered_at: NaiveDateTime.t()
        }

  schema "users" do
    field :first_name
    field :last_name
    field :email
    field :registered_at, :naive_datetime

    timestamps()
  end
end
