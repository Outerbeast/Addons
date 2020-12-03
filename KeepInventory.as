/* A simple plugin that will enable saving of inventory between map transitions.
You can use the CVar "as_command keep_inventory 0" in the map cfg to disable it.
- Outerbeast */

CCVar g_KeepInventory ( "keep_inventory", 1.0f, "Enable inventory saving between changelevels", ConCommandFlag::AdminOnly );

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Outerbeast" );
	g_Module.ScriptInfo.SetContactInfo( "svencoopedia.fandom.com" );
}

void MapStart()
{
    CBaseEntity@ pChangeLevel;
    while( ( @pChangeLevel = g_EntityFuncs.FindEntityByClassname( pChangeLevel, "trigger_changelevel" ) ) !is null )
    {
        g_EntityFuncs.DispatchKeyValue( pChangeLevel.edict(), "keep_inventory", "" + g_KeepInventory.GetInt() );
        g_EngineFuncs.ServerPrint( "-- DEBUG: Keep Inventory setting is " + g_KeepInventory.GetInt() + "\n" );
    }
}
