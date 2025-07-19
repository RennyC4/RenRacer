//
// Street Light - decoration
//

$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10 death11 death12

void()	sign_die1	=[	$death1,	sign_die2	] {};
void()	sign_die2	=[	$death2,	sign_die3	] {self.solid = SOLID_NOT;};
void()	sign_die3	=[	$death3,	sign_die4	] {};
void()	sign_die4	=[	$death4,	sign_die5	] {};
void()	sign_die5	=[	$death5,	sign_die6	] {};
void()	sign_die6	=[	$death6,	sign_die7	] {};
void()	sign_die7	=[	$death7,	sign_die8	] {};
void()	sign_die8	=[	$death8,	sign_die9	] {};
void()	sign_die9	=[	$death9,	sign_die10	] {};
void()	sign_die10	=[	$death10,	sign_die11	] {};
void()	sign_die11	=[	$death11,	sign_die12	] {};
void()	sign_die12	=[	$death12,	sign_die12	] {};

void () stopsign_die =
{
	if (other.owner.driving)
		entity toucher = other.owner.driving;
	if (toucher.health <= 0)
		return;

	self.touch = SUB_Null;
	//self.velocity = other.velocity;
	sound (self, CHAN_BODY, "misc/hitsign.wav", 1, ATTN_NORM);
	sign_die2();
}

void() stopsign =
{
	precache_model ("progs/w_stopsign.mdl");
	precache_sound ("misc/hitsign.wav");
	setmodel (self, "progs/w_stopsign.mdl");
	setsize (self, '-9 -9 -17', '10 8 38');
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	self.takedamage = DAMAGE_NO;
	self.classname = "decor";
	self.origin_z = self.origin_z - 8;
	//	self.health = 1;
	self.touch = stopsign_die;
	droptofloor();
};