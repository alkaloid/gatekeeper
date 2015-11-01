defmodule Gatekeeper.RFIDListenerTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, listener} = Gatekeeper.RFIDListener.start_link "/dev/ttyUSB0"
    {:ok, listener: listener}
  end

  test "reading an RFID card", %{listener: listener} do
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

    assert_receive {:card_read, "7A0092D11F26"}
  end

  test "reading multiple RFID cards sequentially", %{listener: listener} do
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

    assert_receive {:card_read, "7A0092D11F26"}

    send(listener, {:elixir_serial, self(), <<2>>})
    send(listener, {:elixir_serial, self(), "7"})
    send(listener, {:elixir_serial, self(), "A"})
    send(listener, {:elixir_serial, self(), "00"})
    send(listener, {:elixir_serial, self(), "F"})
    send(listener, {:elixir_serial, self(), "2"})
    send(listener, {:elixir_serial, self(), "D1"})
    send(listener, {:elixir_serial, self(), "8"})
    send(listener, {:elixir_serial, self(), "R"})
    send(listener, {:elixir_serial, self(), "2"})
    send(listener, {:elixir_serial, self(), "6"})
    send(listener, {:elixir_serial, self(), "\r\n"})
    send(listener, {:elixir_serial, self(), <<3>>})

    assert_receive {:card_read, "7A00F2D18R26"}
  end
end
