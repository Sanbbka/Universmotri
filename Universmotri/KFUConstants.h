//
//  KFUConstants.h
//  Universmotri
//
//  Created by Alexander Drovnyashin on 03.01.16.
//  Copyright © 2016 Alexander Drovnyashin. All rights reserved.
//

#ifndef KFUConstants_h
#define KFUConstants_h

typedef NS_ENUM(NSInteger, StreamQuality) {
    StreamQualityLight,
    StreamQualityMedium,
    StreamQualityHight
};

typedef NS_ENUM(NSInteger, Stream) {
    StreamKFU,
    StreamUniversmotri
};

typedef NS_ENUM(NSInteger, NewsID) {
    MainNews,
    RectoratNews,
    CultureNews,
    ScienceNews
};

/*Ссылки на стримы*/
static NSString const*universmotriSQLLink   = @"http://tv.kpfu.ru/lqcast/index.html";
static NSString const*universmotriSQMLink   = @"http://tv.kpfu.ru/mqcast/index.html";
static NSString const*universmotriSQHLink   = @"http://tv.kpfu.ru/epg_universmotri";
static NSString const*KFULink               = @"http://tv.kpfu.ru/epg_kpfu";

/*Главная страница*/
static NSString const*MainKFU               = @"http://tv.kpfu.ru";

/*Ссылки на новости*/
/*Загрузка происходит постранично "осн ссылка" + "Page-\(n)-30.html" n - нужная страница */
static NSString const*mainNews              = @"http://tv.kpfu.ru/index.php/novosti/obzory-novostey/";
static NSString const*rectoratNews          = @"http://tv.kpfu.ru/index.php/novosti/novosti-rektorata/";
static NSString const*cultureNews           = @"http://tv.kpfu.ru/index.php/novosti/obschestvo-i-kultura/";
static NSString const*scienceNews           = @"http://tv.kpfu.ru/index.php/novosti/obrazovanie-i-nauka/";

#endif /* KFUConstants_h */
