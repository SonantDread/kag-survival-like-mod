#include "Hitters.as"

void onTick(CBlob@ this){
    if(getGameTime() % 15 != 0){ return;}
    this.server_Hit(this, this.getPosition(), Vec2f(0.0f, -1.0f), (this.getInitialHealth() * 0.05), Hitters::fall, false);
}