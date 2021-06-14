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
        if( pBrushEntity is null || !pBrushEntity.IsBSPModel() )
            continue;

        if( STR_BRUSHMODELS.find( string( pBrushEntity.pev.model ) ) >= 0 )
            continue;

        uint iCurrentBrushMdl = atoi( string( pBrushEntity.pev.model ).Replace( "*", "" ) );
        STR_BRUSHMODELS.resize( iCurrentBrushMdl + 1 );
        STR_BRUSHMODELS[iCurrentBrushMdl] = "" + pBrushEntity.pev.model;
        g_EngineFuncs.ServerPrint( "-- DEBUG -- Found existing brush model: " + pBrushEntity.pev.model + "\n" );
    }
}

void MapStart()
{
    for( uint i = 0; i < STR_BRUSHMODELS.length(); i++ )
    {
        if( i == 0 )
            continue;

        if( STR_BRUSHMODELS[i] == "" )
        {
            dictionary brush =
            {
                { "model", "*" + i },
                { "targetname", "gabens_hairy_taint" }
            };
            CBaseEntity@ pMissingBrush = g_EntityFuncs.CreateEntity( "func_wall_toggle", brush, false );

            if( !BrushExists( string( pMissingBrush.pev.model ) ) )
            {
                g_EntityFuncs.DispatchSpawn( pMissingBrush.edict() );
                g_EngineFuncs.ServerPrint( "-- DEBUG -- Created missing brush model: " + pMissingBrush.pev.model + "\n" );
            }
        }
    }
}

bool BrushExists(const string strModel)
{
    CBaseEntity@ pTemp, pExistingBrush;

    while( ( @pTemp = g_EntityFuncs.FindEntityByString( pTemp, "model", "" + strModel ) ) !is null )
    {
        if( !pTemp.IsBSPModel() || pTemp.GetTargetname() == "gabens_hairy_taint" )
            continue;

        @pExistingBrush = pTemp;
        break;
    }

    return ( pExistingBrush !is null );
}
