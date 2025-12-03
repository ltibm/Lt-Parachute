array<CBaseEntity@> prcEnts(33);
CCVar@ cvar_Enabled;
CCVar@ cvar_AdminOnly;
CCVar@ cvar_PRCOnly;
CCVar@ cvar_ShowModel;
const Cvar@ cvar_AdminOnlyEx;
const string model = "models/parachute.mdl";
void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Lt." );
	g_Module.ScriptInfo.SetContactInfo( "https://steamcommunity.com/id/ibmlt" );
	g_Hooks.RegisterHook( Hooks::Player::PlayerPreThink, @PlPreThink );
	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @PlPutinServer );
	g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );
	g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
	@cvar_Enabled = CCVar("prc_enabled", 1, "Enable or Disable Parachute", ConCommandFlag::AdminOnly);
	@cvar_AdminOnly = CCVar("prc_adminonly", 0, "Set 1 if only used Admins.", ConCommandFlag::AdminOnly);
	@cvar_PRCOnly = CCVar("prc_prconly", 0, "Set 1 if only used mj values is true", ConCommandFlag::AdminOnly);
	@cvar_ShowModel  = CCVar("prc_showmodel", 1, "Enabled or Disable show parachute model", ConCommandFlag::AdminOnly);
	g_Scheduler.SetTimeout("MapActivate", 1.0);
}
void MapInit()
{
	g_Game.PrecacheModel( model );
}
void MapActivate()
{
	@cvar_AdminOnlyEx = g_EngineFuncs.CVarGetPointer("lt_parachute_admin_only");
}
HookReturnCode MapChange(const string& in szNextMap)
{
	RemoveAllEntities();
	return HOOK_CONTINUE;
}
void RemoveAllEntities()
{
	for(uint i = 0; i < prcEnts.length(); i++)
	{
		RemoveEntity(i);

	}
}
void RemoveEntity(uint index)
{
	if(prcEnts[index] !is null)
	{
		g_EntityFuncs.Remove(@prcEnts[index]);
		@prcEnts[index] = null;
	}
}
HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
{
	KeyValueBuffer@ nPysc = g_EngineFuncs.GetPhysicsKeyBuffer(pPlayer.edict());
	nPysc.SetValue("sprc", "0");
	RemoveEntity(pPlayer.entindex());
	return HOOK_CONTINUE;
}
float getAdminCvar()
{
	if(cvar_AdminOnlyEx is null)
	{
		return cvar_AdminOnly.GetFloat();
	}
	return cvar_AdminOnlyEx.value;
}
bool PluginAccessible(CBasePlayer@ cPlayer)
{
	if(cvar_Enabled.GetInt() == 0 || cPlayer is null || !cPlayer.IsConnected() || !cPlayer.IsAlive()) return false;
	float advalue = getAdminCvar();
	KeyValueBuffer@ nPysc = g_EngineFuncs.GetPhysicsKeyBuffer(cPlayer.edict());
	if(advalue == 1)
	{
		if(g_PlayerFuncs.AdminLevel(@cPlayer) <= 0) return false;
	}	
	else if(advalue == 2)
	{
		string cVal = nPysc.GetValue("xp_sadmn");
		if(atoi(cVal) <= 0) return false;
	}
	if(cvar_PRCOnly.GetInt() == 1)
	{
		string cVal = nPysc.GetValue("sprc");
		if(cVal != "1") return false;
	}
	return true;
}
void ParachuteCmd(CBasePlayer@ nPlayer)
{
	if(g_Engine.time <= 2.0 || !nPlayer.IsAlive()) return;
	string cVal = "1";
	int id = nPlayer.entindex();
	if(cVal == "1")
	{	
		Vector fVelocity = nPlayer.pev.velocity;
		if((nPlayer.pev.button & IN_USE) == IN_USE && (nPlayer.pev.flags & FL_ONGROUND) != FL_ONGROUND && fVelocity.z < 0.0)
		{
			if(cvar_ShowModel.GetInt() > 0)
			{
				if(prcEnts[id] is null)
				{
					@prcEnts[id] = @g_EntityFuncs.CreateEntity("info_target");
					if(prcEnts[id] !is null)
					{
						g_EntityFuncs.SetModel(@prcEnts[id], model);
						prcEnts[id].pev.movetype = MOVETYPE_FOLLOW;
						@prcEnts[id].pev.aiment = @nPlayer.edict();
					}
				}
			}

			fVelocity.z = ((fVelocity.z + 40.0 < -100) ? fVelocity.z + 40.0 : -100.0);
			nPlayer.pev.velocity = fVelocity;
			if(cvar_ShowModel.GetInt() > 0)
			{
				if(prcEnts[id].pev.frame < 0 || prcEnts[id].pev.frame > 254)
				{
					if(prcEnts[id].pev.sequence != 1) prcEnts[id].pev.sequence = 1;
					prcEnts[id].pev.frame = 0.0;
				}
				else
				{
					prcEnts[id].pev.frame += 1.0;
				}
			}

		}
		else// if((nPlayer.pev.oldbuttons & IN_USE) == IN_USE)
		{
			RemoveEntity(id);
		}
	}
}
HookReturnCode PlPreThink(CBasePlayer@ cPlayer, uint& out outvar)
{
	if(!PluginAccessible(cPlayer))
	{
		return HOOK_CONTINUE;
	}
	ParachuteCmd(cPlayer);
	return HOOK_CONTINUE;
}
HookReturnCode PlPutinServer( CBasePlayer@ pPlayer )
{
	RemoveEntity(pPlayer.entindex());
	return HOOK_CONTINUE;
}
