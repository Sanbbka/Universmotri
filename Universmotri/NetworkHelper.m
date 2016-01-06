//
//  NetworkHelper.m
//  Universmotri
//
//  Created by Alexander Drovnyashin on 05.01.16.
//  Copyright © 2016 Alexander Drovnyashin. All rights reserved.
//

#import "NetworkHelper.h"
#import "DBMail.h"
#import "DownloadItems.h"
#import "Item.h"
#import <HTMLReader/HTMLReader.h>

@implementation NetworkHelper

+ (void)getNewsForType:(NewsID )uidNews complete:(void(^)(NSError *err))complete {
    
    NSManagedObjectContext *context = [DBMail mocPerThread];
    [context performBlock:^{
        
        DownloadItems *dbPageInfo;
        NSArray *arr = [DBMail objectWithEntity:@"DownloadItems" param:nil sort:nil offset:0 limit:0 MOC:context];
        
        if (arr == nil || arr.count <= 0)
        {
            NSEntityDescription * entityDescription = [NSEntityDescription entityForName:@"DownloadItems" inManagedObjectContext:context];
            dbPageInfo = [[DownloadItems alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
            dbPageInfo.mainNewsPage     = 1;
            dbPageInfo.rectoratNewsPage = 1;
            dbPageInfo.cultureNewsPage  = 1;
            dbPageInfo.scienceNewsPage  = 1;
            
            [context insertObject:dbPageInfo];
            [DBMail saveContext:context];
        }
        else
            dbPageInfo = arr[0];
        
        NSString const*downLink;
        NSInteger  pageDownl;
        
        switch (uidNews) {
            case MainNews:
                downLink  = mainNews;
                pageDownl = dbPageInfo.mainNewsPage;
                break;
            case RectoratNews:
                downLink  = rectoratNews;
                pageDownl = dbPageInfo.rectoratNewsPage;
                break;
            case CultureNews:
                downLink  = cultureNews;
                pageDownl = dbPageInfo.cultureNewsPage;
                break;
            case ScienceNews:
                downLink  = scienceNews;
                pageDownl = dbPageInfo.scienceNewsPage;
                break;
            default:
                break;
        }
        
        NSError *error;
        
        NSString *urlNews = [NSString stringWithFormat:@"%@Page-%i-30.html", downLink, (int)pageDownl];
    
        NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlNews] encoding:NSUTF8StringEncoding error:&error];
        
        if (!error) {
            
            HTMLDocument *document = [HTMLDocument documentWithString:str];
            
            NSArray *newsArr = [document nodesMatchingSelector:@".catItemBody"];
            
            for (HTMLElement *elem in newsArr) {
                
                NSArray *arr = [elem nodesMatchingSelector:@".catItemImage"];
                HTMLElement *itemImage = [arr firstObject];
                
                Item *item;
                
                NSDictionary *dict  =  [(HTMLElement *)[itemImage childAtIndex:1] attributes];
                NSDictionary *dict2 =  [(HTMLElement *)[[itemImage childAtIndex:1] childAtIndex:1] attributes];
                
                NSString *hrefDetail    =  [dict  objectForKey:@"href"];
                NSString *title         =  [dict  objectForKey:@"title"];
                
                NSString *imgLink       =  [dict2 objectForKey:@"src"];
                NSString *dateCreated   = [(HTMLTextNode *)[[[elem nodesMatchingSelector:@".catItemDateCreated"] firstObject] childAtIndex:0] textContent];
                
                NSEntityDescription * entityDescription = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:context];
                item = [[Item alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
                
                [item setItemLinkImage:imgLink];
                [item setItemTime:dateCreated];
                [item setItemTittle:title];
                [item setDetailItemLink:hrefDetail];
                [item setUidNews:uidNews];
                
                [context insertObject:item];
                [DBMail saveContext:context];
            }
            
            switch (uidNews) {
                case MainNews:
                    dbPageInfo.mainNewsPage += 1;
                    break;
                case RectoratNews:
                    dbPageInfo.rectoratNewsPage += 1;
                    break;
                case CultureNews:
                    dbPageInfo.cultureNewsPage += 1;
                    break;
                case ScienceNews:
                    dbPageInfo.scienceNewsPage += 1;
                    break;
                default:
                    break;
            }
            [DBMail saveContext:context];
        }
        
        complete(error);
    }];
}

+(NSData *)getImageNews:(NSURL *)imgLinkAppend {
    
    NSError *err = nil;
    NSData *data = [NSData dataWithContentsOfURL:imgLinkAppend options:NSDataReadingUncached error:&err];
    
    if (err) {
        NSLog(@"\n\n!!!!!!!!!!!!!!\n%@", err);
        return nil;
    } else return data;
}

+(void)downloadAllImages:(NewsID )uidNews {
    
    NSManagedObjectContext *moc = [DBMail mocPerThread];
    [moc performBlock:^{
        NSArray *arrNews = [DBMail objectWithEntity:@"Item" param:@{@"uidNews" : [NSNumber numberWithInt:uidNews]} sort:nil offset:0 limit:0 MOC:moc];
        for (Item *itemNews in arrNews) {
            
            if (!itemNews.itemImage) {
                
                [moc performBlock:^{
                    NSURL *url = [NSURL URLWithString:[MainKFU stringByAppendingString:itemNews.itemLinkImage]];
                    [itemNews setItemImage:[self getImageNews:url]];
                    [DBMail saveContext:moc];
                }];
            }
        }
    }];
}

@end