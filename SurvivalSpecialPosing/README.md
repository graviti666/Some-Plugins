# Survival Special Infected Posing

## Credit
* dustin - help with testing, cfg file & new commands. 

## Description
* This plugin allows to save multiple SI model sets / cameras that load when the round ends. So views will be forced
  to the camera.
* Loads a random saved configuration on round end.
* SI models and cameras are saved at your current position and angles.
  
## Commands
* !simodelmenu - Opens up a menu for creating configs.
* Menu commands:
* Load Random Model Config - Loads a random saved cfg for the map.
* Load Lastest Model Config - Loads latest saved cfg for the map.
* Delete Model Config - Wipes all saved configs for the current map.
* Spawn SI Models - Opens another menu for spawning SI models.
* Create Camera - Spawns an camera entity at your position.

## Installation
* [Compile](https://spider.limetech.io/) the sp file or get the compiled one from plugins/ folder.
* A empty config file will be automatically created by the plugin to sourcemod/data folder (simodelspawns.cfg).
* Optionally can download the cfg file from this folder which already
  has 6 sets of configs for all official maps, and place to ( sourcemod/data ).
  
  ## Version
* 2.0 - Improved menu for ease of use. [Demo](https://youtu.be/O53xMbSKaCU). **TODO**: Add TLS maps to configs (only added some poses to atrium and motel so far).  
* 1.0 - initial release  
