/* Gordon MOTD Welcome Animation
by Outerbeast
Plays dancing Gordon animation with welcome message in your selected maps

Original Gordong model by: ra4fhe
Original AMXX plugin by: KORD_12.7
Holiday related models created by: Gauna and Garompa

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
- Add this new model to your gordon_motd.cfg file using "welcome_mdl" cvar

CVars for gordon_motd.cfg:
- lobby_maps: Semicolon seperate list of lobby maps to enable the welcome animation
- welcome_mdl: Default welcome animation mdl
- welcome_mdl_easter: Welcome animation mdl to use for easter
- welcome_mdl_halloween: Welcome animation mdl to use for halloween
- welcome_mdl_xmas: Welcome animation mdl to use for christmas
- music: lobby music to play. Default is "problems_with_bass.ogg"
- music_volume: Sets the volume for the lobby music. Default is 10. Set to "0" to disable music.
*/
dictionary dictWelcomeCVars;
array<string> STR_LOBBY_MAPS;
string strConfigFile = "scripts/plugins/store/gordon_motd.cfg",
	strWelcomeMusic,
	strWelcomeAnim,
	strWelcomeAnim_XMas,
	strWelcomeAnim_Halloween, 
	strWelcomeAnim_Easter, 
	strWelcomeAnim_Current;

float flMusicVolume = 10.0f;
bool blMusicEnabled, blMusicTriggered, blWelcomeEnabled;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Outerbeast" );
	g_Module.ScriptInfo.SetContactInfo( "svencoopedia.fandom.com" );
}

void MapInit()
{
	SetDefaults();// Don't want persistent vars between map changes
	Config();

	if( STR_LOBBY_MAPS.length() < 1 )
		return;

	if( STR_LOBBY_MAPS.find( string( g_Engine.mapname ) ) >= 0 )
	{
		if( strWelcomeMusic != "" && flMusicVolume > 0.0f )
		{
			g_SoundSystem.PrecacheSound( strWelcomeMusic );
			g_Game.PrecacheGeneric( strWelcomeMusic );

			blMusicEnabled = true;
			blMusicTriggered = false;
		}

		if( strWelcomeAnim_Current != "" )
		{
			g_Game.PrecacheModel( strWelcomeAnim_Current );
			g_Game.PrecacheGeneric( strWelcomeAnim_Current );

			blWelcomeEnabled = true;
		}
	}
	else
		blMusicEnabled = blMusicTriggered = blWelcomeEnabled = false;


	if( blWelcomeEnabled )
	{
		g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, DrawGordonAnimation );
		g_Hooks.RegisterHook( Hooks::Player::PlayerUse, PlayerUse );
		g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, PlayerLeave );
	}

	if( blMusicEnabled )
	{
		dictionary music =
		{
			{ "targetname", "welkum_muzak" },
			{ "message", strWelcomeMusic },
			{ "volume", "" + flMusicVolume },
			{ "spawnflags", "3" }
		};

		g_EntityFuncs.CreateEntity( "ambient_music", music, true );
	}
}

string CurrentAnimation()
{
	switch( DateTime().GetMonth() )
	{
		case 4:
			return strWelcomeAnim_Easter;
		case 10:
			return strWelcomeAnim_Halloween;
		case 12:
			return strWelcomeAnim_XMas;
		default:
			return strWelcomeAnim;
	}

	return strWelcomeAnim;
}

void SetDefaults()
{
	STR_LOBBY_MAPS = 
	{
		"-sp_campaign_portal",
		"dynamic_mapvote",
		"hl_lobby",
		"hl_mapvote",
		"th_lobby",
		"rust_lobby",
		"rsvm_v3b",
		"sc_votemap"
	};

	strWelcomeMusic				= "gordon_motd/problems_with_bass.ogg";
	strWelcomeAnim        		= "models/gordon_motd/gordon_motd.mdl";
	strWelcomeAnim_XMas    		= "models/gordon_motd/gordon_xmas_motd.mdl";
	strWelcomeAnim_Halloween	= "models/gordon_motd/gordon_hween_motd.mdl";
	strWelcomeAnim_Easter		= "models/gordon_motd/gordon_eegg_motd.mdl";

	blMusicEnabled = blMusicTriggered = blWelcomeEnabled = false;
}

