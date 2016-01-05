//
//  Created by Alexandr Okhotnikov on 13.05.13.
//  Copyright (c) 2013 ЗАО "БАРС Груп". All rights reserved.
//

#import "BGTools.h"

//#import <mach/mach.h>
#import <CommonCrypto/CommonDigest.h>


@implementation BGTools

+ (BOOL)isIpad
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

+(NSString *)getUUID
{
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    NSString * uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    CFRelease(newUniqueId);
    
    return uuidString;
}

+ (NSString*)md5:(NSString*)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    
    return [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15] ];
}





# pragma mark - Работа с датой
+ (NSInteger)daysCountFromDate:(NSDate*)date toDate:(NSDate*)anotherDate
{
    NSInteger i = [date timeIntervalSince1970] / (3600 * 24);
    NSInteger j = [anotherDate timeIntervalSince1970] / (3600 * 24);
    return j - i;
}
// Дата строкой (текущая дата выводится как "Сегодня")
+ (NSString*)dateToStringWithDate:(NSDate*)date
{
    date = [NSDate dateWithTimeInterval:-1 sinceDate:date];
    
    NSInteger daysBetweenToday = [self daysCountFromDate:[NSDate date] toDate:date];
    if (daysBetweenToday == -1) return NSLocalizedString(@"Вчера",);
    if (daysBetweenToday == 0) return NSLocalizedString(@"Сегодня",);
    if (daysBetweenToday == 1) return NSLocalizedString(@"Завтра",);
    
    return [self stringFromDate:date];
}

// Дата строкой ("29.12.2012")
+ (NSString*)formtDateWithDate:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy"];
    return [dateFormatter stringFromDate:date];
}

+ (NSString*)stringFromDate:(NSDate*)date
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru"];
        [dateFormatter setDateFormat:@"dd MMMM"];
    });
    return [dateFormatter stringFromDate:date];
}

+ (NSString*)stringFromDateTime:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    return [dateFormatter stringFromDate:date];
}

+ (NSDate*)dateFromString:(NSString*)str
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
//        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru"];
        [dateFormatter setDateFormat:@"dd.MM.yyyy"];
    });
    return [dateFormatter dateFromString:str];
}

+ (NSDate*)timeFromString:(NSString*)str
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
    });
    return [dateFormatter dateFromString:str];
}

+ (NSDate*)dateTimeFromString:(NSString*)str
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    return [dateFormatter dateFromString:str];
}

+ (NSString*)setDateString:(NSString*)dateString withOldFormat:(NSString*)oldFormat newFormat:(NSString*)newFormat
{
    //parse date with old format
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:oldFormat];
    NSDate* date = [dateFormatter dateFromString:dateString];
    //new format
    [dateFormatter setDateFormat:newFormat];
    return [dateFormatter stringFromDate:date];
}

+(NSString*)dateToString:(NSDate*)date format:(NSString*)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}

+(NSDate*)stringToDate:(NSString*)dateString format:(NSString*)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter dateFromString:dateString];
}

+ (NSInteger)dayOfWeek:(NSDate*)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
    NSInteger dayNum = components.weekday;//воскресенье = 1
    dayNum = (dayNum + 5) % 7;
    return dayNum;
}

+ (NSArray*)arrayDaysOfWeek:(NSDate*)date
{
    NSMutableArray* result = [NSMutableArray array];
    
    NSInteger dayNum = [self dayOfWeek:date];
    
    for(NSInteger i = 0; i < 7; i++){
        NSInteger dayDisplace = i - dayNum;
        [result addObject:[NSDate dateWithTimeInterval:(3600 * 24 * dayDisplace) sinceDate:date]];
    }
    return result;
}

+ (BOOL)isSameDay:(NSDate*)date1 otherDay:(NSDate*)date2
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return comp1.day == comp2.day && comp1.month == comp2.month && comp1.year == comp2.year;
}

+ (BOOL)isSameWeek:(NSDate*)date1 otherDay:(NSDate*)date2
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSWeekOfYearCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return comp1.weekOfYear == comp2.weekOfYear && comp1.year == comp2.year;
}


+ (NSDate*)prevDateDay:(NSDate*)date
{
    return [NSDate dateWithTimeInterval:-24*60*60 sinceDate:date];
}
+ (NSDate*)nextDateDay:(NSDate*)date
{
    return [NSDate dateWithTimeInterval:24*60*60 sinceDate:date];
}
+ (NSDate*)prevDateWeek:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *compDate = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    compDate.day -= 7;
    return [calendar dateFromComponents:compDate];
}
+ (NSDate*)nextDateWeek:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *compDate = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    compDate.day += 7;
    return [calendar dateFromComponents:compDate];
}


