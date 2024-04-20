defmodule HomeVisit.Api.Transaction do
  @moduledoc """
  A Transaction struct within the API bounded context.

  The following fields are public:

    * `:pal` - the user who fulfilled the visit
    * `:visit` - the visit that was fulfilled
    * `:fulfilled_at` - the datetime when the visit was fulfilled
    * `:id` - the primary key of the transaction in the database
    * `:pal_id` - the foreign key of the user who fulfilled the visit in the
      database
    * `:visit_id` - the foreign key of the visit that was fulfilled in the
      database
    * `:inserted_at` - the datetime when the transaction was inserted into the
      database
    * `:updated_at` - the datetime when the transaction was last updated in the
      database

  The remaining fields are private and should not be accessed.
  """
  use Ecto.Schema

  alias HomeVisit.Api

  @type t :: %__MODULE__{
          pal_id: pos_integer,
          visit_id: pos_integer,
          fulfilled_at: NaiveDateTime.t()
        }

  schema "transactions" do
    field :fulfilled_at, :naive_datetime

    belongs_to :pal, Api.User
    belongs_to :visit, Api.Visit

    timestamps()
  end
end
