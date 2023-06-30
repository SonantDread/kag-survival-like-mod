#include "Hitters.as"
#include "KnockedCommon.as"
#include "PressOldKeys.as"

void onInit(CBlob@ this){
    this.Tag("flesh");
    this.Tag("jellyfish");
    this.set_s32("last sting time", getGameTime());

    this.set_Vec2f("last water position", this.getPosition()); // assume we spawn in water
    this.getShape().SetRotationsAllowed(false);
    this.getBrain().server_SetActive(true);
    this.server_setTeamNum(-1); // -1 == 255 == spectator
}

void onTick(CBlob@ this){
    Vec2f pos = this.getPosition();
    if(getGameTime() % 90 == 0){ // check to see if tile is below us by 7 blocks
        if(getMap().rayCastSolidNoBlobs(pos, Vec2f(pos.x, pos.y + (7.0f * getMap().tilesize)))){
            this.setKeyPressed(key_up, true);
        }
        else{
            this.setKeyPressed(key_down, true);
        }
    }
    else{
        PressOldKeys(this);
    }

    if((getGameTime() - this.get_s32("last sting time")) < 30) { return; } // cant sting

    // sting nearby players
    for(int player_index = 0; player_index < getPlayerCount(); ++player_index){
        CPlayer@ player = getPlayer(player_index);
        if(player is null){ return; }

        CBlob@ blob = player.getBlob();
        if(blob is null){ return; }

        if(blob.hasTag("flesh") && blob.isOverlapping(this)){
            Sting(blob);
            this.set_s32("last sting time", getGameTime());
        }
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
    f32 speedy = (-velocity.y * 0.5f);
    this.setVelocity(Vec2f(speedx, speedy));
}

bool isTileSolidatVec2f(Vec2f pos){
    return (getMap().isTileSolid(pos) || getMap().hasTileFlag(getMap().getTileOffsetFromTileSpace(pos), Tile::SOLID));
}