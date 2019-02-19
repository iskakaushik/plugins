// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapMarkerController.h"
#import "JsonConversions.h"

@implementation FLTGoogleMapMarkerController {
  GMSMarker* _marker;
  GMSMapView* _mapView;
  FlutterMethodChannel* _channel;
  BOOL _consumeTapEvents;
}
- (instancetype)initWithPositionAndId:(CLLocationCoordinate2D)position
                             markerId:(FLTMarkerId*)markerId
                              mapView:(GMSMapView*)mapView
                            registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  self = [super init];
  if (self) {
    _marker = [GMSMarker markerWithPosition:position];
    _mapView = mapView;
    _markerId = markerId.value;
    _marker.userData = @[ _markerId ];
    NSString* channelName =
        [NSString stringWithFormat:@"plugins.flutter.io/google_maps_markers_%@", _markerId];
    _channel = [FlutterMethodChannel methodChannelWithName:channelName
                                           binaryMessenger:registrar.messenger];
    _consumeTapEvents = NO;
  }
  return self;
}
- (BOOL)onMarkerTap {
  [_channel invokeMethod:@"marker#onTap" arguments:@{}];
  return _consumeTapEvents;
}
- (void)onInfoWindowTap {
  [_channel invokeMethod:@"infoWindow#onTap" arguments:@{}];
}
- (void)removeMarker {
  _marker.map = nil;
}

#pragma mark - FLTGoogleMapMarkerOptionsSink methods

- (void)setAlpha:(float)alpha {
  _marker.opacity = alpha;
}
- (void)setAnchor:(CGPoint)anchor {
  _marker.groundAnchor = anchor;
}
- (void)setConsumeTapEvents:(BOOL)consumes {
  _consumeTapEvents = consumes;
}
- (void)setDraggable:(BOOL)draggable {
  _marker.draggable = draggable;
}
- (void)setFlat:(BOOL)flat {
  _marker.flat = flat;
}
- (void)setIcon:(UIImage*)icon {
  _marker.icon = icon;
}
- (void)setInfoWindowAnchor:(CGPoint)anchor {
  _marker.infoWindowAnchor = anchor;
}
- (void)setInfoWindowTitle:(NSString*)title snippet:(NSString*)snippet {
  _marker.title = title;
  _marker.snippet = snippet;
}
- (void)setPosition:(CLLocationCoordinate2D)position {
  _marker.position = position;
}
- (void)setRotation:(CLLocationDegrees)rotation {
  _marker.rotation = rotation;
}
- (void)setVisible:(BOOL)visible {
  _marker.map = visible ? _mapView : nil;
}
- (void)setZIndex:(int)zIndex {
  _marker.zIndex = zIndex;
}
@end

