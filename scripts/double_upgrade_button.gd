class_name DoubleUpgradeButton extends Button

func set_upgrades(upgrade: Upgrade, repeatable: RepeatableUpgrade):
	%IconBase.texture = upgrade.icon
	%TitleBase.text = "[center][font_size=16]" + upgrade.name
	%DescriptionBase.text = "[font_size=12]" + upgrade.description
	%IconRepeatable.texture = repeatable.icon
	%TitleRepeatable.text = "[center][font_size=16]" + repeatable.name
	pressed.connect($/root/Main._on_upgrade_button_pressed.bind(upgrade.id, repeatable.id))
