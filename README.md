# raz
Regions Areas and Zones for Minetest

## inspired by 
+ areas - ShadowNinja
+ pvp_areas - pvp_areas

# The Idea
a mod to do them all
- mark regions and show them in a hud
- protect areas, invite guests 
- create zones for PvP {Player vs Player}
- prevent damage for player in cities {Mobdamage against Player - MvP}
- give areas an effect like 
-- holy {e.g. heal over time (hot)}
-- evil	{e.g. damage over time (dot)}


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
mark_region *params* |	*pos1* | set one corner for the region |  privileg - region_lv1
| |	*pos2*| set the second corner for the region
| |	*set* **region_name**| set an regon with the name 'region_name'
| |	*remove* **ID** | remove an own-region with the 'ID'
set_region *params* | *protected* **true/false** | Protect the region (true) or clear protection (false)  | privileg - region_lv2
 | | *invite* **name** | invites player **name**. This player can 'dig' and 'build' like in an own protected region
PvP_region *params* | *PvP* **true/false** | can make the zone ti become an arena with PvP (globaly PvP must be enabled) | privileg - region_lv3
form_region *params* | *MvP* **true/false** | can enable or disabel that Mobs can damage the player | players privileg - region_lv4
| | *effect* **hot,bot,holy,dot,choke,evil** | can create an effect in a zone. hot = heal over time, dot = damage over time,...  



