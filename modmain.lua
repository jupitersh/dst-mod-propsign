--修改小木牌建筑
local function onhammered_My(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
	--[[
    inst.components.lootdropper:DropLoot()
    local fx = _G.SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    
	
	--
	_G.SpawnPrefab("propsign").Transform:SetPosition(inst.Transform:GetWorldPosition())
	
	]]--
	inst.components.lootdropper:SpawnLootPrefab("propsign")	--在原版函数中加了一句这个
	inst:Remove()
end

local function Hook_Homesign(inst)
	if inst.components.workable then
		inst.components.workable:SetOnFinishCallback(onhammered_My)
	end
end
AddPrefabPostInit("homesign",Hook_Homesign)
