// Copyright 2004-present Facebook. All Rights Reserved.

#import "EEAppDelegate.h"
#import "EECommunications.h"
#import "EEHomeViewController.h"
#import "EELoginViewController.h"
#import "EEMapStore.h"
#import "EEMapViewController.h"
#import "EESavedMapViewController.h"
#import "EEStatsViewController.h"

@implementation EEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

  [FBProfilePictureView class];
  [Parse setApplicationId:@"eWCDbE2V8Q4TXMLJMlA0wmeUF4cAWzWZFj8cCXqB"
                clientKey:@"qxsMDMKC1yoJHT1zOuKqOeaC36w6xCa9vX1jquly"];
  [PFFacebookUtils initializeFacebook];
  [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

  [application registerForRemoteNotificationTypes:
                                UIRemoteNotificationTypeBadge |
                                UIRemoteNotificationTypeAlert |
                                UIRemoteNotificationTypeSound];

  NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
  if (notificationPayload) {
    NSString *sharedID = [notificationPayload objectForKey:@"sharedProperty"];
    PFObject *sharedProperty = [PFObject objectWithoutDataWithClassName:@"sharedProperties"
                                                               objectId:sharedID];
    [sharedProperty fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
      if (!error && [PFUser currentUser]) {
        PFObject *mapObject = [sharedProperty objectForKey:@"sharedMap"];
        [mapObject fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
          if (!error) {
            [EECommunications decipherMap:object isShared:sharedProperty withCallback:^(BOOL succeeded) {
              if (succeeded) {
                NSString *mapKey = [mapObject objectForKey:@"mapKey"];
                EEMap *sharedMap = [[EEMapStore sharedStore] findMapForKey:mapKey];
                EESavedMapViewController *smvc = [[EESavedMapViewController alloc] initWithMap:sharedMap toUpload:NO atIndex:nil fromNotifiation:YES];
                _navController = [[UINavigationController alloc] initWithRootViewController:smvc];
                _navController.delegate = smvc;
                _window.rootViewController = _navController;
              }
            }];
          }
        }];
      }
    }];
  }

  if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
    EEHomeViewController *hvc = [[EEHomeViewController alloc] init];
    _navController = [[UINavigationController alloc] initWithRootViewController:hvc];
    _navController.delegate = hvc;

  } else {
    EELoginViewController *loginViewController = [[EELoginViewController alloc] init];
    _navController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    _navController.delegate = loginViewController;
  }
  _window.rootViewController = _navController;
  _window.backgroundColor = [UIColor whiteColor];
  [_window makeKeyAndVisible];
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
  return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
  return [PFFacebookUtils handleOpenURL:url];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
  PFInstallation *currentInstallation = [PFInstallation currentInstallation];
  [currentInstallation setDeviceTokenFromData:newDeviceToken];
  currentInstallation.channels = @[@"global"];
  [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
  NSString *sharedID = [userInfo objectForKey:@"sharedProperty"];
  PFObject *sharedProperty = [PFObject objectWithoutDataWithClassName:@"sharedProperties"
                                                             objectId:sharedID];
  [sharedProperty fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
    if (!error && [PFUser currentUser]) {
      PFObject *mapObject = [sharedProperty objectForKey:@"sharedMap"];
      [mapObject fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
          [EECommunications decipherMap:object isShared:sharedProperty withCallback:^(BOOL succeeded) {
            if (succeeded) {
              NSString *mapKey = [mapObject objectForKey:@"mapKey"];
              EEMap *sharedMap = [[EEMapStore sharedStore] findMapForKey:mapKey];
              EESavedMapViewController *smvc = [[EESavedMapViewController alloc] initWithMap:sharedMap toUpload:NO atIndex:nil fromNotifiation:YES];
              [_navController pushViewController:smvc animated:YES];
            }
          }];
        }
      }];
    }
  }];

}

@end
