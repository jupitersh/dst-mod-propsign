--这个是2020-6-27更新中 提取的猪王小木牌定义文件
local global_finiteuses_times = 3	--可以用几次

local assets =
{
    Asset("ANIM", "anim/sign_home.zip"),
    Asset("ANIM", "anim/sign_elite.zip"),
    Asset("ANIM", "anim/swap_sign_elite.zip"),
}

local assets_fx =
{
    Asset("ANIM", "anim/sign_elite.zip"),
}

local prefabs =
{
    "propsignshatterfx",
}

--改动5
local function OnUsed(inst)
	if not inst.components.finiteuses then
		return
	end
	inst.components.finiteuses:Use(1)
end

local function OnUnequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_object")
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_sign_elite", "swap_sign_elite")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function OnSmashed(inst, pos)
    local fx = SpawnPrefab("propsignshatterfx")
    fx.Transform:SetPosition(pos:Get())
    fx.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    --inst:Remove() --改动1
	OnUsed(inst)
end

local function BreakSign(inst)
    if not inst.broken then
        if not inst.components.inventoryitem:IsHeld() then
            inst.broken = true
            inst.persists = false
            inst:AddTag("NOCLICK")
            inst.components.inventoryitem.canbepickedup = false
            if inst.components.burnable:IsBurning() then
                inst.components.burnable:Extinguish()
                inst:AddTag("burnt")
                inst.AnimState:SetMultColour(0, 0, 0, 1)
            end
            inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood", nil, .6)
            inst.AnimState:PlayAnimation("break")
            inst.AnimState:PushAnimation("broken", false)
            inst:DoTaskInTime(1, ErodeAway)
        else
            if inst.components.equippable:IsEquipped() then
                inst.components.inventoryitem.owner.components.inventory:Unequip(EQUIPSLOTS.HANDS, true)
            end
            OnSmashed(inst, inst:GetPosition())
        end
    end
end

local function OnBurnt(inst)
    inst:AddTag("burnt")
    inst.AnimState:SetMultColour(0, 0, 0, 1)
    BreakSign(inst)
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
    inst.OnCancelMinigame() --not inst:OnCancelMinigame() since it expects pig king as param
end

local function OnDelayInteraction(inst)
    inst._knockbacktask = nil
    inst:RemoveTag("knockbackdelayinteraction")
end

local function OnDelayPlayerInteraction(inst)
    inst._playerknockbacktask = nil
    if not inst.broken then
        inst:RemoveTag("NOCLICK")
    end
end

local function OnKnockbackDropped(inst, data)
    if data ~= nil and (data.delayinteraction or 0) > 0 then
        if inst._knockbacktask ~= nil then
            inst._knockbacktask:Cancel()
        else
            inst:AddTag("knockbackdelayinteraction")
        end
        inst._knockbacktask = inst:DoTaskInTime(data.delayinteraction, OnDelayInteraction)
    elseif inst._knockbacktask ~= nil then
        inst._knockbacktask:Cancel()
        OnDelayInteraction(inst)
    end

    if data ~= nil and (data.delayplayerinteraction or 0) > 0 then
        if inst._playerknockbacktask ~= nil then
            inst._playerknockbacktask:Cancel()
        else
            inst:AddTag("NOCLICK")
        end
        inst._playerknockbacktask = inst:DoTaskInTime(data.delayplayerinteraction, OnDelayPlayerInteraction)
    elseif inst._playerknockbacktask ~= nil then
        inst._playerknockbacktask:Cancel()
        OnDelayPlayerInteraction(inst)
    end
end

local function OnFinished(inst)
    --inst.AnimState:PlayAnimation("used")
    --inst:ListenForEvent("animover", inst.Remove)
	inst:Remove()
end




local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sign_home")
    inst.AnimState:SetBuild("sign_elite")
    inst.AnimState:OverrideSymbol("burnt", "sign_home", "burnt")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("propweapon")
    inst:AddTag("minigameitem")
    inst:AddTag("irreplaceable")
    inst:AddTag("nonpotatable")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    inst:SetPrefabNameOverride("homesign")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = true		--改动3

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst:AddComponent("weapon")
    inst.components.weapon:SetRange(TUNING.PROP_WEAPON_RANGE)
    inst.components.weapon:SetDamage(1)
	
	------------------------------- 改动4 
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(global_finiteuses_times)
    inst.components.finiteuses:SetUses(global_finiteuses_times)

    inst.components.finiteuses:SetOnFinished(OnFinished)
	
	-----------------------------------

    MakeSmallBurnable(inst, 5, nil, true)
    MakeSmallPropagator(inst)
    inst.components.burnable:SetOnBurntFn(OnBurnt)

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:ListenForEvent("propsmashed", OnSmashed)
    inst:ListenForEvent("knockbackdropped", OnKnockbackDropped)

    inst.nobrokentoolfx = true
    inst.OnCancelMinigame = function(--[[pigking]])
        --ehhh not valid if removing a pig holding it, for some reason events don't unregister
        if inst:IsValid() then
            inst:DoTaskInTime(1 + math.random(), BreakSign)
        end
    end

	
    return inst
end



local function fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sign_elite")
    inst.AnimState:SetBuild("sign_elite")
    inst.AnimState:PlayAnimation("shatter")

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return Prefab("propsign", fn, assets, prefabs),
    Prefab("propsignshatterfx", fxfn, assets_fx)