# pragma mark - Работа с money и double

+ (NSString*)stringCurrencyWithNumber:(double)number
{
    static NSNumberFormatter *formatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setCurrencySymbol:@""];
        [formatter setMaximumFractionDigits:2];
        [formatter setNegativeSuffix:@""];
        [formatter setNegativePrefix:@"-"];
    });
    
    return [formatter stringFromNumber:[NSNumber numberWithDouble:number]];
}

+ (NSString*)stringDecimalWithNumber:(double)number
{
    static NSNumberFormatter *formatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        //        [formatter setCurrencySymbol:@""];
        [formatter setMaximumFractionDigits:2];
        [formatter setMinimumFractionDigits:0];
        [formatter setGroupingSeparator:@" "];
    });
    
    return [formatter stringFromNumber:[NSNumber numberWithDouble:number]];
}

+ (NSString*)stringDecimalWithNumber:(double)number digits:(NSInteger)digits
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:digits];
    [formatter setMinimumFractionDigits:digits];
    [formatter setGroupingSeparator:@" "];

    return [formatter stringFromNumber:[NSNumber numberWithDouble:number]];
}

+ (BOOL)scanString:(NSString*)strNumber number:(double*)number
{
    NSString *str = [strNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *decSep = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
    if ([decSep isEqualToString:@"."])
        str = [str stringByReplacingOccurrencesOfString:@"," withString:decSep];
    else
        str = [str stringByReplacingOccurrencesOfString:@"." withString:decSep];
    
    NSScanner *scanner = [NSScanner localizedScannerWithString:str];
	
    return [scanner scanDouble:number] && scanner.isAtEnd;
}


# pragma mark - Работа с JSON

+ (NSString*)jsonGetString:(id)strID
{
    NSString *retVal;
    
    if (strID && [strID isKindOfClass:[NSString class]])
        retVal = strID;
    else if ([strID isKindOfClass:[NSNumber class]])
        retVal = [(NSNumber*)strID stringValue];
    else
        retVal = @"";
    
    return retVal;
}

+ (NSArray*)jsonGetArray:(id)arrID
{
    NSArray *retVal;
    
    if (arrID && [arrID isKindOfClass:[NSArray class]])
        retVal = arrID;
    else
        retVal = [NSArray array];
    
    return retVal;
}

+ (NSDictionary*)jsonGetDict:(id)dictID
{
    NSDictionary *retVal;
    
    if (dictID && [dictID isKindOfClass:[NSDictionary class]])
        retVal = dictID;
    else
        retVal = [NSDictionary dictionary];
    
    return retVal;
}

+ (NSInteger)jsonGetInt:(id)intID
{
    NSInteger retVal = 0;
    
    if (intID)
    {
        if ([intID isKindOfClass:[NSNumber class]])
            retVal = [(NSNumber*)intID integerValue];
        else if ([intID isKindOfClass:[NSString class]])
            retVal = [(NSString*)intID integerValue];
    }
    
    return retVal;
}

+ (double)jsonGetDouble:(id)floatID
{
    double retVal = 0.0f;
    
    if (floatID)
    {
        if ([floatID isKindOfClass:[NSNumber class]])
            retVal = [(NSNumber*)floatID doubleValue];
        else if ([floatID isKindOfClass:[NSString class]])
            retVal = [(NSString*)floatID doubleValue];
    }
    
    return retVal;
}

+ (BOOL)jsonGetBool:(id)boolID
{
    BOOL retVal = FALSE;
    
    if (boolID)
    {
        if ([boolID isKindOfClass:[NSNumber class]])
            retVal = [(NSNumber*)boolID boolValue];
        else if ([boolID isKindOfClass:[NSString class]])
            retVal = [(NSString*)boolID boolValue];
    }
    
    return retVal;
}

#pragma mark - UI

// чертовы тонкие линии на ретине!!!
+ (void)thinnerViewsInView:(UIView*)view
{
    CGFloat pixel = [self pixelSize];
    
    if (pixel < 1.0)
    {
        for (UIView *vvv in view.subviews) {
            CGRect rect = vvv.frame;
            if (rect.size.width == 1) {
                rect.size.width = pixel;
                if (rect.origin.x > view.bounds.size.width/2)
                    rect.origin.x += 1.0 - pixel;
                vvv.frame = rect;
            }
            else if (rect.size.height == 1) {
                rect.size.height = pixel;
                if (rect.origin.y > view.bounds.size.height/2)
                    rect.origin.y += 1.0 - pixel;
                vvv.frame = rect;
            }
        }
    }
}

+ (CGFloat)pixelSize
{
    CGFloat pixel = 1.0;
    
    UIScreen *mainScr = [UIScreen mainScreen];
    if (mainScr.scale > 1)
    {
        if ([mainScr respondsToSelector:@selector(nativeScale)])
            pixel = 1.0 / mainScr.nativeScale;
        else
            pixel = 1.0 / mainScr.scale;
    }
    return pixel;
}

+ (void)gradientView:(UIView*)view cornerRadius:(CGFloat)corner vertical:(BOOL)vertical colors:(NSArray*)colors
{
    for(CALayer* layer in view.layer.sublayers)
    {
        if ([layer isKindOfClass:[CAGradientLayer class]])
        {
            [layer removeFromSuperlayer];
            break;
        }
    }
    
    NSMutableArray *colorArr = [NSMutableArray new];
    NSMutableArray *locatArr = [NSMutableArray new];
    double step = 1.0 / (colors.count-1);
    double curStep = 0.0;
    for (UIColor *color in colors) {
        [colorArr addObject:(id)color.CGColor];
        [locatArr addObject:@(curStep)];
        curStep += step;
    }
    
    CAGradientLayer *grad = [CAGradientLayer layer];
    grad.colors    = colorArr;
    grad.locations = locatArr;
    if (! vertical) {
        grad.startPoint = CGPointMake(0.0, 0.5);
        grad.endPoint   = CGPointMake(1.0, 0.5);
    }
    grad.frame = view.bounds;
    grad.cornerRadius = corner;
    view.backgroundColor = [UIColor clearColor];
    [view.layer insertSublayer:grad atIndex:0];
}

+ (UIImage*)imageWithColor:(UIColor*)color size:(CGSize)size radius:(CGFloat)radius
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, size.width, size.height);
    
    [[UIBezierPath bezierPathWithRoundedRect:area cornerRadius:radius] addClip];
    [color set];
    CGContextFillRect(context, area);
    
    UIImage *colorizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return colorizedImage;
}

