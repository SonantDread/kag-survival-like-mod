// LoaderUtilities.as

#include "CustomBlocks.as";

bool onMapTileCollapse(CMap@ map, u32 offset)
{
    return true;
}

// Changes sand when it is damaged
TileType server_onTileHit(CMap@ map, f32 damage, u32 index, TileType oldTileType)
{
    if(map.getTile(index).type > 255)
    {
        switch(oldTileType)
        {
            case CMap::custom_tile_sand:        {return CMap::tile_sand_damaged;}
            case CMap::custom_tile_sand_2:      {return CMap::tile_sand_damaged;}
            case CMap::custom_tile_sand_3:      {return CMap::tile_sand_damaged;}
            case CMap::custom_tile_sand_4:      {return CMap::tile_sand_damaged;}
            case CMap::custom_tile_sand_5:      {return CMap::tile_sand_damaged;}
            case CMap::custom_tile_sand_6:      {return CMap::tile_sand_damaged;}
            case CMap::custom_tile_sand_7:      {return CMap::tile_sand_damaged;}
            case CMap::tile_sand_damaged:       {return CMap::tile_sand_damaged_2;}
            case CMap::tile_sand_damaged_2:     {return CMap::tile_sand_damaged_3;}
            case CMap::tile_sand_damaged_3:     {return CMap::tile_sand_background;}
        }
    }
    return map.getTile(index).type;
}

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
    Vec2f pos = map.getTileWorldPosition(index);
    if (map.getTile(index).type > 255) //custom solids
    {
        map.SetTileSupport(index, -1); // assume custom tiles are just sand & sand backwalls

        switch(tile_new)
        {
            // spawn normal sand
            case CMap::custom_tile_sand:
            case CMap::custom_tile_sand_2:
            case CMap::custom_tile_sand_3:
            case CMap::custom_tile_sand_4:
            case CMap::custom_tile_sand_5:
            case CMap::custom_tile_sand_6:
            case CMap::custom_tile_sand_7:
            {
                map.SetTile(index, CMap::custom_tile_sand+XORRandom(7));
                map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
                map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
                break;
            }
            
            // damaged sand
            case CMap::tile_sand_damaged:
            {
                map.SetTile(index, CMap::tile_sand_damaged);
                map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
                map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
                break;
            }

            case CMap::tile_sand_damaged_2:
            {
                map.SetTile(index, CMap::tile_sand_damaged_2);
                map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
                map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
                break;
            }

            case CMap::tile_sand_damaged_3:
            {
                map.SetTile(index, CMap::tile_sand_damaged_3);
                map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
                map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
                break;
            }
			
			// sand backwall
            case CMap::tile_sand_background:
            {
				map.server_AddSector(pos, pos, "SAND_BACKWALL"); // assume that tiles are sand & sand backwalls
				map.SetTile(index, CMap::tile_sand_background+XORRandom(10));
                map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
				break;
            }
        }
    }
	// set sand backwalls when blocks are placed over it
	CMap::Sector@[] sectors;
	map.getSectorsAtPosition(pos, sectors);

	for(int i = 0; i < sectors.size(); i++){
		if(sectors[i].name == "SAND_BACKWALL"){
			map.SetTileSupport(index, -1);
			if(!map.isTileSolid(pos) && !map.isTileBackground(map.getTile(pos))){
				map.SetTile(index, CMap::tile_sand_background+XORRandom(10));
                map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
				break;
			}
		}
	}
}