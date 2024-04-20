defmodule HomeVisit.ChangesetHelpers do
  @moduledoc false

  @spec errors_on(Ecto.Changeset.t()) :: %{optional(atom) => [String.t(), ...]}
  def errors_on(%Ecto.Changeset{} = changeset),
    do:
      Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
        Regex.replace(~r"%{(\w+)}", message, fn _, key ->
          opts
          |> Keyword.get(String.to_existing_atom(key), key)
          |> to_string()
        end)
      end)
end
