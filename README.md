# HomeVisit

## Testing

1. Download application dependencies with `$ mix deps.get`.
2. Prepare the database with `$ MIX_ENV=test mix ecto.migrate`.
3. Run the test suite with `$ mix test`.

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

**TODO: Add instructions**

## Assumptions

* A user can only register one account per email address
* Tasks can be represented with a string
* Preventing a user from fulfilling their own visit is out of scope
* Balance cannot be negative
* 0 is the default starting balance of a user
