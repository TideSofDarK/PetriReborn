BAG_CONTENTS = {}

BAG_CONTENTS["item_petri_kvn_bag_a"] = {}
BAG_CONTENTS["item_petri_kvn_bag_a"]["0"] = "item_petri_gold_bag"
BAG_CONTENTS["item_petri_kvn_bag_a"]["1"] = "item_petri_gold_bag"
BAG_CONTENTS["item_petri_kvn_bag_a"]["2"] = "item_petri_gold_bag"
BAG_CONTENTS["item_petri_kvn_bag_a"]["3"] = "item_petri_gold_bag"

function OpenBag(keys)
	local caster = keys.caster
	local ability = keys.ability

	local item_name = ability:GetName()

	for i=0,11 do
		local item = caster:GetItemInSlot(i)
		if item then
			caster:RemoveItem(item)
		end
	end

	if BAG_CONTENTS[item_name] then
		for k,v in pairs(BAG_CONTENTS[item_name]) do
			caster:AddItemByName(v)
		end
	end
end