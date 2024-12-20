class_name UpgradeButton extends Button

func set_upgrade(upgrade: Upgrade):
	%Icon.texture = upgrade.icon
	%TitleLabel.text = "[center][font_size=16]" + upgrade.name
	%DescriptionLabel.text = "[font_size=12]" + upgrade.description
	pressed.connect($/root/Main._on_upgrade_button_pressed.bind(upgrade.id))
