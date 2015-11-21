// Copyright 2004-present Facebook. All Rights Reserved.

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

@class EEAnnotation;
@class EEMap;

typedef void(^EECommunicationsCompleteBlock)(BOOL succeeded);

@interface EECommunications : NSObject

+ (void)loginWithCallback:(EECommunicationsCompleteBlock)callback;
+ (void)uploadMap:(EEMap *)currentMap withCallback:(EECommunicationsCompleteBlock)callback;
+ (void)getMapsWithCallback:(EECommunicationsCompleteBlock)callback;
+ (void)shareMap:(EEMap *)currentMap withFriends:(NSArray *)friendsID withCallback:(EECommunicationsCompleteBlock)callback;
+ (void)deleteMap:(EEMap *)currentMap;
+ (void)requestImageForAnnotation:(EEAnnotation *)annotation withCallback:(EECommunicationsCompleteBlock)callback;
+ (void)decipherMap:(PFObject *)mapObject isShared:(PFObject *)sharedProperty withCallback:(EECommunicationsCompleteBlock)callback;
+ (void)requestStatus:(NSString *)text;
+ (void)createGraphObject;
+ (void)checkMapExists:(EEMap *)currentMap withCallback:(EECommunicationsCompleteBlock)callback;

@end
