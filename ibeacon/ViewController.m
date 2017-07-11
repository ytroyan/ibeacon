//
//  ViewController.m
//  ibeacon
//
//  Created by Troyan on 12/27/16.
//  Copyright © 2016 Troyan. All rights reserved.
//

#import "ViewController.h"

@import CoreLocation;
@import UserNotifications;

@interface ViewController ()<CLLocationManagerDelegate>



@end

@implementation ViewController{
    CLBeaconRegion * _region;
    CLLocationManager * _locMan;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _locMan=[[CLLocationManager alloc]init];
    _locMan.delegate=self;
    [_locMan requestAlwaysAuthorization];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

    [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert  completionHandler:^(BOOL granted, NSError * _Nullable error) {

    }];

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
            _region=[[CLBeaconRegion alloc]initWithProximityUUID:[[NSUUID alloc]initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E3"]  identifier:@"BeaconRegion"];
            _region.notifyOnEntry=YES;
            _region.notifyOnExit=YES;
            _region.notifyEntryStateOnDisplay=YES;
            [_locMan startRangingBeaconsInRegion:_region];
            [_locMan startMonitoringForRegion:_region];
            [_locMan requestStateForRegion:_region];
            break;

        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager
rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
              withError:(NSError *)error{
    
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region{
    NSLog(@"didRangeBeacons %i", beacons.count);
    [self sendLocalNotification:@"didRangeBeacons"
                        message:[NSString stringWithFormat:@"%@", region.identifier]
                     identifier:@"didRangeBeacons"];
}

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    NSLog(@"didDetermineState %@, %i", region.identifier, state);
//    [self sendLocalNotification:@"didDetermineState"
//                        message:[NSString stringWithFormat:@"%@", region.identifier]
//                     identifier:@"didDetermineState"];
}

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region{

    NSLog(@"didEnterRegion %@", region.identifier);
    [self sendLocalNotification:@"didEnterRegion"
                        message:[NSString stringWithFormat:@"%@", region.identifier]
                     identifier:@"didEnterRegion"];

}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region{

    NSLog(@"didExitRegion %@", region.identifier);

    [self sendLocalNotification:@"didExitRegion"
                        message:[NSString stringWithFormat:@"%@", region.identifier]
                     identifier:@"didExitRegion"];

}

-(void)sendLocalNotification:(NSString*)title
                     message:(NSString*)message
                  identifier:(NSString*)identifier{

    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {

        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
            if (notifications.count < 1) {
                return;
            }
            NSArray * requests = [notifications valueForKey:@"request"];
            NSArray * identifiers = [requests valueForKey:@"identifier"];
            if ([identifiers containsObject:identifier]) {
                return;
            }
            UNMutableNotificationContent *objNotificationContent = [[UNMutableNotificationContent alloc] init];
            objNotificationContent.title = title;
            objNotificationContent.body = message;
            objNotificationContent.sound=[UNNotificationSound defaultSound];
            UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                                  content:objNotificationContent trigger:trigger];

            [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                if (!error) {
                    NSLog(@"Local Notification succeeded");
                }
                else {
                    NSLog(@"Local Notification failed");
                }
            }];
        }];

    }


}

@end
