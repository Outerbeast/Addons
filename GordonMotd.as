/* Gordon MOTD Welcome Animation
Plays dancing Gordon animation with welcome message in your selected maps
Edit GordonMotd_conf to customise the model and music played

Model by: ra4fhe
Original AMXX plugin by: KORD_12.7

Installation:-
Put the script in screipts/plugins and then
add this to your default_plugins.txt

	"plugin"
 	{
        	"name" "GordonMotd"
		"script" "GordonMotd"
	}
*/

#include "GordonMotd_conf"

bool blMusicEnabled;
bool blMusicTriggered;
bool blWelcomeEnabled;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Outerbeast" );
	g_Module.ScriptInfo.SetContactInfo( "svencoopedia.fandom.com" );

	g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @DrawGordonAnimation );
}

void MapInit()
{
	if( LOBBY_MAPS.find( string( g_Engine.mapname ) ) >= 0 )
	{
		if( strWelcomeMusic != "" )
		{
			g_SoundSystem.PrecacheSound( strWelcomeMusic );
			blMusicEnabled = true;
			blMusicTriggered = false;
		}

		if( strWelcomeModel != "" )
		{
			g_Game.PrecacheModel( strWelcomeModel );
			blWelcomeEnabled = true;
		}
	}
	else
	{
		blMusicEnabled = false;
		blWelcomeEnabled = false;
	}
}

HookReturnCode DrawGordonAnimation(CBasePlayer@ pPlayer)
{
	if( pPlayer !is null )
	{
		pPlayer.pev.viewmodel = strWelcomeModel;

		if( blMusicEnabled && !blMusicTriggered )
		{
			g_Scheduler.SetTimeout( "PlayMusic", 0.1 );
		}
	}
	return HOOK_CONTINUE;
}

void PlayMusic()
{
	CBaseEntity@ pWorld = null;
	if( ( @pWorld = g_EntityFuncs.Instance( 0 ) ) !is null )
	{
		g_SoundSystem.PlaySound( pWorld.edict(), CHAN_MUSIC, strWelcomeMusic, flMusicVolume, ATTN_NONE );
		blMusicTriggered = true;
	}
}
