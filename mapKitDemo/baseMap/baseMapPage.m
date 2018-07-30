//
//  baseMapPage.m
//  mapKitDemo
//
//  Created by 陈乐杰 on 2018/7/30.
//  Copyright © 2018年 nst. All rights reserved.
//

#import "baseMapPage.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "CustomAnnotation.h"

#import <AddressBook/AddressBook.h>
@interface baseMapPage ()<MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *customMapView;
@property (nonatomic) CLLocationCoordinate2D  currentCoordinate;
@property (strong,nonatomic) CustomAnnotation * currentAnnotation;
@property (strong,nonatomic) CLLocationManager * locationM;
@property (strong,nonatomic) CLGeocoder * geocoder;
@end

@implementation baseMapPage

- (CLLocationManager *)locationM{
    if (!_locationM) {
        _locationM = [[CLLocationManager alloc]init];
        if ([_locationM respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [_locationM requestAlwaysAuthorization];
        }
    }
    return _locationM;
}
-(CLGeocoder *)geocoder{
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc]init];
    }
    return _geocoder;
}
- (void)viewDidLoad {
    [super viewDidLoad];
     [self setTitle:@"基本使用"];
    // 1.设置地图显示类型
    /**
     MKMapTypeStandard = 0,  // 标准
     MKMapTypeSatellite,     // 卫星
     MKMapTypeHybrid,        // 混合（标准+卫星）
     MKMapTypeSatelliteFlyover NS_ENUM_AVAILABLE(10_11, 9_0), // 3D立体卫星
     MKMapTypeHybridFlyover NS_ENUM_AVAILABLE(10_11, 9_0), // 3D立体混合
     */
    self.customMapView.mapType = MKMapTypeStandard;
    
    // 2.设置地图的跟随模式
    //（注意：设置此属性会使用到用户的位置隐私，所以需要请求用户授权，否则没有效果）
    /**
     MKUserTrackingModeNone = 0, // 不跟随
     MKUserTrackingModeFollow, // 跟随用户位置
     MKUserTrackingModeFollowWithHeading, // 跟随用户位置，并跟随用户方向
     */
    [self locationM];
//        self.customMapView.showsUserLocation = YES;
    self.customMapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
    self.customMapView.delegate = self;
    
    // 3.设置地图其它属性(操作)
    /** 注意：设置对应的属性时，注意该属性是从哪个系统版本开始引入的，做好不同系统版本的适配*/
    // 是否可以缩放
    self.customMapView.zoomEnabled = YES;
    // 是否可以滚动
    self.customMapView.scrollEnabled = YES;
    // 是否可以旋转
    self.customMapView.rotateEnabled = YES;
    // 是否显示3D
    self.customMapView.pitchEnabled = YES;
    
    // 4.设置地图其它属性（显示）
    // 是否显示指南针
    self.customMapView.showsCompass = YES;
    // 是否显示比例尺
    self.customMapView.showsScale = YES;
    // 是否显示交通
    self.customMapView.showsTraffic = YES;
    // 是否显示建筑物
    self.customMapView.showsBuildings = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark MKMapViewDelegate
//地图位置刷新
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    /*
     当前位置的蓝点是大头针视图，MKUserLocation是大头针模型，视图是根据模型展示的
     MKUserLocation : 被称作“大头针模型”，本质是一个数据模型，只不过此模型遵循了大头针要遵循的协议（MKAnnotation）
     location:  用户当前所在位置信息(CLLocation对象)
     title:     大头针标注要显示的标题(NSString对象)
     subtitle:  大头针标注要显示的子标题(NSString对象)
     */
    
    userLocation.title = @"当前位置";
    userLocation.subtitle = [NSString stringWithFormat:@"设备朝向 %@",userLocation.heading];
    self.currentCoordinate = userLocation.coordinate;
    //第一种方法：设置蓝点在地图中心，设置这个以后就没有朝向了，并且只能手动放大
    //    [mapView setCenterCoordinate:userLocation.coordinate animated:YES];
    //第二种方法：设置蓝点在地图中心，设置这个以后就没有朝向了，会自动放大
    /*
     MKCoordinateSpan 跨度解释：
     latitudeDelta：纬度跨度，因为南北纬各90度，所以此值的范围是（0---180）；此值表示，整个地图视图宽度，显示多大跨度
     longitudeDelta：经度跨度，因为东西经各180度，所以此值范围是（0---360）：此值表示，整个地图视图高度，显示多大跨度
     注意：地图视图显示，不会更改地图的比例，会以地图视图高度或宽度较小的那个为基准，按比例调整
     */
    //设置经纬度跨度，越小地图详细
    MKCoordinateSpan  span = MKCoordinateSpanMake(0.01, 0.01);
        //    设置经纬度区域
    MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.coordinate, span);
        //    设置地图显示区域
    [mapView setRegion:region animated:YES];
    
}

