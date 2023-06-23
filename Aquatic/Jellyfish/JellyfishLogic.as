#include "Hitters.as"
#include "KnockedCommon.as"

void onInit(CBlob@ this){
    this.Tag("flesh");
    this.Tag("builder always hit");
    this.Tag("jellyfish");
    this.set_s32("last sting time", getGameTime());

    this.set_Vec2f("last water position", this.getPosition()); // assume we spawn in water
    this.getShape().SetRotationsAllowed(false);
    this.getBrain().server_SetActive(true);
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