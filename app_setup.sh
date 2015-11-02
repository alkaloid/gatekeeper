#!/bin/bash
if [ "x$1" == "x" ]; then
  echo "You must specify an environment (prod, test, dev) to setup"
  exit 1
fi
set -ex
export MIX_ENV=$1
npm install
mix deps.get
mix deps.compile
mix compile
mix ecto.migrate
