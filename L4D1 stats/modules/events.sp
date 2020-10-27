/*==============================================
				Events - module
===============================================*/

public void Event_OnPlayerHurtConcise(Event event, const char[] name, bool dontBroadcast)
{
	int attacker = event.GetInt("attackerentid");
	int victim = GetClientOfUserId(event.GetInt("userid"));
	
	// Isnt valid survivors or ingame.
	if (!IsSurvivor(attacker) || !IsSurvivor(victim))
	{
		return;
	}
	
	// Damage done to health
	int damage = event.GetInt("dmg_health");
	
	// Time to cache damage dealt by attacker to victim user, if the dmg isnt self-inflicted
	if( victim != attacker )
	{
		g_iDamageCache[attacker][victim] += damage;
		g_iDmgTotal[attacker] += damage;
		g_iDmgTotalCache += damage;
		g_iDmgReceivedTotal[victim] += damage;
	}
}

public void Event_OnPlayerHealed(Event event, const char[] name, bool dontBroadcast)
{	
	int client = GetClientOfUserId(event.GetInt("subject"));
	
	if (!g_bRoundProgress)
		return;
	
	if (client && IsClientInGame(client) && GetClientTeam(client) == 2)
	{
		g_iKitsUsedClient[client]++;
		g_iKitsTotalUsed++;
	}
}

public void Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client && IsClientInGame(client) && GetClientTeam(client) == 3 && GetEntProp(client, Prop_Send, "m_zombieClass") != ZC_TANK && GetEntProp(client, Prop_Send, "m_zombieClass") != ZC_WITCH)
	{
		g_iSpawnTime[client] = GetTime();
	}
}

public void Event_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	
	if (victim > 0)
	{
		g_iSpawnTime[victim] = 0;
	}
	
	if (victim && attacker && IsClientInGame(victim) && IsClientInGame(attacker) && GetClientTeam(victim) == 3 && GetClientTeam(attacker) == 2)
	{
		int zc = GetEntProp(victim, Prop_Send, "m_zombieClass");
		switch (zc)
		{
			case ZC_SMOKER:
			{
				g_iKills[attacker][SI] += 1;
				g_iGlobalKills[SI] += 1;
				
				g_iSIKillsType[SMOKER] += 1;
			}
			case ZC_BOOMER:
			{
				g_iKills[attacker][SI] += 1;
				g_iGlobalKills[SI] += 1;
				
				g_iSIKillsType[BOOMER] += 1;
			}
			case ZC_HUNTER:
			{
				g_iKills[attacker][SI] += 1;
				g_iGlobalKills[SI] += 1;
				
				g_iSIKillsType[HUNTER] += 1;
			}
			case ZC_TANK:
			{
				g_iGlobalKills[TANK] += 1;
			}
		}
	}
}

public void Event_OnInfectedDeath(Event event, const char[] name, bool dontBroadcast)
{
	if (g_bRoundProgress)
	{
		int attacker = GetClientOfUserId(event.GetInt("attacker"));
		if (attacker && IsClientInGame(attacker) && GetClientTeam(attacker) == 2)
		{
			g_iKills[attacker][CI] += 1;
			g_iGlobalKills[CI] += 1;
		}		
	}
}

public Action Event_PlayerHurt(Event hEvent, const char[] name, bool dontBroadcast)
{
	int victim = GetClientOfUserId( GetEventInt(hEvent, "userid") );
	int attacker = GetClientOfUserId( GetEventInt(hEvent, "attacker") );
	
	if (!IS_VALID_INFECTED(victim)) return Plugin_Continue;
	
	int zClass = GetEntProp(victim, Prop_Send, "m_zombieClass");
	switch (zClass)
	{
		case ZC_TANK:
		{
			if (IS_VALID_SURVIVOR(attacker))
			{
				// Track how much damage the survivor did to the tank
				int dmg = GetEventInt(hEvent, "dmg_health");
				
				g_iTankDamage[attacker] += dmg;
				g_iTankDamageTotal += dmg;
			}
		}	
	}
	return Plugin_Continue;
}

public void Event_OnSurvivalStart(Event event, const char[] name, bool dontBroadcast)
{	
	if (!g_bRoundProgress)
	{
		#if DEBUG
		PrintToChatAll("starting survival timer.");
		#endif
		
		g_bRoundProgress = true;
	
		g_iSurvivalTime = GetTime();
		
		ResetStatsArrays();
		ResetHealthArrays();
		ResetFFArrays();
		
		char sHostNameFormat[64];
		FormatEx(sHostNameFormat, sizeof(sHostNameFormat), "%s - Round starting..", g_sOriginalHostName);
		SetConVarString(convar_hostname, sHostNameFormat);
		
		g_iTimeTick = 0;
		g_hTimer = CreateTimer(60.0, Timer_UpdateHostname, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	}
}

public Action Timer_UpdateHostname(Handle timer)
{
	if (g_bRoundProgress)
	{
		g_iTimeTick++;
		
		float SIrate = GetRatePerMinute(g_iGlobalKills[SI]);
		
		char sHostNameFormat[64];
		FormatEx(sHostNameFormat, sizeof(sHostNameFormat), "%s | %im (%.2f SI/min - %i killed)", g_sOriginalHostName, g_iTimeTick, SIrate, g_iGlobalKills[SI]);
		SetConVarString(convar_hostname, sHostNameFormat);
	}
	return Plugin_Continue;
}

public void Event_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{	
	if (g_bRoundProgress)
	{
		delete g_hTimer;
		
		g_bRoundProgress = false;
		g_iRoundEndTime = GetTime() - g_iSurvivalTime;
		
		StatsDisplay(-1);
		
		SetConVarString(convar_hostname, g_sOriginalHostName);
		
		#if DEBUG
		PrintToChatAll("survival time is %is", g_iRoundEndTime);
		#endif
	}
}