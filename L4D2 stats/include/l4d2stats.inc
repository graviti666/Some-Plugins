#if defined __l4d2_stat_tracker_inc__
#endinput
#endif
#define __l4d2_stat_tracker_inc__

enum
{
	STAT_CLIENT = 0,							// Client ID that these stats apply to
	STAT_SI_TOTAL,							// Total SI kills
	STAT_SI_RATE,							// SI kills per minute for this survivor
	STAT_SI_PERCENTAGE,					// Percentage of total SI killed
	STAT_SI_BOOMER,							// Number of boomers killed
	STAT_SI_SMOKER,							// Number of smokers killed
	STAT_SI_HUNTER,							// Number of hunters killed
	STAT_SI_JOCKEY,							// Number of jockies killed
	STAT_SI_CHARGER,						// Number of chargers killed
	STAT_SI_SPITTER,						// Number of spitters killed
	STAT_COMMON_TOTAL,						// Number of common killed
	STAT_COMMON_RATE,						// Common kills per minute for this survivor
	STAT_COMMON_PERCENTAGE,				// Percentage of total common killed
	STAT_TANK_DAMAGE,						// Amount of tank damage done
	STAT_TANK_PERCENTAGE,					// Percentage of tank damage
	STAT_ACC_PERCENTAGE,					// Survivors accuracy
	STAT_ACC_SHOTS_FIRED,					// Total number of shots fired
	STAT_ACC_SHOTS_LANDED,				// Total number of shots landed
	STAT_ACC_HEADSHOT_PERCENTAGE,		// Headshot percentage
	STAT_ACC_HEADSHOT_COUNTS,			// Total headshots landed
	STAT_ACC_SI_HEADSHOT_PERCENTAGE,	// Percentage of shots that landed on an SI that were headshots
	STAT_ACC_SI_HEADSHOT_COUNT,			// Total number of headshots on SI
	STAT_ACC_SI_SHOTS_LANDED,			// Total number of shots landed on SI
	STAT_FF_TAKEN,							// Friendly fire damage taken
	STAT_FF_GIVEN,							// Friendly fire damage given
	STAT_MAX_STATS
}

enum
{
	STAT_TEAM_TOTALSI,						// Total number of SI killed
	STAT_TEAM_SI_RATE,						// Total SI kills per minute
	STAT_TEAM_BOOMER,						// Number of boomers killed
	STAT_TEAM_SMOKER,						// Number of smokers killed
	STAT_TEAM_HUNTER,						// Number of hunters killed
	STAT_TEAM_JOCKEY,						// Number of jockies killed
	STAT_TEAM_CHARGER,						// Number of chargers killed
	STAT_TEAM_SPITTER,						// Number of spitters killed
	STAT_TEAM_COMMON,						// Number of common killed
	STAT_TEAM_COMMON_RATE,				// Total number of common killed per minute
	STAT_TEAM_TANK,							// Number of tanks killed
	STAT_TEAM_TANK_RATE,					// Total number of tanks killed per minute
	STAT_TEAM_TANK_DAMAGE,				// Total damage done to tanks
	STAT_TEAM_MAX_STATS
}

/**
 * Retrieves the survival stats for a specific steam ID. Returns the data in an array of length STAT_MAX_STATS.
 * The array will only contain a single entry (index '0') that contains all the data for the client.
 * 
 * Example:
 * 		Handle hStats = L4D2Stat_GetClientStats(sSteamID);
 *		if (hStats != INVALID_HANDLE && GetArraySize(hStats) > 0)
 *		{
 *			int siTotal = GetArrayCell(hStats, 0, STAT_SI_TOTAL);
 *			...
 *			CloseHandle(hStats);
 *		}
 
 * @param steamID 	Steam ID of the client that you want to retrieve stats for
 * @returns			Handle containing an array of length STAT_MAX_STATS with all the various stats for the client
 */
native Handle L4D2Stat_GetClientStats(const char[] steamID);

/**
 * Retrieves the survival stats for all the current survivor clients in the game. Returns an array of length
 * STAT_MAX_STATS that contains an entry for each survivor.
 * 
 * @returns			Handle containing an array of length STAT_MAX_STATS with all the survival stats for each survivor
 */
native Handle L4D2Stat_GetAllSurvivorStats();

/**
 * Retrieves the overall survival stats for the team. Returns the data in an array of length STAT_TEAM_MAX_STATS.
 * The array will only contain a single entry (index '0') that contains all the data for the team.
 * 
 * Example:
 *		Handle hTeamStats = L4D2Stat_GetTeamStats();
 *		if (hTeamStats != INVALID_HANDLE && GetArraySize(hTeamStats) > 0)
 *		{
 *			int siTotal = GetArrayCell(hTeamStats, 0, STAT_TEAM_TOTALSI);
 *			...
 *			CloseHandle(hTeamStats);
 *		}
 *	
 * @returns			Handle containing an array of length STAT_TEAM_MAX_STATS with all the various stats for the team
 */
native Handle L4D2Stat_GetTeamStats();

