-- The boss life bar shown during boss fights.

local boss_life_builder = {}

local life_bar_img = sol.surface.create("hud/boss_life.png")

function boss_life_builder:new(game, config)

  local boss_life = {}
  local life_bar_enabled = false
  local initial_life
  local current_life

  local dst_x, dst_y = config.x, config.y

  function boss_life:on_draw(dst_surface)

    if life_bar_enabled then
      life_bar_img:draw_region(0, 0, 100, 10, dst_surface, dst_x, dst_y)
      local src_width = math.floor(current_life / initial_life * 90)
      local src_height = 2
      local src_x = 95 - src_width
      local src_y = 14
      life_bar_img:draw_region(src_x, src_y, src_width, src_height, dst_surface, dst_x + 5, dst_y + 4)
    end
  end

  local function check()

    local map = game:get_map()
    local boss = map and map:get_entity("boss") or nil
    if boss == nil or not boss:is_enabled() then
      life_bar_enabled = false
      initial_life = nil
      current_life = nil
    else
      if not life_bar_enabled then
        initial_life = boss:get_life()
        life_bar_enabled = true
      end
      current_life = boss:get_life()
    end

    return true  -- Repeat the timer.
  end

  function boss_life:on_started()
    -- Periodically check whether we are fighting a boss.
    check()
    sol.timer.start(game, 20, check)
  end

  return boss_life
end

return boss_life_builder

