//
//  MXLoginDIDIdentityProvider.h
//  SendingnetworkSDK
//
//  Created by fqchen.abcft on 8/3/22.
//

#import "MXJSONModel.h"
#import "MXDIDLoginIdentifier.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Spec
 */
@interface MXLoginDIDIdentityProvider : MXJSONModel


@property (nonatomic, readonly) NSString *type;

/**
 The identifier field (id field in JSON) is the Identity Provider identifier used for the DID login
 */
@property (nonatomic, readonly) MXDIDLoginIdentifier *identifier;

+ (instancetype)modelFromIdentifier:(MXDIDLoginIdentifier *)identifier;

@end

NS_ASSUME_NONNULL_END
