extends Control

@onready var game: Control = $"."
@onready var cash_label: Label = $CashContainer/MarginContainer/Cash
@onready var sell_button: Button = $Sell
@onready var begin_button: Button = $Begin
@onready var info_button: Button = $Info
@onready var gamble_button: Button = $Gamble
@onready var loan_button: Button = $Loan

var auction_scene: Variant = preload("res://scenes/auction.tscn")

func _ready() -> void:
	update_cash()

## considered doing this by connecting the signal from auction_item to this code, felt less efficient as it was more lines but if im feining for performance later on ill rethink this
func _process(delta: float) -> void:
	update_cash()

func _on_begin_pressed() -> void:
	var auction_instance = auction_scene.instantiate()
	sell_button.queue_free()
	begin_button.queue_free()
	info_button.queue_free()
	gamble_button.queue_free()
	loan_button.queue_free()
	game.add_child(auction_instance)

func update_cash():
	cash_label.text = "$%.2f" % snappedf(Global.coins, 0.01)
