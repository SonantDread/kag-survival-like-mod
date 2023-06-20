#include "AnimalConsts.as";

//sprite

void onInit(CSprite@ this)
{
	this.ReloadSprites(10, 10); // grey shark
}

const string angle_prop = "shark angle";
const string chomp_tag = "chomping";

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if (!blob.isInWater())
	{
		bool very_wet = (getGameTime() - blob.get_u32("last time in water")) < 20;
		if (XORRandom(very_wet ? 4 : 15)==0)
		{
			float radius_x = 16.f;
			float radius_y = 3.f;
			getMap().SplashEffect(blob.getPosition()+Vec2f(-radius_x + XORRandom((radius_x*2+1)*100)*0.01f,
														   -radius_y + XORRandom((radius_y*2+1)*100)*0.01f), 
								  Vec2f(0, 2), 
								  (very_wet ? 8.f : 3.f) + XORRandom(2));
		}
	}
	else
	{
		blob.set_u32("last time in water", getGameTime());
	}
	
	if (!blob.hasTag("dead"))
	{
		//scary chomping
		if (blob.hasTag(chomp_tag))
		{
			if (this.animation.name != "chomp")
			{
				this.PlaySound(blob.get_string("bite sound"));
			}
			this.SetAnimation("chomp");
			return;
		}

		if (blob.getVelocity().LengthSquared() > 0.5f && (!this.isAnimation("chomp") || this.isAnimationEnded()))
		{
			this.SetAnimation("default");
		}
		else if (this.isAnimationEnded())
		{
			this.SetAnimation("idle");
		}
	}
	else
	{
		this.SetAnimation("dead");
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}

//blob

void onInit(CBlob@ this)
{
	//for EatOthers
	string[] tags = {"player", "flesh"};
	this.set("tags to eat", tags);

	this.set_f32("bite damage", 1.5f);

	//for aquatic animal
	this.set_f32(terr_rad_property, 64.0f * 3); // wander farther
	this.set_f32(target_searchrad_property, (96.0f * 10)); // larger see distance of players

	this.set_u8(personality_property, AGGRO_BIT); // not used

	this.getBrain().server_SetActive(true);

	this.set_u8(target_lose_random, 8 * 5); // less chance to lose aggro

	//for steaks
	this.set_u8("number of steaks", XORRandom(5)+5); // FOOD

	//for shape
	this.getShape().SetRotationsAllowed(false);

	//for flesh hit
	this.set_f32("gib health", -0.0f);

	this.Tag("flesh");

	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runProximityTag = "player";
	this.getCurrentScript().runProximityRadius = 320.0f;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;

	AttachmentPoint@[] aps;
	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];
			ap.offsetZ = 10.0f;
		}
	}
	this.set_s32("last lunged", 0);

	this.set_s32("drag delay", 1 * getTicksASecond()); // 1 second extra drag delay after lunge
	this.set_s32("sprite rotation", 0);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false; //maybe make a knocked out state? for loading to cata?
}

void onTick(CBlob@ this)
{
	Vec2f vel = this.getVelocity();

	if (getNet().isServer() && getGameTime() % 10 == 0)
	{
		//player compatible
		CPlayer@ myplayer = this.getPlayer();
		this.getBrain().server_SetActive(myplayer is null || myplayer.isBot());

		if (this.get_u8(state_property) == MODE_TARGET)
		{
			this.set_f32("bite damage", (this.getShape().getVars().waterDragScale == 2.5f) ? 1.5f : 2.0f);
			CBlob@ b = getBlobByNetworkID(this.get_netid(target_property));
			if (b !is null && this.getDistanceTo(b) < 56.0f)
			{
				this.Tag(chomp_tag);
			}
			else
			{
				this.Untag(chomp_tag);
			}

			// shark lunge
			if (XORRandom(5) == 0 && getGameTime() - this.get_s32("last lunged") > (XORRandom(6)+6) * getTicksASecond() && b !is null && this !is null) {
				Vec2f sharkpos = this.getPosition();
				Vec2f playerpos = b.getPosition();

				Vec2f direction = (playerpos - sharkpos);
				if(direction.x == playerpos.x && direction.y == playerpos.y){ return; } // no division by zero error
				direction.Normalize();

				Vec2f velocity;
				f32 lungespeed = 5.0f; // speed of lunge
				// determine which way to lunge based on the relative positions of the shark and player
				if (direction.x > 0) {
					velocity = -direction * lungespeed;
				} else {
					velocity = direction * lungespeed;
				}

				this.setVelocity(velocity);
				this.set_s32("last lunged", getGameTime());
				this.getShape().getVars().waterDragScale = 2.5f;
			}

			if(this.getShape().getVars().waterDragScale == 2.5f && getGameTime() - this.get_s32("last lunged") > this.get_s32("drag delay")){
				this.getShape().getVars().waterDragScale = 1.0f;
			}
		}
		else
		{
			this.Untag(chomp_tag);
		}
		this.Sync(chomp_tag, true);
	}

	bool significantvel = (vel.LengthSquared() > 1.0f && Maths::Abs(vel.x) > 0.2f);

	if (significantvel)
	{
		this.SetFacingLeft(vel.x < 0);
	}

	//rotate based on velocity

	// CSprite@ sprite = this.getSprite();
	// bool left = this.isFacingLeft();
	// vel = this.getVelocity();
	// vel.y *= -0.5f;

	// f32 targetAngle = 0.0f;
	// if (vel.LengthSquared() > 0.01f) // check if the velocity is significant enough
	// {
	// 	targetAngle = -vel.Angle();
	// }

	// f32 currentAngle = this.get_s32("sprite rotation");
	// f32 change = targetAngle - currentAngle;

	// // normalize the angle change to be within -180 to 180 degrees
	// if (change > 180.0f)
	// {
	// 	change -= 360.0f;
	// }
	// else if (change < -180.0f)
	// {
	// 	change += 360.0f;
	// }

	// // gradually adjust the angle towards the target angle
	// f32 maxChange = Maths::Min(Maths::Abs(change) * 0.1f, 10.0f) / 5.0f; // how much change can the shark angle have?
	// f32 angleChange = (left ? 1 : -1) * maxChange;
	// if (Maths::Abs(change) < maxChange)
	// {
	// 	angleChange = change;
	// }
	// f32 newAngle = currentAngle + angleChange;

	// // limit the maximum angle of rotation
	// f32 maxAngle = 20.0f;
	// newAngle = Maths::Clamp(newAngle, -maxAngle, maxAngle);

	// // rotate the sprite
	// sprite.ResetTransform();
	// sprite.RotateByDegrees(-newAngle, Vec2f(sprite.getFrameWidth() / 2, sprite.getFrameHeight() / 2));
	// this.set_s32("sprite rotation", newAngle);
}
