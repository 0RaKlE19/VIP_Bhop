# [VIP] Bhop
Allows you to use an automatic bunny jump - Bunnyhop.

There is a `timer function` until the Bhop is turned on, as well as a notification to VIP players.

Works through the `forced inclusion of the sv_autobunnyhopping variable` for the VIP player
## Requirements
-[VIP Core by R1KO](https://github.com/R1KO/VIP-Core/).

-[Translations Vip Module](https://hlmod.ru/resources/vip-translations-vip-module.938/).

-[[INC] CS:GO Colors](https://hlmod.ru/resources/inc-cs-go-colors.1009/).

## Install
Add the variable to the `groups.ini` file in the `csgo/addons/sourcemod/data/vip/cfg` directory:
```
"BHOP" 					"1"
```
Change the phrase `"BHOP_TIME"` in the `vip_modules.phrases.txt` file located in the `csgo/addons/sourcemod/translations/` directory:
```
"#format"    "{1:f}"
```
replace with this
```
"#format"    "{1:i}"
```
It should look like this:
```
"BHOP_TIME"
    {
        "#format"	"{1:i}"
        "ru"        "Банихоп будет доступен через {1} секунд"
        "ua"        "Банніхоп буде доступний через {1} секунд"
        "en"        "BunnyHop will be available in {1} seconds"
    }
```
## Variables
After the first launch of the module, create a config along the path `csgo/cfg/vip/VIP_Bhop.cfg`
```
// Notify that bhop will work in N seconds?
// -
// Default: "1"
// Minimum: "0.000000"
// Maximum: "1.000000"
sm_vip_bhop_info_on "1"

// How many seconds will it take to allow the player to bhop if the timer function is enabled?
// -
// Default: "5"
// Minimum: "1.000000"
// Maximum: "60.000000"
sm_vip_bhop_timer "5"

// Enable timer functions before turning on Bhop? (1 - Yes, 0 - No)
// -
// Default: "1"
// Minimum: "0.000000"
// Maximum: "1.000000"
sm_vip_bhop_timer_on "1"

// Enable notification 1 - after mp_freeze_time, 0 - at the beginning of the round.
// -
// Default: "1"
// Minimum: "0.000000"
// Maximum: "1.000000"
sm_vip_bhop_info_type "1"
```
