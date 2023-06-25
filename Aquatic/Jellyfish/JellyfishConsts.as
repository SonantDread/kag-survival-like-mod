const string delay_property = "brain_delay";
const string state_property = "brain_state";

const string target_property = "brain_target_id";
const string friend_property = "brain_friend_id";

const string target_searchrad_property = "brain_target_rad";

const string terr_pos_property = "brain_territory_pos";
const string terr_rad_property = "brain_territory_rad";

const string personality_property = "brain_personality";

const string target_lose_random = "target_lose_random";

enum modes
{
	MODE_IDLE = 0, // random swim
	MODE_FIND_WATER, // out of water
}

shared class AnimalVars
{
	Vec2f walkForce;
	Vec2f runForce;
	Vec2f slowForce;
	Vec2f jumpForce;
	f32 maxVelocity;
};
