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

The provided Ansible playbook can be used to configure a Raspberry Pi to run Gatekeeper. These instructions assume you are running Raspbian Jesse (Debian 8).

1. Install Ansible: `sudo apt-get install ansible`
2. Add `127.0.0.1` to the top of `/etc/ansible/hosts` (works around an old Ansible bug)
3. Run the provisioning script:
    `sudo ansible-playbook -c local -e postgresql_password=SuperSecret provisioning/gatekeeper.yml`
Make sure to change the PostgreSQL password to something of your choosing
