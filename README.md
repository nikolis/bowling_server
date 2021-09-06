# BowlingServer

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

The decision was made to user Rest web serivies because of their wide use and because the implementation is client agnostic.
Although under the right circomstances phoenix channel might have been a better
match to tacle the issue


The database used is sqlite so it the whole project should be able to run on on dev mode
as is just by following the default Phoenic instructions.

The swagger documentation of the api is visible through
    http://localhost:4000/swaggerui
