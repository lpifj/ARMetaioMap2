//
//  CapaTrack.m
//  ARMetaioTest
//
//  Created by 池田昂平 on 2014/11/18.
//  Copyright (c) 2014年 池田昂平. All rights reserved.
//

#import "CapaTrack.h"

@implementation CapaTrack

@synthesize delegate;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //値の初期化
        self.armarkerRecog = NO;
        self.aridNum = 0;
        self.multipleTouchEnabled = YES;
        
        [self loadSound];
        
        UIColor *dblue = [UIColor colorWithRed:0x33/255.0 green:0 blue:0x99/255.0 alpha:0.5];
        self.backgroundColor = dblue;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    //UIColor *dblue = [UIColor colorWithRed:0x33/255.0 green:0 blue:0x99/255.0 alpha:0.0];
    //UIColor *blue = [UIColor colorWithRed:0.098 green:0.098 blue:0.439 alpha:0.8];
    UIColor *deepskyblue = [UIColor colorWithRed:0 green:0.749 blue:1 alpha:1.0];
    
    if(self.armarkerRecog){
        //マーカー認識成功
        
        //円描画
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 5.0);
        CGContextSetStrokeColorWithColor(context, [deepskyblue CGColor]);
        //CGContextStrokeEllipseInRect(context, CGRectMake(self.arLocaVec2d.x - 150, self.arLocaVec2d.y - 150, 100, 100));
        CGContextStrokeEllipseInRect(context, CGRectMake(self.arLocaCGPoint.x - 150, self.arLocaCGPoint.y - 150, 100, 100));
        
        //座標・角度の表示
        NSString *arCoordinateTxt = [NSString stringWithFormat:@"x:%f  y:%f",self.arLocaVec2d.x, self.arLocaVec2d.y];
        NSString *arRotationTxt = [NSString stringWithFormat:@"z-axis:%f", self.rotation.z];
        
        CGPoint point_coor = CGPointMake(50, 50);
        CGPoint point_rota = CGPointMake(50, 100);
        UIFont *font = [UIFont systemFontOfSize:30];
        
        [arCoordinateTxt drawAtPoint:point_coor withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: deepskyblue}];
        [arRotationTxt drawAtPoint:point_rota withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: deepskyblue}];
        
        /*
        self.backgroundColor = dblue;
        
        NSString *arRecogTxt = @"Marker recognition is success.";
        CGPoint point = CGPointMake(50, 50);
        UIFont *font = [UIFont systemFontOfSize:30];
        //[arRecogTxt drawAtPoint:point withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: [UIColor orangeColor]}];
        [arRecogTxt drawAtPoint:point withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: deepskyblue}];
        
        //ID認識成功
        if(self.aridNum > 0){
            NSString *idTxt = [NSString stringWithFormat: @"Marker ID : NO.%d.", self.aridNum];
            CGPoint point2 = CGPointMake(50, 100);
            UIFont *font2 = [UIFont systemFontOfSize:30];
            //[idTxt drawAtPoint:point2 withAttributes:@{NSFontAttributeName:font2, NSForegroundColorAttributeName: [UIColor orangeColor]}];
            [idTxt drawAtPoint:point2 withAttributes:@{NSFontAttributeName:font2, NSForegroundColorAttributeName: deepskyblue}];
        }
         */
    }
    
    //マーカー認識が成功した場合に描画
    if(self.capaRecog){
        
        /*
        self.backgroundColor = blue;
        
        //メッセージ表示
        NSString *message = @"Marker recognition is success.";
        CGPoint point = CGPointMake(50, 50);
        UIFont *font = [UIFont systemFontOfSize:30];
        //[message drawAtPoint:point withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: [UIColor orangeColor]}];
        [message drawAtPoint:point withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: deepskyblue}];
        
        //円描画
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 5.0);
        //UIColor *color = [UIColor orangeColor];
        CGContextSetStrokeColorWithColor(context, [deepskyblue CGColor]);
        
        CGContextStrokeEllipseInRect(context, CGRectMake(center.x - 150, center.y - 150, 300, 300));
         */
    }
    
    //ID認識が成功した場合に描画
    if((self.capaRecog)&&(self.capaidNum > 0)){
        /*
        NSString *message = [NSString stringWithFormat: @"Marker ID : NO.%d.", self.capaidNum];
        CGPoint point = CGPointMake(50, 100);
        UIFont *font = [UIFont systemFontOfSize:30];
        //[message drawAtPoint:point withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: [UIColor orangeColor]}];
        [message drawAtPoint:point withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: deepskyblue}];
         */
        
    }
}

