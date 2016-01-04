//
//  NewsTableViewCell.h
//  Universmotri
//
//  Created by Alexander Drovnyashin on 04.01.16.
//  Copyright © 2016 Alexander Drovnyashin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *tittleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tittleImage;

@end
