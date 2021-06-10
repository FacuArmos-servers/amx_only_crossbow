#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "Crossbow Only"
#define VERSION "0.45b"
#define AUTHOR "Facundo Montero (facuarmo)"

// Ucomment to enable server console debugging.
// #define DEBUG

/*
 * Global TODOs:
 *
 * - Cleanup the code so that more constants are used instead of plain strings.
 * - Improve the performance of the code by decreasing the amount of strings usage.
 * - Handle events properly, so that we don't have to use arbitrarily timed tasks anymore.
 * - Currently, arbitrary multiplications are being used in the hope for task IDs to not repeat,
 *   it's clearly know though, that this approach might not be reliable and should be investigated.
 */

/*
 * The constants OFFSET_CLIP and OFFSET_LINUX are based off the following work:
 *
 * https://forums.alliedmods.net/showthread.php?t=132825
 */
const OFFSET_CLIP = 40;
const OFFSET_LINUX = 4;

const CROSSBOW_MAX_CLIP = 5;

new players[32], player_count = 0;

// TODO: Rewrite this constant arrays block, so that it uses constant weapon IDs instead.
new const ammo[9][] = {
	"357",
	"9mmAR",
	"9mmbox",
	"9mmclip",
	"ARgrenades",
	"buckshot",
	"crossbow",
	"gaussclip",
	"rpgclip"
};

new const weapons[13][] = {
	"357",
	"9mmAR",
	"9mmhandgun",
	// "crossbow"
	"crowbar",
	"egon",
	"gauss",
	"handgrenade",
	"hornetgun",
	"rpg",
	"satchel",
	"shotgun",
	"snark",
	"tripmine"
};

new const misc[1][] = { 
	"weaponbox"
}

/*
 * @param String entity_name[]
 * @param String entity_class[] (defaults to empty to discard underscore sub-classed tags)
 *
 * @return void
 */
remove_entity_with_class(entity_name[], entity_class[] = "") {
	new target_entity[64] = "";

	if (strlen(entity_class) > 0) {
		strcat(target_entity, entity_class, 64);
		strcat(target_entity, "_", 64);
	}

	strcat(target_entity, entity_name, 64);

	new entity = -1;

	#if defined DEBUG
	server_print("preparing to think @ %s", target_entity);
	#endif

	while (entity = find_ent_by_class(entity, target_entity)) {
		#if defined DEBUG
		new entity_str[32];

		num_to_str(entity, entity_str, 32);

		server_print("thinking %s", entity_str);
		#endif

		// This *SHOULD* notify the engine that we're gonna remove that entity.
		dllfunc(DLLFunc_Think, entity);
	}

	remove_entity_name(target_entity);

	#if defined DEBUG
	server_print("remove_entity_name: %s", target_entity);
	#endif
}

/*
 * This method forces the player to drop its weapons.
 *
 * @param  int player_id
 * @return int
 */
public drop_weapons(player_id) {
	new weapons[32], weapon_count = 0;

	new weapon_name[32];

	get_user_weapons(player_id, weapons, weapon_count);

	for (new weapon_index = 0; weapon_index < weapon_count; weapon_index++) {
		if (weapon_index != 0) {
			get_weaponname(weapons[weapon_index], weapon_name, 32);
			
			if (!equali(weapon_name, "weapon_crossbow")) {
				client_cmd(player_id, "drop %s", weapon_name);
			}
		}
		
		// This is just a quick workaround, I'm gonna fix it at some point, trust me c:.
		client_cmd(player_id, "drop %s", "weapon_crowbar");
		//client_cmd(player_id, "drop %s", "weapon_9mm_handgun");
	}
	
	return PLUGIN_CONTINUE;
}

/*
 * This method checks if the player is alive, if it is and it doesn't have a crossbow yet, one will
 * be provided.
 *
 * @param int player_id
 * @param int task_id
 * @return int
 */
public handle_weapons(player_id, task_id) {
	if (is_user_alive(player_id)) {
		drop_weapons(player_id);

		if (!user_has_weapon(player_id, HLW_CROSSBOW)) {
			give_item(player_id, "weapon_crossbow");
		}
	}

	return PLUGIN_HANDLED;
}

