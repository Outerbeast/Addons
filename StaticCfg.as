/* StaticCfg- Plugin for overriding standard map cvars
Based on The StaticCfg AMXX plugin

Installation:
1) Put StaticCfg.as into svencoop_addon/scripts/plugins
2) Add this to default_plugins.txt:
	"plugin"
 	{
        "name" "StaticCfg"
        "script" "StaticCfg"
 	}
3) Inside the dir svencoop_addon/scripts/plugins/store create the file static.cfg
4) Add your CVars into this new config file

WARNING:
This will override map cvars and will potentially break maps if you don't know what you're doing.
Add your CVars sparingly.

- Outerbeast*/
const string strCfgDir = "scripts/plugins/store/static.cfg";
dictionary dictCfg;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Outerbeast" );
	g_Module.ScriptInfo.SetContactInfo( "svencoopedia.fandom.com" );

	ReadCfg();
}

void ReadCfg()
{
	File@ pFile = g_FileSystem.OpenFile( strCfgDir, OpenFile::READ );

	if( pFile is null || !pFile.IsOpen() )
		return;

	while( !pFile.EOFReached() )
	{
		string strCurrentLine;
		pFile.ReadLine( strCurrentLine );
		if( strCurrentLine.SubString(0,1) == "#" || strCurrentLine.IsEmpty() )
			continue;

		array<string> parsed = strCurrentLine.Split( " " );
		if( parsed.length() < 2 )
			continue;

		dictCfg[parsed[0]] = parsed[1];
	}

	pFile.Close();
}

void MapInit()
{	
	array<string> STR_CVARS_KEYS = dictCfg.getKeys();
	STR_CVARS_KEYS.sortAsc();
	string strCVarValue;

	if( dictCfg.isEmpty() )
		return;

	for( uint i = 0; i < STR_CVARS_KEYS.length(); ++i )
	{
		if( STR_CVARS_KEYS[i] == "" || strCVarValue == "" )
			continue;

		dictCfg.get( STR_CVARS_KEYS[i], strCVarValue );
		g_EngineFuncs.CVarSetFloat( STR_CVARS_KEYS[i], atof( strCVarValue ) );
		g_EngineFuncs.ServerPrint( "StaticCfg: Set CVar " + STR_CVARS_KEYS[i] + " " + strCVarValue + "\n" );
	}
}
/* Special thanks to
- Neo for scripting support
- Incognico for file parsing code */