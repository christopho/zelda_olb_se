local map = ...
local game = map:get_game()

local fighting_boss = false

local boss_skull_placeholders = {
}

function map:on_started(destination)

  boss_brambler_1:set_enabled(false)
  boss_brambler_2:set_enabled(false)
  boss_brambler_wall:set_enabled(false)
  if boss ~= nil then
    boss:set_enabled(false)
  end
  map:set_doors_open("boss_door", true)

  for placeholder in map:get_entities("boss_skull_placeholder") do
    -- Avoid facing entity conflict with skulls (Solarus issue #1042).
    placeholder:set_enabled(false)
    boss_skull_placeholders[#boss_skull_placeholders + 1] = placeholder
  end
end

function start_boss_sensor:on_activated()

  if boss ~= nil and not fighting_boss then
    hero:freeze()
    map:close_doors("boss_door")
    sol.audio.stop_music()
    sol.timer.start(1000, function()
      boss:set_enabled(true)
      hero:unfreeze()
      sol.audio.play_music("boss")
      fighting_boss = true

      boss_brambler_1:set_enabled(true)
      boss_brambler_2:set_enabled(true)
      boss_brambler_wall:set_enabled(true)
    end)
  end
end

function boss_switch:on_activated()

  if not fighting_boss then
    return
  end

  -- Create a skull at a random place.
  local index = math.random(#boss_skull_placeholders)
  local placeholder = boss_skull_placeholders[index]
  local x, y, layer = placeholder:get_position()
  local skull = map:create_destructible({
    x = x,
    y = y,
    layer = layer,
    sprite = "entities/vase_skull",
    weight = 0,
    destruction_sound = "stone",
    damage_on_enemies = 2,
  })

  function skull:on_removed()
    if not fighting_boss then
      return
    end
    
    -- Make the switch usable again.
    boss_switch:set_activated(false)
  end
end

if boss ~= nil then
  function boss:on_hurt()

    if boss:get_life() == 1 then
      -- One more hit.
      boss_brambler_1:set_life(0)
      boss_brambler_2:set_life(0)
      boss_brambler_wall:set_enabled(false)
    end
  end
end
