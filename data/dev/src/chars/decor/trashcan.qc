//
// TrashCan - decoration
//

$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10 death11



void()	gcan_die1	=[	$death1,	gcan_die2	] {};
void()	gcan_die2	=[	$death2,	gcan_die3	] {	sound (self, CHAN_BODY, "misc/hitbin.wav", 1, ATTN_NORM);};
void()	gcan_die3	=[	$death3,	gcan_die3	] {};

void () trashcan_think = 
{
	if (self.velocity == '0 0 0')
		{
		self.avelocity = '0 0 0';
		self.angles_x = self.angles_z = 0;
		}
	frameskip(0.1);
};


void () trashcan_die =
{

	if (other.takedamage == DAMAGE_AIM)
	{
	self.movetype = MOVETYPE_BOUNCE;
	//setsize(self, '-55 -55 -4', '55 55 60');
	self.velocity = other.velocity + random() * '100 100 0';
	self.avelocity = random() * '600 600 600';
	self.velocity_z += 500;
	self.think = trashcan_think;
	self.nextthink = time;
	
	//Lid

	if(self.frame == 0)
	{
	local entity lid = spawn();
	setmodel (lid, "progs/w_trashlid.mdl");
	setsize(lid, '-25 -25 0', '25 25 2');
	lid.movetype = MOVETYPE_BOUNCE;
	lid.origin = self.origin + '0 0 20';
	lid.solid = SOLID_NOT;
	lid.velocity = other.velocity + random() * '600 600 0';
	lid.avelocity = random() * '1200 1200 1200';
	lid.velocity_z = 800;
	lid.think = trashcan_think;
	lid.nextthink = time;
	}
	
	gcan_die2();
	
	
	}
}


void() trashcan =
{



		precache_model ("progs/w_trashcan.mdl");
		precache_model ("progs/w_trashlid.mdl");
		precache_sound ("misc/hitbin.wav");
		setmodel (self, "progs/w_trashcan.mdl");
		setsize(self, '-15 -15 0', '15 15 60');
		self.movetype = MOVETYPE_NOCLIP;
		self.solid = SOLID_TRIGGER;
		self.takedamage = DAMAGE_NO;
		self.origin_z = self.origin_z - 8;
//		self.health = 1;
		self.touch = trashcan_die;
//		self.think = trashcan_think;
//		self.nextthink = time;

};