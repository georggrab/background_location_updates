generate:
	flutter packages pub run build_runner build

publish: generate
	pub publish