//
//  BadgeButton.h
//  PanClearUnRead
//
//  Created by pro on 2018/5/2.
//  Copyright © 2018年 ChenXiaoJun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BadgeButton : UIButton


/**
 设置未读数

 @param value 值0-N(当为0时自动从父控件移除,超过99时显示..)
 */
-(void)setUnreadValue:(NSInteger)value;


@end
