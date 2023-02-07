// 
// Copyright 2022 New Vector Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "ContactService.h"
@interface ContactService()
@property(nonatomic, strong) NSMutableArray <NSString *>*lastContacters;
@property(nonatomic, strong) NSMutableDictionary <NSString *, MXRemark *>*lastRemarkDictionary;
@end
static NSString * const kContactListLastData = @"kContactListLastData";
static NSString * const kRemarkListLastData = @"kRemarkListLastData";
@implementation ContactService
@synthesize lastData = _lastData;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static ContactService *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
        instance.lastContacters = [NSMutableArray array];
        [instance lastData];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (void)setLastData:(MXContactsListResponse *)lastData {
    _lastData = lastData;
    [self setupLastContacters];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:lastData requiringSecureCoding:NO error:nil];
    [NSUserDefaults.standardUserDefaults setObject:data forKey:kContactListLastData];
    [NSUserDefaults.standardUserDefaults synchronize];
}

//TODO: yk take care about space and userId
- (MXContactsListResponse *)lastData {
    if (_lastData) {
        return _lastData;
    }
    NSData *data = [NSUserDefaults.standardUserDefaults objectForKey:kContactListLastData];
    if (data) {
//        NSError *error = nil;
//        NSArray *classes = @[NSArray.class,NSDictionary.class, NSString.class,MXContactsListResponse.class,MXContactPeopleData.class];
//        _lastData = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithArray:classes] fromData:data error:&error];
        _lastData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [self setupLastContacters];
    }
    return _lastData;
}

- (void)setupRooms:(NSArray <NSString *>*)rooms {
    if (!self.lastData) {
        return;
    }
    self.lastData.rooms = rooms;
    [self setLastData:_lastData];
}

- (void)setupSession:(MXSession *)session {
    self.session = session;
    [self fetchContactsList];
    [self fetchRemarkList];
}

- (void)clear {
    _lastData = nil;
    _lastContacters = nil;
    _lastRemarkDictionary = nil;
    [NSUserDefaults.standardUserDefaults removeObjectForKey:kContactListLastData];
    [NSUserDefaults.standardUserDefaults removeObjectForKey:kRemarkListLastData];
}

#pragma mark - contact data
- (void)fetchContactsList{
    if (!self.session) {
        return;
    }
    //
    NSString *userId = self.session.myUser.userId;
    if (userId.length == 0) {
        return;
    }
    [self.session.sendingnetworkRestClient getContactsListWithUserId:userId success:^(MXContactsListResponse *contactsListResponse) {
        self.lastData = contactsListResponse;
    } failure:^(NSError *error) {
        
    }];
}

- (void)setupLastContacters {
    [self.lastContacters removeAllObjects];
    for (MXContactPeopleData *people in self.lastData.people) {
        [self.lastContacters addObject:people.contactId];
    }
}

- (BOOL)isContacterRoom:(MXRoom *)room {
    if (room.directUserId != nil) {
        return [self.lastContacters containsObject:room.directUserId];
    }
    return [self.lastData.rooms containsObject:room.roomId];
}

- (BOOL)isContacter:(NSString *)contactId {
    return [self.lastContacters containsObject:contactId];
}

- (void)setIsContacter:(BOOL)isContacter
              withRoom:(MXRoom *)room
               success:(void (^)(void))success
               failure:(void (^)(NSError *error))failure
{
    __weak __typeof(room)weakRoom = room;
    [room setIsContacter:isContacter success:^{
        [self updateLastDataWithRoom:weakRoom isContacter:isContacter];
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)setIsContacter:(BOOL)isContacter
              withContactId:(NSString *)contactId
               success:(void (^)(void))success
               failure:(void (^)(NSError *error))failure
{
    NSString *myUserId = self.session.myUserId;

    if (isContacter) {
        [self.session.sendingnetworkRestClient addToFavoritesWithUserId:myUserId contactId:contactId isRoom:NO success:^{
            [self updateLastDataWithContactId:contactId isContacter:isContacter];
            success();
        } failure:failure];
    }else {
        [self.session.sendingnetworkRestClient deleteFavoritesWithUserId:myUserId contactId:contactId isRoom:NO success:^{
            [self updateLastDataWithContactId:contactId isContacter:isContacter];
            success();
        } failure:failure];
    }
}

- (void)updateLastDataWithRoom:(MXRoom *)room isContacter:(BOOL)isContacter {
    if (room.directUserId != nil) {
        if (isContacter) {
            if (![self.lastContacters containsObject:room.directUserId]) {
                [self.lastContacters addObject:room.directUserId];
            }
        }else {
            [self.lastContacters removeObject:room.directUserId];
        }
    }else {
        NSMutableArray *newRooms = self.lastData.rooms.mutableCopy;
        if (isContacter) {
            if (![newRooms containsObject:room.roomId]) {
                [newRooms addObject:room.roomId];
            }
        }else {
            [newRooms removeObject:room.roomId];
        }
        self.lastData.rooms = newRooms;
    }
}

- (void)updateLastDataWithContactId:(NSString *)contactId isContacter:(BOOL)isContacter {
    if (isContacter) {
        if (![self.lastContacters containsObject:contactId]) {
            [self.lastContacters addObject:contactId];
        }
    }else {
        [self.lastContacters removeObject:contactId];
    }
}

#pragma mark - remark data
- (void)fetchRemarkList {
    NSString *userId = self.session.myUser.userId;
    if (userId.length == 0) {
        return;
    }
    [self.session.sendingnetworkRestClient getRemarkListWithContactId:userId success:^(MXRemarkListResponse *remarkResponse) {
        self.lastRemarkDictionary = remarkResponse.remarkList.mutableCopy;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:remarkResponse.remarkList requiringSecureCoding:NO error:nil];
        [NSUserDefaults.standardUserDefaults setObject:data forKey:kRemarkListLastData];
        [NSUserDefaults.standardUserDefaults synchronize];
    } failure:^(NSError *error) {
        
    }];
}

- (NSString * _Nullable)remarkNameWithContactId:(NSString *)contactId {
    MXRemark *remark = [self.lastRemarkDictionary objectForKey:contactId];
    if (!remark) {
        return nil;
    }
    return remark.name;
}

- (NSMutableDictionary *)lastRemarkDictionarys {
    if (_lastRemarkDictionary) {
        return _lastRemarkDictionary;
    }
    NSData *data = [NSUserDefaults.standardUserDefaults objectForKey:kRemarkListLastData];
    if (data) {
        _lastRemarkDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return _lastRemarkDictionary;
}
@end
