/*
 * Library for various development type functions to left 4 dead 2.
*/
#include <sdktools>
#include <sdktools_gamerules>

#if defined _l4d2_devstocks_included
 #endinput
#endif
#define _l4d2_devstocks_included

enum
{
	BOT_CMD_ATTACK = 0,
	BOT_CMD_MOVE,
	BOT_CMD_RETREAT,
	BOT_CMD_RESET
}

enum
{
	TEAM_NONE = 0,
	TEAM_SPECTATOR,
	TEAM_SURVIVOR,
	TEAM_INFECTED,
}

enum
{
	ZC_NONE = 0,
	ZC_SMOKER,
	ZC_BOOMER,
	ZC_HUNTER,
	ZC_SPITTER,
	ZC_JOCKEY,
	ZC_CHARGER,
	ZC_WITCH,
	ZC_TANK,
}

// shqke's
#define VECTOR(%1) (%1)[0], (%1)[1], (%1)[2]

// Some generic color arrays for glow effect stock RGB
#define COLOR_RED		{ 255, 0, 0 }
#define COLOR_GREEN		{ 0, 255, 0 }
#define COLOR_BLUE		{ 0, 0, 255 }
#define COLOR_WHITE		{ 255, 255, 255 }
#define COLOR_YELLOW	{ 255, 255, 0}

#define TR_RED     {255, 0, 0, 255} 
#define TR_GREEN   {0, 255, 0, 255} 
#define TR_BLUE    {0, 0, 255, 255} 

// FROM/CREDITS: shqke
/*
 * Checks whether a round is in progress.
 * @return		True if survival in progress false otherwise.
*/
stock bool IsRoundInProgress()
{
	return GameRules_GetPropFloat("m_flRoundStartTime") > 0.0 && GameRules_GetPropFloat("m_flRoundEndTime") == 0.0;
}

/*
 * Returns whether a client is incapped.
 * @client		Client index.
 * @return		True if incapacitated false otherwise.
*/
stock bool IsIncapped(int client)
{
	return view_as<bool>(GetEntProp(client, Prop_Send, "m_isIncapacitated", 1));
}

/*
 * Returns whether a client is on a ladder. Or has this MoveType value.
 * @client		Client index.
 * @return		True if on ladder false otherwise.
*/
stock bool IsOnLadder(int client)
{
	if (GetEntityMoveType(client) & MOVETYPE_LADDER)
		return true;
	return false;
}

// CREDITS: Drakogas
/* Returns the nearest survivor index for a specified client.
 * @client		client index
 * @return		nearest survivor index or 0 on failure.
*/
stock int GetNearestSurvivor(int client) 
{
	static float tpos[3], spos[3], dist, mindist;
	static int i, iNearClient;
	mindist = 0.0;
	iNearClient = 0;
	GetClientAbsOrigin(client, tpos);
	
	for (i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i) && !IsFakeClient(i)) {
			GetClientAbsOrigin(i, spos);
			dist = GetVectorDistance(tpos, spos, false);
			if (dist < mindist || mindist < 0.1) {
				mindist = dist;
				iNearClient = i;
			}
		}
	}
	return iNearClient;
}

/* Returns the nearest Real (non-fakeclient) survivor index for a specified client.
 * @client		client index
 * @return		nearest real survivor index or 0 on failure.
*/
stock int GetNearestRealSurvivor(int client) 
{
	static float tpos[3], spos[3], dist, mindist;
	static int i, iNearClient;
	mindist = 0.0;
	iNearClient = 0;
	GetClientAbsOrigin(client, tpos);
	
	for (i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i) && !IsFakeClient(i)) {
			GetClientAbsOrigin(i, spos);
			dist = GetVectorDistance(tpos, spos, false);
			if (dist < mindist || mindist < 0.1) {
				mindist = dist;
				iNearClient = i;
			}
		}
	}
	return iNearClient;
}

