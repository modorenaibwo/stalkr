// Copyright 2004-present Facebook. All Rights Reserved.

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class EEAnnotation;
@class EEMap;

@interface EEMapStore : NSObject <NSCoding>

@property (nonatomic, strong) NSMutableArray *allImages;

+ (instancetype)sharedStore;
- (void)addLocation:(CLLocation *)currentLocation forMap:(EEMap *)currentMap;
- (NSMutableArray *)allPointsForMap:(EEMap *)currentMap;
- (void)saveMaps;
- (void)removeMap:(EEMap *)currentMap;
- (void)addMap:(EEMap *)currentMap;
- (NSArray *)allMapTitles;
- (void)addAnnotation:(EEAnnotation *)annotation forMap:(EEMap *)currentMap;
- (void)removeAnnotation:(EEAnnotation *)annotation forMap:(EEMap *)currentMap;
- (NSArray *)allAnnotationsForMap:(EEMap *)currentMap;
- (NSArray *)allMaps;
- (void)removeAllMaps;
- (EEMap *)findMapForKey:(NSString *)mapKey;

@end
