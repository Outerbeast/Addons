/* Gordon MOTD Welcome Animation
Plays dancing Gordon animation with welcome message in your selected maps
Edit GordonMotd_conf to customise the model and music played

Model by: ra4fhe
Original AMXX plugin by: KORD_12.7

Installation:-
Put the script in scripts/plugins and then
add this to your default_plugins.txt

	"plugin"
 	{
        "name" "GordonMotd"
		"script" "GordonMotd"
	}

How to customise your welcome model:
- Make a 512x512 8bit image with a black background and design your welcome message. Name it v2.bmp.
- Make a copy of "gordon_motd_base.mdl" and name to it to anything you prefer
- Using a tool like Half-Life Asset Manager, open the model and go to the Textures tab then select the v2.bmp texture
- Import your custom v2.bmp you made from earlier and then save the model
- Add this new model to your GordonMotd_conf file
*/

#include "GordonMotd_conf"

bool blMusicEnabled, blMusicTriggered, blWelcomeEnabled;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Outerbeast" );
	g_Module.ScriptInfo.SetContactInfo( "svencoopedia.fandom.com" );

	g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, DrawGordonAnimation );
}

void MapInit()
{
	const array<string> LOBBY_MAPS = strLobbyMaps.Split( ";" );

	if( LOBBY_MAPS.find( string( g_Engine.mapname ) ) >= 0 )
	{
		if( strWelcomeMusic != "" )
		{
			g_SoundSystem.PrecacheSound( strWelcomeMusic );
			g_Game.PrecacheGeneric( strWelcomeMusic );

			blMusicEnabled = true;
			blMusicTriggered = false;
		}

		if( strWelcomeModel != "" )
		{
			g_Game.PrecacheModel( strWelcomeModel );
			g_Game.PrecacheGeneric( strWelcomeModel );

			blWelcomeEnabled = true;
		}
	}
	else
		blMusicEnabled = blMusicTriggered = blWelcomeEnabled = false;
}

void MapActivate()
{
	if( !blMusicEnabled )
		return;

	dictionary music =
	{
		{ "targetname", "welkum_muzak" },
		{ "message", "" + strWelcomeMusic },
		{ "volume", "" + flMusicVolume },
		{ "spawnflags", "3" }
	};
	
	g_EntityFuncs.CreateEntity( "ambient_music", music, true );
}

HookReturnCode DrawGordonAnimation(CBasePlayer@ pPlayer)
{
	if( pPlayer is null )
		return HOOK_CONTINUE;
	// !-BUG-!: Modifying player rendermodes affects the model rendering for textures, which is set to additive. Causes glass lens and message texture backgrounds to draw!
	if( blWelcomeEnabled && pPlayer.pev.viewmodel != strWelcomeModel )
		pPlayer.pev.viewmodel = strWelcomeModel;

	if( blMusicEnabled && !blMusicTriggered )
	{
		g_EntityFuncs.FireTargets( "welkum_muzak", pPlayer, pPlayer, USE_ON, 0.0f, 0.5f );
		blMusicTriggered = true;
	}

	return HOOK_CONTINUE;
}
