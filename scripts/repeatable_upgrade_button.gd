class_name RepeatableUpgradeButton extends Button

func set_upgrade(upgrade: RepeatableUpgrade):
	%Icon.texture = upgrade.icon
	%TitleLabel.text = "[center][font_size=16]" + upgrade.name
	pressed.connect($/root/Main._on_upgrade_button_pressed.bind(upgrade.id))
