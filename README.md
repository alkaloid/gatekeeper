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

1. Set up the app with `sudo ./app_setup.sh prod` (for local development: `./app_setup.sh dev`, without sudo - note that GPIO will be disabled)
2. Start Phoenix endpoint with `sudo MIX_ENV=prod PORT=4000 mix phoenix.server`

Note that sudo and root access is required due to the GPIO interface.

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

## The Hardware

The parts listed here are just what I used. Feel free to replace them with equivalents that may be easier or cheaper to acquire.

* [Raspberry Pi](https://www.raspberrypi.org/) ($35) - Any model should do
* [12V DC power supply](http://www.amazon.com/gp/product/B0023Y9EQC) ($8) - recommend at least 2A
* [12V Electric Door Strike](http://www.amazon.com/gp/product/B005IH0HVW) ($53)
* [12V-5V DC power regulator](http://www.amazon.com/gp/product/B00OY0G2LI) ($8) - These circuits are pretty easy to build, but as cheap as they are on Amazon, I opted to purchase this and hack it for my own purposes. It comes with a convenient enclosure and with a mini-USB connector prewired which is great for powering the RPi. Too easy.
* [Relay](http://www.amazon.com/gp/product/B00TO7IY76) ($4.50) - This one is nice because it includes circuitry allowing it to be driven directly from the TTL-level pins on the Raspberry Pi. Don't try driving a relay directly from the RPi pins without protective circuitry!
* [Female-to-Female Breadboard Jumper Wires](http://www.amazon.com/Foxnovo-Female-Cables-40-pin-Breadboard/dp/B00JUKL4XI) ($9) - These make it easy and relatively safe to wire the RPi to the relay
* [USB RFID Reader](https://www.sparkfun.com/products/13198) ($50) - This includes the reader, the USB adapter, and 2 RFID cards. Additional RFID tags are between $2 and $5 apiece.

**Total: $167.50**

### Skills required:

* Curiosity
* Basic Linux Command Line skills
* Ability to screw and unscrew things
* [Optional] Basic soldering skills if you decide to hack up the 12V-5V DC power regulator

### Circuit Diagram

![Gatekeeper circuit diagram](doc/circuit%20diagram.png)