LinkLuaModifier("modifier_model_change", "internal/modifier_model_change.lua", LUA_MODIFIER_MOTION_NONE)

modifier_model_change = class({})

function modifier_model_change:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
        MODIFIER_PROPERTY_ATTACK_POINT_CONSTANT
    }

    return funcs
end

function modifier_model_change:GetPriority()
    return MODIFIER_PRIORITY_ULTRA
end

function modifier_model_change:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_model_change:GetModifierBaseAttackTimeConstant()
    return 1.51
end

function modifier_model_change:GetModifierAttackPointConstant()
    return 0.269
end

function modifier_model_change:GetModifierModelChange()
    if self:GetParent().model then
        return self:GetParent().model
    else
        return self:GetParent():GetModelName()
    end
end

function modifier_model_change:IsPurgable()
    return false
end

function modifier_model_change:IsHidden()
    return true
end