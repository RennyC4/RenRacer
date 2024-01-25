+--------+
RenRacer by RenegadeC/RennyC (https://www.youtube.com/@RenegadeC)
+--------+

RenRacer started off as a combination of Urre/Polo's func_vehicle mod (https://github.com/TLWmarko/func_vehicle),
ReScratched (which is a modified/recovered version of Scratch tutorials by Ender), a recovered GoldCup Quake Rally (by Chazz)
as well as implementing FrikBotX; slowly it's morphing into it's own now.

The GoldCup entities were pretty much entirely rewritten and plays better than the original version, mostly thanks to
func_vehicle and clean source code.

W: Drive Forward
S: Drive Backward
A: Roll Left (when toppled)
D: Roll Right (when toppled)

Impulse 1 toggles your headlights, binded to shift
+Button1 is turbo boost, binded to mouse1 (left mouse button)
+Button2 is handbreak / drift, binded to mouse 2 (right mouse button)

--------
How to build terrain .hmd maps
--------

Bring down the console (`) and type:
mod_terrain_create foo "this is my first terrain map" nosky grass 0 water 4

(mod_terrain_create mapname “DESCRIPTION” SKYNAME DEFAULTGROUNDTEX DEFAULTHEIGHT DEFAULTWATER DEFAULTWATERHEIGHT)

This creates a new *.hmp file calleed "foo.hmp" located in the data/maps/ folder

Once again, in the console (`) type:
mapedit foo

Mapedit will disable all game logic and allow easy editing of foo.hmp now. Press M to toggle
on CsAddon and you can now play around with editing terrain and other fun things; you'll also
notice that you'll see black sky & water, the actual terrain is just 4 quake units below the water.

'Entities' / 'Lights' section seem to be currently broken inside the editor, and 'Brushes' I have yet
to figure out.

---
Entities
---

Placing entities is a bit trickier, you need to re-enter foo.hmp with developer 1 enabled, the console
will now be filled with informaton about your X,Y,Z coordinates and your angles. Fly to a spot where
you want to place an entity, and open foo.hmp as a plain text file.

.hmp files are essentially barebones and are mostly used for entity placement inside of terrain maps,
feel free to poke around in RenRacer's hmp files to see how I've set things up; once you take a look
you should quickly understand how entities are placed.

---
BSP inside terrain Maps
---

I have yet to experiment with this.

---
Recommendations / Comments
---

* Height maps are an easy way to create race tracks and you can make a good one in a few hours, less if you're experienced.
* Be sure to set some fog, otherwise everything will be drawn in the entire map; unless you want that and bad FPS.
* If you don't want water in your map, set the ground height to 50 and water height to 0.

--------
Bot Waypoints
--------

Recommended console settings for laying waypoints down are enabling "developer 2", and "sv_playerslots 1", start the race as normal
and bind a key to "impulse 3"; go around the track especially in troublesome spots and lay the waypoints you want down.
When you're finished laying the waypoints, use impulse 4 (bind it to a key preferbly) and it will spit out a bunch of information
into the console of the waypoints, their origin etc.

Inside the console again type "condump", FTEQuake will now dump condump.txt in the RenRacer/data/ folder, open it in a text editor
alongside waypoint.qc in data data/dev/src/chars and search down for the load_waypoints(); function. You will notice that waypoints
are created on map load and are tied to the maps filename as well; very similar to your condump.txt. Copy/Paste your condump waypoints
into the waypoint.qc and recompile RenRacer.

If you wish to test out your waypoints and see how the bots travel along and to optimize further, while still in "developer 2"
mode it's recommended to set "sv_playerslots" to 2, start the race and follow the bot along the track. This is great for experimenting
and getting their lap times down!

Furthermore: setting a waypoint or even a checkpoint/markers "waypoint_speed" value to 999 will tell the bot to turbo boost, otherwise any
other value aside from 0 (default driving behavior) will have the bot match the waypoints speed value.

---
Bot Behavior vs Waypoints:
---

Bots will normally go for checkpoints if waypoints are not present and they always know where they are, with waypoints involved it becomes a
hybrid process of looking for waypoints along the way to the next checkpoint to help them reach their goal. Bots will continue to look for
waypoints as well even after all checkpoints have been hit, otherwise they will be told to go for the Start/Finish goal flag. Bots can only see
one waypoint at a time (for now); their behavior will continue to improve.

Bots also run an internal timer to check if they're stuck/can't see their target, if this condition is met then they will start working backwards
down the waypoints in order to try and get back on track. If no waypoints are present then the bot will not work backwards but instead will keep
trying to reach their target.

Some maps function fine without waypoints depending on how the map was built, Map3 is a great example of bots doing well enough without waypoints
and solely relying on checkpoints instead; it's a good practice to treat checkpoints as waypoints as well!

Credits: / Resources:
--------   ---------

Urre - The amazing func_vehicle itself
shp/shpuld - Turbo boost code, borrowing some other code
Chazz - GoldCup assets
xAge - Ideas / general help / texturing / art
QRally - Some assets
spike - FTEQW / general help
FrikaC - FrikBot X, now gutted
Electro - Func_vehicles HotRod car model
https://www.naturalreaders.com/online/ - Announcer voice
Gridluster - Race1.ogg
The End By A-ONE ft Odyssey - Race2.ogg
Touhou Adequate By Odyssey - Race3.ogg
On The Moon By A-ONE ft Odyssey - Race4.ogg
King Of Eurobeat Majestic ReMix By Jordan - Race5.ogg
Tokyo Yo Yo By Milena Farrow - Race6.ogg
https://freestocktextures.com/photos-ground/ - Some terrain textures
kilomile - v_speed.mdl
Coffee - TutorBot waypoint system; modified
HUD for Quake (https://github.com/whipowill/quake-mod-hud) - Used & Modified scoreboard CSQC code
Mr.M - Boomerang model
SinisterSpud - Created Wraith, Road Bastard, Law Breaker, Razorback models
SingleTrac - Dead company, created Twisted Metal 1/2, using their assets
Strideh - Cactus models to be used in Map3