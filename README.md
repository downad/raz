# raz
Regions, Areas and Zones for Minetest

## Inspired by 
+ areas - ShadowNinja - https://github.com/minetest-mods/areas
+ pvp_areas - everamzah - https://github.com/everamzah/pvp_areas
+ landrush - Bremaweb - https://github.com/Bremaweb/landrush


# The Idea
a mod to do them all!
it allows players {depending on privilegs}
- to mark their (region / areas / zones) with name
- to protect / open their (region / areas / zones)
- to invite / ban other players to interact in own protected (region / areas / zones)
- to allow / disallow PvP in own (region / areas / zones)
- to allow / disable Mobdamage {Mobdamage vs. Player - MvP} in own (region / areas / zones)
- to set own (region / areas / zones) with an effect like hot, dot, holy, evil

|effect| description | |
|-----|-----|-----|
hot| heal over time
bot | restore breath over time
holy | both: heal an breath over time 
dot| damage over time
choke | reduve breath over time
evil | both: damage and choke over time

For the region admin the mod allows {privileg region_admin}
- to create an named city (maybe portected)
- set some building plots for the playes, so player can protect ther own (region / areas / zones) in the city 



## Versions
- v 0.1 - start of the projekt
- v 0.2	- placing regions, zones an areas by hand and these commands: region_mark pos1, region_mark pos2, region_mark set **region_name**
- v 0.3 - adding the effects. Protection is working. protection_violation makes damage
- v 0.4 - export and import regions to/from file, convert and import areas from ShadowNinja areas mod!
- v 0.5	- guest-status works, commands region *command* *params* 
- v 0.6 - more commands for modifying the attributs, changing the privilegs
- v 0.7 - PvP and MvP wokrs
- v 0.8 - Sokomine/markers supports raz
- v 0.9 - landrush module started 

### Roadmap
- PvP, MvP attribute (done)
- PvP - module (done)
- items from mod marker (done, downads marker now supports raz)
- more commands (border,plot, city)
- clear code (in work) 
- color the hud
- make effect for food work
- some controls for placing regions, e.g. max regions/player, default high, region can only placed in 'wilderness' or 'parent'

## Privilegs:
+ "region_admin" ==> modify all regions, import, export regions, convert areas.dat, ...
+ "region_effect" ==> Can set and remove effects for own regions.
+ "region_mvp" ==> Can enable/disable MvP for own regions.
+ "region_pvp" ==> Can enable/disable PvP for own regions.
+ "region_set" ==> Can invite/ban guests or change owner of own regions.
+ "region_mark" ==> Can set, remove and rename own regions and protect and open them.

## Commands

|command|parameters|what does the command do|who can use is
|------|------|-------|-------| 
region *help* | **command** | Get some infos about the use of the *command* | privileg: interact
region *status* | no params | Get some more infos about the region at your position. | privileg: interact
region *border* | no params | Make your region at this position visible. | privileg: interact
| | **name** | Make the region of player**name**  visible. | privileg: region_admin
region *own* | no params | Get a list of all your regions. | privileg: region_mark
region *pos1* | no params |	Set one corner for the region |  privileg: region_mark
region *pos2* | no params |	Set the second corner for the region |  privileg: region_mark
region *set_y* | no params | Set the y-values of your region to 90% of the max_height. 1/3 down and 2/3 up. |  privileg: region_mark
region *set*  | **region_name**| Marks an region with the name **region_name** | privileg: region_mark
region *remove* | **ID** | Remove an OWN-region with the **ID** | privileg: region_mark
| | **all** | Removes **all** region, a backup will be created. | privileg: region_admin
region *protect* | **ID**| Protect the region with the ID (only OWN regions) | privileg: region_mark
region *open* | **ID** | Opens the region with the **ID** for all players to 'dig' (only OWN regions).| privileg: region_mark
region *invite* | **ID** + **name** | Invites player **name** as guest in your OWN-Region with the **ID** - The guest player can 'dig' and 'build' like in an own protected region.| privileg: region_set
region *ban* | **ID** + **name** | Bans the player **name** from the guestlist of your region with the **ID**.| privileg: region_set
region *change_owner* | **id** + **new_owner** | Changes the owner from your region (**ID**) to **new_owner**.| privileg: region_set
region *pvp* | **ID** + **+ or -** | Enable(+) or disable(-) PvP in your region to become an arena (globaly PvP must be enabled) | privileg: region_pvp
region *mvp* |  **ID** + **+ or -** | Enable(+) or disable(-) that mobs can damage the player | privileg: region_mvp
region *effect* |**ID** + **none, hot, bot, holy, dot, choke, evil** | Create an effect in your zone.<br> hot = heal over time,<br> dot = damage over time,<br>...|privileg: region_effect
region *plot* | **ID** + **+ or -**  | Mark(+) or unmark(-) an region as building plot. Other regions can only be placed in 'wildernesss' or in an building plot region. | privileg: region_admin
region *city* | **ID** + **+ or -**  | Mark(+) or unmark(-) an region as city. In an city-zone you can playce building plots. | privileg: region_admin
region *show* | no params | Shows a list of all regions-data values from all regions | privileg: region_admin
|	| **ID** | Shows a list of all values from regions-data in the region **ID** | privileg: region_admin
|	| **ID1** + **ID2** | Shows a list off all values in the range of **ID1** to **ID2** | privileg: region_admin 
region *import* | no params| Import the regions from raz.export_file_name. | privileg: region_admin 
region *export* |  no params| Export all region to raz.export_file_name.| privileg: region_admin 
region *convert_areas* |  no params| Conversts areas from ShadowNinja areas! - read existing areas.dat - create an raz.areas_raz_export file for import_areas.| privileg: region_admin 
region *import_areas* |  no params| Import the file: raz.areas_raz_export.| privileg: region_admin 
region *player* | **name** | Shows a list of all regions from  Player **name**.| privileg: region_admin


### Licence
GNU General Public License v3.0

## Textures and Models
Bremaweb/landrush models
- landrush_showarea.png
- landrush_showarea.x
Bremaweb/landrush textures
- landrush_landclaim.png