+ (BOOL)assetRepresentation:(ALAssetRepresentation*)rep toData:(NSMutableData*)data
{
    static const NSUInteger bufferSize = 50*1024;

    uint8_t *buffer = calloc(bufferSize, sizeof(*buffer));
    
    NSUInteger offset = 0, bytesRead = 0;
    do {
        @try {
            bytesRead = [rep getBytes:buffer fromOffset:offset length:bufferSize error:nil];
            offset += bytesRead;
            [data appendBytes:buffer length:bytesRead];
        } @catch (NSException *exception) {
            free(buffer);
            return NO;
        }
    } while (bytesRead > 0);
    
    free(buffer);
    
    return YES;
}



#pragma mark - strings

+ (CGFloat)heightOfTextForString:(NSString *)aString andFont:(UIFont *)aFont maxSize:(CGSize)aSize
{
    if(!aString)
        return 0;
    
    NSDictionary* attributes = @{NSFontAttributeName : aFont};
    
    if(aString.length>0 && [aString characterAtIndex:[aString length] - 1]=='\n'){
        //в случае когда последний символ "перевод строки" добавляем пробел чтоб функция правильно посчитала высоту
        //тк по невыясненным обстоятельствам функция boundingRectWithSize игнорирует именно последний символ переноса строки
        // (если переносов строки подряд несколько то игнорируется только последний)
        aString = [aString stringByAppendingString:@" "];
    }
    
    CGSize sizeOfText = [aString boundingRectWithSize: aSize
                                              options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                           attributes: attributes
                                              context: nil].size;
    
   return ceilf(sizeOfText.height);
}

+ (CGFloat)widthOfTextForString:(NSString *)aString andFont:(UIFont *)aFont maxSize:(CGSize)aSize
{
    NSDictionary* attributes = @{NSFontAttributeName : aFont};
    CGSize sizeOfText = [aString boundingRectWithSize: aSize
                                              options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                           attributes: attributes
                                              context: nil].size;
    
    return ceilf(sizeOfText.width);;
}

+(void) setViewY:(UIView*) view newY:(CGFloat) newY
{
    //if(true)
    //    return;
    
    CGRect rect = view.frame;
    rect.origin.y = newY;
    view.frame = rect;
}


#pragma mark - по заданному пути запрет на попадание содержимого в резервную копию

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL*)URL
{
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    if(!success)
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    
    return success;
}

@end
