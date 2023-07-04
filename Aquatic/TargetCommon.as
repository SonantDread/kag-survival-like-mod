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