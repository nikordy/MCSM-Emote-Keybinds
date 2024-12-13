require("JesseEmotes.lua");
local kLogicAgent = "logic_script"
local kScriptCommand = "Script - Command"
local kScriptCurrent = "Script - Current"
local kScriptPrevious = "Script - Previous"
local kScriptDialogNode = "Script - Dialog Node"
local kGameCombatMode = "Game - Combat Mode"
local kPropLogicGameLocations = "logic_game_locations.prop"
local kScriptSceneMap = "Script to Scene Map"
local kDialogSceneMap = "Dialog to Scene Map"
local kSceneDialog = "Scene - Dialog"
local kSceneDialogNode = "Scene - Dialog Node"
local kScenePlayer = "Scene - Player"
local kGameLoadScript = "Game - Load Script On End"
local kUseableName = "Useable - Name"
eModeNone = {name = "None", bHidesCursor = true}
eModeNavigate = {
  name = "Navigate",
  bHidesCursor = true,
  bPlayMode = true,
  bShowsInventory = true
}
eModeCombat = {
  name = "Combat",
  bHidesCursor = true,
  bPlayMode = true
}
eModeCredits = {
  name = "Credits",
  bDisablesSaves = true,
  bHidesCursor = true
}
eModeCutscene = {
  name = "Cutscene",
  bDisablesSaves = true,
  bHidesCursor = true
}
eModeDialog = {
  name = "Dialog",
  bDisablesSaves = true,
  bDisablesReticle = true
}
eModeDialogBox = {name = "Dialog Box", bPausesGame = true}
eModeCrafting = {
  name = "Crafting",
  bPlayMode = true,
  bDisablesReticle = true,
  bShowsInventory = true
}
eModeDrag = {name = "Drag", bHidesCursor = true}
eModeMenu = {name = "Menu", bPausesGame = true}
eModePaused = {
  name = "Paused",
  bHidesCursor = true,
  bPausesGame = true
}
eModePeek = {
  name = "Peek",
  bHidesCursor = true,
  bPlayMode = true
}
eModeQTE = {
  name = "Quick Time Event",
  bHidesCursor = true
}
eModeStation = {
  name = "Station",
  bHidesCursor = true,
  bPlayMode = true,
  bShowsInventory = true
}
eModeStruggle = {
  name = "Struggle",
  bDisablesReticle = true,
  bHidesCursor = true
}
local mScene, mPlayer, mSceneAgent, mSceneCam, mDialogScene, mDialogPlayer, mPropsCharacter, mPropsSpeaker, mPropsUIScene, mPropsUseable, mPausedScenes, mShowCursorRefs
local mModeStack = {
  eModeNone
}
local mMode = eModeNone
local mbLoadedGame = false
local mbCombatMode
local CreateAssets = function()
  CreateGameLogic(kPropLogicGameLocations)
  if ResourceExists(kPropLogicGameLocations) and not PropertyExists(kPropLogicGameLocations, kScriptSceneMap) then
    CreateProperty(kPropLogicGameLocations, kScriptSceneMap, "Map<String,String,less<String>>")
    Save(kPropLogicGameLocations)
  end
  if ResourceExists(kPropLogicGameLocations) and not PropertyExists(kPropLogicGameLocations, kDialogSceneMap) then
    CreateProperty(kPropLogicGameLocations, kDialogSceneMap, "Map<String,String,less<String>>")
    Save(kPropLogicGameLocations)
  end
  CreateGameLogicKey(kGameCombatMode, kBool)
  local fileName = FileSetExtension(kLogicAgent, "prop")
  if CreateResource(fileName, kDirProperties) then
    PropertyCreate(fileName, kScriptCommand, kString)
    PropertyCreate(fileName, kScriptCurrent, kString)
    PropertyCreate(fileName, kScriptPrevious, kString)
    PropertyCreate(fileName, kScriptDialogNode, kString)
    Save(fileName)
  end
  CreateLogicAgent(kLogicAgent, fileName)
  fileName = "game_start.prop"
  if CreateResource(fileName, kDirPrimitives) then
    PropertyCreate(fileName, kGameLoadScript, kString)
    Save(fileName)
  end
  local kStartNodeProps = "module_dlgProps_Start.prop"
  if not PropertyHasGlobal(kStartNodeProps, fileName) then
    PropertyAddGlobal(kStartNodeProps, fileName)
    Save(kStartNodeProps)
  end
