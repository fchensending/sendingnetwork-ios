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

#import "SendingnetworkSDKTestsData.h"

#import "MXRoomMember.h"

@interface MXRoomMemberTests : XCTestCase
{
    SendingnetworkSDKTestsData *sendingnetworkSDKTestsData;
}
@end

@implementation MXRoomMemberTests

- (void)setUp
{
    [super setUp];

    sendingnetworkSDKTestsData = [[SendingnetworkSDKTestsData alloc] init];
}

- (void)tearDown
{
    sendingnetworkSDKTestsData = nil;
    
    [super tearDown];
}

- (void)testKickedMember
{
    [sendingnetworkSDKTestsData doMXRestClientTestWithBobAndAliceInARoom:self readyToTest:^(MXRestClient *bobRestClient, MXRestClient *aliceRestClient, NSString *roomId, XCTestExpectation *expectation) {
        
        [bobRestClient kickUser:sendingnetworkSDKTestsData.aliceCredentials.userId fromRoom:roomId reason:@"No particular reason" success:^{
            
            // Check room actual members
            [bobRestClient membersOfRoom:roomId success:^(NSArray *roomMemberEvents) {
                
                for (MXEvent *roomMemberEvent in roomMemberEvents)
                {
                    MXRoomMember *member = [[MXRoomMember alloc] initWithMXEvent:roomMemberEvent];
                    
                    if ([member.userId isEqualToString:sendingnetworkSDKTestsData.aliceCredentials.userId])
                    {
                        XCTAssertEqual(member.membership, MXMembershipLeave, @"A kicked user membership is leave, not %tu", member.membership);
                        // rooms/<room_id>/members does not return prev-content anymore - we comment the related test
                        //XCTAssertEqual(member.prevMembership, MXMembershipJoin, @"The previous membership of a kicked user must be join, not %tu", member.prevMembership);
                        
                        XCTAssert([member.originUserId isEqualToString:sendingnetworkSDKTestsData.bobCredentials.userId], @"This is Bob who kicked Alice, not %@", member.originUserId);
                    }
                }
                
                [expectation fulfill];
                
            } failure:^(NSError *error) {
                XCTFail(@"Cannot check test result - error: %@", error);
                [expectation fulfill];
            }];
            
        } failure:^(NSError *error) {
            XCTFail(@"The request should not fail - NSError: %@", error);
            [expectation fulfill];
        }];
    }];
}

- (void)testEncryptionTargetMembersWithoutInvitedMember
{
    [sendingnetworkSDKTestsData doMXSessionTestWithBobAndAliceInARoom:self readyToTest:^(MXSession *bobSession, MXRestClient *aliceRestClient, NSString *roomId, XCTestExpectation *expectation) {
        MXRoom *room = [bobSession roomWithRoomId:roomId];
        
        [room state:^(MXRoomState *roomState) {
            [room members:^(MXRoomMembers *roomMembers) {
                NSArray *encryptionTargetMembers = [roomMembers encryptionTargetMembers:roomState.historyVisibility];
                XCTAssertEqual(encryptionTargetMembers.count, 2, @"Encryption target members should include all the joined members");
                [expectation fulfill];
                
            } failure:^(NSError *error) {
                XCTFail(@"The request should not fail - NSError: %@", error);
                [expectation fulfill];
            }];
        }];
        
    }];
}

// Test the list of members we should be encrypting for when there is some invited members and the room history visibility is enabled for invited members.
- (void)testEncryptionTargetMembersWithInvitedMemberAndkRoomHistoryVisibilityInvited
{
    [sendingnetworkSDKTestsData doMXSessionTestWithBobAndARoomWithMessages:self readyToTest:^(MXSession *bobSession, MXRoom *room, XCTestExpectation *expectation) {
        
        [sendingnetworkSDKTestsData doMXRestClientTestWithAlice:nil readyToTest:^(MXRestClient *aliceRestClient, XCTestExpectation *expectation2) {
            
            // We will force the room history visibility for invited members.
            [bobSession.sendingnetworkRestClient setRoomHistoryVisibility:room.roomId historyVisibility:kMXRoomHistoryVisibilityInvited success:^{
                
                // Listen to the invitation for Alice
                [bobSession listenToEventsOfTypes:@[kMXEventTypeStringRoomMember] onEvent:^(MXEvent *event, MXTimelineDirection direction, id customObject) {
                    
                    // Check whether Alice belongs to the encryption target members
                    [room state:^(MXRoomState *roomState) {
                        [room members:^(MXRoomMembers *roomMembers) {
                            NSArray *encryptionTargetMembers = [roomMembers encryptionTargetMembers:roomState.historyVisibility];
                            XCTAssertEqual(encryptionTargetMembers.count, 2, @"Encryption target members should include bob and alice");
                            [expectation fulfill];
                            
                        } failure:^(NSError *error) {
                            XCTFail(@"The request should not fail - NSError: %@", error);
                            [expectation fulfill];
                        }];
                    }];
                    
                }];
                
                // Send the invitation
                [bobSession.sendingnetworkRestClient inviteUser:aliceRestClient.credentials.userId toRoom:room.roomId success:nil failure:^(NSError *error) {
                    XCTFail(@"Cannot set up intial test conditions - error: %@", error);
                    [expectation fulfill];
                }];
                
            } failure:^(NSError *error) {
                XCTFail(@"Cannot set up intial test conditions - error: %@", error);
                [expectation fulfill];
            }];
        }];
    }];
}

// Test the list of members we should be encrypting for when there is some invited members and the room history visibility is not enabled for invited members.
- (void)testEncryptionTargetMembersWithInvitedMemberAndkRoomHistoryVisibilityJoined
{
    [sendingnetworkSDKTestsData doMXSessionTestWithBobAndARoomWithMessages:self readyToTest:^(MXSession *bobSession, MXRoom *room, XCTestExpectation *expectation) {
        
        [sendingnetworkSDKTestsData doMXRestClientTestWithAlice:nil readyToTest:^(MXRestClient *aliceRestClient, XCTestExpectation *expectation2) {
            
            // We will force the room history visibility for joined members.
            [bobSession.sendingnetworkRestClient setRoomHistoryVisibility:room.roomId historyVisibility:kMXRoomHistoryVisibilityJoined success:^{
                
                // Listen to the invitation for Alice
                [bobSession listenToEventsOfTypes:@[kMXEventTypeStringRoomMember] onEvent:^(MXEvent *event, MXTimelineDirection direction, id customObject) {
                    
                    // Check whether Alice doesn't belong to the encryption target members
                    [room state:^(MXRoomState *roomState) {
                        [room members:^(MXRoomMembers *roomMembers) {
                            NSArray *encryptionTargetMembers = [roomMembers encryptionTargetMembers:roomState.historyVisibility];
                            XCTAssertEqual(encryptionTargetMembers.count, 1, "There must be only one member: mxBob");
                            [expectation fulfill];
                            
                        } failure:^(NSError *error) {
                            XCTFail(@"The request should not fail - NSError: %@", error);
                            [expectation fulfill];
                        }];
                    }];
                    
                }];
                
                // Send the invitation
                [bobSession.sendingnetworkRestClient inviteUser:aliceRestClient.credentials.userId toRoom:room.roomId success:nil failure:^(NSError *error) {
                    XCTFail(@"Cannot set up intial test conditions - error: %@", error);
                    [expectation fulfill];
                }];
                
            } failure:^(NSError *error) {
                XCTFail(@"Cannot set up intial test conditions - error: %@", error);
                [expectation fulfill];
            }];
        }];
    }];
}

@end
