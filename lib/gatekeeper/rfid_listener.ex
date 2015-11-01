defmodule Gatekeeper.RFIDListener do
  require Logger

  use GenServer

  def start_link(device, opts \\ []) do
    GenServer.start_link(__MODULE__, [device, self()], opts)
  end

  def init([device, handler]) do
    {:ok, serial} = Serial.start_link

    Serial.open(serial, device)
    Serial.set_speed(serial, 9600)
    Serial.connect(serial)

    Logger.info "RFID listener process started for reader #{device}"

    {:ok, buffer} = StringIO.open("in")

    {:ok, {buffer, handler}}
  end

  def handle_info({:elixir_serial, _serial, data}, {buffer, handler} = state) do
    Logger.debug "Received data from RFID reader: #{inspect data}"
    leading = byte_size(data) - 1
    case data do
      <<2, rest :: binary>> ->
        Logger.info "Began receiving an RFID"
        IO.write(buffer, rest)
      <<rest :: binary-size(leading), 3>> ->
        IO.write(buffer, rest)
        id = buffer |> StringIO.flush |> String.rstrip
        Logger.info "RFID card presented with ID #{id}"
        send(handler, {:card_read, id})
      _other -> IO.write(buffer, data)
    end
    {:noreply, state}
  end
end