void Config()
{
	File@ fileCfg = g_FileSystem.OpenFile( strConfigFile, OpenFile::READ );

	if( fileCfg is null || !fileCfg.IsOpen() )
		return;

	while( !fileCfg.EOFReached() )
	{
		string strCurrentLine;
		fileCfg.ReadLine( strCurrentLine );

		if( strCurrentLine.SubString( 0, 1 ) == "#" || strCurrentLine.IsEmpty() )
			continue;

		array<string> parsed = strCurrentLine.Split( " " );

		if( parsed.length() < 2 )
			continue;

		dictWelcomeCVars[parsed[0]] = parsed[1];
	}

	fileCfg.Close();

	array<string> STR_CVARS_KEYS = dictWelcomeCVars.getKeys();
	STR_CVARS_KEYS.sortAsc();

	for( uint i = 0; i < STR_CVARS_KEYS.length(); ++i )
	{
		if( STR_CVARS_KEYS[i] == "" )
			continue;

		string strCVarValue;
		dictWelcomeCVars.get( STR_CVARS_KEYS[i], strCVarValue );

		if( strCVarValue == "" || strCVarValue == "disable" )
			continue;

		if( STR_CVARS_KEYS[i] == "lobby_maps" )
			STR_LOBBY_MAPS = strCVarValue.Split( ";" );
		else if( STR_CVARS_KEYS[i] == "welcome_mdl" )
			strWelcomeAnim = strCVarValue;
		else if( STR_CVARS_KEYS[i] == "welcome_mdl_halloween" )
			strWelcomeAnim_Halloween = strCVarValue;
		else if( STR_CVARS_KEYS[i] == "welcome_mdl_xmas" )
			strWelcomeAnim_XMas = strCVarValue;
		else if( STR_CVARS_KEYS[i] == "welcome_mdl_easter" )
			strWelcomeAnim_Easter = strCVarValue;
		else if( STR_CVARS_KEYS[i] == "music" )
			strWelcomeMusic = strCVarValue;
		else if( STR_CVARS_KEYS[i] == "music_volume" )
			flMusicVolume = atof( strCVarValue );
	}

	strWelcomeAnim_Current = CurrentAnimation();
}

bool OpenGordonAnimation(EHandle hPlayer)
{
	if( !hPlayer )
		return false;

	CBasePlayer@ pPlayer = cast<CBasePlayer@>( hPlayer.GetEntity() );

	if( pPlayer is null )
		return false;

	// !-BUG-!: Modifying player rendermodes affects the model rendering for textures, which is set to additive. Causes glass lens and message texture backgrounds to draw!
	if( blWelcomeEnabled && pPlayer.pev.viewmodel != strWelcomeAnim_Current )
		pPlayer.pev.viewmodel = strWelcomeAnim_Current;

	return pPlayer.pev.viewmodel == strWelcomeAnim_Current;
}

bool CloseGordonAnimation(EHandle hPlayer)
{
	if( !hPlayer )
		return false;

	CBasePlayer@ pPlayer = cast<CBasePlayer@>( hPlayer.GetEntity() );

	if( pPlayer is null )
		return false;

	if( pPlayer.pev.viewmodel == strWelcomeAnim_Current )
		pPlayer.pev.viewmodel = "";

	return pPlayer.pev.viewmodel != strWelcomeAnim_Current;
}

HookReturnCode DrawGordonAnimation(CBasePlayer@ pPlayer)
{
	if( pPlayer is null || !pPlayer.IsConnected() )
		return HOOK_CONTINUE;

	OpenGordonAnimation( pPlayer );

	if( blMusicEnabled && !blMusicTriggered )
	{
		g_EntityFuncs.FireTargets( "welkum_muzak", pPlayer, pPlayer, USE_ON, 0.0f, 0.5f );
		blMusicTriggered = true;
	}

	return HOOK_CONTINUE;
}

HookReturnCode PlayerUse(CBasePlayer@ pPlayer, uint& out uiFlags)
{
	if( pPlayer is null || !pPlayer.IsConnected() || pPlayer.m_afButtonPressed & IN_RELOAD == 0 )
		return HOOK_CONTINUE;

	CloseGordonAnimation( pPlayer );

	return HOOK_CONTINUE;
}

HookReturnCode PlayerLeave(CBasePlayer@ pPlayer)
{
	if( pPlayer is null )
		return HOOK_CONTINUE;

	CloseGordonAnimation( pPlayer );

	return HOOK_CONTINUE;
}
