class_name DoubleUpgradeButton extends Button

func set_upgrades(upgrade: Upgrade, repeatable: RepeatableUpgrade):
	%IconBase.texture = upgrade.icon
	%TitleBase.text = "[center][font_size=16]" + tr(str(upgrade.id) + "_NAME")
	%DescriptionBase.text = "[font_size=12]" + tr(str(upgrade.id) + "_DESC")
	%IconRepeatable.texture = repeatable.icon
	%TitleRepeatable.text = "[center][font_size=16]" + tr(str(repeatable.id) + "_NAME")
	pressed.connect($/root/Main._on_upgrade_button_pressed.bind(upgrade.id, repeatable.id))
