defmodule Gatekeeper.DoorLockTest do
  use ExUnit.Case, async: true

  import Gatekeeper.Factory

  setup do
    door_group = create_door_group()
    door = create_door door_group: door_group
    gpio_pin = 1
    lock = case Gatekeeper.DoorLock.start_link(Gatekeeper.DoorLock.Dummy, door.id, gpio_pin) do
      {:ok, lock} ->
        lock
      {:error, {:already_started, lock}} ->
        lock
    end

    {:ok, lock: lock}
  end

  test "the lock starts locked", %{lock: lock} do
    assert Gatekeeper.DoorLock.state(lock) == :locked
  end

  test "can be unlocked", %{lock: lock} do
    Gatekeeper.DoorLock.unlock(lock)
    assert Gatekeeper.DoorLock.state(lock) == :unlocked
  end

  test "can be locked", %{lock: lock} do
    Gatekeeper.DoorLock.unlock(lock)
    Gatekeeper.DoorLock.lock(lock)
    assert Gatekeeper.DoorLock.state(lock) == :locked
  end

  test "can be flipflopped", %{lock: lock} do
    Gatekeeper.DoorLock.flipflop(lock, 50)
    assert Gatekeeper.DoorLock.state(lock) == :unlocked
    :timer.sleep(100)
    assert Gatekeeper.DoorLock.state(lock) == :locked
  end
end
