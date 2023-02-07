# Uncomment this line to define a global platform for your project

# Expose Objective-C frameworks to Swift
# Build and link dependencies as static frameworks
use_frameworks! :linkage => :static

abstract_target 'SendingnetworkSDK' do
    
    pod 'AFNetworking', '~> 4.0.0'
    pod 'GZIP', '~> 1.3.0'

    pod 'SwiftyBeaver', '1.9.5'
    
    pod 'OLMKit', '~> 3.2.5', :inhibit_warnings => true
    #pod 'OLMKit', :path => '../olm/OLMKit.podspec'
    
    pod 'Realm', '10.27.0'
    pod 'libbase58', '~> 0.1.4'
    pod 'MatrixSDKCrypto', "0.1.7", :configurations => ['DEBUG'], :inhibit_warnings => true
    pod "SVGKit"
    
    pod 'TrustWalletCore', '~> 2.9.2'
    pod 'RNCryptor', '~> 5.0'
    
    target 'SendingnetworkSDK-iOS' do
        platform :ios, '12.0'
        
        target 'SendingnetworkSDKTests-iOS' do
            inherit! :search_paths
            pod 'OHHTTPStubs', '~> 9.1.0'
        end
    end
end
