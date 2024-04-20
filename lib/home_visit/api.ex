defmodule HomeVisit.Api do
  @moduledoc """
  The API of the HomeVisit application.
  """
  @type email :: binary
  @type params :: %{optional(atom) => term}
  @type visit_id :: pos_integer

  @required_user_fields [:first_name, :last_name, :email, :balance]
  @required_visit_fields [:date, :minutes, :tasks]

  @doc """
  Registers a new user with the given `params`.

  If `params` are valid, then `:ok` is returned.  Otherwise, field errors are
  returned in the shape of `{:error, changeset}`.

  ## Examples

      iex> Api.register_user(%{
      iex>   first_name: "Ursula",
      iex>   last_name: "Le Guin",
      iex>   email: "hello@ursulakleguin.com"
      iex> })
      :ok

  """
  @spec register_user(params) :: :ok | {:error, Ecto.Changeset.t()}
  def register_user(params) when is_map(params) do
    registered_at = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    with {:ok, _} <-
           %__MODULE__.User{registered_at: registered_at}
           |> Ecto.Changeset.cast(params, @required_user_fields)
           |> Ecto.Changeset.validate_required(@required_user_fields)
           |> Ecto.Changeset.validate_number(:balance,
             greater_than_or_equal_to: 0,
             message: "can't be negative"
           )
           |> Ecto.Changeset.unique_constraint(:email)
           |> __MODULE__.Repo.insert(),
         do: :ok
  end

  @doc """
  Issues a member request for a visit with the given `params`.

  If member with the given `email` is found and `params` are valid, then a
  unique visit ID is returned in the shape of `{:ok, id}`.  If the member
  cannot be found, `{:error, :member_not_found}` is returned.  If `params` are
  invalid, field errors are returned in the shape of `{:error, changeset}`.
  """
  @spec request_visit(email, params) ::
          {:ok, visit_id} | {:error, :member_not_found | Ecto.Changeset.t()}
  def request_visit(email, params) when is_binary(email) and is_map(params) do
    case __MODULE__.Repo.get_by(__MODULE__.User, email: email) do
      nil ->
        {:error, :member_not_found}

      member ->
        requested_at = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

        with {:ok, %{id: visit_id}} <-
               %__MODULE__.Visit{member_id: member.id, requested_at: requested_at}
               |> Ecto.Changeset.cast(params, @required_visit_fields)
               |> Ecto.Changeset.validate_required(@required_visit_fields)
               |> __MODULE__.Repo.insert(),
             do: {:ok, visit_id}
    end
  end
end
