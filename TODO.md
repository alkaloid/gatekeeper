* Allow unassigning/re-assigning RFID tokens
  - Disable ability to delete RFID token
  - Form changes to unassign/re-assign
  - Add member ID to `door_access_attempt` because it may change over time

* Use `history(-1)` on RFID token links so they load relatively

* Check for future-dated Company deactivation dates (so we can schedule deactivations)
* Fix Company Join Date to be a date only (no time)
* Change all Deletes to Deactivates
* Add phony-style phone validation & normalization & display formatting
* Allow time-of-day and day-of-week restrictions on door group access
