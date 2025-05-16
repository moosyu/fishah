extends Control

## defining variables for the container that will display the items and the timer for item spawns
@onready var container : VBoxContainer = $AuctionItems/VBoxContainer
@onready var item_spawn: Timer = $AuctionItems/ItemSpawn
@onready var auction: Control = $"."

## creating a random number generator
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var nemo_found: bool = false

## grabbing the auction item display
var auction_item: Variant = preload("res://scenes/auction_item.tscn")
var auction_item_display: Variant = preload("res://scenes/auction_item_display.tscn")


## set an empty current_display_instance so _on_auction_item_clicked doesnt throw an error 
var current_display_instance: Control = null

## declaring arrays
const types: Array = [
	{"name": "Salmon", "base": 30, "fact": "Salmon can actually jump up to two metres, only 0.4m away from the Olympic world record!"},
	{"name": "Tuna", "base": 35, "fact": "The bluefin tuna is the largest tuna species. It can grow up to 4m long and weight up to 800kgs!"},
	{"name": "Cod", "base": 25, "fact": "Cods can travel up to 320km to reach their breeding grounds during mating season!"},
	{"name": "Trout", "base": 20, "fact": "Trouts can rapidly change colour depending on their surroundings or their mood."},
	{"name": "Snapper", "base": 40, "fact": "Snappers have their name because of the audible snap their powerful jaws make when biting down!"},
	{"name": "Catfish", "base": 60, "fact": "Catfish don't just swim, they can walk on land, climb walls and even breath air."},
	{"name": "Carp", "base": 15, "fact": "Wild carp can live up to 40 years in the wild and the oldest carp was 226 years old."},
	{"name": "Herring", "base": 10, "fact": "Herrings swim in schools that can consist of millions of fish and be as high as 100 metres."},
	{"name": "Pike", "base": 50, "fact": "A single female pike could produce between 50,000 and 500,000 eggs in her lifetime."}
]

const rarities: Array = [
	{"name": "Trash", "weight": 50, "colour": Color8(255, 255, 255), "multiplier": 0.5},
	{"name": "Common", "weight": 35, "colour": Color8(85, 255, 85), "multiplier": 1},
	{"name": "Rare", "weight": 10, "colour": Color8(85, 85, 255), "multiplier": 3},
	{"name": "Legendary", "weight": 5, "colour": Color8(255, 170, 0), "multiplier": 5}
]

const specials: Array = [
	{"name": "Addicting", "weight": 20, "multiplier": 2},
	{"name": "Rejuvinating", "weight": 20, "multiplier": 15},
	{"name": "Strengthening", "weight": 20, "multiplier": 10},
	{"name": "Weakening", "weight": 10, "multiplier": 0.5},
	{"name": "Beautifying", "weight": 10, "multiplier": 5},
	{"name": "Charismatising", "weight": 10, "multiplier": 5},
	{"name": "Enraging", "weight": 10, "multiplier": 2}
]

const sizes = [
	{"name": "Tiny", "weight": 25, "colour": Color(1, 0, 0), "multiplier": 0.25},
	{"name": "Small", "weight": 35, "colour": Color(1, 0, 0), "multiplier": 0.5},
	{"name": "Medium", "weight": 30, "colour": Color(1, 1, 0), "multiplier": 1},
	{"name": "Large", "weight": 5, "colour": Color(0, 1, 0), "multiplier": 1.5},
	{"name": "Huge", "weight": 5, "colour": Color(0, 1, 0), "multiplier": 2}
]

func _ready() -> void:
	## TODO: set max amount to spawn to be 15 (for 3 minute timer round)
	## TODO: make auction_item_display display the right thing with stats, description and icon
	## TODO: decrease coin count when you press buy
	## gets a random seed so every round is different
	randomize()
	## starts the item spawn timer (which doesnt autostart so items dont spawn before ready)
	item_spawn.start()
	## item_spawn.wait_time = rng.randf_range(10.0, 20.0)

## ran when the item spawn timer hits 0
func _on_item_spawn_timeout() -> void:
	## item_spawn.wait_time = rng.randf_range(10.0, 20.0)
	create_button()

