// shark brain

// TODO: AGGRESSIVE SHARK
// TODO: SHARK AIMS TO GO BACK IN WATER IF IT GOES OUT

// TODO: builderlogic.as line 374

#define SERVER_ONLY

#include "PressOldKeys.as";
#include "SharkConsts.as";

void onInit(CBrain@ this)
{
	CBlob@ blob = this.getBlob();
	blob.set_u8(delay_property , 5 + XORRandom(5));
	blob.set_u8(state_property, MODE_IDLE);
	blob.set_Vec2f("last water position", blob.getPosition());

	if (!blob.exists(terr_rad_property))
	{
		blob.set_f32(terr_rad_property, 32.0f * 3); // larger territory
	}

	if (!blob.exists(target_searchrad_property))
	{
		blob.set_f32(target_searchrad_property, 32.0f);
	}

	if (!blob.exists(personality_property))
	{
		blob.set_u8(personality_property, 0);
	}

	if (!blob.exists(target_lose_random))
	{
		blob.set_u8(target_lose_random, 14);
	}

	if (!blob.exists("random move freq"))
	{
		blob.set_u8("random move freq", 2);
	}

	this.getCurrentScript().removeIfTag	= "dead";
	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().runProximityTag = "player";
	this.getCurrentScript().runProximityRadius = 200.0f;

	Vec2f terpos = blob.getPosition();
	terpos.y += blob.getRadius();
	blob.set_Vec2f(terr_pos_property, terpos);
}


void onTick(CBrain@ this)
{
	CBlob@ blob = this.getBlob();

	u8 delay = blob.get_u8(delay_property);
	if (delay > 0) delay--;

	// set territory
	if (blob.getTickSinceCreated() == 10)
	{
		Vec2f terpos = blob.getPosition();
		terpos.y += blob.getRadius();
		blob.set_Vec2f(terr_pos_property, terpos);
    }

	if (delay == 0)
	{
		delay = 4 + XORRandom(8);

		if(blob.isInWater()){
			blob.set_Vec2f("last water position", blob.getPosition());
		}

        u8 mode = blob.get_u8(state_property);

		CBlob@ target = getBlobByNetworkID(blob.get_netid(target_property));

        if (target is null || XORRandom(blob.get_u8(target_lose_random)) == 0 || target.isInInventory()) {
            mode = MODE_IDLE;
        }
        else { // target exists, set modes
			f32 search_radius = blob.get_f32(target_searchrad_property) * 10;

			if(!blob.isInWater()){
				mode = MODE_FIND_WATER;
			}

			else if(!target.isInWater()){ // try to stay in water
				mode = MODE_IDLE;
			}

			else if((target.getPosition() - blob.getPosition()).getLength() >= (search_radius))
			{
				mode = MODE_IDLE;
			}

			else if(XORRandom(blob.get_u8(target_lose_random)) == 0){
				mode = MODE_IDLE;
			}

			else{
				mode = MODE_TARGET;
			}
		}

		if(mode == MODE_TARGET){
			Vec2f pos = blob.getPosition();
			Vec2f targetpos = target.getPosition();

			f32 search_radius = blob.get_f32(target_searchrad_property) * 5;

			// are we inside the radius of finding a target?
			if((targetpos - pos).getLength() <= search_radius){
				// todo: code shark target mode, and find water
				this.SetPathTo(targetpos, false);
				this.SetTarget(target);

				// if(!getMap().rayCastSolidNoBlobs(pos, targetpos)){
					// direct path to target
					// TODO: maybe this somehow gets stuck on other blobs?
					// TODO: maybe this gets stuck on walls?
					f32 xpos = (targetpos.x - pos.x);
					f32 ypos = (targetpos.y - pos.y);

					blob.setKeyPressed(xpos < 0.0f ? key_left : key_right, true);
					blob.setKeyPressed(ypos < 0.0f ? key_up : key_down, true);

					// blob.setKeyPressed((territory_dir.x < 0.0f) ? key_left : key_right, true);
					// blob.setKeyPressed((territory_dir.y > 0.0f) ? key_down : key_up, true);
				// }
				// else{
				// 	//not a direct path to target
				// 	// TODO: add this
				// 	print("path not direct.");

				// 	f32 xpos = (targetpos.x - pos.x);
				// 	f32 ypos = (targetpos.y - pos.y);

				// 	blob.setKeyPressed(xpos < 0.0f ? key_left : key_right, true);
				// 	blob.setKeyPressed(ypos < 0.0f ? key_up : key_down, true);
				// }
			}
			else if(mode == MODE_FIND_WATER){
				// TODO: code this
				// if() {// if "last water position" is a water tile

				// }
				// else{
				// 	// nearby search for water
				// 	// if no water, shark slowly dies
				// }
			}
			else{
				mode = MODE_IDLE;
			}
		}

		if (mode == MODE_IDLE) // find a new target
		{
			// print("finding new target");
			f32 search_radius = blob.get_f32(target_searchrad_property) * 5;
			string name = blob.getName();

			CBlob@[] available_players;

			// if()
			for(int player_index = 0; player_index < getPlayerCount(); ++player_index){
				CPlayer@ player = getPlayer(player_index);

				if(player is null){ return; }
				if(player.getBlob() is null){ return; }
				if(blob is null) { return; }

				if(player.getBlob().hasTag("flesh")
				&& player.getBlob().isInWater() &&
				(player.getBlob().getPosition() - blob.getPosition()).getLength() <= search_radius){
					available_players.push_back(player.getBlob());
				}
			}
			
			if(available_players.size() > 0){
				CBlob@ closestplayer = available_players[0];

				for(int closest = 0; closest < available_players.size(); ++closest){
					if(closest == 0){ continue; } // closest already set to this
					if((closestplayer.getPosition() - available_players[closest].getPosition()).getLength() > 0){
						// the other player is closer
						CBlob@ closestplayer = available_players[closest];
					}
				}

				blob.set_netid(target_property, closestplayer.getNetworkID());
				print("Target: " + closestplayer.getPlayer().getUsername());
				mode = MODE_TARGET;
			}
			else{
				// TODO: add random moving
			}
		}

        blob.set_u8(state_property, mode);
	}
	else
	{
		PressOldKeys(blob);
	}

	blob.set_u8(delay_property, delay);
}