static void interpretMarkerOptions(id json, id<FLTGoogleMapMarkerOptionsSink> sink,
                                   NSObject<FlutterPluginRegistrar>* registrar) {
  NSDictionary* data = json;
  id alpha = data[@"alpha"];
  if (alpha) {
    [sink setAlpha:toFloat(alpha)];
  }
  id anchor = data[@"anchor"];
  if (anchor) {
    [sink setAnchor:toPoint(anchor)];
  }
  id draggable = data[@"draggable"];
  if (draggable) {
    [sink setDraggable:toBool(draggable)];
  }
  id icon = data[@"icon"];
  if (icon) {
    NSArray* iconData = icon;
    UIImage* image;
    if ([iconData[0] isEqualToString:@"defaultMarker"]) {
      CGFloat hue = (iconData.count == 1) ? 0.0f : toDouble(iconData[1]);
      image = [GMSMarker markerImageWithColor:[UIColor colorWithHue:hue / 360.0
                                                         saturation:1.0
                                                         brightness:0.7
                                                              alpha:1.0]];
    } else if ([iconData[0] isEqualToString:@"fromAsset"]) {
      if (iconData.count == 2) {
        image = [UIImage imageNamed:[registrar lookupKeyForAsset:iconData[1]]];
      } else {
        image = [UIImage imageNamed:[registrar lookupKeyForAsset:iconData[1]
                                                     fromPackage:iconData[2]]];
      }
    }
    [sink setIcon:image];
  }
  id flat = data[@"flat"];
  if (flat) {
    [sink setFlat:toBool(flat)];
  }
  id consumeTapEvents = data[@"consumeTapEvents"];
  if (consumeTapEvents) {
    [sink setConsumeTapEvents:toBool(consumeTapEvents)];
  }
  id infoWindow = data[@"infoWindow"];
  if (infoWindow) {
    NSString* title = infoWindow[@"title"];
    NSString* snippet = infoWindow[@"snippet"];
    if (title) {
      [sink setInfoWindowTitle:title snippet:snippet];
    }
    id infoWindowAnchor = infoWindow[@"infoWindowAnchor"];
    if (infoWindowAnchor) {
      [sink setInfoWindowAnchor:toPoint(infoWindowAnchor)];
    }
  }
  id position = data[@"position"];
  if (position) {
    [sink setPosition:toLocation(position)];
  }
  id rotation = data[@"rotation"];
  if (rotation) {
    [sink setRotation:toDouble(rotation)];
  }
  id visible = data[@"visible"];
  if (visible) {
    [sink setVisible:toBool(visible)];
  }
  id zIndex = data[@"zIndex"];
  if (zIndex) {
    [sink setZIndex:toInt(zIndex)];
  }
}

@implementation FLTMarkerId
- (instancetype)init:(NSString*)value {
  self = [super init];
  if (self) {
    _value = value;
  }
  return self;
}
- (id)copyWithZone:(nullable NSZone*)zone {
  FLTMarkerId* copy = [[FLTMarkerId alloc] init];

  if (copy != nil) {
    copy->_value = _value;
  }

  return copy;
}

- (BOOL)isEqual:(id)other {
  if (other == self) return YES;
  if (!other || ![[other class] isEqual:[self class]]) return NO;
  return [self isEqualToId:other];
}
- (BOOL)isEqualToId:(FLTMarkerId*)markerId {
  if (self == markerId) return YES;
  if (markerId == nil) return NO;
  if (self.value == nil) return NO;
  return [self.value isEqualToString:markerId.value];
}
- (NSUInteger)hash {
  return [self.value hash];
}

@end

@implementation FLTMarkerUpdate
- (instancetype)initWithJson:(id)json {
  self = [super init];
  if (self) {
    NSDictionary* data = json;
    NSString* markerId = data[@"markerId"];
    if (markerId) {
      _markerId = [[FLTMarkerId alloc] init:markerId];
    } else {
      @throw([NSException exceptionWithName:@"null markerId"
                                     reason:@"No marker id was passed."
                                   userInfo:nil]);
    }

    _changes = data[@"changes"];
    NSString* updateEventType = data[@"updateEventType"];
    if (updateEventType) {
      if ([updateEventType isEqualToString:@"MarkerUpdateEventType.add"]) {
        id position = _changes[@"position"];
        if (position) {
          _position = toLocation(position);
        }
        _updateEventType = ADD;
      } else if ([updateEventType isEqualToString:@"MarkerUpdateEventType.remove"]) {
        _updateEventType = REMOVE;
      } else if ([updateEventType isEqualToString:@"MarkerUpdateEventType.update"]) {
        _updateEventType = UPDATE;
      } else {
        @throw([NSException exceptionWithName:@"invalid event type"
                                       reason:@"Event type was not one of add, remove or update."
                                     userInfo:nil]);
      }
    }
  }
  return self;
}
- (void)sinkChanges:(id<FLTGoogleMapMarkerOptionsSink>)sink
          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  interpretMarkerOptions(_changes, sink, registrar);
}

@end