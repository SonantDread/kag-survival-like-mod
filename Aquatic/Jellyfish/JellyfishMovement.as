// from SharkMovement.as

void onTick(CMovement@ this)
{
    CBlob@ blob = this.getBlob();

    const f32 swimspeed = 0.6f;
    const f32 swimforce = 0.6f;

    Vec2f vel = blob.getVelocity();
    Vec2f waterForce;

    //up and down
    if (blob.isKeyPressed(key_up) && vel.y > -swimspeed)
    {
        waterForce.y -= 1;
    }

    if (blob.isKeyPressed(key_down) && vel.y < swimspeed)
    {
        waterForce.y += 1;
    }

    //left and right
    if (blob.isKeyPressed(key_left) && vel.x > -swimspeed)
    {
        waterForce.x -= 1;
    }

    if (blob.isKeyPressed(key_right) && vel.x < swimspeed)
    {
        waterForce.x += 1;
    }

    waterForce *= swimforce * blob.getMass();
    blob.AddForce(waterForce);
}