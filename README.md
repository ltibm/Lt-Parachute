## Installation
1. Download  **lt_parachute.as** and copy to **scripts/plugins** folder.
2. Download **parachute.mdl** and copy to **models** on svencoop folder.
3. Open your **default_plugins.txt** in **svencoop** folder
  and put in;
```
"plugin"
{
    "name" "Lt - Parachute"
    "script" "lt_parachute"
    "concommandns" "lt"
}
```
3. Send command **as_reloadplugins** to server or restart server.

## Commands
- usage **as_command lt.prc_enabled 1**
- **lt.prc_enabled**: 0 or 1, Enable or Disable current plugin (default 1).
- **lt.prc_adminonly**: 0 or 1 Parachute admin only (default 0)
- **lt.prc_prconly** : 0 or 1 Parachute only sprc pysc code only (default 0);
- **lt.prc_showmodel** : 0 or 1 Create parachute entity when player using parachute (default 1);