
MODEL_LISTING = {
    ["846578"] = {
        offset = {-10,-120,20},
        -- Confirmed that this isn't always true
        __probably_a = "Metal door",
        type = "DOOR",
        normalized_action = "Drilling...",
        normalized_jammed = "Jammed!",
        world_size = {104,200},
        size = {202,400}
    },
    ["98a92c"] = {
        offset = {-50,-150,20},
        __probably_a = "Vault door",
        type = "DOOR",
        normalized_action = "Drilling...",
        normalized_jammed = "Jammed!",
        world_size = {200,300},
        size = {400,500}
    },
    DEFAULT = {
        offset = {-25,-25,0},
        world_size = {50,50},
        size = {50,50},
        normalized_action = "No clue",
        normalized_jammed = "Bad, but no clue",
    }
}

function TimerGui:add_workspace(gui_object)
    self._ws = self._new_gui:create_object_workspace(0, 0, gui_object, Vector3(0, 0, 0))
    self._gui = self._ws:panel():gui(Idstring("guis/timer_gui"))
    self._gui_script = self._gui:script()

    self.model_key = string.sub(tostring(self._unit:orientation_object():name():key()), 0, 6)

    local model = MODEL_LISTING[self.model_key] or MODEL_LISTING.DEFAULT
    self._model = model

    self.hologram = VisualOverhaulCore.managers.holograms:create({
        name = "drill_hologram",
        world_size = model.world_size,
        size = model.size,
        offset = model.offset,
        debug = false,
        unit = self._unit,
        update = function (t,dt)
            if not self._current_timer or not self._timer then
                self._starting_frame = t
                return
            end
            local progress = (1 - self._current_timer / self._timer)
            local time = string.format("%.f", self._current_timer)
            local time_string = time.." seconds"
            local progress_percent = string.format("%.f", progress * 100)
            local progress_with_random = string.sub(tostring(progress),2,4)..self._random_substr

            local start_progress = 1 - math.min(1,math.pow((t - self._starting_frame),8)*15)

            if time ~= self._prev_time_string then
                self._random_substr = string.sub(tostring(math.random()),3,7)
            end

            self.progression_main_holder:child("progression_main_filler"):set_width(self.progression_main_holder:w() * progress)
            self.progression_panel:child("progression_main_percent"):set_text(progress_percent.."%")
            self.progression_seconds:set_text(time_string)
            if progress < 0.5 then
                self.progression_seconds:set_left(self.progression_main_holder:w() * progress)
                self.progression_seconds:set_align("left")
            else
                self.progression_seconds:set_left(self.progression_main_holder:w() * progress - self.progression_main_holder:w())
                self.progression_seconds:set_align("right")
            end
            self.hologram_panel:child("progression_non_static_right_text"):set_text(string.sub(tostring(progress),2,4))
            self.hologram_panel:child("progression_static_random_text"):set_text(progress_with_random)
            self.hologram_panel:child("progression_timer_stripe_text"):set_text(time)
            self.hologram_panel:child("progression_non_static_right"):set_width(self.hologram_panel:w() * (0.2 * progress) + self.hologram_panel:w() * 0.2)
            self.hologram_panel:child("progression_non_static_right"):set_left(self.hologram_panel:w() - 30 - (self.hologram_panel:w() * (0.2 * progress) + self.hologram_panel:w() * 0.2))

            self._prev_time_string = time

            if not self._jammed then
                self.hologram_panel:child("action_type"):set_text(self._model.normalized_action)
            else
                self.hologram_panel:child("action_type"):set_text(self._model.normalized_jammed)
            end

            if start_progress > 0 then
                self.corner_top_left:set_top(20 * start_progress)
                self.corner_top_left:set_left(20 * start_progress)
                self.corner_top_left:set_alpha(1 - start_progress)

                self.corner_top_right:set_top(20 * start_progress)
                self.corner_top_right:set_left(self.hologram_panel:w() - self.corner_top_right:w() - 20 * start_progress)
                self.corner_top_right:set_alpha(1 - start_progress)

                self.corner_bottom_right:set_top(self.hologram_panel:h() - self.corner_top_right:h() - 20 * start_progress)
                self.corner_bottom_right:set_left(self.hologram_panel:w() - self.corner_top_right:w() - 20 * start_progress)
                self.corner_bottom_right:set_alpha(1 - start_progress)

                self.corner_bottom_left:set_top(self.hologram_panel:h() - self.corner_top_right:h() - 20 * start_progress)
                self.corner_bottom_left:set_left(20 * start_progress)
                self.corner_bottom_left:set_alpha(1 - start_progress)

                self.center_panel:set_alpha(1 - start_progress)
                self.hologram_panel:child("progression_static_stripe1"):set_alpha(1 - start_progress)
                self.hologram_panel:child("progression_static_stripe1"):set_width(self.hologram_panel:w() * (0.2 * (1 - start_progress)))
            
                self.hologram_panel:child("progression_non_static_right"):set_alpha(1 - start_progress)
                self.hologram_panel:child("progression_non_static_right"):set_width(self.hologram_panel:w() * (0.2 * (1 - start_progress)))
                self.hologram_panel:child("progression_non_static_right"):set_left(self.hologram_panel:w() - 30 - (self.hologram_panel:w() * (0.2 * (1 - start_progress))))
            
                self.hologram_panel:child("progression_static_random"):set_alpha(1 - start_progress)
                self.hologram_panel:child("progression_static_stripe2"):set_alpha(1 - start_progress)
                self.hologram_panel:child("progression_timer_stripe"):set_alpha(1 - start_progress)

                self.hologram_panel:child("progression_non_static_right_text"):set_alpha(1 - start_progress)
                self.hologram_panel:child("progression_timer_stripe_text"):set_alpha(1 - start_progress)
                self.hologram_panel:child("progression_static_random_text"):set_alpha(1 - start_progress)
                self.hologram_panel:child("action_type"):set_alpha(1 - start_progress)
                
            end
        end
    })

    self.hologram_panel = self.hologram:get_panel()

    local corner_size = self.hologram_panel:w() / 3
    local completion = 0.65
    local time = 20
    
    self.corner_top_left =  self.hologram_panel:bitmap({
        name = "corner_top_left",
        visible = true,
        w = corner_size,
        h = corner_size,
        texture = "thuverx/textures/drill/drillOverlayCorner",
        layer = 4,
        alpha = 0,
        rotation = 0
    })
    self.corner_top_right = self.hologram_panel:bitmap({
        name = "corner_top_right",
        visible = true,
        w = corner_size,
        h = corner_size,
        x = self.hologram_panel:w() - corner_size,
        texture = "thuverx/textures/drill/drillOverlayCorner",
        layer = 4,
        rotation = 90,
        alpha = 0
    })

    self.corner_bottom_left = self.hologram_panel:bitmap({
        name = "corner_bottom_left",
        visible = true,
        w = corner_size,
        h = corner_size,
        y = self.hologram_panel:h() - corner_size,
        texture = "thuverx/textures/drill/drillOverlayCorner",
        layer = 4,
        rotation = 270,
        alpha = 0
    })

    self.corner_bottom_right = self.hologram_panel:bitmap({
        name = "corner_bottom_right",
        visible = true,
        w = corner_size,
        h = corner_size,
        x = self.hologram_panel:w() - corner_size,
        y = self.hologram_panel:h() - corner_size,
        texture = "thuverx/textures/drill/drillOverlayCorner",
        layer = 4,
        rotation = 180,
        alpha = 0
    })

    local center_height = self.hologram_panel:h() / 2
    local center_safe_offset = 10
    self.center_panel = self.hologram_panel:panel({
        name = "center_panel",
        w = self.hologram_panel:w() - (center_safe_offset * 2),
        h = center_height,
        x = center_safe_offset,
        y = self.hologram_panel:h() / 2 - 40,
        alpha = 0
    })

    self.hologram_panel:text({
        name = "action_type",
        text = "Drilling...",
        valign = "center",
        align = "left",
        x = 10,
        h = 55,
        y = self.center_panel:y() - 45,
        vertical = "center",
        color = Color.white,
        font = VisualOverhaulCore.global.font.light_xl,
        font_size = 50
    })

    self.progression_panel = self.center_panel:panel({
        name = "progression_panel",
        w = self.center_panel:w() * 0.95,
        h = 100,
        x = self.center_panel:w() * 0.05
    })

    self.progression_main_holder = self.progression_panel:panel({
        name = "progression_main_holder",
        w = self.progression_panel:w(),
        h = 10,
        y = self.progression_panel:h() - 25,
        layer = 7
    })

    self.progression_main_holder:rect({
        color = Color.black:with_alpha(0.7)
    })

    self.progression_main_holder:rect({
        name = "progression_main_filler",
        w = self.progression_main_holder:w() * completion,
        h = self.progression_main_holder:h(),
        color = Color.white
    })  

    self.progression_panel:text({
        name = "progression_main_percent",
        text = tostring(completion * 100).."%",
        valign = "center",
        align = "center",
        h = self.progression_panel:h() - 25,
        vertical = "center",
        color = Color.white,
        font = VisualOverhaulCore.global.font.light_xl,
        font_size = 90
    })

    self.progression_seconds = self.progression_panel:text({
        name = "progression_main_seconds",
        text = tostring(time).." seconds",
        valign = "top",
        align = "right",
        vertical = "top",
        w = self.progression_main_holder:w(),
        y = self.progression_panel:h() - 18,
        h = 30,
        x = self.progression_main_holder:w() * completion - self.progression_main_holder:w(),
        color = Color.white,
        font = VisualOverhaulCore.global.font.light,
        font_size = 20
    })

    self.hologram_panel:rect({
        name = "progression_static_random",
        h = 5,
        w = self.hologram_panel:w() * 0.4,
        color = Color.white,
        x = 50,
        y = self.hologram_panel:h() - 60
    })

    self.hologram_panel:rect({
        name = "progression_static_stripe1",
        h = 2,
        w = self.hologram_panel:w() * 0.2,
        color = Color.white,
        x = self.hologram_panel:w() - self.hologram_panel:w() * 0.2 - 60,
        y = self.hologram_panel:h() - 110,
        alpha = 0
    })

    self.hologram_panel:rect({
        name = "progression_static_stripe2",
        h = 3,
        w = self.hologram_panel:w() * 0.6,
        color = Color.white,
        x = self.hologram_panel:w() - 20 - self.hologram_panel:w() * 0.6,
        y = 110,
        alpha = 0
    })

    self.hologram_panel:rect({
        name = "progression_timer_stripe",
        h = 2,
        w = self.hologram_panel:w() * 0.3,
        color = Color.white,
        x = 30,
        y = 80,
        alpha = 0
    })

    self.hologram_panel:rect({
        name = "progression_non_static_right",
        h = 2,
        w = self.hologram_panel:w() * 0.4,
        color = Color.white,
        x = self.hologram_panel:w() - 30 - self.hologram_panel:w() * 0.4,
        y = 30,
        alpha = 0
    })

    self.hologram_panel:text({
        name = "progression_non_static_right_text",
        text = string.sub(tostring(completion),2,4),
        valign = "top",
        align = "right",
        vertical = "top",
        color = Color.white,
        font = VisualOverhaulCore.global.font.light,
        font_size = 15,
        h = 25,
        w = self.hologram_panel:w() * 0.4,
        color = Color.white,
        x = self.hologram_panel:w() - 30 - self.hologram_panel:w() * 0.4,
        y = 30 + 4,
        alpha = 0
    })

    self.hologram_panel:text({
        name = "progression_timer_stripe_text",
        text = tostring(time),
        valign = "top",
        align = "left",
        vertical = "top",
        color = Color.white,
        font = VisualOverhaulCore.global.font.light,
        font_size = 15,
        h = 25,
        w = self.hologram_panel:w() * 0.4,
        color = Color.white,
        x = 30,
        y = 80 + 2,
        alpha = 0
    })

    self.hologram_panel:text({
        name = "progression_static_random_text",
        text = string.sub(tostring(completion),2,4)..string.sub(tostring(math.random()),3,7),
        valign = "top",
        align = "right",
        vertical = "top",
        color = Color.white,
        font = VisualOverhaulCore.global.font.light,
        font_size = 15,
        h = 25,
        w = self.hologram_panel:w() * 0.4,
        color = Color.white,
        x = 50,
        y = self.hologram_panel:h() - 60 + 4,
        alpha = 0
    })

    self._random_substr = string.sub(tostring(math.random()),3,7)
    self._prev_time_string = "-1"
    self._starting_frame = -1
    self._ending_frame = -1

end

Hooks:PostHook(TimerGui, "_start", "F_"..Idstring("PostHook:TimerGui:_start"):key(), function(self)
    self.hologram_panel:child("action_type"):set_text(self._model.normalized_action)
end)

Hooks:PostHook(TimerGui, "done", "F_"..Idstring("PostHook:TimerGui:done"):key(), function(self)
    self.hologram_panel:set_visible(false)
end)

Hooks:PostHook(TimerGui, "destroy", "F_"..Idstring("PostHook:TimerGui:done"):key(), function(self)
    self.hologram_panel:set_visible(false)
    self.hologram:destroy()
    self.hologram = nil
end)

Hooks:PostHook(TimerGui, "hide", "F_"..Idstring("PostHook:TimerGui:hide"):key(), function(self)
    self.hologram_panel:set_visible(false)
end)

Hooks:PostHook(TimerGui, "show", "F_"..Idstring("PostHook:TimerGui:show"):key(), function(self)
    self.hologram_panel:set_visible(true)
end)

function TimerGui:set_visible(visible)
    self._visible = visible
    
    self.hologram_panel:set_visible(visible)
    self._gui:set_visible(visible)
end