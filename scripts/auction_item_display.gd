extends PanelContainer

## declaring labels n buttons here so theyre accessible anywhere the buttons been instantiated (and its cleaner) 
@onready var stats_label: Label = $MarginContainer/ContentContainer/InfoContainer/StatsLabel
@onready var fact_label: Label = $MarginContainer/ContentContainer/InfoContainer/FactLabel
@onready var fish_name: Label = $MarginContainer/ContentContainer/TitleContainer/FishName
@onready var icon_texture: TextureRect = $MarginContainer/ContentContainer/TitleContainer/IconTexture
