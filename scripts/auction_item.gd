extends PanelContainer

## declaring labels n buttons here so theyre accessible anywhere the buttons been instantiated (and its cleaner) 
@onready var fish_type_label: Label = $MarginContainer/ContentContainer/FishType
@onready var fish_special_label: Label = $MarginContainer/ContentContainer/ValuesContainer/Special
@onready var fish_size_label: Label = $MarginContainer/ContentContainer/ValuesContainer/Size
@onready var fish_expiration_label: Label = $MarginContainer/ContentContainer/ValuesContainer/Expiration
@onready var fish_rarity_label: Label = $MarginContainer/ContentContainer/ValuesContainer/Rarity
@onready var price_label: Label = $MarginContainer/ContentContainer/HBoxContainer/Price
@onready var bid_button: Button = $MarginContainer/ContentContainer/BidButton
@onready var auction_timer: Timer = $AuctionTimer
@onready var countdown_label: Label = $MarginContainer/ContentContainer/HBoxContainer/Countdown
@onready var label_update_timer: Timer = $MarginContainer/ContentContainer/HBoxContainer/LabelUpdateTimer

## data storage for fish properties (so i can store them inside the instance and then access them later (same situation as the variables above))
var type_data: Dictionary
var expiration_data: int
var rarity_data: Dictionary
var size_data: Dictionary
var special_data: Dictionary
var special_dice: int
var base_value: float

## custom signal for when it is clicked
signal clicked

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	label_update_timer.start()
	auction_timer.start()

## https://docs.godotengine.org/en/stable/classes/class_control.html#class-control-private-method-gui-input
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("clicked")
