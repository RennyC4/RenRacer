//
// Street Light - decoration
//

$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10 death11

void()	lamp_die1	=[	$death1,	lamp_die2	] {};
void()	lamp_die2	=[	$death2,	lamp_die3	] {self.angles_y = random()*360;self.solid = SOLID_NOT;};
void()	lamp_die3	=[	$death3,	lamp_die4	] {};
void()	lamp_die4	=[	$death4,	lamp_die5	] {};
void()	lamp_die5	=[	$death5,	lamp_die6	] {};
void()	lamp_die6	=[	$death6,	lamp_die7	] {};
void()	lamp_die7	=[	$death7,	lamp_die8	] {};
void()	lamp_die8	=[	$death8,	lamp_die9	] {};
void()	lamp_die9	=[	$death9,	lamp_die10	] {};
void()	lamp_die10	=[	$death10,	lamp_die11	] {};
void()	lamp_die11	=[	$death11,	lamp_die11	] {};


void () streetlamp_die =
{
	if (other.owner.driving)
		entity toucher = other.owner.driving;
	if (toucher.health <= 0)
		return;

	self.touch = SUB_Null;
	//self.velocity = other.velocity;
	sound (self, CHAN_BODY, "misc/hitpole.wav", 1, ATTN_NORM);
	lamp_die2();
}


void() lightoffset_think =
{
	if (self.owner.frame > 0)
	{
	remove(self);
	}
	frameskip(0.01);
};


void() streetlamp =
{

	local vector offset;


		precache_model ("progs/w_streetlamp.mdl");
		precache_sound ("misc/hitpole.wav");
		setmodel (self, "progs/w_streetlamp.mdl");
		setsize (self, '-9 -9 -17', '10 8 38');
		self.movetype = MOVETYPE_NONE;
		self.solid = SOLID_TRIGGER;
		self.takedamage = DAMAGE_NO;
		self.origin_z = self.origin_z - 8;
//		self.health = 1;
		self.touch = streetlamp_die;
		droptofloor();


		//glowy light crap

		makevectors (self.angles);
		local entity lightoffset = spawn();
		lightoffset.owner = self;
		lightoffset.movetype = MOVETYPE_NOCLIP;
		lightoffset.solid = SOLID_NOT;
		setorigin (lightoffset,self.origin + v_forward * 95 + '0 0 48');
		setmodel (lightoffset, "*null");
		lightoffset.color = [1, 1, 1];
		lightoffset.light_lev = 200;
		//offset = self.origin + (v_forward * 95);
		self.movetype = MOVETYPE_NONE;
		lightoffset.pflags = PFLAGS_FULLDYNAMIC;
		lightoffset.light_lev = 150;
		lightoffset.color = [2, 2, 1.5];
		lightoffset.think = lightoffset_think;
		lightoffset.nextthink = time;
};