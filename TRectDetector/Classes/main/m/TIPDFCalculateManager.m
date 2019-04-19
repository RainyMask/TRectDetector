//
//  TIPDFCalculateManager.m
//  DocumentScanner
//
//  Created by tao on 2018/6/3.
//  Copyright © 2018年 tao. All rights reserved.
//

#import "TIPDFCalculateManager.h"

@implementation TIPDFCalculateManager

/*
 * 计算两点间距离
 */
+ (CGFloat)distanceOfStartPoint:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint {
    return  sqrtf(powf(startPoint.x  - endPoint.x, 2) + powf(startPoint.y - endPoint.y, 2));
}


/*
 *  两条线是否有交点
 */
+ (BOOL)haveCrossPoint:(CGPoint)s1 end_1:(CGPoint)e1 start_2:(CGPoint)s2 end_2:(CGPoint)e2 {
    
    CGFloat k1 = (s1.y - e1.y) / (s1.x - e1.x);
    CGFloat k2 = (s2.y - e2.y) / (s2.x - e2.x);
    
    return k1 != k2;
}

/*
 * 两条直线的交点
 */
+ (CGPoint)returnCrossPoint:(CGPoint)s1 end_1:(CGPoint)e1 start_2:(CGPoint)s2 end_2:(CGPoint)e2 {
    CGFloat k1 = (s1.y - e1.y) / (s1.x - e1.x);
    CGFloat b1 = s1.y - (k1 * s1.x);
    
    CGFloat k2 = (s2.y - e2.y) / (s2.x - e2.x);
    CGFloat b2 = s2.y - (k2 * s2.x);
    
    CGFloat x = (b1 - b2) / (k2 - k1);
    CGFloat y = k1 * x + b1;
    
    return CGPointMake(x, y);
}



+ (BOOL)isQuadrilateralOfPoints:(CGPoint)topL topR:(CGPoint)topR bottomL:(CGPoint)bottomL bottomR:(CGPoint)bottomR {
    //任意一条边  与不相邻的一边是否有交点
    
    //1.topL->topR  VS  bottomL->bottomR
    if ([self lineIntersects:topL e1:topR s2:bottomL e2:bottomR]) {
        return false;
    }
    
    if ([self lineIntersects:topR e1:bottomR s2:topL e2:bottomL]) {
        return false;
    }
    
    return true;
}


+ (CGPoint)pointSub:(CGPoint)fir sec:(CGPoint)sec {
    return CGPointMake(fir.x - sec.x, fir.y - sec.y);
}

+ (CGFloat)pointCrossPow:(CGPoint)fir sec:(CGPoint)sec {
    return fir.x * 1.0 * sec.y - sec.x * 1.0 * fir.y;
}

+ (BOOL)lineIntersects:(CGPoint)s1 e1:(CGPoint)e1 s2:(CGPoint)s2 e2:(CGPoint)e2 {
    if (MAX(s1.x, e1.x) < MIN(s2.x, e2.x) ||
        MAX(s1.y, e1.y) < MIN(s2.y, e2.y) ||
        MIN(s1.x, e1.x) > MAX(s2.x, e2.x) ||
        MIN(s1.y, e1.y) > MAX(s2.y, e2.y)) {
        return false;
    }
    
    CGFloat pow1 = [self pointCrossPow:[self pointSub:s1 sec:s2]
                                   sec:[self pointSub:e2 sec:s2]]
                * [self pointCrossPow:[self pointSub:e2 sec:s2]
                                  sec:[self pointSub:e1 sec:s2]];
    
    CGFloat pow2 = [self pointCrossPow:[self pointSub:s2 sec:s1]
                                   sec:[self pointSub:e1 sec:s1]]
                * [self pointCrossPow:[self pointSub:e1 sec:s1]
                                  sec:[self pointSub:e2 sec:s1]];
    
    if (pow1 >= 0.f && pow2 >= 0.f) {
        return true;
    }
    return false;
}


/**
 * 四边形的面积
 */
+ (CGFloat)areaOfTheQuadrilateral:(CIRectangleFeature *)feature {
    
    CGFloat area = 0.f;
    
    area += (feature.topLeft.x*feature.topRight.y - feature.topLeft.y*feature.topRight.x);
    area += (feature.topRight.x*feature.bottomRight.y - feature.topRight.y*feature.bottomRight.x);
    area += (feature.bottomRight.x*feature.bottomLeft.y - feature.bottomRight.y*feature.bottomLeft.x);
    area += (feature.bottomLeft.x*feature.topLeft.y - feature.bottomLeft.y*feature.topLeft.x);
    
    area = fabs(area*0.5);
    
    return area;
}




@end