end
local SetMode = function(eMode)
  if eMode == mMode then
    return
  end
  local kUseForwardScaleMinClamp = "Use Forward Scale Min Clamp"
  local lastMode = mMode
  mMode = eMode
  Cursor_Highlight(false)
  if lastMode.bPlayMode then
    Navigate_EnableInput(false)
    VirtualStick_EnableInput(false)
    UI_Activate(false)
    Reticle_EnableSelection(false)
    if mPlayer then
      Look_EnableFocus(mPlayer, false)
    end
    if lastMode.bShowsInventory then
      Inventory_Hide()
    end
    if mMode ~= eModeDrag then
      Drag_Enable(false)
    end
  end
  if lastMode == eModeNavigate then
    if mPlayer and mPlayer.mProps then
      mPlayer.mProps[kUseForwardScaleMinClamp] = false
    end
  elseif lastMode == eModeCombat then
    Combat_SetActivated(false)
  elseif lastMode == eModeCrafting then
    Crafting_Activate(false)
  elseif lastMode == eModeCutscene then
    if IsPlatformTouch() and Input_UseCursor() then
      Vignette_Hide()
    end
  elseif lastMode == eModePeek then
    Peek_Activate(false)
  elseif lastMode == eModeQTE then
    QTE_SetActivated(false)
  elseif lastMode == eModeStation then
    Station_Activate(false)
  end
  if lastMode.bHidesCursor then
    CursorHide(false, lastMode.name)
  end
  if mMode == eModeNavigate then
    if mPlayer and mPlayer.mProps then
      mPlayer.mProps[kUseForwardScaleMinClamp] = true
    end
  elseif mMode == eModeCombat then
    Combat_SetActivated(true)
  elseif mMode == eModeCrafting then
    Crafting_Activate(true)
  elseif mMode == eModeCutscene then
    if IsPlatformTouch() and Input_UseCursor() and not mbCombatMode then
      Vignette_Show()
    end
  elseif mMode == eModePeek then
    Peek_Activate(true)
  elseif mMode == eModeQTE then
    QTE_SetActivated(true)
  elseif mMode == eModeStation then
    Station_Activate(true)
  end
  if mMode.bPlayMode then
    Navigate_EnableInput(true)
    VirtualStick_EnableInput(true)
    UI_Activate(true)
    Reticle_EnableSelection(true)
    if mPlayer then
      Look_EnableFocus(mPlayer, true)
    end
    if mMode.bShowsInventory then
      Inventory_Show()
    end
    Drag_Enable(true)
    Trigger_PreloadEnterDialogs()
  end
  if not (IsToolBuild() and mMode.bHidesCursor) or mMode ~= eModeNavigate or not IsPlatformTouch() then
    CursorHide(mMode.bHidesCursor or false, mMode.name)
  end
  RolloverResetStatus()
end
local Pause = function(bPause, bReset)
  if not mScene then
    return
  end
  if bPause then
    if mPausedScenes then
      return
    end
    mPausedScenes = {}
    mShowCursorRefs = {}
    local sceneNames = SceneGetActiveSceneNames(true)
    for _, name in ipairs(sceneNames) do
      local scene = SceneFind(name)
      if scene then
        local bPauseScene = true
        local sceneAgent = SceneGetSceneAgent(scene)
        if sceneAgent and PropertyHasGlobal(sceneAgent.mProps, mPropsUIScene) then
          bPauseScene = sceneAgent.mProps["UI Scene - Pause"]
          if bPauseScene then
            name = FileStripExtension(name)
            if Cursor_IsHidden(name) then
              CursorHide(false, name)
              table.insert(mShowCursorRefs, name)
            end
          end
        end
        if bPauseScene then
          scene.mTimeScale = SceneGetTimeScale(scene)
          table.insert(mPausedScenes, scene)
          SceneSetTimeScale(scene, 0)
        end
      end
    end
  elseif mPausedScenes then
    for _, scene in ipairs(mPausedScenes) do
      SceneSetTimeScale(scene, scene.mTimeScale)
    end
    for _, ref in ipairs(mShowCursorRefs) do
      CursorHide(true, ref)
    end
    mPausedScenes = nil
    mShowCursorRefs = nil
  elseif bReset then
    local sceneNames = SceneGetActiveSceneNames(true)
    for _, name in ipairs(sceneNames) do
      SceneSetTimeScale(name, 1)
    end
  end
end
local GetUseableName = function(agent)
  local name = AgentGetProperty(agent, kUseableName)
  if name == "" then
    name = AgentGetName(agent)
    local index = string.find(name, "_")
    if index then
      name = string.sub(name, index + 1)
    end
  end
  return name
