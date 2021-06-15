amx_only_crossbow
=================

Welcome to the open-source repository for FacuArmo's servers' crossbow-only server.

Feel free to look around the code, make improvements and provide suggestions and feedback.

## Introduction

This is a rather simple plugin part of the "gungame" category. Select any Half-Life 1 map and get a crossbow! Everything else is blocked, ammo is infinite.

You're allowed to use basic items, only those that aren't under the `weapon_*` category.

## Screenshots
![First gameplay screenshot](https://i.ibb.co/KDtq8JK/example0.png)
![Second gameplay screenshot](https://i.ibb.co/dJKdSVJ/example1.png)

## Dependencies

- Engine
- Fun
- FakeMeta
- HamSandwich

## Commands

This plugin doesn't support any command.

## CVARs

This plugin doesn't support any CVARs.

## Installation

- Drop the plugin inside of your `addons/amxmodx/plugins` folder
- Edit your `plugins.ini` (inside of `addons/amxmodx/configs`) and add its filename (`amx_only_crossbow.amxx`)
- Restart your server or change the level to initialize it

## Development

On its current stage, the plugin is completely stable and usable. Although it might become rather slow on small systems or heavily loaded servers and further testing might be necessary in order to meet the standards of older plugins.

If you're planning on contributing, passing `debug` next to the filename within `plugins.ini` will provide you most of the unhandled exceptions that might occur, however, if you want to go even further, you might as well just re-build the plugin enabling the constant `DEBUG` (check the source header for more information), which will provide you with server-side insights about each of the plugin operation steps.

## Contributions

If you liked the plugin or you feel like there's anything to improve on or optimize, feel free to provide your suggestions or, better yet, **submit a pull request to the repo!**

## Credits

- To [sourceruns.org](https://sourceruns.org) for providing a starting point for me to learn about entity classes.
- To the [official Valve documentation](https://developer.valvesoftware.com/wiki/) for providing a [comprehensive list of entity classes](https://developer.valvesoftware.com/wiki/List_of_Half-Life_entities) with a proper description for the most important ones.
- To the writers of the [documentation for the AMX Mod X API](https://www.amxmodx.org/api/amxmodx/) for providing useful resources to start with.
- To [[Godmin] Gonzo](https://forums.alliedmods.net/member.php?u=1603) for providing a well-written and readable [plugin](https://forums.alliedmods.net/showthread.php?p=189356) with a code that I could learn how to handle Pawn from and how to manage entities.

## License

This project is licensed under the [GNU Affero General Public License v3.0](LICENSE).