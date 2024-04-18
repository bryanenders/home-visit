defmodule HomeVisit.Api.Visit do
  @moduledoc """
  A Visit struct within the API bounded context.

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

  @type t :: %__MODULE__{
          member_id: pos_integer,
          requested_at: NaiveDateTime.t()
        }

  schema "visits" do
    field :date, :date
    field :minutes, :integer
    field :tasks
    field :requested_at, :naive_datetime

    belongs_to :member, Api.User

    timestamps()
  end
end
