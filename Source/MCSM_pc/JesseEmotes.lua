require("PlayerChoice.lua");
local kPlayerChoice = "Player Choice"
local kInputMap = "JesseEmotes"
local CreateAssets = function()
  local fileNamea = FileSetExtension(kInputMap, "imap")
  InputMapperAddEvent(fileNamea, kEventCodeF, kEventBegin, "Jesse_Dance")
  InputMapperAddEvent(fileNamea, kEventCodeG, kEventBegin, "Jesse_Laugh")
  InputMapperAddEvent(fileNamea, kEventCodeH, kEventBegin, "Jesse_Scream")
  InputMapperAddEvent(fileNamea, kEventCodeJ, kEventBegin, "Jesse_Point")
  InputMapperAddEvent(fileNamea, kEventCodeK, kEventBegin, "Jesse_ActualScream")
  InputMapperAddEvent(fileNamea, kEventCodeL, kEventBegin, "Jesse_FallDown")
  InputMapperAddEvent(fileNamea, kEventCodeP, kEventBegin, "WhosGuyWithASword")
  InputMapperAddEvent(fileNamea, kEventCodeM, kEventBegin, "Jesse_No")
  InputMapperAddEvent(fileNamea, kEventCodeN, kEventBegin, "Jesse_Clap")
  InputMapperAddEvent(fileNamea, kEventCodeB, kEventBegin, "Jesse_ShutUp")
  InputMapperAddEvent(fileNamea, kEventCodeV, kEventBegin, "Jesse_GetAway")
end

local jessegender = SaveLoad_GetSlotValue(kPlayerChoice)

function Jesse_Dance()
    ChorePlay("skM1_jesse_toHappyA");
    PlayAnimation("Jesse", "skM1_minecraftGMStandA_cheerB_add");
    if jessegender > 3 then
      PlayAnimation("Jesse", "a_367088557");
      SoundPlay("a_367088557");
    else
        PlayAnimation("Jesse", "a_367088557_female");
        SoundPlay("a_367088557_female");
    end      
end

function Jesse_Laugh()
    PlayAnimation("Jesse", "skM1_jesseStandA_laugh_add");
    if jessegender > 3 then
        SoundPlay("JesseLaugh_M");
    else
        SoundPlay("JesseLaugh_F");
    end
end

function Jesse_Scream()
    ChorePlay("skM1_jesse_toFearA");
    PlayAnimation("Jesse", "skM1_minecraftGMStandA_scaredTake_add");
    if jessegender > 3 then
        SoundPlay("NV_Jesse_Shock");
    else
        SoundPlay("NV_JesseF_Shock");
    end
end

function Jesse_Point()
    ChorePlay("skM1_jesse_toAngryA");
    PlayAnimation("Jesse", "skM1_mineCraftGMStandA_pointRight_add");
    if jessegender > 3 then
        PlayAnimation("Jesse", "a_367096610");
        SoundPlay("a_367096610");
    else
        PlayAnimation("Jesse", "a_367096610_female");
        SoundPlay("a_367096610_female");
    end
end

function Jesse_ActualScream()
    ChorePlay("skM1_jesse_toFearX");
    PlayAnimation("Jesse", "skM1_minecraftGMStandA_enragedGestureA_add");
    PlayAnimation("Jesse", "a_367128938");
    if jessegender > 3 then
        SoundPlay("a_367128938");
    else
        SoundPlay("a_367128938_female"); 
    end       
end

function Jesse_FallDown()
    ChorePlay("skM1_jesse_toFearA");
    PlayAnimation("Jesse", "skM1_action_gillKnockedOverByFirework_add");
    if jessegender > 3 then
        SoundPlay("NV_Jesse_Oof");
    else
        SoundPlay("NV_JesseF_Oof"); 
    end
end

function WhosGuyWithASword()
    ChorePlay("skM1_jesse_toConfusedA");
    PlayAnimation("Jesse", "skM1_oliviaStandA_scratchHead_add");
    SoundPlay("whosguy");
    PlayAnimation("Jesse", "whosguy");
end

function Jesse_No()
    ChorePlay("skM1_jesse_toFearX");
    PlayAnimation("Jesse", "skM1_minecraftGMStandA_enragedGestureB_add");
    if jessegender > 3 then
        SoundPlay("male_no");
        PlayAnimation("Jesse", "male_no");
    else
        SoundPlay("female_no");
        PlayAnimation("Jesse", "female_no");
    end
end

function Jesse_Clap()
    ChorePlay("skM1_jesse_toHappyA");
    PlayAnimation("Jesse", "skM1_minecraftGMStandA_clap_add");
end

function Jesse_ShutUp()
    ChorePlay("skM1_jesse_toAngryA");
    PlayAnimation("Jesse", "skM1_minecraftGM_handPointRight_add");
    if jessegender > 3 then
        SoundPlay("male_shutup");
        PlayAnimation("Jesse", "male_shutup");
    else
        SoundPlay("female_shutup");
        PlayAnimation("Jesse", "female_shutup");
    end
end

function Jesse_GetAway()
    ChorePlay("skM1_jesse_toFearA");
    PlayAnimation("Jesse", "skM1_minecraftGM_armsUpWave_add");
    if jessegender > 3 then
        SoundPlay("male_getaway");
        PlayAnimation("Jesse", "male_getaway");
    else
        SoundPlay("female_getaway");
        PlayAnimation("Jesse", "female_getaway");
    end
end

CreateAssets();
InputMapperActivate(kInputMap);