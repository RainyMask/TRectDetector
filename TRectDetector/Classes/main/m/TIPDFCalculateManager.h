//
//  TIPDFCalculateManager.h
//  DocumentScanner
//
//  Created by tao on 2018/6/3.
//  Copyright © 2018年 tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreImage/CoreImage.h>

@interface TIPDFCalculateManager : NSObject

/**
 *  计算两点间距离
 */
+ (CGFloat)distanceOfStartPoint:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint;

/**
 *  两条直线是否有交点
 */
+ (BOOL)haveCrossPoint:(CGPoint)s1 end_1:(CGPoint)e1 start_2:(CGPoint)s2 end_2:(CGPoint)e2;

/**
 * 两条直线的交点
 */
+ (CGPoint)returnCrossPoint:(CGPoint)s1 end_1:(CGPoint)e1 start_2:(CGPoint)s2 end_2:(CGPoint)e2;

/**
 *  两条线段的交点
 */
+ (BOOL)lineIntersects:(CGPoint)s1 e1:(CGPoint)e1 s2:(CGPoint)s2 e2:(CGPoint)e2;

/**
 *  判断是否是四边形
 *  topL -> topR -> bottomR ->bottomL -> topL
 */
+ (BOOL)isQuadrilateralOfPoints:(CGPoint)topL topR:(CGPoint)topR bottomL:(CGPoint)bottomL bottomR:(CGPoint)bottomR;



/**
 * 四边形的面积
 */
+ (CGFloat)areaOfTheQuadrilateral:(CIRectangleFeature *)feature;



@end