end
local UseAgent = function(agent)
  local nodeName = Game_GetUseNodeName(agent)
  if not nodeName then
    return
  end
  if DlgIsObjVisible(mDialogScene, nodeName) then
    Dialog_Run(mDialogScene, nodeName)
    return
  end
  if DlgIsObjVisible(mDialogPlayer, nodeName) then
    Dialog_Run(mDialogPlayer, nodeName)
    return
  end
  local dialogFile
  dialogFile, nodeName = Game_GetSpeakerDialog(agent)
  if dialogFile then
    Dialog_Run(dialogFile, nodeName)
    return
  end
  nodeName = "use_all"
  if DlgIsObjVisible(mDialogScene, nodeName) then
    Dialog_Run(mDialogScene, nodeName)
    return
  end
end
local OnSetCombatMode = function(key, value)
  if value == mbCombatMode then
    return
  end
  Reticle_EnableCombatMode(value)
  Drag_EnableCombatMode(value)
  if value then
    Inventory_Hide()
  elseif mbCombatMode ~= nil then
    Inventory_Show()
    if IsPlatformTouch() and Input_UseCursor() and mMode == eModeCutscene then
      Vignette_Show()
    end
  end
  mbCombatMode = value
end
local UpdateDialogSceneMap = function()
  if not IsToolBuild() or not mDialogScene then
    return
  end
  local dialogName = ResourceGetName(mDialogScene)
  local sceneName = ResourceGetName(mScene)
  local bSave = false
  local container = PropertyGet(kPropLogicGameLocations, kDialogSceneMap)
  local element = ContainerGetElement(container, dialogName)
  if not element then
    ContainerInsertElement(container, sceneName, dialogName)
    bSave = true
  elseif element ~= sceneName then
    Print("UpdateDialogSceneMap: Warning! Dialog \"" .. dialogName .. "\" is already mapped to scene \"" .. element .. "\". Cannot map to \"" .. sceneName .. "\"")
  end
  if bSave then
    Save(kPropLogicGameLocations)
  end
end
local OnSetSceneDialog = function(key, value)
  if not mScene then
    return
  end
  if value then
    mDialogScene = value
    UpdateDialogSceneMap()
  end
end
local OnSetPlayer = function(key, value)
  if not mScene then
    return
  end
  local curPlayer = mPlayer
  mPlayer = nil
  if value ~= "" and AgentExists(value) then
    mPlayer = AgentFind(value)
  end
  if curPlayer then
    Look_EnableFocus(curPlayer, false)
  end
  if mPlayer then
    mDialogPlayer = mPlayer.mProps["Player - Dialog"]
    AgentSetSelectable(mPlayer, false)
    if Game_IsPlayMode() then
      Look_EnableFocus(mPlayer, true)
    end
    if curPlayer then
      PropertyRemove(curPlayer.mProps, kGameSelectable)
      local kNavCamTarget = "NavCam - Target Agent"
      local kTriggerTarget = "Trigger Target Name"
      local curName = AgentGetName(curPlayer)
      local agents = SceneGetAgents(mScene)
      for i, agent in pairs(agents) do
        if PropertyExists(agent.mProps, kNavCamTarget) then
          if agent.mProps[kNavCamTarget] == curName then
            agent.mProps[kNavCamTarget] = value
          end
        elseif PropertyExists(agent.mProps, kTriggerTarget) and agent.mProps[kTriggerTarget] == curName then
          agent.mProps[kTriggerTarget] = value
        end
      end
    end
  end
  Callback_OnSetPlayer:Run(mPlayer)
end
local OnSetScriptCommand = function(key, value)
  if not mScene or value == "" then
    return
  end
  Print("Executing script command " .. value)
  DoString(value)
end
local OnSetScriptDialogNode = function(key, value)
  if not mScene or value == "" then
    return
  end
  Print("Running dialog node " .. value)
  Game_RunDialog(value, false)
end
local OnStartNode = function(dialog, nodeID, instanceID, executionCount)
  local script = DlgGetObjUserPropsValue(dialog, nodeID, kGameLoadScript)
  ThreadStart(Game_PreloadScene, script, nil, instanceID)
