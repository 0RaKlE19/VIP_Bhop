#pragma semicolon 1
#pragma newdecls required

#include <vip_core>

public Plugin myinfo = 
{
    name = "[VIP] Bhop",
    author = "R1KO (Fork by PSIH :{ )",
    version = "1.0.0",
    url = "https://github.com/0RaKlE19/VIP_Bhop"
};

static const char g_sFeature[] = "BHOP";
static bool g_bTimerOn, g_bInfoOn, g_bBHOPStart, g_bFreezeType;
static int g_iTimer;
ConVar sv_autobunnyhopping;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    HookEvent("round_start", eRoundStart, EventHookMode_Pre);
    HookEvent("round_freeze_end", eRoundFreezeEnd, EventHookMode_Pre);
    LoadTranslations("vip_modules.phrases");
    sv_autobunnyhopping = FindConVar("sv_autobunnyhopping");
    return APLRes_Success;
}

public void OnPluginStart()
{
    if (VIP_IsVIPLoaded())
        VIP_OnVIPLoaded();
    
    Handle hRegister;

    HookConVarChange(hRegister = CreateConVar("sm_vip_bhop_timer_on", "1", "Enable timer functions before turning on Bhop? (1 - Yes, 0 - No)", 0, true, 0.0, true, 1.0), OnTimerOnChange);
    g_bTimerOn = GetConVarBool(hRegister);

    HookConVarChange(hRegister = CreateConVar("sm_vip_bhop_timer", "5", "How many seconds will it take to allow the player to bhop if the timer function is enabled?", 0, true, 1.0, true, 60.0), OnTimerChange);
    g_iTimer = GetConVarInt(hRegister);

    HookConVarChange(hRegister = CreateConVar("sm_vip_bhop_info_on", "1", "Notify that bhop will work in N seconds?", 0, true, 0.0, true, 1.0), OnInfoOnChange);
    g_bInfoOn = GetConVarBool(hRegister);

    HookConVarChange(hRegister = CreateConVar("sm_vip_bhop_info_type", "1", "Enable notification 1 - after mp_freeze_time, 0 - at the beginning of the round.", 0, true, 0.0, true, 1.0), OnFreezeTypeChange);
    g_bFreezeType = GetConVarBool(hRegister);

    AutoExecConfig(true, "VIP_Bhop", "vip");
    CloseHandle(hRegister);
}

public void OnInfoOnChange(Handle ConVars, const char[] oldValue, const char[] newValue){g_bInfoOn = GetConVarBool(ConVars);}
public void OnTimerChange(Handle ConVars, const char[] oldValue, const char[] newValue){g_iTimer = GetConVarInt(ConVars);}
public void OnTimerOnChange(Handle ConVars, const char[] oldValue, const char[] newValue){g_bTimerOn = GetConVarBool(ConVars);}
public void OnFreezeTypeChange(Handle ConVars, const char[] oldValue, const char[] newValue){g_bFreezeType = GetConVarBool(ConVars);}

public void VIP_OnVIPLoaded(){VIP_RegisterFeature(g_sFeature, INT);}

public void OnPluginEnd()
{
    if (CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "VIP_UnregisterFeature") == FeatureStatus_Available)
        VIP_UnregisterFeature(g_sFeature);
    CloseHandle(sv_autobunnyhopping);
}

public Action eRoundStart(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
    if(g_bTimerOn && g_bInfoOn && !g_bFreezeType)
    {
        char szBuffer[128];
        FormatEx(szBuffer, sizeof(szBuffer), "%t", "BHOP_TIME", g_iTimer);
        if (g_iTimer > 0)
        {
            for (int i = 1; i < MaxClients; i++)
            {
                if(IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i) && IsPlayerAlive(i))
                {
                    sv_autobunnyhopping.ReplicateToClient(i, "0");
                    if(VIP_IsClientFeatureUse(i, g_sFeature))
                        VIP_PrintToChatClient(i, szBuffer);
                }
            }
        }
    }
    else if(!g_bTimerOn)
    {
        g_bBHOPStart = true;
        for (int i = 1; i < MaxClients; i++)
        {
            if(IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i) && IsPlayerAlive(i) && VIP_IsClientFeatureUse(i, g_sFeature))
                sv_autobunnyhopping.ReplicateToClient(i, "1");
        }
    }
    return Plugin_Continue;
}

public Action eRoundFreezeEnd(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
    if(g_bTimerOn)
    {
        g_bBHOPStart = false;
        CreateTimer(float(g_iTimer), Timer_BhopStart, _, TIMER_FLAG_NO_MAPCHANGE);
        if(g_bInfoOn && g_bFreezeType)
        {
            char szBuffer[128];
            FormatEx(szBuffer, sizeof(szBuffer), "%t", "BHOP_TIME", g_iTimer);
            if (g_iTimer > 0)
            {
                for (int i = 1; i < MaxClients; i++)
                {
                    if(IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i) && IsPlayerAlive(i))
                    {
                        sv_autobunnyhopping.ReplicateToClient(i, "0");
                        if(VIP_IsClientFeatureUse(i, g_sFeature))
                            VIP_PrintToChatClient(i, szBuffer);
                    }
                }
            }
        }
    }
    else
    {
        g_bBHOPStart = true;
        for (int i = 1; i < MaxClients; i++)
        {
            if(IsClientConnected(i) && IsClientInGame(i) && IsPlayerAlive(i) && VIP_IsClientFeatureUse(i, g_sFeature))
                sv_autobunnyhopping.ReplicateToClient(i, "1");
        }
    }
    return Plugin_Continue;
}

public Action Timer_BhopStart(Handle hTimer)
{
    g_bBHOPStart = true;
    for(int i = 1; i <= MaxClients; i++)
    {
        if(IsClientConnected(i) && IsClientInGame(i) && IsPlayerAlive(i) && VIP_IsClientFeatureUse(i, g_sFeature))
            sv_autobunnyhopping.ReplicateToClient(i, "1");
    }
    return Plugin_Stop;
}

public Action OnPlayerRunCmd(int iClient, int & iButtons)
{
    if (!g_bBHOPStart && g_bTimerOn) return;
    
    if (IsPlayerAlive(iClient) && VIP_IsClientFeatureUse(iClient, g_sFeature) && iButtons & IN_JUMP && !(GetEntityFlags(iClient) & FL_ONGROUND) && !(GetEntityMoveType(iClient) & MOVETYPE_LADDER))
        iButtons &= ~IN_JUMP;
}
