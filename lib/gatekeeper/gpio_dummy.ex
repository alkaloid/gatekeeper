defmodule Gatekeeper.GpioDummy do
  use GenServer

  def start_link(_gpio_number, _type, opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, 1}
  end

  def write(pid, value) do
    GenServer.call(pid, {:write, value})
  end

  def read(pid) do
    GenServer.call(pid, :read)
  end

  def handle_call({:write, value}, _from, _state) do
    {:reply, :ok, value}
  end

  def handle_call(:read, _from, state) do
    {:reply, state, state}
  end
end
