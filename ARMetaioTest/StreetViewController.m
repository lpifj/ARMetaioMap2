//
//  StreetViewController.m
//  ARMetaioMap
//
//  Created by 池田昂平 on 2014/11/26.
//  Copyright (c) 2014年 池田昂平. All rights reserved.
//

#import "StreetViewController.h"

@interface StreetViewController ()

@end

@implementation StreetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //panoramaViewインスタンス
    CLLocationCoordinate2D panoramaNear = {34.70, 137.61};
    self.panoramaView = [GMSPanoramaView panoramaWithFrame:CGRectZero nearCoordinate:panoramaNear];
    self.view =  self.panoramaView;
    
    //ビューコントローラの変更 (ViewController → StreetViewController)
    [super presentViewController:self animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
