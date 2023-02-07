//
//  MXDappInfo.h
//  SendingnetworkSDK
//
//  Created by fqchen.abcft on 8/20/22.
//
#import <Foundation/Foundation.h>
#import "MXJSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MXDappInfo : MXJSONModel

- (BOOL)isEmpty;

@property (nonatomic, readonly, nullable) NSString *appName;

@property (nonatomic, readonly, nullable) NSString *appUrl;

@property (nonatomic, readonly, nullable) NSString *appLogo;

@end

NS_ASSUME_NONNULL_END
