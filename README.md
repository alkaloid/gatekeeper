# Gatekeeper

## Prereqs
* Elixir 1.5 & Erlang/OTP 20
* cmake
* Erlang development headers
* NodeJS 6.11 (or later) and npm
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

1. Install Ansible 1.9 (or later) on your workstation - this can be done via Pip, Homebrew, apt, etc.
2. Modify `provisioning/hosts` as necessary to deploy to your devices remotely.
3. Install provisioning dependencies: `ansible-galaxy install -r provisioning/requirements.txt`.
4. Run the provisioning script: `ansible-playbook -e postgresql_password=SuperSecret provisioning/gatekeeper.yml`.

**Make sure to change the PostgreSQL password to something of your choosing**

## Authentication

The application is built to authenticate via Slack. To set up the OAuth connection with Slack, you will need:

* A `CLIENT_ID` and a `CLIENT_SECRET`, which can be obtained by [registering your app on Slack](https://api.slack.com/applications)
* Optional: Your `TEAM_ID`, if you want to restrict logins to a specific Slack team - [find your Slack Team ID here](https://api.slack.com/methods/auth.test/test)

Make sure you set these environment variables:
* `SLACK_CLIENT_ID`
* `SLACK_CLIENT_SECRET`
* `SLACK_TEAM_ID` (optional)
* `GUARDIAN_SECRET_KEY` - Set this to a long random string; it is used to ensure the validity of session tokens

## The Hardware

The parts listed here are just what I used. Feel free to replace them with equivalents that may be easier or cheaper to acquire.

* [Raspberry Pi](http://www.amazon.com/gp/product/B01CD5VC92/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B01CD5VC92&linkCode=as2&tag=alkalogateke-20&linkId=RGZPVHE22TEYIRZV) ($35) - Any model should do
* [12V DC power supply](http://www.amazon.com/gp/product/B0023Y9EQC/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B0023Y9EQC&linkCode=as2&tag=alkalogateke-20&linkId=DBBZFY3TXJEDTJN3) ($8) - recommend at least 2A
* [12V Electric Door Strike](http://www.amazon.com/gp/product/B005IH0HVW/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B005IH0HVW&linkCode=as2&tag=alkalogateke-20&linkId=JXEVP2436BSJNBCM) ($53)
* [12V-5V DC power regulator](http://www.amazon.com/gp/product/B00OY0G2LI/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B00OY0G2LI&linkCode=as2&tag=alkalogateke-20&linkId=OL4GF7EVDDT5PJ6E) ($8) - These circuits are pretty easy to build, but as cheap as they are on Amazon, I opted to purchase this and hack it for my own purposes. It comes with a convenient enclosure and with a mini-USB connector prewired which is great for powering the RPi. Too easy.
* [Relay](http://www.amazon.com/gp/product/B00TO7IY76/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B00TO7IY76&linkCode=as2&tag=alkalogateke-20&linkId=DZAPY3U5FZGS3PW4) ($4.50) - This one is nice because it includes circuitry allowing it to be driven directly from the TTL-level pins on the Raspberry Pi. Don't try driving a relay directly from the RPi pins without protective circuitry!
* [Female-to-Female Breadboard Jumper Wires](http://www.amazon.com/gp/product/B00JUKL4XI/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B00JUKL4XI&linkCode=as2&tag=alkalogateke-20&linkId=3RKK36R6IROZIY5U) ($9) - These make it easy and relatively safe to wire the RPi to the relay
* [USB RFID Reader](https://www.sparkfun.com/products/13198) ($50) - This includes the reader, the USB adapter, and 2 RFID cards. Additional RFID tags are between $2 and $5 apiece.

**Total: $167.50**

### Skills required:

* Curiosity
* Basic Linux Command Line skills
* Ability to screw and unscrew things
* [Optional] Basic soldering skills if you decide to hack up the 12V-5V DC power regulator

### Circuit Diagram

![Gatekeeper circuit diagram](doc/circuit%20diagram.png)
