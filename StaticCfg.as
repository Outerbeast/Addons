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
dictionary dCvars;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Outerbeast" );
	g_Module.ScriptInfo.SetContactInfo( "svencoopedia.fandom.com" );

	ReadCfg();
}

void ReadCfg()
{
	File@ pFile = g_FileSystem.OpenFile( strCfgDir, OpenFile::READ );

	if( pFile !is null && pFile.IsOpen() )
	{
		while( !pFile.EOFReached() )
		{
			string sLine;
			pFile.ReadLine( sLine );
			if( sLine.SubString(0,1) == "#" || sLine.IsEmpty() )
				continue;

			array<string> parsed = sLine.Split( " " );
			if( parsed.length() < 2 )
				continue;

			dCvars[parsed[0]] = parsed[1];
		}
		pFile.Close();
	}
}

void MapInit()
{	
	array<string> @dCvarsKeys = dCvars.getKeys();
	dCvarsKeys.sortAsc();
	string CvarValue;

	for( uint i = 0; i < dCvarsKeys.length(); ++i )
	{
		dCvars.get( dCvarsKeys[i], CvarValue );
		g_EngineFuncs.CVarSetFloat( dCvarsKeys[i], atof( CvarValue ) );
		g_EngineFuncs.ServerPrint( "StaticCfg: Set CVar " + dCvarsKeys[i] + " " + CvarValue + "\n" );
	}
}
/* Special thanks to
- Neo for scripting support
- Incognico for file parsing code */