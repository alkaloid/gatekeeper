defmodule Gatekeeper.RFIDListenerTest do
  use ExUnit.Case, async: true

  test "reading an RFID card" do
    {:ok, listener} = Gatekeeper.RFIDListener.start_link

    send(listener, {:elixir_serial, self(), <<2>>})
    send(listener, {:elixir_serial, self(), "7"})
    send(listener, {:elixir_serial, self(), "A"})
    send(listener, {:elixir_serial, self(), "00"})
    send(listener, {:elixir_serial, self(), "9"})
    send(listener, {:elixir_serial, self(), "2"})
    send(listener, {:elixir_serial, self(), "D1"})
    send(listener, {:elixir_serial, self(), "1"})
    send(listener, {:elixir_serial, self(), "F"})
    send(listener, {:elixir_serial, self(), "2"})
    send(listener, {:elixir_serial, self(), "6"})
    send(listener, {:elixir_serial, self(), "\r\n"})
    send(listener, {:elixir_serial, self(), <<3>>})

    assert_receive "7A0092D11F26"
  end
end
