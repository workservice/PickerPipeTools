require('__stdlib__/stdlib/config').control = true

local Event = require('__stdlib__/stdlib/event/event')
Event.protected_mode = true

require('__stdlib__/stdlib/event/player').register_events(true)
require('__stdlib__/stdlib/event/force').register_events(true)

--(( Load Scripts ))--
require('scripts/orphans')
require('scripts/pipe-highlight')
require('scripts/pipe-cleaner')
require('scripts/pipe-clamps')
require('scripts/pipe-filter')
--)) Load Scripts ((--

remote.add_interface(script.mod_name, require('__stdlib__/stdlib/scripts/interface'))