func create_button():
	## define the values by picking randomly from the list or just getting random values
	var type_value : int = rng.randi_range(0, types.size() - 1)
	var expiration_value : int = rng.randi_range(1, 10)
	var special_dice: int = rng.randi_range(0, 19)
	var rarity_value : Dictionary = get_weighted(rarities)
	var size_value : Dictionary = get_weighted(sizes)
	var special_value : Dictionary = get_weighted(specials)
	## calculate base item value
	var base_value: float = types[type_value].base * size_value.multiplier * rarity_value.multiplier * (float(expiration_value) / 5) 
	## https://www.youtube.com/watch?v=Qs8oSGmhx-U
	var auction_item_instance : Variant = auction_item.instantiate()
	
	## adding auction_item_instance to container up here so the rest of the values dont give errors because theyre trying to change null values
	container.add_child(auction_item_instance)
	
	## storing data inside the instance so it can be accessed from my _on_auction_item_clicked
	auction_item_instance.type_data = types[type_value]
	auction_item_instance.expiration_data = expiration_value
	auction_item_instance.rarity_data = rarity_value
	auction_item_instance.size_data = size_value
	auction_item_instance.special_data = special_value
	auction_item_instance.special_dice = special_dice
	auction_item_instance.base_value = base_value
	
	## connecting the custom clicked signal created in the auction_item.gd script to this, the bind is binding the function _on_auction_item_clicked to the instance itself (so that all the buttons can be used uniquely)
	auction_item_instance.connect("clicked", _on_auction_item_clicked.bind(auction_item_instance))
	## connecting the button pressed signal and mouse entered signal to every button created
	auction_item_instance.bid_button.pressed.connect(_on_bid_button_pressed.bind(auction_item_instance))
	## https://docs.godotengine.org/en/stable/classes/class_control.html#class-control-signal-mouse-entered


	## check if the one in 20 chance for special dice to been rolled
	if special_dice == 6:
		auction_item_instance.fish_special_label.text = first_char(special_value.name)
		auction_item_instance.fish_special_label.set("theme_override_colors/font_color", Color8(200, 0, 255))
		base_value * special_value.multiplier ## need to fix, doesnt apply, scoping issue
	else:
		auction_item_instance.fish_special_label.text = "N" ## displays n (none) if special dice hasnt rolled correctly
	
	## https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html
	auction_item_instance.price_label.text = "$%.2f" % snappedf(base_value, 0.01)
	auction_item_instance.bid_button.text = "Bid $%.2f" % snappedf(base_value * 0.3, 0.01)
	auction_item_instance.fish_type_label.text = types[type_value].name
	auction_item_instance.fish_rarity_label.text = first_char(rarity_value.name)
	auction_item_instance.fish_rarity_label.set("theme_override_colors/font_color", rarity_value.colour)
	
	auction_item_instance.fish_expiration_label.text = str(expiration_value)
	
	## https://docs.godotengine.org/en/stable/classes/class_color.html
	if expiration_value > 5:
		auction_item_instance.fish_expiration_label.set("theme_override_colors/font_color", Color(0, 1, 0))
	elif expiration_value <= 5 and expiration_value >= 3:
		auction_item_instance.fish_expiration_label.set("theme_override_colors/font_color", Color(1, 1, 0))
	else:
		auction_item_instance.fish_expiration_label.set("theme_override_colors/font_color", Color(1, 0, 0))
	
	auction_item_instance.fish_size_label.text = first_char(size_value.name)
	auction_item_instance.fish_size_label.set("theme_override_colors/font_color", size_value.colour)

## gets first char in a string
func first_char(f_char: String) -> String:
	return f_char.substr(0, 1)
	
## picks a random value based on the weight value i gave them
func get_weighted(weighted_array: Array) -> Dictionary:	
	## this assumes the weights all add to 100
	var rand = rng.randi_range(0, 99)
	var current = 0
	
	for weighted_value in weighted_array:
		current += weighted_value.weight
		if rand < current:
			return weighted_value
	
	## returns the first value in the array if something goes horribly wrong
	return weighted_array[0]

func _on_bid_button_pressed(auction_item_instance):
	print("Bid button pressed on ", auction_item_instance.fish_type_label.text)
	Global.coins -= auction_item_instance.base_value * 0.3
	auction_item_instance.queue_free()
	print(Global.coins)
		
func _on_auction_item_clicked(auction_item_instance):    
	## remove the previous display instance if it exists
	if current_display_instance != null:
		current_display_instance.queue_free()

	## create instance for item display and display it
	var auction_item_display_instance : Variant = auction_item_display.instantiate()
	auction.add_child(auction_item_display_instance)
	
	current_display_instance = auction_item_display_instance

	auction_item_display_instance.fish_name.text = auction_item_instance.type_data.name
	auction_item_display_instance.fact_label.text = auction_item_instance.type_data.fact
	## bracket just makes me able to break line, same output if this was all written in one line
	## need to fix special attributes not being none
	auction_item_display_instance.stats_label.text = (
		"Quality: " + auction_item_instance.rarity_data.name + "\n" +
		"Size: " + auction_item_instance.size_data.name + "\n" +
		"Expiration date: " + str(auction_item_instance.expiration_data) + " days\n" +
		"Special attributes: " + auction_item_instance.special_data.name
	)
	print("Auction item clicked!")
