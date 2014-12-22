//
//  ViewController.m
//  ARMetaioTest
//
//  Created by 池田昂平 on 2014/10/20.
//  Copyright (c) 2014年 池田昂平. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.glView = [[EAGLView alloc] initWithFrame:self.view.bounds]; //EAGLView (metaio AR)
    self.capatrack = [[CapaTrack alloc] initWithFrame:self.view.bounds]; //CapaTrack (metaio AR)
    
    self.capatrack.delegate = self;

    m_metaioSDK->setTrackingEventCallbackReceivesAllChanges(true); //常時onTrackingEventを呼ぶ
    
    [self loadSound]; //サウンド設定
    
    [self showMap]; //地図表示
    
    [self loadConfig]; //マーカー設定ファイル (AR)
    
    [self.view addSubview:self.capatrack];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//サウンド設定
- (void)loadSound {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"recogHover" ofType:@"wav"];
    NSURL *url = [NSURL fileURLWithPath:path];
    self.recogSound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
}

//認識イベント (ARマーカー)
- (void)onTrackingEvent:(const metaio::stlcompat::Vector<metaio::TrackingValues> &)poses{
    
      if(poses.size() >= 1){
      //NSLog(@"onTrackingEvent: quality:%0.2f", poses[1].quality);
            
      //for(int i = 0; i < poses.size(); i++){
        if(poses[0].quality >= 0.5){
            self.capatrack.armarkerRecog = YES;
            [self.recogSound play];
            
            NSLog(@"capaRecog = %d", self.capatrack.capaRecog);
            
            if(self.capatrack.capaRecog){   //初めて認識された1回のみ
                [self.capatrack removeFromSuperview];
                [self showMap]; //地図表示
                [self.view addSubview:self.capatrack];
                
                //NSLog(@"preMapCoordinate = (%f, %f)", preMapCoordinate.longitude, preMapCoordinate.latitude);
                
            }else{
                bool isMapPorjEnabled = [self.mapView.projection containsCoordinate:preMapCoordinate];
                if(isMapPorjEnabled){
                    //Vector3d 切り捨てしてから代入
                    self.capatrack.transComp = metaio::Vector3d(floor(poses[0].translation.x), floor(poses[0].translation.y), floor(poses[0].translation.z));
                    
                    //座標
                    //self.capatrack.arLocaVec2d = m_metaioSDK->getViewportCoordinatesFrom3DPosition(poses[0].coordinateSystemID, self.capatrack.transComp); //Vector3d → Vector2d
                    
                    if(self.capatrack.transComp.z <= -100){ //ある程度カメラに接近したら中止
                        //地図の移動
                        
                        self.capatrack.arLocaVec2d = metaio::Vector2d(poses[0].translation.y, poses[0].translation.x);
                        self.capatrack.arLocaCGPoint = CGPointMake(968*(self.capatrack.arLocaVec2d.x/175)+(968/2)-180, 1024*(self.capatrack.arLocaVec2d.y/210)+(1024/2));
                        
                        //self.capatrack.arLocaCGPoint = CGPointMake(self.capatrack.arLocaVec2d.x, self.capatrack.arLocaVec2d.y); //Vector2d → CGPoint
                        mapCoordinate = [self.mapView.projection coordinateForPoint: self.capatrack.arLocaCGPoint]; //CGPoint → CLLocationCoordinate2D
                        [self.mapView animateToLocation:mapCoordinate];
                        NSLog(@"mapCoordinate (%f, %f)", mapCoordinate.longitude, mapCoordinate.latitude);
                        
                        preMapCoordinate = mapCoordinate;
                        
                        //地図の拡大・縮小
                        float zoomLevel = 12;
                        
                        if(self.capatrack.transComp.z <= -1410){
                            zoomLevel = 12;
                        }else{
                            zoomLevel = 14;
                        }
                        [self.mapView animateToZoom:zoomLevel];
                        NSLog(@"zoomLevel = %f", zoomLevel);
                    }
                }else{
                    NSLog(@"MapProj is not Enabled");
                }
                //NSLog(@"preMapCoordinate = (%f, %f)", preMapCoordinate.longitude, preMapCoordinate.latitude);
            }
            
            self.capatrack.capaRecog = NO;

            //ID
            NSString *markerName = [NSString stringWithCString:poses[0].cosName.c_str() encoding:[NSString defaultCStringEncoding]];
            [self recogARID:markerName];
            
            //角度  Rotation → Vector3d
            self.capatrack.rotation = poses[0].rotation.getEulerAngleDegrees();
            
            //NSLog(@"coordinateID = %d", poses[0].coordinateSystemID);
            
            [self.capatrack setNeedsDisplay];
            
            NSLog(@"3次元 x座標:%f, y座標:%f, z座標:%f", self.capatrack.transComp.x, self.capatrack.transComp.y, self.capatrack.transComp.z); //3次元座標
            NSLog(@"2次元(Vector2d) x座標:%f, y座標:%f ", self.capatrack.arLocaVec2d.x, self.capatrack.arLocaVec2d.y); //2次元座標
            NSLog(@"2次元(CGPoint) x座標:%f, y座標:%f ", self.capatrack.arLocaCGPoint.x, self.capatrack.arLocaCGPoint.y); //2次元座標
        }else{
            self.capatrack.armarkerRecog = NO;
        }
      //}
        
    }
    //NSLog(@"poses.size() = %lu", poses.size());
    //NSLog(@"poses[0].quality = %f", poses[0].quality);
    //NSLog(@"poses[1].quality = %f", poses[1].quality);
}