- (void)loadSound {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"recog" ofType:@"wav"];
    NSURL *url = [NSURL fileURLWithPath:path];
    self.capaRecogSound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
    
}

//タッチイベント
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //4点以外の認識になったとき
    if([[event allTouches] count] != 4){
        self.calcReset = YES; //再度2点間の距離を計算
        self.capaRecog = NO;
        //[self setNeedsDisplay];
        return;
    }
    [self showTouchPoint:[event allTouches]];
}

//ドラッグイベント
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([[event allTouches] count] != 4){
        return;
    }
    [self showTouchPoint:[event allTouches]];
}

//タッチオブジェクト取得
- (void)showTouchPoint:(NSSet *)allTouches{
    self.touchObjects = [allTouches allObjects]; //タッチオブジェクト(4点)を配列に保存
    
    //[self setNeedsDisplay]; //描画
    
    if(self.calcReset){
        [self calcDistance]; //距離
    }
}

//固定点と中央点を求める．中央点の相対位置を求める．
- (void)calcDistance{
    
    //手順
    //①fixP1とfixP2 (対角線上にある固定点) を求める
    //②fixP3 (3点目の固定点) を求める
    
    //最大2点間距離 = fixP1・fixP2距離
    float maxDis = 0;
    
    //固定点 (要素番号)
    int fixP1_ind = 0;
    int fixP2_ind = 0;
    int fixP3_ind = 0;
    
    //中央点 (要素番号)
    int cenP_ind = 0;
    
    //固定点
    CGPoint fixP1_posi;
    CGPoint fixP2_posi;
    CGPoint fixP3_posi;
    
    //中央点
    CGPoint cenP_posi;
    
    //①fixP1とfixP2を探す
    for(int i = 0; i < 4; i++){
        for(int j = 0; j < 4; j++){
            //全ての2点間距離を計算
            if(i != j){
                UITouch *tobj1 = [self.touchObjects objectAtIndex:i];
                UITouch *tobj2 = [self.touchObjects objectAtIndex:j];
                CGPoint loc1 = [tobj1 locationInView:self];
                CGPoint loc2 = [tobj2 locationInView:self];
                
                float disX = pow((loc1.x - loc2.x), 2); //xの差分を2乗
                float disY = pow((loc1.y - loc2.y), 2); //yの差分を2乗
                float dis = sqrt(disX + disY); //2点間の距離を求める
                
                //最大2点間距離
                if(dis > maxDis){
                    maxDis = dis;
                    fixP1_ind = i;
                    fixP2_ind = j;
                    fixP1_posi = loc1;
                    fixP2_posi = loc2;
                }
            }
        }
    }
    NSLog(@"固定点2点：(%.1f, %.1f)と(%.1f, %.1f)", fixP1_posi.x, fixP1_posi.y, fixP2_posi.x, fixP2_posi.y);
    
    //②fixP3を探す
    for(int i = 0; i < 4; i++){
        //残り2点の中から
        if((i != fixP1_ind)&&(i != fixP2_ind)){
            UITouch *tobj1 = [self.touchObjects objectAtIndex:fixP1_ind]; //fixP1
            UITouch *tobj3 = [self.touchObjects objectAtIndex:i]; //調べる点
            CGPoint loc1 = [tobj1 locationInView:self];
            CGPoint loc3 = [tobj3 locationInView:self];
            
            float disX = pow((loc1.x - loc3.x), 2);
            float disY = pow((loc1.y - loc3.y), 2);
            float dis = sqrt(disX + disY); //2点間の距離
            dis = (dis / 132) * 2.54; //px → cm 変換
            
            //fixP1との距離が特定の数値のとき
            if((dis >= 2.0)&&(dis <= 4.0)){
                NSLog(@"dis = %.1fcm", dis);
                
                UITouch *tobj2 = [self.touchObjects objectAtIndex:fixP2_ind]; //fixP2
                CGPoint loc2 = [tobj2 locationInView:self];
                
                float disX = pow((loc2.x - loc3.x), 2);
                float disY = pow((loc2.y - loc3.y), 2);
                dis = sqrt(disX + disY); //2点間の距離
                dis = (dis / 132) * 2.54; //px → cm 変換
                
                NSLog(@"dis = %.1fcm", dis);
                
                //fixP2との距離が特定の数値のとき
                if((dis >= 2.0)&&(dis <= 4.0)){
                    fixP3_ind = i;
                    fixP3_posi = loc3;
                    NSLog(@"残りの固定点：(%.1f, %.1f)", fixP3_posi.x, fixP3_posi.y);
                    
                    //中央点を求める
                    for(int i = 0; i < 4; i++){
                        if((i != fixP1_ind)&&(i != fixP2_ind)&&(i != fixP3_ind)){
                            cenP_ind = i;
                            UITouch *tobj4 = [self.touchObjects objectAtIndex:cenP_ind]; //cenP
                            cenP_posi = [tobj4 locationInView:self];
                            
                            NSLog(@"中央点：(%.1f, %.1f)", cenP_posi.x, cenP_posi.y);
                        }
                    }
                    
                    //固定点と中央点の位置関係 → マーカーの向きを4つに分類
                    if((fixP3_posi.x >= cenP_posi.x)&&(fixP3_posi.y >= cenP_posi.y)){
                        NSLog(@"回転角 0°");
                        if(fixP1_posi.y > fixP2_posi.y){
                            int index = fixP1_ind;
                            fixP1_ind = fixP2_ind;
                            fixP2_ind = index; //P1とP2 要素番号の入れ替え
                            
                            CGPoint position = fixP1_posi;
                            fixP1_posi = fixP2_posi;
                            fixP2_posi = position; //P1とP2 要素番号の入れ替え
                        }
                        
                        center.x = fixP2_posi.x + (fixP1_posi.x - fixP2_posi.x) / 2;
                        center.y = fixP1_posi.y + (fixP2_posi.y - fixP1_posi.y) / 2;
                        
                    }else if((fixP3_posi.x >= cenP_posi.x)&&(fixP3_posi.y <= cenP_posi.y)){
                        NSLog(@"回転角 90°");
                        if(fixP1_posi.y > fixP2_posi.y){
                            int index = fixP1_ind;
                            fixP1_ind = fixP2_ind;
                            fixP2_ind = index;
                            
                            CGPoint position = fixP1_posi;
                            fixP1_posi = fixP2_posi;
                            fixP2_posi = position;
                        }
                        
                        center.x = fixP1_posi.x + (fixP2_posi.x - fixP1_posi.x) / 2;
                        center.y = fixP1_posi.y + (fixP2_posi.y - fixP1_posi.y) / 2;
                        
                    }else if((fixP3_posi.x <= cenP_posi.x)&&(fixP3_posi.y <= cenP_posi.y)){
                        NSLog(@"回転角 180°");
                        if(fixP1_posi.y < fixP2_posi.y){
                            int index = fixP1_ind;
                            fixP1_ind = fixP2_ind;
                            fixP2_ind = index;
                            
                            CGPoint position = fixP1_posi;
                            fixP1_posi = fixP2_posi;
                            fixP2_posi = position;
                        }
                        
                        center.x = fixP1_posi.x + (fixP2_posi.x - fixP1_posi.x) / 2;
                        center.y = fixP2_posi.y + (fixP1_posi.y - fixP2_posi.y) / 2;
                        
                    }else if((fixP3_posi.x <= cenP_posi.x)&&(fixP3_posi.y >= cenP_posi.y)){
                        NSLog(@"回転角 270°");
                        if(fixP1_posi.y < fixP2_posi.y){
                            int index = fixP1_ind;
                            fixP1_ind = fixP2_ind;
                            fixP2_ind = index;
                            
                            CGPoint position = fixP1_posi;
                            fixP1_posi = fixP2_posi;
                            fixP2_posi = position;
                        }
                        
                        center.x = fixP2_posi.x + (fixP1_posi.x - fixP2_posi.x) / 2;
                        center.y = fixP2_posi.y + (fixP1_posi.y - fixP2_posi.y) / 2;
                        
                    }
                    
                    //静電マーカーの重心
                    float centGravX = (fixP1_posi.x + fixP2_posi.x + fixP3_posi.x) / 3;
                    float centGravY = (fixP1_posi.y + fixP2_posi.y + fixP3_posi.y) / 3;
                    self.centGrav = CGPointMake(centGravX, centGravY);
                    NSLog(@"centGrav = %@", NSStringFromCGPoint(self.centGrav));
                    
                    [self didRecognition];
                    
                    
                    //fixP1・cenP間の距離
                    float dis1X = pow((cenP_posi.x - fixP1_posi.x), 2);
                    float dis1Y = pow((cenP_posi.y - fixP1_posi.y), 2);
                    float dis1 = sqrt(dis1X + dis1Y);
                    dis1 = (dis1 / 132) * 2.54; //px → cm 変換
                    NSLog(@"dis1 (%@)と中央点の距離 = %.1fcm", NSStringFromCGPoint(fixP1_posi), dis1);
                    
                    //fixP2・cenP間の距離
                    float dis2X = pow((cenP_posi.x - fixP2_posi.x), 2);
                    float dis2Y = pow((cenP_posi.y - fixP2_posi.y), 2);
                    float dis2 = sqrt(dis2X + dis2Y);
                    dis2 = (dis2 / 132) * 2.54; //px → cm 変換
                    NSLog(@"dis2 (%@)と中央点の距離 = %.1fcm", NSStringFromCGPoint(fixP2_posi), dis2);
                    
                    //fixP3・cenP間の距離
                    float dis3X = pow((cenP_posi.x - fixP3_posi.x), 2);
                    float dis3Y = pow((cenP_posi.y - fixP3_posi.y), 2);
                    float dis3 = sqrt(dis3X + dis3Y);
                    dis3 = (dis3 / 132) * 2.54; //px → cm 変換
                    NSLog(@"dis3 (%@)と中央点の距離 = %.1fcm", NSStringFromCGPoint(fixP3_posi), dis3);
                    
                    [self identify:dis1 distance3:dis3]; //ID認識
                    
                    break; //中央点が求まったので, 探索終了
                }else{
                    self.capaRecog = NO;
                }
            }else{
                self.capaRecog = NO;
            }
        }
    }
    
    self.calcReset = NO; //一度限りの実行
}

