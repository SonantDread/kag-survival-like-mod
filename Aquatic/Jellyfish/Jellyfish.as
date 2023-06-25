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
        }
    }

    else{
        PressOldKeys(blob);
    }
}