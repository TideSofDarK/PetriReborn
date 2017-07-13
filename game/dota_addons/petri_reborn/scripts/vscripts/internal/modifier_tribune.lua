LinkLuaModifier("modifier_tribune", "internal/modifier_tribune.lua", LUA_MODIFIER_MOTION_NONE)

modifier_tribune = class({})

function modifier_tribune:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
 
	return funcs
end

function modifier_tribune:IsHidden()
	return true
end

function modifier_tribune:GetDisableHealing()
	return true
end

function modifier_tribune:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_TRUESIGHT_IMMUNE] = true
	}
	return state
end