--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require ("app/libs/dragonbones")
local gt = cc.exports.gt
local DragonBoneCreator = class("DragonBoneCreator")

DragonBoneCreator.DEFAULT_SCALE = 0.618
DragonBoneCreator.DEFUALT_POSITION = cc.p(0, 0)
DragonBoneCreator.DEFUALT_ARMATURE_NAME = "armatureDisplay"
DragonBoneCreator.DEFAULT_SPEED = 0.5
DragonBoneCreator.DEFAULT_ROTATION = 0
DragonBoneCreator.cacheDBObjs = DragonBoneCreator.cacheDBObjs or {}
DragonBoneCreator.resHasLoaded = {}

--[[----        self._armatureDisplay:bindDragonEventListener(handler(self,self._animationEventHandler))
----        self._armatureDisplay:addDragonEventType("start")
----        self._armatureDisplay:addDragonEventType("loopComplete")
----        self._armatureDisplay:addDragonEventType("complete")
----function EntryMainScene:_animationEventHandler(typename, name, eventobj, obj)
----    gt.log(eventobj:AnimationState():getName() .. "," .. typename .. "," .. name)
----end
]]

--dbData.skeDataPath
--dbData.texDataPath
--dbData.armatureName
--dbData.animationName
--dbData.targetNode
function DragonBoneCreator:ctor(dbData)
    gt.log("*************************DragonBoneCreator:ctor*************************")
    if nil == dbData.targetNode then
        gt.log("DB target node not found, return")
        return
    end

    local exist = DragonBoneCreator.cacheDBObjs[dbData.targetNode]
    if nil ~= exist then
        gt.log("DB target node already added, return")
        return
    end

    local dbConfig = {}
    dbConfig._dbFactory = db.CCFactory:getInstance()
    if nil == DragonBoneCreator.resHasLoaded[dbData.skeDataPath] and nil == DragonBoneCreator.resHasLoaded[dbData.texDataPath] then
        dbConfig._dragonBonesData = dbConfig._dbFactory:loadDragonBonesData(dbData.skeDataPath)
        dbConfig._dbFactory:loadTextureAtlasData(dbData.texDataPath)
        DragonBoneCreator.resHasLoaded[dbData.skeDataPath] = true
        DragonBoneCreator.resHasLoaded[dbData.texDataPath] = true
    end
    dbConfig._armatureDisplay = dbConfig._dbFactory:buildArmatureDisplay(dbData.armatureName)
    dbConfig._armatureDisplay:setPosition(dbData.armaturePos and dbData.armaturePos or DragonBoneCreator.DEFUALT_POSITION)
    dbConfig._armatureDisplay:setScale(dbData.armatureScale and dbData.armatureScale or DragonBoneCreator.DEFAULT_SCALE)
	dbConfig._armatureDisplay:setRotation(dbData.armatureRotation and dbData.armatureRotation or DragonBoneCreator.DEFAULT_ROTATION)
    dbConfig._armatureDisplay:setName(dbData.armatureObjName and dbData.armatureObjName or DragonBoneCreator.DEFUALT_ARMATURE_NAME)
    dbConfig._armatureDisplay:getAnimation():play(dbData.animationName).timeScale = dbData.armatureSpeed and dbData.armatureSpeed or DragonBoneCreator.DEFAULT_SPEED
    dbData.targetNode:addChild(dbConfig._armatureDisplay)
    dbConfig.dbData = dbData
    DragonBoneCreator.cacheDBObjs[dbData.targetNode] = dbConfig
end

function DragonBoneCreator:stop(targetNode)
    gt.log("*************************DragonBoneCreator:stop*************************")
    if nil == targetNode or nil == DragonBoneCreator.cacheDBObjs[targetNode] then
        return
    end

    local dbConfig = DragonBoneCreator.cacheDBObjs[targetNode]
    dbConfig._armatureDisplay:getAnimation():stop(dbConfig.dbData.animationName)
end

function DragonBoneCreator:disposeDB(targetNode)
    gt.log("*************************DragonBoneCreator:disposeDB*************************")
    if nil == targetNode or nil == DragonBoneCreator.cacheDBObjs[targetNode] then
        return
    end

    local dbConfig = DragonBoneCreator.cacheDBObjs[targetNode]
    dbConfig._armatureDisplay:getAnimation():stop(dbConfig.dbData.animationName)
    dbConfig._armatureDisplay:removeFromParent()
	--???
    db.CCFactory:getInstance():removeDragonBonesData(dbConfig.dbData.skeDataPath)
end

function DragonBoneCreator:disposeAllDBs()
    gt.log("*************************DragonBoneCreator:disposeAllDBs*************************")
    for k,v in pairs(DragonBoneCreator.cacheDBObjs) do
        local dbConfig = v
        dbConfig._armatureDisplay:getAnimation():stop(dbConfig.dbData.animationName)
        dbConfig._armatureDisplay:removeFromParent()
    end
    db.CCFactory:getInstance():clear()
    DragonBoneCreator.cacheDBObjs = {}
	DragonBoneCreator.resHasLoaded = {}
end

return DragonBoneCreator
--endregion