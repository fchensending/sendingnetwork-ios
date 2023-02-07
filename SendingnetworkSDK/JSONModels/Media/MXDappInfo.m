//
//  MXDappInfo.m
//  SendingnetworkSDK
//
//  Created by fqchen.abcft on 8/20/22.
//

#import "MXDappInfo.h"

@interface MXDappInfo()

@property (nonatomic, readwrite) NSString *appName;
@property (nonatomic, readwrite) NSString *appUrl;
@property (nonatomic, readwrite) NSString *appLogo;

@end

@implementation MXDappInfo

static NSString * const kAppNameJSONKey = @"app_name";
static NSString * const kAppUrlJSONKey = @"app_url";
static NSString * const kAppLogoJSONKey = @"app_logo";

- (BOOL)isEmpty {
    if (_appName || _appUrl || _appLogo) {
        return false;
    }
    return true;
}

+ (instancetype)modelFromJSON:(NSDictionary *)JSONDictionary
{
    MXDappInfo *ret = [MXDappInfo new];
    MXJSONModelSetString(ret.appName, JSONDictionary[kAppNameJSONKey])
    MXJSONModelSetString(ret.appUrl, JSONDictionary[kAppUrlJSONKey])
    MXJSONModelSetString(ret.appLogo, JSONDictionary[kAppLogoJSONKey])
    
    return ret;
}

- (NSDictionary *)JSONDictionary {
    return @{
        kAppNameJSONKey: _appName,
        kAppUrlJSONKey: _appUrl,
        kAppLogoJSONKey: _appLogo
    };
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _appName = [coder decodeObjectForKey:kAppNameJSONKey];
        _appUrl = [coder decodeObjectForKey:kAppUrlJSONKey];
        _appLogo = [coder decodeObjectForKey:kAppLogoJSONKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_appName forKey:kAppNameJSONKey];
    [coder encodeObject:_appUrl forKey:kAppUrlJSONKey];
    [coder encodeObject:_appLogo forKey:kAppLogoJSONKey];
}


@end
