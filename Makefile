
.PHONY : log install_buck build watch message targets audit debug test xcode_tests clean project audit

# Use local version of Buck
BUCK=tools/buck

log:
	echo "Make"

install_buck:
	curl https://jitpack.io/com/github/airbnb/buck/f2865fec86dbe982ce1f237494f10b65bce3d270/buck-f2865fec86dbe982ce1f237494f10b65bce3d270-java11.pex --output tools/buck
	chmod u+x tools/buck

update_cocoapods:
	pod repo update
	pod install

build:
	$(BUCK) build :


debug:
	$(BUCK) install //BuckExample/: --run --simulator-name 'iPhone 8'

ci: install_buck install_ruby_gems targets build test ui_test ruby_test project xcode_tests watch message
	echo "Done"

install_ruby_gems:
	bundle install --path vendor/bundle

ruby_test:
	buck_binary_path=tools/buck bundle exec rspec BuckLocal/ruby_scripts/ -I BuckLocal/ruby_scripts/

audit:
	$(BUCK) audit rules App/BUCK > Config/Gen/App-BUCK.py
	$(BUCK) audit rules Pods/BUCK > Config/Gen/Pods-BUCK.py

clean:
	rm -rf **/*.xcworkspace
	rm -rf **/*.xcodeproj
	$(BUCK) clean

kill_xcode:
	killall Xcode || true
	killall Simulator || true

xcode_tests: project
	xcodebuild build test -workspace BuckExample.xcworkspace -scheme ExampleApp -destination 'platform=iOS Simulator,name=iPhone 8,OS=latest' | xcpretty && exit ${PIPESTATUS[0]}

project: clean
	$(BUCK) project //App:workspace
	open BuckExample.xcworkspace