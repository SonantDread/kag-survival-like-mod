namespace CMap
{
	enum CustomTiles
	{
		tile_sand_back = 257,
		tile_sand_back_2 = 258,
		tile_sand_back_3 = 259,
		tile_sand_back_4 = 260,

		custom_tile_sand = 272,
		custom_tile_sand_2 = 273,
		custom_tile_sand_3 = 274,
		custom_tile_sand_4 = 275,
		custom_tile_sand_5 = 276,
		custom_tile_sand_6 = 277,
		custom_tile_sand_7 = 278,

		tile_sand_grass = 279,
		tile_sand_grass_2 = 280,

		sandy_grass_1 = 281,
		sandy_grass_2 = 282,
		sandy_grass_3 = 283,
		sandy_grass_4 = 284,

		tile_sand_damaged = 285,
		tile_sand_damaged_2 = 286,
		tile_sand_damaged_3 = 287,

		tile_sand_background = 288,
		tile_sand_background_2 = 289,
		tile_sand_background_3 = 290,
		tile_sand_background_4 = 291,
		tile_sand_background_5 = 292,
		tile_sand_background_6 = 293,
		tile_sand_background_7 = 294,
		tile_sand_background_8 = 295,
		tile_sand_background_9 = 296,
		tile_sand_background_10 = 297,

		tile_sandbag = 304,
		tile_sandbag_2 = 305,
		tile_sandbag_3 = 306,

		tile_sandbag_damaged = 317,
		tile_sandbag_damaged_2 = 318,
		tile_sandbag_damaged_3 = 319
	};
};
//! https://forum.thd.vg/threads/implementing-custom-tiles-not-blobs-at-the-map-loaders.25694/
const SColor color_sand        =   SColor(255, 25, 34, 10);
const SColor color_sand_back   =   SColor(255, 56, 82, 98);
const SColor color_sandy_grass =   SColor(255, 8, 12, 128);
const SColor color_sandbag 	   =   SColor(255, 181, 163, 100);

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	//map.AddTileFlag(offset, Tile::BACKGROUND);
	//map.AddTileFlag(offset, Tile::LADDER);
	//map.AddTileFlag(offset, Tile::LIGHT_PASSES);
	//map.AddTileFlag(offset, Tile::WATER_PASSES);
	//map.AddTileFlag(offset, Tile::FLAMMABLE);
	//map.AddTileFlag(offset, Tile::PLATFORM);
	//map.AddTileFlag(offset, Tile::LIGHT_SOURCE);
	//map.AddTileFlag(offset, Tile::SOLID);
	//map.AddTileFlag(offset, Tile::COLLISION);

	// map.SetTile(offset, CMap::**tile**);


	// tile flags handled in loaderutilities.as
	if(pixel == color_sand){
		map.SetTile(offset, CMap::custom_tile_sand+XORRandom(7)); // random int for random tile of the list
	}

	else if(pixel == color_sand_back){
		map.SetTile(offset, CMap::tile_sand_background+XORRandom(6));
	}
	
	else if(pixel == color_sandy_grass){
		map.SetTile(offset, CMap::sandy_grass_1+XORRandom(2));
	}
		else if(pixel == color_sandbag){
		map.SetTile(offset, CMap::tile_sandbag+XORRandom(3));
	}
}