end
local EndScene = function(bFadeOut)
  Game_PopMode(eModeNavigate)
  UI_EnableInput(false)
  Reticle_Enable(false)
  CursorHide(true)
  RenderDelay(1)
  Yield()
  while Game_IsPaused() do
    Yield()
  end
  if bFadeOut then
    UI_OverlayFadeOut()
  end
  SoundStartMusicDriftForSceneChange(mScene)
  SceneHide(mScene, true)
  RenderDelay(10)
  AgentSetProperty(kLogicAgent, kScriptPrevious, AgentGetProperty(kLogicAgent, kScriptCurrent))
end
function Game_NewScene(scene, script)
  if IsString(scene) then
    mScene = SceneFind(scene)
  else
    mScene = scene
  end
  SceneHide(mScene, true)
  mSceneAgent = SceneGetSceneAgent(mScene)
  Callback_OnGameSceneOpen:Run(mScene)
  local camName = mSceneAgent.mProps["Scene - Camera"]
  if camName ~= "" then
    mSceneCam = AgentFind(camName)
    CameraPush(mSceneCam)
  else
    mSceneCam = SceneGetCamera(mScene)
    mSceneAgent.mProps["Scene - Camera"] = AgentGetName(mSceneCam)
  end
  local fxScene = mSceneAgent.mProps["Scene - FX Scene"]
  if fxScene ~= "" then
    SceneAdd(fxScene)
  end
  mPropsCharacter = Load("character.prop")
  mPropsSpeaker = Load("speaker.prop")
  mPropsUIScene = Load("ui_scene.prop")
  mPropsUseable = Load("useable.prop")
  Yield()
  Yield()
  local logicProps = AgentGetProperties(kLogicAgent)
  PropertyRemove(logicProps, kScriptCommand)
  PropertyRemove(logicProps, kScriptDialogNode)
  LogicAddKeyCallback(kGameCombatMode, OnSetCombatMode)
  PropertyAddKeyCallback(mSceneAgent.mProps, kSceneDialog, OnSetSceneDialog)
  PropertyAddKeyCallback(mSceneAgent.mProps, kScenePlayer, OnSetPlayer)
  PropertyAddKeyCallback(logicProps, kScriptCommand, OnSetScriptCommand)
  PropertyAddKeyCallback(logicProps, kScriptDialogNode, OnSetScriptDialogNode)
  Callback_DialogOnStartNodeBegin:Add(OnStartNode)
  mDialogScene = mSceneAgent.mProps[kSceneDialog]
  UpdateDialogSceneMap()
  mbLoadedGame = script == AgentGetProperty(kLogicAgent, kScriptCurrent)
  AgentSetProperty(kLogicAgent, kScriptCurrent, script)
  if not mbLoadedGame then
    PropertyRemove(GameLogicGet(), kGameCombatMode)
  end
  OnSetCombatMode(kGameCombatMode, LogicGet(kGameCombatMode))
  if IsToolBuild() then
    local scriptNoExt = FileStripExtension(script)
    local sceneName = ResourceGetName(mScene)
    local bSave = false
    local container = PropertyGet(kPropLogicGameLocations, kScriptSceneMap)
    local element = ContainerGetElement(container, scriptNoExt)
    if not element then
      ContainerInsertElement(container, sceneName, scriptNoExt)
      bSave = true
    elseif element ~= sceneName then
      ContainerSetElement(container, scriptNoExt, sceneName)
      bSave = true
    end
    if bSave then
      Save(kPropLogicGameLocations)
    end
  end
  OnSetPlayer(kScenePlayer, mSceneAgent.mProps[kScenePlayer])
  local rules = mSceneAgent.mProps["Scene - Rules"]
  if rules then
    RulesExecute(rules)
  end
  local dialog, dialogNode
  if not mbLoadedGame then
    dialog = mDialogScene
    dialogNode = mSceneAgent.mProps[kSceneDialogNode]
  else
    dialog, dialogNode = SaveLoad_GetCheckpointDialog()
  end
  if dialog and dialogNode and DlgIsObjVisible(dialog, dialogNode) then
    Preload_Dialog(dialog, dialogNode, 0, nil, 0, false, true)
  end
