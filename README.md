# Gatekeeper

To start your Phoenix app:

  1. Install dependencies with `mix deps.get && mix deps.compile && mix deps.compile` (repeat compilation is necessary first time around to get the Serial library working)
  2. Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  3. Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Tests

To run the tests, use either `mix test` or `mix test.watch`.

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: http://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix

## Provisioning a Raspberry Pi

The provided Ansible playbook can be used to configure a Raspberry Pi to run Gatekeeper

You will need to provide a password for the PostgreSQL database. For example:

* `sudo ansible-playbook -c local -e postgresql_password=SuperSecret provisioning/gatekeeper.yml`