//マーカーとして認識完了
- (void)didRecognition{

    self.capaRecog = YES; //認識状態
    
    [self.capaRecogSound play]; //認識音
    
    [self.delegate showStreetView]; //ストリートビュー表示
}

//ID (静電マーカー)
- (void)identify:(float)d1 distance3:(float)d3{
    NSLog(@"d1 = %.1fcm", d1);
    NSLog(@"d3 = %.1fcm", d3);
    
    self.capaidNum = 0;
    
    //Marker NO.1
    if( ((d1 >= 1.0)&&(d1 <= 1.6)) && ((d3 >= 2.0)&&(d3 <=  2.6)) ){
        NSLog(@"このマーカーはNO.1");
        self.capaidNum = 1;
    }
    
    //Marker NO.3
    if( ((d1 >= 2.0)&&(d1 <= 2.6)) && ((d3 >= 2.7)&&(d3 <= 3.3)) ){
        NSLog(@"このマーカーはNO.3");
        self.capaidNum = 3;
    }
    
    //Marker NO.4
    if( ((d1 >= 1.5)&&(d1 <= 2.1)) && ((d3 >= 1.4)&&(d3 <= 2.0)) ){
        NSLog(@"このマーカーはNO.4");
        self.capaidNum = 4;
    }
    
    //Marker NO.5
    if( ((d1 >= 1.8)&&(d1 <= 2.4)) && ((d3 >= 1.8)&&(d3 <= 2.4)) ){
        NSLog(@"このマーカーはNO.5");
        self.capaidNum = 5;
    }
    
    //Marker NO.6
    if( ((d1 >= 1.9)&&(d1 <= 2.5)) && ((d3 >= 2.2)&&(d3 <= 2.8)) ){
        NSLog(@"このマーカーはNO.6");
        self.capaidNum = 6;
    }
    
    //Marker NO.7
    if( ((d1 >= 2.0)&&(d1 <= 2.6)) && ((d3 >= 1.0)&&(d3 <= 1.6)) ){
        NSLog(@"このマーカーはNO.7");
        self.capaidNum = 7;
    }
    
    //Marker NO.8
    if( ((d1 >= 2.3)&&(d1 <= 2.9)) && ((d3 >= 1.4)&&(d3 <= 2.0)) ){
        NSLog(@"このマーカーはNO.8");
        self.capaidNum = 8;
    }
    
    //Marker NO.9
    if( ((d1 >= 2.7)&&(d1 <= 3.3)) && ((d3 >= 2.0)&&(d3 <= 2.6)) ){
        NSLog(@"このマーカーはNO.9");
        self.capaidNum = 9;
    }
    
}

@end
