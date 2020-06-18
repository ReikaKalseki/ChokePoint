data:extend({
        {
            type = "double-setting",
            name = "terrain-scale",
            setting_type = "runtime-global",
            default_value = 1.0,
			minimum_value = 0.125,
			maximum_value = 100000,
            order = "r",
        },
		{
            type = "int-setting",
            name = "terrain-offset-x",
            setting_type = "runtime-global",
            default_value = 0,
            order = "r",
        },
		{
            type = "int-setting",
            name = "terrain-offset-y",
            setting_type = "runtime-global",
            default_value = 0,
            order = "r",
        },
		{
            type = "int-setting",
            name = "terrain-mixin-seed",
            setting_type = "runtime-global",
            default_value = 0,
            order = "r",
        },--[[
		{
            type = "bool-setting",
            name = "terrain-retrogen",
            setting_type = "runtime-global",
            default_value = false,
            order = "r",
        },--]]
		{
            type = "double-setting",
            name = "river-thickness",
            setting_type = "runtime-global",
            default_value = 1.0,
            order = "r",
        },
		{
            type = "bool-setting",
            name = "allow-traversible-shores",
            setting_type = "runtime-global",
            default_value = true,
            order = "r",
        }
})