//マーカー設定ファイル読み込み (AR)
- (void)loadConfig {
    NSString *trackingid01 = [[NSBundle mainBundle] pathForResource:@"idmarkerConfig" ofType:@"zip"];
    if(trackingid01){
        bool success = m_metaioSDK->setTrackingConfiguration([trackingid01 UTF8String]);
        if(!success){
            NSLog(@"No success loading the trackingconfiguration");
        }
    }else{
        NSLog(@"No success loading the trackingconfiguration");
    }
}

//ID認識 (ARマーカー)
- (void)recogARID:(NSString *)markerName{
    
    if([markerName isEqualToString:@"ID marker 1"]){
        self.capatrack.aridNum = 1;
    }else if([markerName isEqualToString:@"ID marker 2"]){
        self.capatrack.aridNum = 2;
    }else{
        self.capatrack.aridNum = 0;
        NSLog(@"maker name is %@", markerName);
    }
}

//地図の表示
- (void)showMap {
    [self.mapView animateToViewingAngle:45];
    CLLocationCoordinate2D defaultMapCoordinate = {34.7070318, 137.615537};
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:defaultMapCoordinate.latitude
                                                            longitude:defaultMapCoordinate.longitude
                                                                 zoom:12];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.view = self.mapView;
    
    preMapCoordinate = defaultMapCoordinate;
}

- (void)showStreetView {
    
    CLLocationCoordinate2D panoramaNear = {34.70, 137.61};
    GMSPanoramaView* panoramaView = [GMSPanoramaView panoramaWithFrame:CGRectZero nearCoordinate:panoramaNear];
    self.view =  panoramaView;
    
    bool isMapPorjEnabled = [self.mapView.projection containsCoordinate:preMapCoordinate];
    if(isMapPorjEnabled){
        panoramaNear = [self.mapView.projection coordinateForPoint: self.capatrack.centGrav]; //CGPoint → CLLocationCoordinate2D
        [panoramaView moveNearCoordinate:panoramaNear];
    }

    //panoramaNear = [self.mapView.projection coordinateForPoint: self.capatrack.arLocaCGPoint];
        
    NSLog(@"showStreetView was called");
    NSLog(@"panoramaNear (%f, %f)", panoramaNear.longitude, panoramaNear.latitude);
}

@end
