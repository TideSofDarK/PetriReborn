LinkLuaModifier("modifier_bonus_life", "internal/modifier_bonus_life.lua", LUA_MODIFIER_MOTION_NONE)

modifier_bonus_life = class({})

function modifier_bonus_life:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS, }
    return funcs
end

function modifier_bonus_life:GetModifierExtraHealthBonus(params)
    if IsServer() then
        if not self.health then
            return 0
        end
        self:SetStackCount(self.health)
        return self.health
    else
        return self:GetStackCount()
    end
end

function modifier_bonus_life:IsHidden()
    return true
end