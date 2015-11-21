// Copyright 2004-present Facebook. All Rights Reserved.

#import "EECommunications.h"

#import "EEAnnotation.h"
#import "EEMap.h"
#import "EEMapStore.h"

@implementation EECommunications

+ (void)loginWithCallback:(EECommunicationsCompleteBlock)callback
{
  NSArray *permissionsArray = @[@"user_friends", @"public_profile", @"publish_actions"];
  [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
    if (!user) {
      callback(NO);
		} else {
			[FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
          NSDictionary <FBGraphUser> *me = (NSDictionary <FBGraphUser> *)result;
          [[PFUser currentUser] setObject:me.objectID forKey:@"fbId"];
          [[PFUser currentUser] setObject:me.name forKey:@"fullName"];
          NSString *profilePicAddress = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", me.objectID];
          NSURL *profilePicURL = [NSURL URLWithString:profilePicAddress];
          dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:profilePicURL];
            dispatch_async(dispatch_get_main_queue(), ^{
              PFFile *profilePicFile = [PFFile fileWithData:imageData];
              [profilePicFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                  [[PFUser currentUser] setObject:profilePicFile forKey:@"profilePic"];
                  [[PFUser currentUser] saveInBackground];
                }
              }];
            });
          });

          PFInstallation *currentInstallation = [PFInstallation currentInstallation];
          [currentInstallation setObject:me.objectID forKey:@"owner"];
          [currentInstallation saveInBackground];
          [[PFUser currentUser] saveInBackground];
          if (callback) {
            callback(YES);
          }
        }
      }];
    }
	}];
}

+ (void)uploadMap:(EEMap *)currentMap withCallback:(EECommunicationsCompleteBlock)callback
{
  PFQuery *dupMaps = [PFQuery queryWithClassName:@"EEMap"];
  [dupMaps whereKey:@"mapKey" equalTo:currentMap.mapKey];
  [dupMaps findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (!error && [objects count] == 0) {
      NSData *mapPoints = [NSKeyedArchiver archivedDataWithRootObject:currentMap.points];
      PFFile *mapPointsFile = [PFFile fileWithName:@"points" data:mapPoints];
      [mapPointsFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
          PFObject *mapObject = [PFObject objectWithClassName:@"EEMap"];
          mapObject[@"mapKey"] = currentMap.mapKey;
          mapObject[@"mapTitle"] = currentMap.mapTitle;
          mapObject[@"points"] = mapPointsFile;
          mapObject[@"userFBId"] = [[PFUser currentUser] objectForKey:@"fbId"];
          mapObject[@"user"] = [PFUser currentUser].username;
          mapObject[@"fullName"] = [[PFUser currentUser] objectForKey:@"fullName"];
          mapObject[@"location"] = currentMap.location;

          NSMutableArray *annotationsParseArray = [[NSMutableArray alloc] init];
          int count = (int)[currentMap.annotations count];
          for(int i = 0; i < count; i++ ) {
            EEAnnotation *annotation = currentMap.annotations[i];
            NSData *annotationData = [NSKeyedArchiver archivedDataWithRootObject:annotation];
            PFFile *annotationFile = [PFFile fileWithName:@"annotation" data:annotationData];
            annotationsParseArray[i] = annotationFile;
          }
          mapObject[@"annotations"] = annotationsParseArray;
          currentMap.mapObject = mapObject;
          [mapObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
              if (callback) {
                callback(YES);
              }
            } else {
              if (callback) {
                callback(NO);
              }
            }
          }];
        } else {
          if (callback) {
            callback(NO);
          }
        }
      }];
    }
  }];
}

+ (void)getMapsWithCallback:(EECommunicationsCompleteBlock)callback
{
  PFQuery *query = [PFQuery queryWithClassName:@"EEMap"];
  [query whereKey:@"userFBId" equalTo:[[PFUser currentUser] objectForKey:@"fbId"]];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (!error) {
      for (PFObject *mapObject in objects) {
        [self decipherMap:mapObject isShared:nil withCallback:^(BOOL succeeded) {
          if (succeeded) {
            if (callback) {
              callback(YES);
            }
          }
        }];
      }
    } else {
      NSLog(@"Error: %@ %@", error, [error userInfo]);
    }
  }];
  PFQuery *sharedQuery = [PFQuery queryWithClassName:@"sharedProperties"];
  [sharedQuery whereKey:@"sharedWith" equalTo:[[PFUser currentUser] objectForKey:@"fbId"]];
  [sharedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (!error) {
      for(PFObject *sharedProperty in objects) {
        PFObject *mapObject = [sharedProperty objectForKey:@"sharedMap"];
        [mapObject fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
          if (!error) {
            [self decipherMap:object isShared:sharedProperty withCallback:^(BOOL succeeded) {
              if (succeeded) {
                if (callback) {
                  callback(YES);
                }
              }
            }];
          }
        }];
      }
    } else {
      NSLog(@"Error: %@ %@", error, [error userInfo]);
    }
  }];
}

+ (void)checkMapExists:(EEMap *)currentMap withCallback:(EECommunicationsCompleteBlock)callback
{
  PFQuery *mapQuery = [PFQuery queryWithClassName:@"EEMap"];
  [mapQuery whereKey:@"mapKey" equalTo:currentMap.mapKey];
  [mapQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (!error && [objects count] > 0) {
      if (callback) {
        callback(YES);
      }
    } else {
      if (callback) {
        callback(NO);
      }
    }
  }];
}