/*
 * Gets nearest Special infected.
 * @client		Client index.
 * @returning	SI index or 0 on failure.
*/
stock int GetNearestSI(int client) 
{
	static float tpos[3], spos[3], dist, mindist;
	static int i, iNearClient;
	mindist = 0.0;
	iNearClient = 0;
	GetClientAbsOrigin(client, tpos);
	
	for (i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && GetClientTeam(i) == 3 && IsPlayerAlive(i) && IsFakeClient(i)) {
			GetClientAbsOrigin(i, spos);
			dist = GetVectorDistance(tpos, spos, false);
			if (dist < mindist || mindist < 0.1) {
				mindist = dist;
				iNearClient = i;
			}
		}
	}
	return iNearClient;
}

/*
 * Returns the nearest CI index.
 * @client		Client index.
 * @return		CI index or 0 on failure.
*/
stock int GetNearestCI(int client) 
{
	static float tpos[3], spos[3], dist, mindist;
	static iNearClient;
	mindist = 0.0;
	iNearClient = 0;
	GetClientAbsOrigin(client, tpos);
	
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "Infected")) != -1) {
		if (!IsValidEdict(ent) || !IsValidEntity(ent))
			continue;
		
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", spos);
		
		dist = GetVectorDistance(tpos, spos, false);
		if (dist < mindist || mindist < 0.1) {
			mindist = dist;
			iNearClient = ent;
		}
	}
	return iNearClient;
}

// FROM/CREDITS: https://forums.alliedmods.net/showthread.php?t=318466
/*
 * Calculates required velocity vectors to move to a specified location.
 * @client		client index
 * @flGoal		Goal vector position
 * @fVelocity	Pass Current velocity of client here
 * @fAng			Pass current angles of client here
*/
stock void L4D2_MoveToPos(int client, float flGoal[3], float fVelocity[3], float fAng[3])
{
	float flPos[3];
	GetClientAbsOrigin(client, flPos);
	
	float newmove[3];
	SubtractVectors(flGoal, flPos, newmove);
	
	newmove[1] = -newmove[1];
	
	float sin = Sine(fAng[1] * FLOAT_PI / 180.0);
	float cos = Cosine(fAng[1] * FLOAT_PI / 180.0);
	
	fVelocity[0] = cos * newmove[0] - sin * newmove[1];
	fVelocity[1] = sin * newmove[0] + cos * newmove[1];
	
	NormalizeVector(fVelocity, fVelocity);
	ScaleVector(fVelocity, 450.0);
}

/* 
 * Returns an accurate movement velocity like in cl_showpos.
 * @client		Client index.
 * @return		Current velocity.
*/
stock float GetAccurateMovementVelocity(int client)
{
	float fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
	return SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0));
}

// FROM/CREDITS: Drakogas
/*
 * Performs a smooth teleport in the eye view direction and sets view to a nearest survivor.
 * @client		Client index.
 * @distance	Distance value.
 * @jump_power	Jump velocity impulse.
 * @return		no return.
*/
stock bool TeleportPlayerSmooth(int client, float distance, float jump_power = 251.0)
{
	static float angle[3], dir[3], current[3], resulting[3], vecOrigin[3], vecTarget[3];
	
	static int iVelocity = 0;
	if (iVelocity == 0)
		iVelocity = FindSendPropInfo("CBasePlayer", "m_vecVelocity[0]");
		
	int iNear = GetNearestSurvivor(client);
	if (iNear != 0) {
		GetClientAbsOrigin(client, vecOrigin);
		GetClientAbsOrigin(iNear, vecTarget);
		GetVectorOrigins(vecOrigin, vecTarget, angle);
		TeleportEntity(client, NULL_VECTOR, angle, NULL_VECTOR);
	}
	
	GetClientEyeAngles(client, angle);
	
	GetAngleVectors(angle, dir, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(dir, distance);
	
	GetEntDataVector(client, iVelocity, current);
	resulting[0] = current[0] + dir[0];
	resulting[1] = current[1] + dir[1];
	resulting[2] = current[2] + jump_power;
	
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, resulting);
	return true;
}

