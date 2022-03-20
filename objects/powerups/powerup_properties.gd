class_name PowerupProperties extends Resource


const boost_color = Color("2f8735")
const spray_color = Color("2abbd0")
const stop_color = Color("ff2b00")
const hand_color = Color("d59ff4")
const double_color = Color("ffffff")
const halve_color = Color("777777")


enum Type {
	BOOST,
	SPRAY,
	STOP,
	HAND,
	DOUBLE,
	HALVE
}


const powerup_database = {
	Type.BOOST: {
		"name": "Boost",
		"tooltip": "Get an extra boost in your turn!",
		"colour": boost_color,
		"icon_frame": 0,
		"icon_texture": preload("res://ui/powerup_icons_small_boost.png"),
		"target_method": "boost"
	},
	Type.SPRAY: {
		"name": "Spray",
		"tooltip": "Spawn 3 small harvesters in front of you for 2 seconds!",
		"colour": spray_color,
		"icon_frame": 1,
		"icon_texture": preload("res://ui/powerup_icons_small_spray.png"),
		"target_method": "spray"
	},
	Type.STOP: {
		"name": "Stop Enemies",
		"tooltip": "Stop all enemies in their tracks for 2 turn!",
		"colour": stop_color,
		"icon_frame": 2,
		"icon_texture": preload("res://ui/powerup_icons_small_stop.png"),
		"target_method": "stop"
	},
	Type.HAND: {
		"name": "+1 Farmhand",
		"tooltip": "Spawn an extra AI farmhand for 3 turns",
		"colour": hand_color,
		"icon_frame": 3,
		"icon_texture": preload("res://ui/powerup_icons_small_hand.png"),
		"target_method": "spawn_farmhand"
	},
	Type.DOUBLE: {
		"name": "Double Harvester Size",
		"tooltip": "Double the width of your harvester for 3 turns!",
		"colour": double_color,
		"icon_frame": 4,
		"icon_texture": preload("res://ui/powerup_icons_small_double.png"),
		"target_method": "double_size"
	},
	Type.HALVE: {
		"name": "Double Harvester Size",
		"tooltip": "Double the width of your harvester for 3 turns!",
		"colour": halve_color,
		"icon_frame": 5,
		"icon_texture": preload("res://ui/powerup_icons_small_halve.png"),
		"target_method": "halve_size"
	}
}
