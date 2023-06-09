// AquaticAnimal.as

#define SERVER_ONLY

#include "Hitters.as";

//blob
void onInit(CBlob@ this)
{
	this.getShape().getVars().waterDragScale = 1.0f; //water drag == regular drag

	if (!this.exists("swimspeed"))
		this.set_f32("swimspeed", 1.0f * 1.25f);
	if (!this.exists("swimforce"))
		this.set_f32("swimforce", 0.7f * 1.25f); // faster shark

	// force no team
	this.server_setTeamNum(-1);

	this.getCurrentScript().runFlags |= Script::tick_not_inwater;
	this.getCurrentScript().runFlags |= Script::tick_onground;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this)
{
	Vec2f vel = Vec2f(0, -(10 + XORRandom(30)) * 0.1f);
	if (this.isKeyPressed(key_left))
		vel.x -= 1.0f;
	if (this.isKeyPressed(key_right))
		vel.x += 1.0f;
	this.setVelocity(vel);
}


//movement

void onInit(CMovement@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_inwater;
	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().runProximityTag = "player";
	this.getCurrentScript().runProximityRadius = 200.0f * 5;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CMovement@ this)
{
	CBlob@ blob = this.getBlob();

	const f32 swimspeed = blob.get_f32("swimspeed");
	const f32 swimforce = blob.get_f32("swimforce");

	Vec2f vel = blob.getVelocity();
	Vec2f waterForce;

	//up and down
	if (blob.isKeyPressed(key_up)
			&& vel.y > -swimspeed)
	{
		waterForce.y -= 1;
	}

	if (blob.isKeyPressed(key_down)
			&& vel.y < swimspeed)
	{
		waterForce.y += 1;
	}

	//left and right
	if (blob.isKeyPressed(key_left)
			&& vel.x > -swimspeed)
	{
		waterForce.x -= 1;
	}

	if (blob.isKeyPressed(key_right)
			&& vel.x < swimspeed)
	{
		waterForce.x += 1;
	}

	waterForce *= swimforce * blob.getMass();
	blob.AddForce(waterForce);
}
