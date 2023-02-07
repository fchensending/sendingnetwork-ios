/*
 Copyright 2014 OpenMarket Ltd

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <XCTest/XCTest.h>

#import "MXTools.h"
#import "SendingnetworkSDKTestsSwiftHeader.h"

@interface MXToolsUnitTests : XCTestCase

@end

@implementation MXToolsUnitTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testGenerateSecret
{
    NSString *secret = [MXTools generateSecret];

    XCTAssertNotNil(secret);
}

- (void)testSendingnetworkIdentifiers
{
    // Tests on homeserver domain (https://sending.network/docs/spec/legacy/#users)
    XCTAssertTrue([MXTools isSendingnetworkUserIdentifier:@"@bob:sending.network"]);
    XCTAssertTrue([MXTools isSendingnetworkUserIdentifier:@"@bob:chat1234.sending.network"]);
    XCTAssertTrue([MXTools isSendingnetworkUserIdentifier:@"@bob:chat-1234.sending.network"]);
    XCTAssertTrue([MXTools isSendingnetworkUserIdentifier:@"@bob:chat-1234.aa.bbbb.sending.network"]);
    XCTAssertTrue([MXTools isSendingnetworkUserIdentifier:@"@bob:sending.network:8480"]);
    XCTAssertTrue([MXTools isSendingnetworkUserIdentifier:@"@bob:localhost"]);
    XCTAssertTrue([MXTools isSendingnetworkUserIdentifier:@"@bob:localhost:8480"]);
    XCTAssertTrue([MXTools isSendingnetworkUserIdentifier:@"@bob:127.0.0.1"]);
    XCTAssertTrue([MXTools isSendingnetworkUserIdentifier:@"@bob:127.0.0.1:8480"]);
    
    XCTAssertFalse([MXTools isSendingnetworkUserIdentifier:@"@bob:sendingnetwork+25.org"]);
    XCTAssertFalse([MXTools isSendingnetworkUserIdentifier:@"@bob:sendingnetwork[].org"]);
    XCTAssertFalse([MXTools isSendingnetworkUserIdentifier:@"@bob:sending.network."]);
    XCTAssertFalse([MXTools isSendingnetworkUserIdentifier:@"@bob:sending.network-"]);
    XCTAssertFalse([MXTools isSendingnetworkUserIdentifier:@"@bob:sendingnetwork-.org"]);
    XCTAssertFalse([MXTools isSendingnetworkUserIdentifier:@"@bob:sendingnetwork.&aaz.org"]);
    
    XCTAssertTrue([MXTools isSendingnetworkUserIdentifier:@"@Bob:sending.network"]);
    XCTAssertTrue([MXTools isSendingnetworkUserIdentifier:@"@bob1234:sending.network"]);
    XCTAssertTrue([MXTools isSendingnetworkUserIdentifier:@"@+33012:sending.network"]);

    XCTAssertTrue([MXTools isSendingnetworkEventIdentifier:@"$123456EventId:sending.network"]);
    XCTAssertTrue([MXTools isSendingnetworkEventIdentifier:@"$pmOSN/DognfuSfhdW/qivXT19lfCWpdSfaPFKDBTJUk+"]);

    XCTAssertTrue([MXTools isSendingnetworkRoomIdentifier:@"!an1234Room:sending.network"]);

    XCTAssertTrue([MXTools isSendingnetworkRoomAlias:@"#sendingnetwork:sending.network"]);
    XCTAssertTrue([MXTools isSendingnetworkRoomAlias:@"#sendingnetwork:sending.network:1234"]);

    XCTAssertTrue([MXTools isSendingnetworkGroupIdentifier:@"+sendingnetwork:sending.network"]);
}


#pragma mark - Strings encoding

// Sendingnetwork identifiers can be found at https://sending.network/docs/spec/appendices.html#common-identifier-format
- (void)testRoomIdEscaping
{
    NSString *string = @"!tDRGDwZwQnlkowsjsm:sending.network";
    XCTAssertEqualObjects([MXTools encodeURIComponent:string], @"!tDRGDwZwQnlkowsjsm%3Asending.network");
}

- (void)testRoomAliasEscaping
{
    NSString *string = @"#riot-ios:sending.network";
    XCTAssertEqualObjects([MXTools encodeURIComponent:string], @"%23riot-ios%3Asending.network");
}

- (void)testEventIdEscaping
{
    NSString *string = @"$155006612045UiBxj:sending.network";
    XCTAssertEqualObjects([MXTools encodeURIComponent:string], @"%24155006612045UiBxj%3Asending.network");
}

- (void)testV3EventIdEscaping
{
    NSString *string = @"$pmOSN/DognfuSfhdW/qivXT19lfCWpdSfaPFKDBTJUk+";
    XCTAssertEqualObjects([MXTools encodeURIComponent:string], @"%24pmOSN%2FDognfuSfhdW%2FqivXT19lfCWpdSfaPFKDBTJUk%2B");
}

- (void)testGroupIdEscaping
{
    NSString *string = @"+sendingnetwork:sending.network";
    XCTAssertEqualObjects([MXTools encodeURIComponent:string], @"%2Bsendingnetwork%3Asending.network");
}


#pragma mark - File extensions

- (void)testFileExtensionFromImageJPEGContentType
{
    XCTAssertEqualObjects([MXTools fileExtensionFromContentType:@"image/jpeg"], @".jpeg");
}

#pragma mark - URL creation

- (void)testUrlGeneration
{
    NSString *base = @"https://www.domain.org";
    NSString *parameter = @"parameter_name=parameter_value";
    NSString *currentResult = base;
    NSString *url = [NSString stringWithFormat:@"%@?%@", base, parameter];
    while (url.length < [MXTools kMXUrlMaxLength]) {
        currentResult = [MXTools urlStringWithBase:currentResult queryParameters:@[parameter]];
        // if the url is shorter than kMXUrlMaxLength, the result shouldn't be truncated
        XCTAssertEqualObjects(url, currentResult);
        url = [NSString stringWithFormat:@"%@&%@", url, parameter];
    }
    
    // if the URL is longer than kMXUrlMaxLength, no more parameter should be added
    XCTAssertEqualObjects(currentResult, [MXTools urlStringWithBase:currentResult queryParameters:@[parameter]]);
    XCTAssertNotEqualObjects(url, [MXTools urlStringWithBase:currentResult queryParameters:@[parameter]]);
}

@end
