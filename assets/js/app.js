// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import socket from "./socket"

// Make each door lock status icon clickable to unlock that door
$.each(door_ids, (i, door_id) => {
  $('.door_lock_'+door_id+'_status').on('click', (ev) => {
    $.get($(ev.currentTarget).attr('href'))
    return false
  })
})

$.each(preScheduledRows, (i, preScheduledRow) => {
  addScheduleRow(...preScheduledRow)
})
$('button#add_schedule').click(function(ev) {
  addScheduleRow()
  ev.preventDefault()
})
