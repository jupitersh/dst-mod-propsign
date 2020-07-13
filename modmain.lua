if not GLOBAL.TheNet:GetIsServer() then
    return
end

local require = GLOBAL.require
local SpawnPrefab = GLOBAL.SpawnPrefab
local Prefabs = GLOBAL.Prefabs
local UpvalueHacker = require("upvaluehacker")

local propsign_uses = GetModConfigData("finiteuses")

--锤掉木牌生成打人木牌

local function OnHammer(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:SpawnLootPrefab("propsign")
    inst:Remove()
end

local function HomsignTwk(inst)
    if inst.components.workable then
        inst.components.workable:SetOnFinishCallback(OnHammer)
    end
end

AddPrefabPostInit("homesign", HomsignTwk)

--打人木牌修改

local function OnFinished(inst)
    inst:Remove()
end

local function OnSmashed(inst, pos)
    local fx = SpawnPrefab("propsignshatterfx")
    fx.Transform:SetPosition(pos:Get())
    fx.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    if inst.components.finiteuses then
        inst.components.finiteuses:Use(1)
    end
end

local function PropSignTwk(inst)
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(propsign_uses)
    inst.components.finiteuses:SetUses(propsign_uses)
    inst.components.finiteuses:SetOnFinished(OnFinished)
    if inst.components.inventoryitem then
        inst.components.inventoryitem.cangoincontainer = true
    end
    inst.OnCancelMinigame = function() end
    UpvalueHacker.SetUpvalue(Prefabs.propsign.fn, OnSmashed, "OnSmashed")
    if inst:HasTag("irreplaceable") then
        inst:RemoveTag("irreplaceable")
    end
end

AddPrefabPostInit("propsign", PropSignTwk)