//
//  CustomAnnotation.h
//  mapKitDemo
//
//  Created by 陈乐杰 on 2018/7/30.
//  Copyright © 2018年 nst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
typedef enum{
    AnnotationTypeMovie = 0,
    AnnotationTypeHotel
} AnnotationType;
@interface CustomAnnotation : NSObject<MKAnnotation>
// 大头针所在经纬度（订在地图哪个位置）
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
// 大头针标注显示的标题
@property (nonatomic, copy, nullable) NSString *title;
// 大头针标注显示的子标题
@property (nonatomic, copy, nullable) NSString *subtitle;
@property (nonatomic, assign) AnnotationType AT;
@end
