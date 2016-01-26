//
//  SettingsViewController.m
//  Universmotri
//
//  Created by Alexander Drovnyashin on 24.01.16.
//  Copyright © 2016 Alexander Drovnyashin. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *qualityStreamPickrer;

@end

@implementation SettingsViewController
{
    NSArray *arr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    arr = @[@"Низкое", @"Среднее", @"Высокое"];
    
    self.qualityStreamPickrer.delegate = self;
    self.qualityStreamPickrer.dataSource = self;
    [self.qualityStreamPickrer selectRow:[[NSUserDefaults standardUserDefaults] integerForKey:@"streamQuality"] inComponent:0 animated:NO];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

//- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    
//    return arr[row];
//}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return arr.count;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSUserDefaults *stremQuality = [NSUserDefaults standardUserDefaults];
    [stremQuality setInteger:row forKey:@"streamQuality"];
}

- (nullable NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *infoString=arr[row];
    
    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:infoString];
    NSInteger _stringLength=[infoString length];
    
    UIColor *_black =[UIColor colorWithRed:255./255. green:200./255. blue:247./255. alpha:1];
    UIFont *font = [UIFont systemFontOfSize:14];
    [attString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, _stringLength)];
    [attString addAttribute:NSForegroundColorAttributeName value:_black range:NSMakeRange(0, _stringLength)];
    return attString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
