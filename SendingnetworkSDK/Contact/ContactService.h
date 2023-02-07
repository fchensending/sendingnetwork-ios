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

#import <Foundation/Foundation.h>
#import "MXSession.h"

#define ContactServiceShared ContactService.sharedInstance
NS_ASSUME_NONNULL_BEGIN

@interface ContactService : NSObject
@property(nonatomic, strong) MXSession *session;
@property(nonatomic, strong) MXContactsListResponse *lastData;

+ (instancetype)sharedInstance;
- (void)clear;
- (void)setupSession:(MXSession *)session;
- (void)setupRooms:(NSArray <NSString *>*)rooms;
- (BOOL)isContacterRoom:(MXRoom *)room;
- (BOOL)isContacter:(NSString *)contactId;

- (void)setIsContacter:(BOOL)isContacter
              withContactId:(NSString *)contactId
               success:(void (^)(void))success
               failure:(void (^)(NSError *error))failure;
- (void)setIsContacter:(BOOL)isContacter
              withRoom:(MXRoom *)room
               success:(void (^)(void))success
               failure:(void (^)(NSError *error))failure;

- (void)fetchRemarkList;
- (NSString * _Nullable)remarkNameWithContactId:(NSString *)contactId;
@end

NS_ASSUME_NONNULL_END
