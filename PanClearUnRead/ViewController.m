//
//  ViewController.m
//  PanClearUnRead
//
//  Created by pro on 2018/5/2.
//  Copyright © 2018年 ChenXiaoJun. All rights reserved.
//

#import "ViewController.h"
#import "BadgeButton.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    BadgeButton *btn = [[BadgeButton alloc] initWithFrame:CGRectMake(100, 100, 22, 22)];
    [self.view addSubview:btn];
    [btn setUnreadValue:10];
    
    
}




@end
