

local throttled_mod_names = {}
throttled_mod_names["mesecons"] = true
throttled_mod_names["advtrains"] = true

minetest.register_on_mods_loaded(function()
  for i, globalstep in ipairs(minetest.registered_globalsteps) do

    local info = minetest.callback_origins[globalstep]

    if throttled_mod_names[info.mod] then
      local skip_counter = monitoring.counter(
        "globalstep_skip_counter_" .. info.mod,
        "count of skipped calls for globalsteps in mod " .. info.mod
      )

      local last_call = 0
      local acc_dtime = 0

      local new_callback = function(dtime)
        local now = minetest.get_us_time()
        local diff = now - last_call

        acc_dtime = acc_dtime + dtime

        if diff < 50000 then
          -- not enough time passed
          skip_counter.inc()

        else
          -- execute callback
          globalstep(acc_dtime)
          acc_dtime = 0

        end
      end

      minetest.registered_globalsteps[i] = new_callback

      -- for the profiler
      if minetest.callback_origins then
        minetest.callback_origins[new_callback] = info
      end
    end
  end
end)



print("[globalstep_throttle] OK")
