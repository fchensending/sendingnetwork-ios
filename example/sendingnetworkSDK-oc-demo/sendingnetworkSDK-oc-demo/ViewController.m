//
//  ViewController.m
//  sendingnetworkSDK-oc-demo
//
//  Created by ch on 2023/2/22.
//

#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object; if (!self) return;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object; if (!self) return;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object; if (!self) return;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object; if (!self) return;
#endif
#endif
#endif

#import "ViewController.h"
#import <SendingnetworkSDK/SendingnetworkSDK-Swift.h>
#import <SendingnetworkSDK.h>
#import "sendingnetworkSDK-oc-demo-Bridging-Header.h"


@interface ViewController ()
@property(nonatomic,strong) RadixService *dendrite;
@property(nonatomic,strong) MXRestClient *client;
@property(nonatomic,strong) MXSession *session;
@end

@implementation ViewController
{
    dispatch_queue_t dendriteQueue;
    NSString *privateKey;
    NSString *walletAddress;
    NSString *base_url;
    NSString *userId;
    NSString *accessToken;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    base_url = @"http://127.0.0.1:65432";
    privateKey = @"6f2e978b08db57348dacfdf48ddaee7586b95331e0db070472bbc16a3981887e";
    walletAddress = @"0x6F47cAf3270b14AB7242317a176ed8B69d393eBb";
    
    
    MXCredentials *credentials = [[MXCredentials alloc] init];
    credentials.homeServer = base_url;
    credentials.userId = userId;
    credentials.accessToken = accessToken;
    self.client = [[MXRestClient alloc] initWithCredentials:credentials andOnUnrecognizedCertificateBlock:nil];
        
    self.dendrite = [RadixService shared];
//    [self startService];
    // Do any additional setup after loading the view.
}


- (void)startService {
    NSTimeInterval dendriteStartTime = [[NSDate now] timeIntervalSince1970];
    dendriteQueue = dispatch_queue_create("dendrite-queue", DISPATCH_QUEUE_SERIAL_WITH_AUTORELEASE_POOL);
    // TODO: @coral Initialize DendritService on demand and remove this compiler directive block
    dispatch_async(dendriteQueue, ^{
        NSLog(@"[Dendrite] Starting dendrite service...");
        [self.dendrite start];
        NSTimeInterval dendriteStartDuration = [[NSDate now] timeIntervalSince1970] - dendriteStartTime;
        NSLog(@"[Dendrite] HOMESERVER URL: %@ (%.3f used)\n", self.dendrite.baseURL, dendriteStartDuration);
    });
}

- (void)stopService {
    [self.dendrite stop];
}

- (void)didList {
    
    [self.client getDIDList:walletAddress success:^(MXDIDListResponse *response) {
        NSLog(@"getDidListSuccess:listResponse:%@",response);
    } failure:^(NSError *error) {
        NSLog(@"getDidListFail:%@",error.debugDescription);
    }];
}


- (void)createDid {
    @weakify(self);
    [self.client postCreateDID:[@"did:pkh:eip155:1:" stringByAppendingString:walletAddress] success:^(MXCreateDIDResponse *response) {
        @strongify(self);
        NSLog(@"create did success response: message-%@,did-%@,updateTime-%@",response.message,response.did,response.updated);
        [self saveWithDid:response.did params:@{@"signature":[self signMessage:response.message],@"updated":response.updated,@"operation":@"create",@"address":[@"did:pkh:eip155:1:" stringByAppendingString:self->walletAddress]}];
    } failure:^(NSError *error) {
        NSLog(@"createDidFail:%@",error.debugDescription);
    }];
}

- (void)saveWithDid:(NSString *)did params:(NSDictionary *)params {
    @weakify(self);
    [self.client postSaveDID:did withParameter:params success:^(MXSaveDIDResponse *response) {
        @strongify(self);
        [self pre_logDid:did];
    } failure:^(NSError *error) {
        
    }];
}

- (void)didInfo:(NSString *)did {
    [self.client getDIDInfo:did success:^(MXDIDListInfoResponse *response) {
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)pre_logDid:(NSString *)did {
    [self.client postPreLoginDID:did success:^(MXPreLoginResponse *response) {
        [self loginWithDID:did withIdentifier:@{@"did":did,@"token":[self signMessage:response.message]} updateTime:response.updated];
    } failure:^(NSError *error) {
        
    }];
}

- (void)loginWithDID:(NSString *)did withIdentifier:(NSDictionary *)identifier updateTime:(NSString *)updateTime {
    [self.client postLoginDID:did withParameter:identifier success:^(MXDIDLoginResponse *response) {
        NSLog(@"userID:%@,accessToken:%@",response.userId,response.accessToken);
        
        [self reInitWithUserId:response.userId accessToken:response.accessToken];

        [self event_dispatch];
    } failure:^(NSError *error) {
        
    }];
}

- (void)reInitWithUserId:(NSString *)userId accessToken:(NSString *)accessToken {
    MXCredentials *credentials = [[MXCredentials alloc] init];
    credentials.homeServer = base_url;
    credentials.userId = userId;
    credentials.accessToken = accessToken;
    self.client = [[MXRestClient alloc] initWithCredentials:credentials andOnUnrecognizedCertificateBlock:nil];
    self.session = [[MXSession alloc] initWithSendingnetworkRestClient:self.client];
}

- (void)event_dispatch {
    [self.session start:^{
        [self.session listenToEvents:^(MXEvent *event, MXTimelineDirection direction, id customObject) {
            // self.session is ready to be used
            // Now we can get all rooms with:
            // self.session.rooms -> [MXRoom]
            NSLog(@"%@",self.session.rooms);
            //event
            switch (direction) {
                case MXTimelineDirectionForwards:
                    // Live/New events come here
                    if ([event.wireType isEqualToString:kMXEventTypeStringRoomMessage]) {
                        
                    }
                    if ([event.wireType isEqualToString:kMXEventTypeStringRoomMember]) {
                        
                    }
                    //......

                    break;
                case MXTimelineDirectionBackwards:
                    NSLog(@"get event backwards: %@", event);
                    break;
                    
                default:
                    break;
            }
        }];
    } failure:^(NSError *error) {
        
    }];
}

- (NSString*)signMessage:(NSString *)message {
    return @"";
}




@end
