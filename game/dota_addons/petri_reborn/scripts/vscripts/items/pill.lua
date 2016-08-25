function PopupNumbers(target, pfx, color, lifetime, number, presymbol, postsymbol, incr)
    local pfxPath = string.format("particles/msg_fx/msg_%s.vpcf", pfx)
    local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN_FOLLOW, target) -- target:GetOwner()

    local digits = 0
    if number ~= nil then
        digits = #tostring(number)
    end
    if presymbol ~= nil then
        digits = digits + 1
    end
    if postsymbol ~= nil then
        digits = digits + 1
    end

    ParticleManager:SetParticleControl(pidx, 1, Vector(tonumber(presymbol), tonumber(number), tonumber(postsymbol)))
    ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
end

function Crit( keys )
	local caster = keys.caster
	local target = keys.target 

	PopupNumbers(target, "crit", Vector(255, 0, 0), 1.0, math.floor(keys.damage * 1.025), nil, POPUP_SYMBOL_POST_LIGHTNING)
end