// FROM/CREDITS: Drakogas
/*
 * Returns the angle to a vector position.
 * @vecClientPos		Vector location of subject.
 * @vecTargetPos		Vector location of target.
 * @ang		Angle buffer to store vector angles.
*/
stock void GetVectorOrigins(float vecClientPos[3], float vecTargetPos[3], float ang[3])
{
	static float v[3];
	SubtractVectors(vecTargetPos, vecClientPos, v);
	NormalizeVector(v, v);
	GetVectorAngles(v, ang);
}

/*
 * Returns the vector distance between subject and target client.
 * @client		Client index.
 * @target		Client index.
*/
stock float GetDistance(int client, int target)
{
	float vec1[3], vec2[3];
	GetClientAbsOrigin(client, vec1);
	GetClientAbsOrigin(target, vec2);
	return GetVectorDistance(vec1, vec2);
}

/*
 * Returns whether a SI is using it's ability.
 * @client		Client index.
 * @return		True if using ability false otherwise.
*/
stock bool IsAbilityInUse(int client)
{
	bool bAbilityInUse = false;
	if( GetEntProp(client, Prop_Send, "m_tongueVictim") > 0 ) 	bAbilityInUse = true;
	if( GetEntProp(client, Prop_Send, "m_pounceVictim") > 0 ) 	bAbilityInUse = true;
	if( GetEntProp(client, Prop_Send, "m_carryVictim") > 0 ) 	bAbilityInUse = true;
	if( GetEntProp(client, Prop_Send, "m_pummelVictim") > 0 ) 	bAbilityInUse = true;
	if( GetEntProp(client, Prop_Send, "m_jockeyVictim") > 0 ) 	bAbilityInUse = true;
	return bAbilityInUse;
}

/*
 * Returns whether a infected has a visible threat. Works for survivors too maybe.
 * @client		Client index.
 * @return		True if has visible threat false otherwise.
*/
stock bool HasVisibleThreats(int client)
{
	if (GetEntProp(client, Prop_Send, "m_hasVisibleThreats") > 0)
		return true;
	return false;
}

// FROM/CREDITS: Timocop alliedmodders forums.
/*
 * Runs a single line of vscript code. Always use this instead of "script" commands cause those leak badly.
 * @sCode		Vscript code to run.
 * @return		no return.
*/
stock void L4D2_RunScript(const char[] sCode, any:...)
{
	int iScriptLogic;
	if(iScriptLogic == INVALID_ENT_REFERENCE || !IsValidEntity(iScriptLogic)) {
		iScriptLogic = EntIndexToEntRef(CreateEntityByName("logic_script"));
		if(iScriptLogic == INVALID_ENT_REFERENCE || !IsValidEntity(iScriptLogic))
			SetFailState("Could not create 'logic_script'");
		
		DispatchSpawn(iScriptLogic);
	}
	
	static char sBuffer[512];
	VFormat(sBuffer, sizeof(sBuffer), sCode, 2);
	
	SetVariantString(sBuffer);
	AcceptEntityInput(iScriptLogic, "RunScriptCode");
}

