// this file handles movement and damaging states

#include "JellyFishConsts.as"
#include "PressOldKeys.as"
#include "Hitters.as"
#include "KnockedCommon.as"



// important vars

void onInit(CBlob@ this){
    this.Tag("flesh");
    this.Tag("builder always hits");
    this.Tag("jellyfish");
    this.set_s32("last sting time", getGameTime());
    this.set_u8("action type", MODE_IDLE);
    this.set_Vec2f("last water position", this.getPosition()); // assume we spawn in water
}

void onInit(CBrain@ this){
    this.getBlob().set_u8(state_property, MODE_IDLE);
}

void onInit(CShape@ this)
{
    this.SetRotationsAllowed(false);
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

void onTick(CBlob@ this){
    if(getGameTime() % 5 == 0){
        this.AddForce(Vec2f(0.0f, 0.01f)); // slowly drift down
    }
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid){
    if(blob is null){ return; }
    if(blob.hasTag("flesh") && (getGameTime() - this.get_s32("last sting time")) > 30){
        Sting(blob);
    }
    this.set_s32("last sting time", getGameTime());
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob){
    return false;
}

void Sting(CBlob@ this){
    this.server_Hit(this, this.getPosition(), Vec2f(this.isFacingLeft() ? -1.0 : 1.0, 0.0f), 1.0f, Hitters::fall);

    setKnocked(this, 15); // stun player for half a second

    // shoot player back
    Vec2f velocity = this.getVelocity();
    f32 speedx = -velocity.x * 0.75f;
    f32 speedy = (-velocity.y * 0.75f) - 1.0f; // todo: is this - 1.0f needed?
    this.setVelocity(Vec2f(speedx, speedy));
}