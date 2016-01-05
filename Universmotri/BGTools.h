//
//  Created by Alexandr Okhotnikov on 13.05.13.
//  Copyright (c) 2013 ЗАО "БАРС Груп". All rights reserved.
//

#define DEBUG_TEST_WITHOUT_INTERNET

#define IS_IPHONE_5 ( [ [ UIScreen mainScreen ] bounds ].size.height == 568 )


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface BGTools : NSObject

+ (BOOL)isIpad;
+(NSString *)getUUID;
+ (NSString*)md5:(NSString*)str;

+ (NSString*)dateToStringWithDate:(NSDate*)date;
+ (NSString*)formtDateWithDate:(NSDate*)date;
+ (NSString*)stringFromDate:(NSDate*)date;
+ (NSString*)stringFromDateTime:(NSDate*)date;
+ (NSDate*)dateFromString:(NSString*)str;
+ (NSDate*)timeFromString:(NSString*)str;
+ (NSDate*)dateTimeFromString:(NSString*)str;
+ (NSString*)setDateString:(NSString*)dateString withOldFormat:(NSString*)oldFormat newFormat:(NSString*)newFormat;
+ (NSString*)dateToString:(NSDate*)date format:(NSString*)format;
+ (NSDate*)stringToDate:(NSString*)dateString format:(NSString*)format;
+ (NSInteger)dayOfWeek:(NSDate*)date;
+ (NSArray*)arrayDaysOfWeek:(NSDate*)date;

+ (BOOL)isSameDay:(NSDate*)date1 otherDay:(NSDate*)date2;
+ (BOOL)isSameWeek:(NSDate*)date1 otherDay:(NSDate*)date2;

+ (NSDate*)prevDateDay:(NSDate*)date;
+ (NSDate*)nextDateDay:(NSDate*)date;
+ (NSDate*)prevDateWeek:(NSDate*)date;
+ (NSDate*)nextDateWeek:(NSDate*)date;

+ (NSString*)stringCurrencyWithNumber:(double)number;
+ (NSString*)stringDecimalWithNumber:(double)number;
+ (NSString*)stringDecimalWithNumber:(double)number digits:(NSInteger)digits;
+ (BOOL)scanString:(NSString*)strNumber number:(double*)number;

+ (NSString*)jsonGetString:(id)strID;
+ (NSArray*)jsonGetArray:(id)arrID;
+ (NSDictionary*)jsonGetDict:(id)dictID;
+ (NSInteger)jsonGetInt:(id)intID;
+ (double)jsonGetDouble:(id)floatID;
+ (BOOL)jsonGetBool:(id)boolID;

+ (void)gradientView:(UIView*)view cornerRadius:(CGFloat)corner vertical:(BOOL)vertical colors:(NSArray*)colors;
+ (void)thinnerViewsInView:(UIView*)view;
+ (CGFloat)pixelSize;
+ (UIImage*)imageWithColor:(UIColor*)color size:(CGSize)size radius:(CGFloat)radius;
+ (BOOL)assetRepresentation:(ALAssetRepresentation*)rep toData:(NSMutableData*)data;

+ (CGFloat)heightOfTextForString:(NSString *)aString andFont:(UIFont *)aFont maxSize:(CGSize)aSize;
+ (CGFloat)widthOfTextForString:(NSString *)aString andFont:(UIFont *)aFont maxSize:(CGSize)aSize;
+ (void) setViewY:(UIView*) view newY:(CGFloat) newY;

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL*)URL;

@end
