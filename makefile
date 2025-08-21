# Define flutter command
FLUTTER := flutter

# Main sequence: clean, get, build web, build android, run
.PHONY: all
all:
	flutter clean
	flutter pub get
# 	flutter build apk --debug

# 	flutter build apk --release

	flutter run