/*
 * Sets a glow effect on a entity for the specified duration.
 * @entity		Entity index.
 * @color		RGB values for the color desired.
 * @duration	Duration of the glow.
 * @return		no return.
*/
stock void ApplyHighlightGlow(int client, int color[3], float duration = 1.0)
{
	SetEntityGlowColor(client, color);
	CreateTimer(duration, Timer_RemoveGlow, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_RemoveGlow(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	ClearGlow(client);
}

stock void SetEntityGlowColor(int entity, int colorOverride[3])
{
	SetEntProp(entity, Prop_Send, "m_iGlowType", 3);
	SetEntProp(entity, Prop_Send, "m_glowColorOverride", colorOverride[0] + (colorOverride[1] * 256) + (colorOverride[2] * 65536));
}

stock void ClearGlow(int entity)
{
	SetEntProp(entity, Prop_Send, "m_iGlowType", 0);
	SetEntProp(entity, Prop_Send, "m_glowColorOverride", 0);
}

/*
 * Sends a CommandABot table vscript input for a specified client.
 * @client		Client index.
 * @cmd			Command type BOT_CMD_ATTACK etc enumerations above.
 * @target		Target entity index. NOTE: only used for BOT_CMD_ATTACK and BOT_CMD_RETREAT.
 * @vecPos		Target vector position to move to. NOTE: only used for BOT_CMD_MOVE and this has dev type of pathfollowing the SI wont react to any threats while this is sent initially.
*/
stock void CommandABot(int client, int cmd, int target = 0, const float vecPos[3] = {0.0, 0.0, 0.0})
{
	switch (cmd)
	{
		case BOT_CMD_ATTACK:
		{
			L4D2_RunScript("CommandABot( {cmd=0, bot=GetPlayerFromUserID(%i), target=GetPlayerFromUserID(%i)} )", GetClientUserId(client), GetClientUserId(target));
		}
		case BOT_CMD_MOVE:
		{
			L4D2_RunScript("CommandABot( {cmd=1, bot=GetPlayerFromUserID(%i), pos=Vector(%f,%f,%f)} )", GetClientUserId(client), vecPos[0], vecPos[1], vecPos[2]);
		}
		case BOT_CMD_RETREAT:
		{
			L4D2_RunScript("CommandABot( {cmd=2, bot=GetPlayerFromUserID(%i), target=GetPlayerFromUserID(%i)} )", GetClientUserId(client), GetClientUserId(target));
		}
		case BOT_CMD_RESET:
		{
			L4D2_RunScript("CommandABot( {cmd=3, bot=GetPlayerFromUserID(%i)} )", GetClientUserId(client));
		}
	}	
}

/*
 * Returns whether a SI is in a idle anim sequence currently.
 * @client		Client index.
 * @return		True if in idle sequence false otherwise.
*/
stock bool InIdleSequence(int client)
{
	int seq = GetEntProp(client, Prop_Send, "m_nSequence");
	
	char mdl[64];
	GetEntPropString(client, Prop_Data, "m_ModelName", mdl, sizeof(mdl));
	
	// TODO: ADD boomette on this list!!
	if (StrContains(mdl, "charger") != -1)
	{
		if (seq == 2 || seq == 3)
			return true;
	}
	else if (StrContains(mdl, "hunter") != -1)
	{
		if (seq == 2 || seq == 3 || seq == 4 || seq == 5)
			return true;
	}
	else if (StrContains(mdl, "smoker") != -1)
	{
		if (seq == 2 || seq == 3 || seq == 4)
			return true;
	}
	else if (StrContains(mdl, "boomer") != -1)
	{
		if (seq == 2 || seq == 3 || seq == 4)
			return true;
	}
	else if (StrContains(mdl, "jockey") != -1)
	{
		if (seq == 2 || seq == 3)
			return true;
	}
	else if (StrContains(mdl, "spitter") != -1)
	{
		if (seq == 2 || seq == 3)
			return true;
	}
	return false;
}

// FROM/CREDITS: khan
/*
 * Returns whether a player is staggering/stumbling.
 * @client		Client index.
 * @return		True if staggering false otherwise.
*/
stock bool IsStaggering(int client)
{
	float vec[3];
	GetEntPropVector(client, Prop_Send, "m_staggerStart", vec);
	if (vec[0] != 0.000000 || vec[1] != 0.000000 || vec[2] != 0.000000)
	{
		return true;
	}
	return false;
}

/*
 * Returns whether a SI/survivor is stuck in collision and can't move possibly. Beats performing a trace ray operation.
 * @client		Client index.
 * @return		True if stuck in collision false otherwise.
*/
stock bool IsStuckInCollision(int client)
{
	if (GetEntProp(client, Prop_Data, "m_StuckLast") > 0)
		return true;
	return false;
}

/*
 * Sets a players 'lagged' movement speed.
 * @client		Client index.
 * @val			Speed.
 * @return		no return.
*/
stock void SetLaggedMovementSpeed(int client, float val = 1.0)
{
	SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", val);
}

/*
 * Tells all existing NextBots to start assault. 
*/
stock void L4D2_StartAssault()
{
	L4D2_RunScript("StartAssault()");
}

/*
 * Slays all living special infected.
 * @return		no return.
*/
stock void SlayAllSpecials()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))continue;
		if (GetClientTeam(i) == TEAM_INFECTED && IsPlayerAlive(i))
			ForcePlayerSuicide(i);
	}
}

