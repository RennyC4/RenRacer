RenRacer by RenegadeC/RennyC (https://www.youtube.com/@RenegadeC)
--------

RenRacer started off as a combination of Urre/Polo's func_vehicle mod (https://github.com/TLWmarko/func_vehicle),
ReScratched (which is a modified/recovered version of Scratch tutorials by Ender), a recovered GoldCup Quake Rally (by Chazz)
as well as implementing FrikBotX; slowly it's morphing into it's own now.

The GoldCup entities were pretty much entirely rewritten and plays better than the original version, mostly thanks to
func_vehicle, and clean source code.

W: Drive Forward
S: Drive Backward
A: Roll Left (when toppled)
D: Roll Right (when toppled)

Impulse 1 toggles your headlights, binded to shift
+Button1 is turbo boost, binded to mouse1 (left mouse button)
+Button2 is handbreak / drift, binded to mouse 2 (right mouse button)

How to build terrain .hmd maps
--------

Bring down the console (`) and type:
mod_terrain_create foo "this is my first terrain map" nosky grass 0 water 4

(mod_terrain_create mapname “DESCRIPTION” SKYNAME DEFAULTGROUNDTEX DEFAULTHEIGHT DEFAULTWATER DEFAULTWATERHEIGHT)

This creates a new *.hmp file calleed "foo.hmp" located in the data/maps/ folder

Once again, in the console (`) type:
mapedit foo

Mapedit will disable all game logic and allow easy editing of foo.hmp now. Press K to toggle
on CsAddon and you can now play around with editing terrain and other fun things.

'Entities' / 'Lights' section seem to be currently broken inside the editor, and 'Brushes' I have yet
to figure out

Entities
---

Placing entities is a bit trickier, you need to re-enter foo.hmp with developer 1 enabled, the console
will now be filled with informaton about your X,Y,Z coordinates and your angles. Fly to a spot where
you want to place an entity, and open foo.hmp as a plain text file.

.hmp files are essentially barebones and are mostly used for entity placement inside of terrain maps,
feel free to poke around in RenRacer's hmp files to see how I've set things up; once you take a look
you should quickly understand how entities are placed.

BSP inside terrain Maps
---

I have yet to experiment with this.

Recommendations / Comments
---

* Height maps are an easy way to create race tracks and you can make a good one in a few hours, less if you're experienced
* Be sure to set some fog, otherwise everything will be drawn in the entire map; unless you want that.
* If you don't want water in your map, set the ground height to 50 and water height to 0

Credits: / Resources:
--------   ---------

shp/shpuld - Turbo boost code, peeking at how he does things
Urre - The amazing func_vehicle itself
Chazz - GoldCup assets
QRally - Some assets
spike - FTEQW / help
FrikaC - FrikBot X
Electro - Func_vehicle car model
https://www.naturalreaders.com/online/ - Announcer voice
MANUEL / GAS GAS GAS - Race1.ogg
The End By A-ONE ft Odyssey - Race2.ogg
https://freestocktextures.com/photos-ground/ - Some terrain textures
kilomile - v_speed.mdl