/*
 * This method will detect when a player changes a weapon and then, it'll delay a task to run
 * "handle_weapons" so that it doesn't trigger fast enough to crash the server.
 *
 * NOTE: I'm pretty sure there's a better way to do this, please don't hurt me, I'm new to Pawn. :)
 *
 * @param int player_id
 * @return int
 */
public weapon_changed(player_id) {
	set_task(0.1, "handle_weapons", player_id);

	return PLUGIN_HANDLED;
}

/*
 * This method will fire during every round start and it'll try to traverse through each active real
 * player (not HLTV, alive and not connecting) and then it'll try to force them to drop back any
 * weapon they might've gotten during their spawn. Once dropped, it'll give them a crossbow.
 *
 * @return int
 */
public handle_round_start() {
	get_players(players, player_count,"ahi");

	for (new player_index = 0; player_index < player_count; player_index++) {
		if (is_user_alive(players[player_index])) {
			drop_weapons(players[player_index]);
	
			give_item(players[player_index], "weapon_crossbow");
		}
	}

	return PLUGIN_HANDLED;
}

/*
 * This method will detect when a new round begins and then, it'll delay a task to run
 * "handle_round_start" so that it doesn't trigger fast enough to crash the server.
 *
 * NOTE: I'm pretty sure there's a better way to do this, please don't hurt me, I'm new to Pawn. :)
 *
 * @param int player_id
 * @return int
 */
public round_start(player_id) {
	set_task(0.1, "handle_round_start", player_id);

	return PLUGIN_HANDLED;
}

/*
 * This method will iterate through each of the constant arrays defined above and try to get rid of
 * any matching entity in a safe and controlled manner (by "thinking" and then actually removing the
 * entity).
 *
 * @return void
 */
public remove_entities_from_arrays() {
	for (new index = 0; index < sizeof(ammo); index++) {
		remove_entity_with_class(ammo[index], "ammo");
	}

	for (new index = 0; index < sizeof(weapons); index++) {
		remove_entity_with_class(weapons[index], "weapon");
	}

	for (new index = 0; index < sizeof(misc); index++) {
		remove_entity_with_class(misc[index]);
	}
}

/*
 * This method is a forwarded call from HamSandwich, which from the expectation of the spawn of a
 * weaponbox, it'll try to remove all unwanted entities back again (this might not be what should
 * really be happening? But eh... atm it just works).
 *
 * @return void
 */
public fwd_misc_spawned(entity_id) {
	#if defined DEBUG
	new entity_id_str[32];
	
	num_to_str(entity_id, entity_id_str, 32);
	
	server_print("fwd_misc_spawned: %s", entity_id_str);
	#endif

	set_task(0.25, "remove_entities_from_arrays", entity_id * 16);
}

/*
 * This method ensures that on any weapon drop, we're 100% certain that the target player will get
 * at least one crossbow given again in order to keep playing throughout the gamemode.
 *
 * @return int
 */
public handle_drop(player_id) {
	handle_weapons(player_id, player_id * 32);

	return PLUGIN_CONTINUE;
}

/*
 * This method will handle the primary attack so that it can reset the entity ammo to its default
 * (which is 5 for the crossbow). This operation, in fact, provides support for infinite ammo.
 *
 * @param int entity_id
 * @return int
 */
public handle_primary_attack(entity_id) {
	set_pdata_int(entity_id, OFFSET_CLIP, CROSSBOW_MAX_CLIP, OFFSET_LINUX);

	#if defined DEBUG
	server_print("handle_primary_attack: set ammo.");
	#endif

	return PLUGIN_CONTINUE;
}

public plugin_init() {
	remove_entities_from_arrays();

	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("CurWeapon","weapon_changed","b","1=1");
	register_event("ResetHUD","round_start","b","1=1");
	register_clcmd("drop", "handle_drop");
	RegisterHam( Ham_Spawn, "weaponbox", "fwd_misc_spawned", 1 );
	RegisterHam( Ham_Weapon_PrimaryAttack, "weapon_crossbow", "handle_primary_attack", 1 );

	return PLUGIN_CONTINUE;
}