end
function Game_StartScene(bFadeIn)
  local chore = mSceneAgent.mProps["Scene - Chore"]
  if chore then
    ChorePlay(chore)
  end
  SceneHide(mScene, false)
  if mbLoadedGame then
  elseif bFadeIn then
    ThreadStart(UI_OverlayFadeIn)
  end
  Pause(false, true)
  Game_PushMode(eModeNavigate)
  UI_EnableInput(true)
  Reticle_Enable(true)
  if not mbLoadedGame then
    if not Game_GetSkipEnterCutscenes() then
      Dialog_Run(mDialogScene, mSceneAgent.mProps[kSceneDialogNode], false)
    end
    local SetLocationEntered = function()
      local key = "bEntered" .. AgentGetProperty(kLogicAgent, kScriptCurrent)
      if IsToolBuild() then
        CreateProperty(kPropLogicGameLocations, key, kBool, false)
      end
      if not LogicGet(key) then
        Yield()
        Yield()
        LogicSet(key, true)
      end
    end
    ThreadStart(SetLocationEntered)
  else
    if mSceneCam then
      Station_Restore(mSceneCam)
    end
    SaveLoad_RestoreCheckpoint()
  end
end
function Game_EndScene(nextScript, bFadeOut)
  EndScene(bFadeOut)
  if nextScript then
    LoadScript(FileSetExtension(nextScript, "lua"))
  else
    ResetGame("_boot.lua")
  end
end
function Game_EndEpisode(nextProject, projectStartScript, newResourceSets, bFadeOut)
  EndScene(bFadeOut)
  if nextProject then
    SubProject_Switch(nextProject, FileSetExtension(projectStartScript, "lua"), newResourceSets)
  else
    ResetGame("_boot.lua")
  end
end
function Game_GetScene()
  return mScene
end
function Game_GetPausedScenes()
  return mPausedScenes
end
function Game_IsPaused()
  return mPausedScenes ~= nil
end
function Game_IsCombatMode()
  return mbCombatMode == true
end
function Game_GetPlayer()
  return mPlayer
end
function Game_GetPlayerName()
  return mSceneAgent and mSceneAgent.mProps[kScenePlayer] or ""
end
function Game_SetPlayer(name)
  mSceneAgent.mProps[kScenePlayer] = name
end
function Game_PushMode(eMode)
  SetMode(eMode)
  if eMode ~= eModeNavigate then
    Navigate_Enable(false)
  end
  if eMode.bDisablesReticle or eMode.bPausesGame then
    Reticle_Enable(false, eMode.name)
  end
  if eMode.bDisablesSaves then
    SaveLoad_EnableSaves(false)
  end
  if eMode.bPausesGame then
    Pause(true)
  end
  table.insert(mModeStack, 1, eMode)
end
function Game_PopMode(eMode)
  local index = table.find(mModeStack, eMode)
  if not index then
    Print("Attempt to pop mode; \"" .. eMode.name .. "\" not on stack")
    return
  end
  table.remove(mModeStack, index)
  SetMode(mModeStack[1])
  if eMode ~= eModeNavigate then
    Navigate_Enable(true)
  end
  if eMode.bDisablesReticle or eMode.bPausesGame then
    Reticle_Enable(true, eMode.name)
  end
  if eMode.bDisablesSaves then
    SaveLoad_EnableSaves(true)
  end
  local bPause = false
  for i, mode in pairs(mModeStack) do
    if mode.bPausesGame then
      bPause = true
      break
    end
  end
  Pause(bPause)
end
function Game_GetMode()
  return mMode
end
function Game_IsPlayMode()
  return mMode.bPlayMode
end
function Game_ModeIsOnStack(eMode)
  for i, mode in pairs(mModeStack) do
    if mode == eMode then
      return true
    end
  end
  return false
end
function Game_PrintMode()
  Print("Active mode: " .. mMode.name)
end
function Game_PrintModeStack()
  Print("")
  for i, mode in pairs(mModeStack) do
    Print("Mode " .. i .. ": " .. mode.name)
  end
end
function Game_GetUseNodeName(agent)
  if not Game_IsUseable(agent) then
    return nil
  end
  return "use_" .. GetUseableName(agent)
end
function Game_IsUseable(agent)
  if not agent then
    return false
  end
  return PropertyHasGlobal(AgentGetProperties(agent), mPropsUseable)
end
function Game_UseAgent(agent)
  UseAgent(agent)
end
function Game_GetSceneDialog()
  return mDialogScene
end
function Game_GetPlayerDialog()
  return mDialogPlayer
end
function Game_GetDialog(nodeName)
  if DlgIsObjVisible(mDialogScene, nodeName) then
    return mDialogScene
  end
  if DlgIsObjVisible(mDialogPlayer, nodeName) then
    return mDialogPlayer
  end
  return nil
end
function Game_DialogExists(nodeName)
  return DlgIsObjVisible(mDialogScene, nodeName) or DlgIsObjVisible(mDialogPlayer, nodeName)
