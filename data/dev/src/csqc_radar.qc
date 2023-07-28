//+---------------+
//|csqc_radar.qc  |
//+---------------+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Entities to send to CSQC                                                   |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

//
// Radar by Reki
//

float SendEntity_RadarBlip(entity to, float sendflags) // in this, "to" is the client being sent the data and "self" is the entity being networked
{
	if (to == self.owner) // don't send the player their own blip
		return FALSE;

	WriteByte(MSG_ENTITY, NETENTITY::RADARBLIP);
	WriteByte(MSG_ENTITY, sendflags);

	if (sendflags & 0x01) // send coordinates (where the blip will show)
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
	}

	if (sendflags & 0x02) // send color, you can replace this with colormod x y z or something
	{
		WriteByte(MSG_ENTITY, num_for_edict(self.owner) - 1); // player index
	}

	return TRUE;
}

void Think_RadarBlip()
{
	if !(self.owner) // if we don't have an owner, we don't need to update since we won't be moving!
	{
		remove(self);
		return;
	}
	if (self.owner.cloak_finished > time)
		return;

	setorigin(self, self.owner.origin);
	self.SendFlags |= 0x01; // tell the SendEntity to update our coordinates on the client

	self.think = Think_RadarBlip;
	frameskip(0.01);
}

entity Spawn_RadarBlip(entity player)
{
	entity blip = spawn();
	blip.SendEntity = SendEntity_RadarBlip; // use our SendEntity for networking
	blip.SendFlags = 0x03; // tell it to send both coordinates and color for initial state
	blip.pvsflags = PVSF_IGNOREPVS; // never cull via pvs for the network

	// start think loop
	blip.think = Think_RadarBlip;
	blip.nextthink = time + 0.1;

	// initial state
	blip.owner = player;
	blip.colormap = player.colormap;
	blip.origin = player.origin;

	return blip;
}