/*
 * Allows to call most cheat flagged commands.
 * @client		Client index.
 * @command		Command name.
 * @argument	Command arguments.
*/
stock void CheatCommand(int client, const char[] command, const char[] argument)
{
	int iflags = GetCommandFlags(command);
	SetCommandFlags(command, iflags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, argument);
	SetCommandFlags(command, iflags);
}

// TODO: Improve.
/*
 * Checks for current velocity and animation seq of an SI to determine if moving currently.
 * @client		Client index.
 * @return		True if not moving false otherwise.
*/
stock bool IsNotMoving(int client)
{
	if (InIdleSequence(client) && (GetAccurateMovementVelocity(client) < 40.0))
		return true;
	return false;
}

/*
 * Returns true if is survival mode.
*/
stock bool IsSurvival()
{
	char sGameMode[16];
	GetConVarString(FindConVar("mp_gamemode"), sGameMode, sizeof(sGameMode));
	return (StrEqual(sGameMode, "survival"));
}

/*
 * Returns true if is coop mode.
*/
stock bool IsCoop()
{
	char sGameMode[16];
	GetConVarString(FindConVar("mp_gamemode"), sGameMode, sizeof(sGameMode));
	return (StrEqual(sGameMode, "coop") || StrEqual(sGameMode, "realism"));
}

/*
 * Perform a trace from eye view to check if a entity is visible.
 * @client		Client index.
 * @entity		Entity index.
*/
stock bool IsVisibleTo(int client, int entity)
{
	float vAngles[3], vOrigin[3], vEnt[3], vLookAt[3];
	
	GetClientEyePosition(client, vOrigin);
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vEnt);
	
	MakeVectorFromPoints(vOrigin, vEnt, vLookAt); // compute vector from player to zombie
	GetVectorAngles(vLookAt, vAngles); // get angles from vector for trace
	
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceFilter);
	
	bool isVisible = false;
	if (TR_DidHit(trace))
	{
		float vStart[3];
		TR_GetEndPosition(vStart, trace); // retrieve our trace endpoint
		
		if ((GetVectorDistance(vOrigin, vStart, false) + 75.0) >= GetVectorDistance(vOrigin, vEnt))
		{
			isVisible = true; // if trace ray lenght plus tolerance equal or bigger absolute distance, you hit the targeted zombie
		}
	}
	else
		isVisible = true;
	delete trace;
	return isVisible;
}

public bool TraceFilter(int entity, int contentsMask)
{
	if (entity <= MaxClients || !IsValidEntity(entity)) // dont let WORLD, players, or invalid entities be hit
		return false;
	char class[64];
	GetEdictClassname(entity, class, sizeof(class)); // Ignore prop_physics since some can be seen through
	return !StrEqual(class, "prop_physics", false);
}

/*
 * True if the client is a root admin, false otherwise.
 * @client - client index.
*/
stock bool IsClientRootAdmin(int client)
{
    return ((GetUserFlagBits(client) & ADMFLAG_ROOT) != 0);
}

/*
 * Returns the real player count on the server, no bots. all teams.
 * @return - The real player count on the server.
*/
stock int GetRealPlayerCount()
{
	int count;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientConnected(i))continue;
		
		if (GetClientTeam(i) == 2 || GetClientTeam(i) == 1 || GetClientTeam(i) == 3)
		{
			if (IsFakeClient(i))
				continue;
				
			count++;
		}
	}
	return count;
}