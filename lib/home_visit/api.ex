defmodule HomeVisit.Api do
  @moduledoc """
  The API of the HomeVisit application.
  """
  @type params :: %{optional(atom) => term}

  @required_user_fields [:first_name, :last_name, :email]

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
           |> Ecto.Changeset.unique_constraint(:email)
           |> __MODULE__.Repo.insert(),
         do: :ok
  end
end