+ (void)decipherMap:(PFObject *)mapObject isShared:(PFObject *)sharedProperty withCallback:(EECommunicationsCompleteBlock)callback
{
  NSString *mapKey = mapObject[@"mapKey"];
  if ([[EEMapStore sharedStore] findMapForKey:mapKey]) {
    if (callback) {
      callback(YES);
    }
    return;
  }
  EEMap *map = [[EEMap alloc] init];
  map.mapKey = mapKey;
  map.mapTitle = mapObject[@"mapTitle"];
  map.location = mapObject[@"location"];
  map.dateCreated = [mapObject createdAt];
  if (!sharedProperty) {
    map.mapObject = mapObject;
  } else {
    map.sharedProperty = sharedProperty;
    map.sharedBy = [sharedProperty objectForKey:@"sharedBy"];
  }
  PFFile *mapPointsFile = mapObject[@"points"];
  [mapPointsFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
    map.points = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!error) {
      NSArray *annotations = mapObject[@"annotations"];
      int annotationsCount = (int)[annotations count];
      __block int index = 0;
      if ([annotations count] == 0) {
        [[EEMapStore sharedStore] addMap:map];
      }
      for (PFFile *annotationFile in annotations) {
        [annotationFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
          EEAnnotation *unarchivedAnnotation = [NSKeyedUnarchiver unarchiveObjectWithData:data];
          [map.annotations addObject:unarchivedAnnotation];
          [self requestImageForAnnotation:unarchivedAnnotation withCallback:^(BOOL succeeded) {
            if (!succeeded) {
              UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not retrieve photos" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
              [error show];
            } else {
              index++;
              if (index == annotationsCount) {
                if (![[EEMapStore sharedStore] findMapForKey:map.mapKey]) {
                  [[EEMapStore sharedStore] addMap:map];
                }
                if (callback) {
                  callback(YES);
                }
              }
            }
          }];
        }];
      }
    }
  }];
}

+ (void)shareMap:(EEMap *)currentMap withFriends:(NSArray *)friendsID withCallback:(EECommunicationsCompleteBlock)callback
{
  for (id <FBGraphUser> friend in friendsID) {
    PFObject *sharedProperties = [PFObject objectWithClassName:@"sharedProperties"];
    if (!currentMap.sharedBy) {
      sharedProperties[@"sharedBy"] = [PFUser currentUser];
    } else {
      sharedProperties[@"sharedBy"] = currentMap.sharedBy;
      if ([[currentMap.sharedBy objectForKey:@"fbId"] isEqualToString:friend.objectID]) {
        if (callback) {
          callback(NO);
        }
        return;
      }
    }
    sharedProperties[@"sharedWith"] = friend.objectID;
    sharedProperties[@"sharedMap"] = currentMap.mapObject;
    PFQuery *sharedQuery = [PFQuery queryWithClassName:@"sharedProperties"];
    PFObject *sharedMap = [PFObject objectWithoutDataWithClassName:@"EEMap" objectId:currentMap.mapObject.objectId];
    [sharedQuery whereKey:@"sharedWith" equalTo:friend.objectID];
    [sharedQuery whereKey:@"sharedMap" equalTo:sharedMap];
    [sharedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
      if ([objects count] == 0) {
        [sharedProperties saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
          if (succeeded) {
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"owner" equalTo:friend.objectID];
            PFPush *pushNotif = [[PFPush alloc] init];
            [pushNotif setQuery:pushQuery];
            NSDictionary *data = @{@"alert": @"Your friend has shared a map with you!",
                                   @"sharedProperty": sharedProperties.objectId};
            [pushNotif setData:data];
            [pushNotif sendPushInBackground];
            if (callback) {
              callback(YES);
            }
          }
        }];
      }
    }];
  }
}

+ (void)deleteMap:(EEMap *)currentMap
{
  if (currentMap.mapObject) {
    PFQuery *sharedQuery = [PFQuery queryWithClassName:@"sharedProperties"];
    PFObject *sharedMap = [PFObject objectWithoutDataWithClassName:@"EEMap" objectId:currentMap.mapObject.objectId];
    [sharedQuery whereKey:@"sharedMap" equalTo:sharedMap];
    [sharedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
      for(PFObject *sharedProperty in objects) {
        [sharedProperty deleteEventually];
      }
    }];
    [currentMap.mapObject deleteEventually];
  } else if (currentMap.sharedProperty) {
    [currentMap.sharedProperty deleteEventually];
  }
}

+ (void)requestImageForAnnotation:(EEAnnotation *)annotation withCallback:(EECommunicationsCompleteBlock)callback
{
  if (!annotation.imageURL) {
    if (callback) {
      callback(YES);
    }
    return;
  }
  NSURL *imageRequestURL = [NSURL URLWithString:annotation.imageURL];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSData *imageData = [NSData dataWithContentsOfURL:imageRequestURL];
    dispatch_async(dispatch_get_main_queue(), ^{
      annotation.image = [UIImage imageWithData:imageData];
      if (annotation.image) {
        [[[EEMapStore sharedStore] allImages] addObject:annotation.image];
        if (callback) {
          callback(YES);
        }
      }
    });
  });
}

+ (void)requestStatus:(NSString *)text
{
  [FBRequestConnection startForPostStatusUpdate:text
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
    if (!error) {
      NSLog(@"result: %@", result);
    } else {
      NSLog(@"%@", error.description);
    }
  }];
}


+ (void)createGraphObject
{
  NSMutableDictionary <FBOpenGraphObject> *post = [FBGraphObject openGraphObjectForPost];
  post.provisionedForPost = YES;
  post.title = @"Created a map";
  post.type = @"fbmapjourney:map";

  [FBRequestConnection startForPostOpenGraphObject:post completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
    if(!error) {
      NSString *objectId = [result objectForKey:@"id"];
    } else {
      NSLog(@"Error posting the Open Graph object to the Object API: %@", error);
    }
  }];
}

@end
