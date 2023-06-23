// "brain" of jellyfish

#include "JellyfishConsts.as"
#include "PressOldKeys.as"

void onInit(CBrain@ this){
    this.getBlob().set_u8("action type", MODE_IDLE);
}

void onTick(CBrain@ this){
    if(this is null){ return; }
    
    CBlob@ blob = this.getBlob();
    
    if(blob is null){ return; }

    if(blob.isInWater()){
        blob.set_Vec2f("last water position", blob.getPosition());
    }

    // prevent falling out of map
    if(blob.getPosition().y < getMap().tilemapheight - (3.0f * getMap().tilesize)){
        blob.setKeyPressed(key_up, true);
    }

    if(getGameTime() % 15 == 0){
        u8 action = blob.get_u8("action type");

        if(action == MODE_IDLE){
            // find water if out of it
            if(!blob.isInWater()){
                blob.set_u8("action type", MODE_FIND_WATER);
            }

            CBlob@ our_friend = getBlobByNetworkID(blob.get_netid(friend_property));
            if (our_friend is null)
            {
                blob.set_u8("action type", MODE_IDLE);
            }

            else{
                blob.set_u8("action type", MODE_FIND_FRIENDS);
            }
        }

        else if(action == MODE_FIND_WATER){
            // todo: check if "last water position" is still water
            // try this? bool isInWater(Vec2f posWorldspace) *CMap*
        }

        else if(action == MODE_FIND_FRIENDS){
            // find other jellyfish
            CBlob@ our_friend = getBlobByNetworkID(blob.get_netid(friend_property));
			
            if (our_friend is null)
            {
                blob.set_u8("action type", MODE_IDLE);
			}

            else{
                // todo: prevent these from just overlapping
                f32 targetpos = (our_friend.getPosition() - blob.getPosition()).getLength();
                // todo: check if this works
                blob.setKeyPressed(key_left, targetpos > 0 ? true : false);
                blob.setKeyPressed(key_right, targetpos < 0 ? true : false);
                blob.setKeyPressed(key_up, targetpos > 0 ? true : false);
                blob.setKeyPressed(key_down, targetpos < 0 ? true : false);
            }
        }
    }

    else{
        PressOldKeys(blob);
    }
}