end
function Game_RunDialog(nodeName, bWait)
  if DlgIsObjVisible(mDialogScene, nodeName) then
    return Dialog_Run(mDialogScene, nodeName, bWait)
  else
    return Dialog_Run(mDialogPlayer, nodeName, bWait)
  end
end
function Game_RunSceneDialog(nodeName, bWait)
  return Dialog_Run(mDialogScene, nodeName, bWait)
end
function Game_RunPlayerDialog(nodeName, bWait)
  return Dialog_Run(mDialogPlayer, nodeName, bWait)
end
function Game_GetNounText(agent)
  local nodeName = agent.mProps["Useable - Noun Node"]
  if nodeName == "" then
    nodeName = GetUseableName(agent)
  end
  local text = Dialog_GetText(mDialogScene, nodeName)
  if text == "" then
    text = Dialog_GetText("ui_episode", nodeName)
  end
  return text
end
function Game_GetSpeakerDialog(agent)
  local props = AgentGetProperties(agent)
  if PropertyHasGlobal(props, mPropsSpeaker) then
    local dialogFile = props["Speaker - Dialog File"]
    if dialogFile then
      local nodeName = props["Speaker - Dialog Node"]
      if nodeName == "" then
        nodeName = AgentGetName(agent)
      end
      return dialogFile, nodeName
    end
  end
end
function Game_SetSceneDialog(dialog)
  if not mScene then
    return
  end
  AgentSetProperty(SceneGetSceneAgent(mScene), kSceneDialog, FileSetExtension(dialog, "dlog"))
end
function Game_SetSceneDialogNode(node)
  if not mScene then
    return
  end
  AgentSetProperty(SceneGetSceneAgent(mScene), kSceneDialogNode, node)
end
function Game_GetCurrentScript()
  return AgentGetProperty(kLogicAgent, kScriptCurrent)
end
function Game_GetPreviousScript()
  return AgentGetProperty(kLogicAgent, kScriptPrevious)
end
function Game_GetDebug()
  return AgentGetProperty(kLogicAgent, kScriptPrevious) == "DebugMenu"
end
function Game_GetLoaded()
  return mbLoadedGame
end
function Game_GetSkipEnterCutscenes()
  return Game_GetDebug() and PropertyGet(GetPreferences(), "Skip Enter Cutscenes")
end
function Game_PreloadAgentDialog(agent)
  if agent and IsString(agent) then
    agent = AgentFind(agent)
  end
  if not agent then
    return false
  end
  local nodeName = Game_GetUseNodeName(agent)
  if not nodeName or agent.preloadUseNode and agent.preloadUseNode == nodeName then
    return false
  end
  local dialog = Game_GetDialog(nodeName)
  if not dialog then
    return false
  end
  local timeNeeded = 0
  if mPlayer and Navigate_IsAgentPathingEnabled(agent) and not ReticleVerbs_AgentCanDisablePathing(agent) then
    if not ChoredMovement_IsActive() then
      local agentUsePos = WalkBoxesPosOnWalkBoxes(PathAgentGetUsePosition(mPlayer, agent), 0, PathAgentGetWalkBoxes(mPlayer))
      local playerPos = WalkBoxesPosOnWalkBoxes(AgentGetWorldPos(mPlayer), 0, PathAgentGetWalkBoxes(mPlayer))
      local dist = VectorDistance(agentUsePos, playerPos)
      timeNeeded = dist / (AgentGetForwardAnimVelocity(mPlayer) * mPlayer.mProps["Player - Run Speed"])
    else
      local controller = ChoredMovement_GetController()
      if controller then
        timeNeeded = ControllerGetLength(controller) - ControllerGetTime(controller)
      end
    end
  end
  Preload_Dialog(dialog, nodeName, timeNeeded)
  agent.preloadUseNode = nodeName
  return true
end
function Game_PreloadScene(nextScript, timeNeeded, currentInstanceID, bFadeOut)
  if not nextScript or nextScript == "" or not ResourceExists(FileSetExtension(nextScript, "lua")) then
    return
  end
  local container = PropertyGet(kPropLogicGameLocations, kScriptSceneMap)
  local sceneName = ContainerGetElement(container, FileStripExtension(nextScript))
  if sceneName and ResourceExists(sceneName) then
    Preload_Scene(sceneName, timeNeeded)
  end
  if currentInstanceID then
    DlgWait(currentInstanceID)
    Game_EndScene(nextScript, bFadeOut)
  end
end
if IsToolBuild() then
  CreateAssets()
end