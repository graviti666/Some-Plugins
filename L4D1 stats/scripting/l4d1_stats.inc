/*
** Forwards & Natives from l4d1_stats.smx
*/
#if defined _l4d1_stats_included
 #endinput
#endif
#define _l4d1_stats_included

/*
 * @return: true whether a survival round is in-progress false otherwise.
*/
native bool IsSurvivalInProgress();

/*
 * @param - SI client index.
 * @return - Living time in seconds.
*/
native int SICurrentAliveTime(int client);

/*
 * @return: current SI/min rate.
*/
native int CurrentSIrate();

/*
 * Called when a survival round starts.
*/
forward void OnSurvivalRoundStart();