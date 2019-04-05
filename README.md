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
- v 0.2	- placing regions, zones by hand and these commands: region_mark pos1, region_mark pos2, region_mark set **region_name**
- v 0.3 - adding the effects, a base protection
- v 0.4 - export and import regions, convert and import areas from mod areas!
- v 0.5	- guest-status works, commands region_set *params* 

roadmap
	- PvP, MvP flag
	- PvP - module 
	- items from mod marker
	- more commands
	- clear code

## Privilegs:
+ "region_admin" ==> Can set, remove and modify all regions.
+ "region_lv4" ==> Can set and remove an effect and allow MvP for own regions.
+ "region_lv3" ==> Can set and remove and allow PvP for own regions.
+ "region_lv2" ==> Can protect and remove protection, invite and ban guests on own regions.
+ "region_lv1" ==> Can set, remove own regions.

## commands

|command|parameters|what does the command do|who can use is
|------|------|-------|-------| 
region *params*| *status*| Show a list of this regions with all data.|all players
region_mark *params* |	*pos1* | set one corner for the region |  privileg - region_lv1
| |	*pos2*| set the second corner for the region
| |	*set* **region_name**| set an regon with the name **region_name**
| |	*remove* **ID** | remove an own-region with the **ID**
region_set *params* | *protected* **true/false** | Protect the region (true) or clear protection (false)  | privileg - region_lv2
 | | *invite* **name** | invites player **name**. This player can 'dig' and 'build' like in an own protected region
region_pvp *params* | *PvP* **true/false** | can make the zone to become an arena with PvP (globaly PvP must be enabled) | privileg - region_lv3
region_form *params* | *MvP* **true/false** | can enable or disable that Mobs can damage the player | privileg - region_lv4
| | *effect* **hot,bot,holy,dot,choke,evil** | can create an effect in a zone.<br> hot = heal over time,<br> dot = damage over time,<br>...  
region_special *parms* | *parent* | mark an region as parent, so other regions can be placed in that region | privileg - region_admin
| | *show* **1 - 3** | shows a list of all values from regions-data in the range **Start** **-** **End**. If only **Start** is given than it shows region **Start**
| | *import* | import raz.export_file_name |
| | *export* | export all region to raz.export_file_name 
| | *convert_areas* | read existing areas.dat - create an raz.areas_raz_export file for import 
| | *import_areas* | import the file: raz.areas_raz_export
| | *parent* **+** or **-** | enable / disable the parent-flag of an region 




