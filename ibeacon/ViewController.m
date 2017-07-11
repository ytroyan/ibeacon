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
    [self startMonitoring];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

    [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert  completionHandler:^(BOOL granted, NSError * _Nullable error) {

    }];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];


    
}

-(void)enterBackground{
    NSLog(@"enterBackground");
    [self startMonitoring];

}
-(void)startMonitoring{

    _region=[[CLBeaconRegion alloc]initWithProximityUUID:[[NSUUID alloc]initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E3"]  identifier:@"BeaconRegion"];
    _region.notifyOnEntry=YES;
    _region.notifyOnExit=YES;
    _region.notifyEntryStateOnDisplay=YES;
    [_locMan startMonitoringForRegion:_region];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{

    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
            manager.allowsBackgroundLocationUpdates = true;
            [self startMonitoring];
            break;
    default:
            break;
    }

}



- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region{
    NSLog(@"didRangeBeacons %lu", (unsigned long)beacons.count);
}

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{

    NSLog(@"didDetermineState %@, %li", region.identifier, (long)state);
    [self sendLocalNotification:@"didDetermineState"
                        message:[NSString stringWithFormat:@"%@, state=%li", region.identifier, (long)state]
                     identifier:@"didDetermineState"];
}

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region{

    NSLog(@"didEnterRegion %@", region.identifier);
    [self sendLocalNotification:@"didEnterRegion"
                        message:[NSString stringWithFormat:@"%@", region.identifier]
                     identifier:@"didEnterRegion"];
      [_locMan startRangingBeaconsInRegion:(CLBeaconRegion*)region];

}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region{

    NSLog(@"didExitRegion %@", region.identifier);

    [self sendLocalNotification:@"didExitRegion"
                        message:[NSString stringWithFormat:@"%@", region.identifier]
                     identifier:@"didExitRegion"];
    [_locMan stopRangingBeaconsInRegion:(CLBeaconRegion*)region];

}

-(void)sendLocalNotification:(NSString*)title
                     message:(NSString*)message
                  identifier:(NSString*)identifier{

    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {

        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];            UNMutableNotificationContent *objNotificationContent = [[UNMutableNotificationContent alloc] init];
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


    } else {
        [self showMessage:message
                withTitle:title
                     type:UIAlertControllerStyleAlert
                cancelBtn:@"Ok"];
    }


}

-(void)showMessage:(NSString *)message
         withTitle:(NSString *)title
              type:(UIAlertControllerStyle)type
         cancelBtn:(NSString *)cancelBtn
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:type];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelBtn
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                         }];

    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
