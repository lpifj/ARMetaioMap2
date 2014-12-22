//
//  BasicMapControllerViewController.m
//  ARMetaioMap
//
//  Created by 池田昂平 on 2014/11/26.
//  Copyright (c) 2014年 池田昂平. All rights reserved.
//

#import "BasicMapController.h"

@interface BasicMapController ()

@end

@implementation BasicMapController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:34.7070318
                                                            longitude:137.615537
                                                                 zoom:10];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.view = self.mapView;    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
