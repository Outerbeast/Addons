/* Simple script that finds deleted brush entities in the bsp and then
reports the missing ones and creates them in-game so they can be re-added to the bsp
- Outerbeast
*/

array<string> STR_BRUSHMODELS;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Outerbeast" );
	g_Module.ScriptInfo.SetContactInfo( "svencoopedia.fandom.com" );
}

void MapActivate()
{
    STR_BRUSHMODELS.resize(0);
    CBaseEntity@ pBrushEntity;

    while( ( @pBrushEntity = g_EntityFuncs.FindEntityByString( pBrushEntity, "model", "*" ) ) !is null )
    {
        if( !pBrushEntity.IsBSPModel() )
            continue;

        if( STR_BRUSHMODELS.find( "" + pBrushEntity.pev.model ) >= 0 )
            continue;

        string strBrushMdl = string( pBrushEntity.pev.model ).SubString( 1, String::INVALID_INDEX );
        int iCurrentBrushMdl = atoi( strBrushMdl );
        STR_BRUSHMODELS.resize( iCurrentBrushMdl + 1 );
        STR_BRUSHMODELS[iCurrentBrushMdl] = "" + pBrushEntity.pev.model;
        g_EngineFuncs.ServerPrint( "-- DEBUG -- Existing brush model: " + pBrushEntity.pev.model + "\n" );
    }
}

void MapStart()
{
    for( uint i = 1; i <= STR_BRUSHMODELS.length(); i++ )
    {
       if( STR_BRUSHMODELS[i] == "" )
        {
            dictionary brush =
            {
                { "model", "*" + i },
                { "targetname", "gaben_" + i }
            };
            CBaseEntity@ pMissingBrush = g_EntityFuncs.CreateEntity( "func_wall_toggle", brush, true );
            g_EngineFuncs.ServerPrint( "-- DEBUG -- Created missing brush model: " + pMissingBrush.pev.model + "\n" );
        }
    }
}