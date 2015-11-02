# Gatekeeper

## Prereqs
* Elixir 1.0
* cmake
* Erlang development headers
* NodeJS 0.10 (or later) and npm
* PostgreSQL
* One free GPIO pin

This app is written with a Raspberry Pi in mind. See the Provisioning section below for more information.

## Starting the app

To start your Phoenix app:

1. Set up the app with `./app_setup.sh prod` (use `dev` for local development - note that GPIO will be disabled)
2. Start Phoenix endpoint with `MIX_ENV=prod PORT=4000 mix phoenix.server`

Now you can visit [`raspberrypi.local:4000`](http://raspberrypi.local:4000) from your browser.

## Tests

To run the tests, use either `mix test` or `mix test.watch`.

## Provisioning a Raspberry Pi

The provided Ansible playbook can be used to configure a Raspberry Pi to run Gatekeeper. These instructions assume you are running Raspbian Jesse (Debian 8).

1. Install Ansible: `sudo apt-get install ansible`
2. Add `127.0.0.1` to the top of `/etc/ansible/hosts` (works around an old Ansible bug)
3. Run the provisioning script:
    `sudo ansible-playbook -c local -e postgresql_password=SuperSecret provisioning/gatekeeper.yml`
Make sure to change the PostgreSQL password to something of your choosing

You are now ready to run the `app_setup.sh` and boot the app.