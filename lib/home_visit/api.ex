defmodule HomeVisit.Api do
  @moduledoc """
  The API of the HomeVisit application.
  """
  @type email :: binary
  @type params :: %{optional(atom) => term}
  @type visit_id :: pos_integer

  @required_visit_fields [:date, :minutes, :tasks]

  @doc """
  Fulfills a visit request with the given `id` on behalf of a pal.

  If pal with the given `email` and visit with the given `id` are found, then
  `:ok` is returned.  If the pal cannot be found, `{:error, :pal_not_found}` is
  returned.  If the visit cannot be found, `{:error, :visit_not_found}` is
  returned.
  """
  @spec fulfill_visit(email, visit_id) :: :ok | {:error, :pal_not_found | :visit_not_found}
  def fulfill_visit(email, id) when is_binary(email) and is_integer(id) and id > 0 do
    with {:ok, pal} <- fetch_pal(email),
         {:ok, visit} <- fetch_visit(id),
         {:ok, _transaction} <-
           __MODULE__.Repo.transaction(fn ->
             debit_visit_member(visit)
             credit_pal_for_visit(pal, visit)
             create_transaction(pal, visit)
           end),
         do: :ok
  end

  @spec credit_pal_for_visit(__MODULE__.User.t(), __MODULE__.Visit.t()) :: :ok
  defp credit_pal_for_visit(%__MODULE__.User{} = pal, %__MODULE__.Visit{} = visit) do
    credit =
      (visit.minutes * 0.85)
      |> ceil()
      |> trunc()

    pal = __MODULE__.Repo.reload(pal)

    pal
    |> Ecto.Changeset.change(balance: pal.balance + credit)
    |> __MODULE__.Repo.update!()

    :ok
  end

  @spec debit_visit_member(__MODULE__.Visit.t()) :: :ok
  defp debit_visit_member(%__MODULE__.Visit{} = visit) do
    member = __MODULE__.Repo.get!(__MODULE__.User, visit.member_id)

    member
    |> Ecto.Changeset.change(balance: member.balance - visit.minutes)
    |> __MODULE__.Repo.update!()

    :ok
  end

  @spec create_transaction(__MODULE__.User.t(), __MODULE__.Visit.t()) ::
          __MODULE__.Transaction.t()
  defp create_transaction(%__MODULE__.User{id: pal_id}, %__MODULE__.Visit{id: visit_id}),
    do:
      __MODULE__.Repo.insert!(%__MODULE__.Transaction{
        pal_id: pal_id,
        visit_id: visit_id,
        fulfilled_at: now()
      })

  @spec fetch_pal(email) :: {:ok, __MODULE__.User.t()} | {:error, :pal_not_found}
  defp fetch_pal(email) when is_binary(email) do
    if pal = __MODULE__.Repo.get_by(__MODULE__.User, email: email) do
      {:ok, pal}
    else
      {:error, :pal_not_found}
    end
  end

  @spec fetch_visit(visit_id) :: {:ok, __MODULE__.Visit.t()} | {:error, :visit_not_found}
  defp fetch_visit(id) when is_integer(id) and id > 0 do
    if visit = __MODULE__.Repo.get(__MODULE__.Visit, id) do
      {:ok, visit}
    else
      {:error, :visit_not_found}
    end
  end

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
    with {:ok, _} <-
           %__MODULE__.User{registered_at: now()}
           |> __MODULE__.User.changeset(params)
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
    with {:ok, member} <- fetch_member(email) do
      __MODULE__.Repo.transaction(fn ->
        case do_request_visit(member, params) do
          {:ok, %{id: visit_id}} ->
            visit_id

          {:error, %Ecto.Changeset{} = changeset} ->
            __MODULE__.Repo.rollback(changeset)
        end
      end)
    end
  end

  @spec do_request_visit(__MODULE__.User.t(), params) ::
          {:ok, __MODULE__.Visit.t()} | {:error, Ecto.Changeset.t()}
  defp do_request_visit(%__MODULE__.User{} = member, params) when is_map(params) do
    %__MODULE__.Visit{member_id: member.id, requested_at: now()}
    |> Ecto.Changeset.cast(params, @required_visit_fields)
    |> Ecto.Changeset.validate_required(@required_visit_fields)
    |> Ecto.Changeset.validate_number(:minutes, greater_than: 0)
    |> Ecto.Changeset.validate_number(:minutes,
      less_than_or_equal_to: __MODULE__.Repo.reload(member).balance,
      message: "can't exceed member balance"
    )
    |> __MODULE__.Repo.insert()
  end

  @spec fetch_member(email) :: {:ok, __MODULE__.User.t()} | {:error, :member_not_found}
  defp fetch_member(email) when is_binary(email) do
    if member = __MODULE__.Repo.get_by(__MODULE__.User, email: email) do
      {:ok, member}
    else
      {:error, :member_not_found}
    end
  end

  ## Helpers

  @spec now :: NaiveDateTime.t()
  defp now,
    do: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
end