//地图区域改变调用，在这个方法里，手动放大地图区域，找到最适合的经纬度跨度
-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    NSLog(@"纬度%f,经度%f",mapView.region.span.latitudeDelta,mapView.region.span.longitudeDelta);
}

//大头针操作
#pragma mark 大头针基本操作
//将点击的坐标转换为经纬度添加大头针
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 获取当前触摸点在地图上的坐标
    UITouch *touch = [touches anyObject];
    //点击的坐标
    CGPoint touchPoint = [touch locationInView:self.customMapView];
    // 将坐标转换为经纬度
    CLLocationCoordinate2D center = [self.customMapView convertPoint:touchPoint toCoordinateFromView:self.customMapView];
//    CustomAnnotation * annotation = [[CustomAnnotation alloc]init];
//    self.currentAnnotation = annotation;
    // 创建CLLocation对象
    CLLocation *location = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
    // 根据CLLocation对象进行反地理编码
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * __nullable placemarks, NSError * __nullable error) {
        // 包含区，街道等信息的地标对象
        CLPlacemark *placemark = [placemarks firstObject];
        self.currentAnnotation.title = placemark.name;
        self.currentAnnotation.subtitle = placemark.country;
    }];
    
    [self addAnnotationWithCoordinate:center];
}


// 根据经纬度坐标添加大头针
- (void)addAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    
    //    实际操作中使用地址编码创建CLLocationCoordinate2D指定大头针的位置
    CustomAnnotation *annotation = [[CustomAnnotation alloc] init];
    self.currentAnnotation = annotation;
    self.currentAnnotation.coordinate = coordinate;
    [self.customMapView addAnnotation:self.currentAnnotation];
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //    删除所有的的大头针
    [self.customMapView removeAnnotations:self.customMapView.annotations];
    
}
#pragma mark 自定义大头针
// 当添加大头针数据模型时，会调用此方法，获取对应的大头针视图。如果返回nil，则默认使用系统自带的大头针视图。
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(CustomAnnotation *)annotation{
//    循环使用
    static NSString *pinID = @"pinID";
    MKAnnotationView *customPinView = [mapView dequeueReusableAnnotationViewWithIdentifier:pinID];
    if (!customPinView) {
        customPinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinID];
    }
    
//    二次赋值，保证是真正的值，而不是循环复用的值
//    customPinView.annotation = annotation;
    NSString *imageName = nil;
//    保证一定加载
    if(self.currentAnnotation)
    {
        switch (annotation.AT) {
            case AnnotationTypeMovie:
                imageName = @"category_5";
                break;
            case AnnotationTypeHotel:
                imageName = @"category_3";
                break;
                
            default:
                break;
        }
    }
//    大头针视图
    customPinView.image = [UIImage imageNamed:@"category_5"];
    customPinView.canShowCallout = YES;
    // 设置点击后标注左侧视图
    UIImageView *leftIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    leftIV.image = [UIImage imageNamed:@"category_3"];
    customPinView.leftCalloutAccessoryView = leftIV;

    // 设置点击后标注右侧视图
    UIImageView *rightIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    rightIV.image = [UIImage imageNamed:@"category_2"];
    customPinView.rightCalloutAccessoryView = rightIV;

    // 设置点击后标注详情视图（iOS9.0）
    customPinView.detailCalloutAccessoryView = [[UISwitch alloc] init];
    return customPinView;
}
// 选中一个大头针时调用
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"选中%@", [view.annotation title]);
}

// 取消选中大头针时调用
-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"取消选中%@", [view.annotation title]);
}
@end
