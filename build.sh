#!/bin/sh

set -e
set -x

pod install

if [ $1 == 'xcframework' ]	# optionally supports additional arguments for CFBundleShortVersionString and CFBundleVersion
then
	# archive the framework for iOS, macOS, Catalyst and the Simulator
	xcodebuild archive -workspace SendingnetworkSDK.xcworkspace -scheme SendingnetworkSDK-iOS -destination "generic/platform=iOS" -archivePath build/SendingnetworkSDK-iOS SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES IPHONEOS_DEPLOYMENT_TARGET=11.0 GCC_WARN_ABOUT_DEPRECATED_FUNCTIONS=NO MARKETING_VERSION=$2 CURRENT_PROJECT_VERSION=$3
	xcodebuild archive -workspace SendingnetworkSDK.xcworkspace -scheme SendingnetworkSDK-iOS -destination "generic/platform=iOS Simulator" -archivePath build/SendingnetworkSDK-iOSSimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES IPHONEOS_DEPLOYMENT_TARGET=11.0 GCC_WARN_ABOUT_DEPRECATED_FUNCTIONS=NO MARKETING_VERSION=$2 CURRENT_PROJECT_VERSION=$3
	xcodebuild archive -workspace SendingnetworkSDK.xcworkspace -scheme SendingnetworkSDK-macOS -destination "generic/platform=macOS" -archivePath build/SendingnetworkSDK-macOS SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES MACOSX_DEPLOYMENT_TARGET=10.10 GCC_WARN_ABOUT_DEPRECATED_FUNCTIONS=NO MARKETING_VERSION=$2 CURRENT_PROJECT_VERSION=$3
	xcodebuild archive -workspace SendingnetworkSDK.xcworkspace -scheme SendingnetworkSDK-iOS -destination "generic/platform=macOS,variant=Mac Catalyst" -archivePath ./build/SendingnetworkSDK-MacCatalyst SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES IPHONEOS_DEPLOYMENT_TARGET=13.0 GCC_WARN_ABOUT_DEPRECATED_FUNCTIONS=NO MARKETING_VERSION=$2 CURRENT_PROJECT_VERSION=$3

	cd build

	# clean xcframework artifacts
	if [ -d 'SendingnetworkSDK.xcframework' ]; then rm -rf SendingnetworkSDK.xcframework; fi
	if [ -f 'SendingnetworkSDK.xcframework.zip' ]; then rm -rf SendingnetworkSDK.xcframework.zip; fi

	# build and zip the xcframework
	xcodebuild -create-xcframework \
		-framework SendingnetworkSDK-iOS.xcarchive/Products/Library/Frameworks/SendingnetworkSDK.framework \
		-debug-symbols ${PWD}/SendingnetworkSDK-iOS.xcarchive/dSYMs/SendingnetworkSDK.framework.dSYM \
		-debug-symbols ${PWD}/SendingnetworkSDK-iOS.xcarchive/BCSymbolMaps/*.bcsymbolmap \
		-framework SendingnetworkSDK-iOSSimulator.xcarchive/Products/Library/Frameworks/SendingnetworkSDK.framework \
		-debug-symbols ${PWD}/SendingnetworkSDK-iOSSimulator.xcarchive/dSYMs/SendingnetworkSDK.framework.dSYM \
		-framework SendingnetworkSDK-macOS.xcarchive/Products/Library/Frameworks/SendingnetworkSDK.framework \
		-framework SendingnetworkSDK-MacCatalyst.xcarchive/Products/Library/Frameworks/SendingnetworkSDK.framework \
		-output SendingnetworkSDK.xcframework
	zip -ry SendingnetworkSDK.xcframework.zip SendingnetworkSDK.xcframework
else
	xcodebuild -workspace SendingnetworkSDK.xcworkspace/ -scheme SendingnetworkSDK -sdk iphonesimulator  -destination 'name=iPhone 5s'
fi