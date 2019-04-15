# raz
Regions, Areas and Zones for Minetest

## Inspired by 
+ areas - ShadowNinja
+ pvp_areas - pvp_areas

# The Idea
a mod to do them all
- mark regions and show them in a hud
- protect areas, invite guests 
- create zones for PvP {Player vs. Player}
- prevent damage for player in cities {Mobdamage vs. Player - MvP}
- give areas an effect like 

|effect| description | |
|-----|-----|-----|
|hot| heal over time
|bot | restore breath over time
holy | both: heal an breath over time 
dot| damage over time
choke | reduve breath over time
evil | both: damage and choke over time

## Versions
- v 0.1 - start of the projekt
- v 0.2	- placing regions, zones an areas by hand and these commands: region_mark pos1, region_mark pos2, region_mark set **region_name**
- v 0.3 - adding the effects. Protection is working. protection_violation makes damage
- v 0.4 - export and import regions to/from file, convert and import areas from ShadowNinja areas mod!
- v 0.5	- guest-status works, commands region_set *params* 
- v 0.6 - more commands fot modifying the attributs

roadmap
	- PvP, MvP attribute
	- PvP - module 
	- items from mod marker
	- more commands
	- clear code

## Privilegs:
+ "region_admin" ==> modify all regions, import, export regions, convert areas.dat,
+ "region_lv5" ==> Can set and remove effects for own regions.
+ "region_lv4" ==> Can enable/disable MvP for own regions.
+ "region_lv3" ==> Can enable/disable PvP for own regions.
+ "region_lv2" ==> Can enable/disable protection and invite/ban guests on own regions.
+ "region_lv1" ==> Can set and remove own regions.

## commands

|command|parameters|what does the command do|who can use is
|------|------|-------|-------| 
region *params*| *status*| Show a list of this regions with all data.|all players
region_mark *params* |	*pos1* | set one corner for the region |  privileg - region_lv1
| |	*pos2*| set the second corner for the region
| |	*set* **region_name**| set an regon with the name **region_name**
| |	*remove* **ID** | remove an own-region with the **ID**
region_set *params* | *protect* <id> | Protect the region with the ID (only OWN regions) | privileg - region_lv2
 | | *open* <id> | Opens the region with the ID for all players to 'dig' (only OWN regions).| 
 | | *invite* **name** | invites player **name**. (only OWN regions) - The guest player can 'dig' and 'build' like in an own protected region.
 | | *ban* **name** | disallow the player **name** (only OWN regions) to 'dig' and 'build' like in the protected region.
region_pvp *params* | *PvP* **true/false** | can make the zone to become an arena with PvP (globaly PvP must be enabled) | privileg - region_lv3
region_MvP *params* | *MvP* **true/false** | can enable or disable that Mobs can damage the player | privileg - region_lv4
region_effect *params* | *effect* **none,hot,bot,holy,dot,choke,evil** | can create an effect in a zone.<br> hot = heal over time,<br> dot = damage over time,<br>...|privileg - region_lv5
region_special *parms* | *parent* | mark an region as parent, so other regions can be placed in that region | privileg - region_admin.
| | *show* **1 - 3** | shows a list of all values from regions-data in the range **start** **-** **end**. If only **start** is given it shows the region **start**. Without **start** all regions are listed.
| | *import* | import raz.export_file_name. 
| | *export* | export all region to raz.export_file_name.
| | *convert_areas* | conversts from ShadowNinja areas! - read existing areas.dat - create an raz.areas_raz_export file for import.
| | *import_areas* | import the file: raz.areas_raz_export.
| | *parent* **+** or **-** | enable / disable the parent-attribute of an region.
| | *change_owner* **id** **new owner** | changes the owner from an region to **new owner**.




