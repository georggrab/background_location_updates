generate:
	flutter packages pub run build_runner build

format:
	flutter format lib/

publish: generate format
	pub publish