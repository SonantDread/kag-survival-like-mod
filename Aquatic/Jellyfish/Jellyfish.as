// "brain" of jellyfish

#include "JellyfishConsts.as"
#include "PressOldKeys.as"
#include "TargetCommon.as"

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

    if(getGameTime() % 15 == 0){
        u8 action = blob.get_u8("action type");

        if(action == MODE_IDLE){
            // find water if out of it
            if(!blob.isInWater()){
                blob.set_u8("action type", MODE_FIND_WATER);
            }
        }

        else if(action == MODE_FIND_WATER){
            // todo: check if "last water position" is still water
            // try this? bool isInWater(Vec2f posWorldspace) *CMap*
            if(getMap().isInWater(blob.get_Vec2f("last water position"))){
                blob.set_u8("action type", MODE_TARGET);
                blob.set_Vec2f("target position", blob.get_Vec2f("last water position"));
            }
            else{
                Vec2f pos = SearchWaterNear(blob.get_Vec2f("last water position"));
                if(pos == Vec2f(0, 0)){ return; }

                else{
                    blob.set_u8("action type", MODE_TARGET);
                    blob.set_Vec2f("target position", pos);
                }
            }
        }
        
        else if(action == MODE_TARGET){
            Vec2f pos = blob.get_Vec2f("target position");
            Vec2f targetpos = pos - blob.getPosition();

            SetKeysCommon(blob, pos);
        }
    }

    else{
        PressOldKeys(blob);
    }
}