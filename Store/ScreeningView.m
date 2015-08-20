//
//  ScreeningView.m
//  Store
//
//  Created by tangmingming on 15/8/17.
//  Copyright (c) 2015年 tangmingming. All rights reserved.
//

#import "ScreeningView.h"
#import "StoreDefine.h"

@interface ScreeningView()

@end

@implementation ScreeningView

-(id)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        UIButton *btnAll = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 30)];
        [btnAll setBackgroundColor:[UIColor whiteColor]];
        [btnAll setTitleColor:[UIColor lightGrayColor] forState:0];
        [btnAll setTitle:@"全部" forState:0];
        [btnAll.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btnAll addTarget:self action:@selector(screeingAll) forControlEvents:UIControlEventTouchUpInside];
        
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]];
       
        [self addSubview:btnAll];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideSelf)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

#pragma mark -筛选所有
-(void)screeingAll{
    [_delegate searchProductListWithType:SCREENING_ALL_TAG];
}

#pragma mark -隐藏
-(void)hideSelf{
      [_delegate searchProductListWithType:HIED_SELF_TAG];
}

@end
