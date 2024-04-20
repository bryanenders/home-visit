# HomeVisit

## Viewing Documentation

1. Download application dependencies with `$ mix deps.get`.
2. Generate documentation with `$ mix docs`.
3. View documentation with `$ open doc/index.html`.

## Testing

1. Download application dependencies with `$ mix deps.get`.
2. Prepare the database with `$ MIX_ENV=test mix ecto.migrate`.
3. Run the test suite with `$ mix test`.

## Static Analysis

1. Download application dependencies with `$ mix deps.get`.
2. Analyze for:
    * type errors and unreachable code paths with `$ mix dialyzer`.
    * refactoring opportunities, complex code fragments, common mistakes, and inconsistencies with `$ mix credo`.

## Accessing the REPL

### Development Environment

1. Download application dependencies with `$ mix deps.get`.
2. Migrate the database with `$ mix ecto.migrate`.
3. Access the REPL with `$ iex -S mix`.

### Production Environment

1. Download application dependencies with `$ mix deps.get`.
2. Build production release with `$ MIX_ENV=prod mix release`.
3. Migrate the database with `$ _build/prod/rel/home_visit/bin/home_visit eval "HomeVisit.Release.migrate"` with `DATABASE_PATH` set.
4. Start the application with `$ _build/prod/rel/home_visit/bin/home_visit start` with `DATABASE_PATH` set.
5. Access the REPL with `$ _build/prod/rel/home_visit/bin/home_visit remote` in another terminal session.

## Exercising the API

### Get things ready.

    iex> email1 = "1@example.com"
    "1@example.com"

    iex> email2 = "2@example.com"
    "2@example.com"

    iex> alias HomeVisit.Api
    HomeVisit.Api

### Register users.

    iex> Api.register_user(%{first_name: "User", last_name: "1", email: email1, balance: 100})
    :ok

    iex> Api.register_user(%{first_name: "User", last_name: "2", email: email2})
    :ok

### Request visits.

    iex> {:ok, visit_id} = Api.request_visit(email1, %{date: ~D[2024-04-20], minutes: 10, tasks: "Exercise the API"})
    {:ok, 1}

    iex> Api.request_visit(email2, %{date: ~D[2024-04-20], minutes: 1, tasks: "Use my balance"})
    {:error,
     #Ecto.Changeset<
       action: :insert,
       changes: %{date: ~D[2024-04-20], minutes: 1, tasks: "Use my balance"},
       errors: [
         minutes: {"can't exceed member balance",
          [validation: :number, kind: :less_than_or_equal_to, number: 0]}
       ],
       data: #HomeVisit.Api.Visit<>,
       valid?: false
     >}

### Fulfill a visit.

    iex> Api.fulfill_visit(email2, visit_id)
    :ok

### Re-request the previously declined visit.

    iex> Api.request_visit(email2, %{date: ~D[2024-04-20], minutes: 1, tasks: "Use my balance"})
    {:ok, 2}

## Assumptions

* A user can only register one account per email address
* Tasks can be represented with a string
* Preventing a user from fulfilling their own visit is out of scope
* Balance cannot be negative
* 0 is the default starting balance of a user
* Visits will take at least 1 minute
* Accepting a visit, to prevent multiple pals visiting for a single request, is out of scope
* Limiting visit fulfillment to once per visit is out of scope
* SQLite locks the whole database during a transaction which prevents a race condition while updating user balances
* Balances are stored and computed as integers representing a whole minute
* When debiting a pal it’s preferable to round up
* If a member’s account has insufficient minutes to cover a requested visit, this should be denied since it would yield a sub-zero balance
