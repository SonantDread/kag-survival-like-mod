void SetKeysCommon(CBlob@ this, Vec2f targetpos){
    // TODO: improve this pathing logic
    // TODO: maybe this somehow gets stuck on other blobs?
    // TODO: maybe this gets stuck on walls?
	Vec2f pos = this.getPosition();

    this.getBrain().SetPathTo(targetpos, false);
    // this.SetTarget(target);

    f32 xpos = (targetpos.x - pos.x);
    f32 ypos = (targetpos.y - pos.y);

    this.setKeyPressed(xpos < 0.0f ? key_left : key_right, true);
    this.setKeyPressed(ypos < 0.0f ? key_up : key_down, true);
}

// expects a Vec2f position
// returns (0,0) if no water is found
Vec2f SearchWaterNear(Vec2f pos){
    for(int y = 0; y < 5.0f; y++){
        for(int x = 0; x < 5.0f; x++){
            if(getMap().isInWater(Vec2f(pos.x + (x * 8.0f), pos.y + (y * 8.0f)))){
                return Vec2f(pos.x + (x * 8.0f), pos.y + (y * 8.0f));
            }

            else if(getMap().isInWater(Vec2f(pos.x - (x * 8.0f), pos.y - (y * 8.0f)))){
                return Vec2f(pos.x - (x * 8.0f), pos.y - (y * 8.0f));
            }
        }
    }

    return Vec2f(0,0);
}