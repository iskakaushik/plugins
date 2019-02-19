// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

// Defines marker UI options writable from Flutter.
@protocol FLTGoogleMapMarkerOptionsSink
- (void)setAlpha:(float)alpha;
- (void)setAnchor:(CGPoint)anchor;
- (void)setConsumeTapEvents:(BOOL)consume;
- (void)setDraggable:(BOOL)draggable;
- (void)setFlat:(BOOL)flat;
- (void)setIcon:(UIImage*)icon;
- (void)setInfoWindowAnchor:(CGPoint)anchor;
- (void)setInfoWindowTitle:(NSString*)title snippet:(NSString*)snippet;
- (void)setPosition:(CLLocationCoordinate2D)position;
- (void)setRotation:(CLLocationDegrees)rotation;
- (void)setVisible:(BOOL)visible;
- (void)setZIndex:(int)zIndex;
@end

// Defines the user assigned marker id that is passed from dart.
@interface FLTMarkerId : NSObject <NSCopying>
@property(atomic, readonly) NSString* value;
- (instancetype)init:(NSString*)value;
- (BOOL)isEqual:(id)other;
- (BOOL)isEqualToId:(FLTMarkerId*)markerId;
- (NSUInteger)hash;
@end

// Defines marker controllable by Flutter.
@interface FLTGoogleMapMarkerController : NSObject <FLTGoogleMapMarkerOptionsSink>
@property(atomic, readonly) NSString* markerId;
- (instancetype)initWithPositionAndId:(CLLocationCoordinate2D)position
                             markerId:(FLTMarkerId*)markerId
                              mapView:(GMSMapView*)mapView
                            registrar:(NSObject<FlutterPluginRegistrar>*)registrar;
- (BOOL)onMarkerTap;
- (void)onInfoWindowTap;
- (void)removeMarker;
@end

typedef NS_ENUM(NSInteger, FLTMarkerUpdateEventType) { ADD, REMOVE, UPDATE };

// Defines a marker update.
@interface FLTMarkerUpdate : NSObject
@property(atomic, readonly) FLTMarkerId* markerId;
@property(atomic, readonly) FLTMarkerUpdateEventType updateEventType;
@property(atomic, readonly) id changes;
@property(atomic, readonly) CLLocationCoordinate2D position;
- (instancetype)initWithJson:(id)json;
- (void)sinkChanges:(id<FLTGoogleMapMarkerOptionsSink>)sink
          registrar:(NSObject<FlutterPluginRegistrar>*)registrar;
@end
