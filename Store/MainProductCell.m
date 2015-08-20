//
//  MainProductCell.m
//  Store
//
//  Created by tangmingming on 15/8/16.
//  Copyright (c) 2015年 tangmingming. All rights reserved.
//

#import "MainProductCell.h"


@implementation MainProductCell


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = 100;
        _productImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, height-30, height-30)];
        _productName = [[UILabel alloc]initWithFrame:CGRectMake(width*0.4, 15, width*0.4, 20)];
        [_productName setTextColor:[UIColor orangeColor]];
        _productDetail = [[UILabel alloc]initWithFrame:CGRectMake(width*0.4, _productName.frame.origin.y + 20, width*0.5, 20)];
        [_productDetail setFont:[UIFont systemFontOfSize:12]];
        [_productDetail setNumberOfLines:0];
        _productPrice = [[UILabel alloc]initWithFrame:CGRectMake(width*0.4, 80, 100, 20)];
        [_productPrice setTextColor:[UIColor redColor]];
        [_productPrice setFont:[UIFont fontWithName:@"Thonburi-Bold" size:13.0]];
        
        //加入购物车
        _addShopCar = [[UIButton alloc]initWithFrame:CGRectMake(width-55, height-50, 33, 28)];
        [_addShopCar setImage:[UIImage imageNamed:@"shopCar"] forState:0];
        
        //已售数量
        _productScaleCount = [[UILabel alloc]initWithFrame:CGRectMake(width-60, height-23, 80, 20)];
        [_productScaleCount setFont:[UIFont systemFontOfSize:12]];

        
    
        [self.contentView addSubview:_productImage];
        [self.contentView addSubview:_productName];
        [self.contentView addSubview:_productDetail];
        [self.contentView addSubview:_productPrice];
        [self.contentView addSubview:_addShopCar];
        [self.contentView addSubview:_productScaleCount];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}


-(void)setCellDataWithProduct:(StoreProductsModel *)product{
    [self.productImage setImage: [UIImage imageNamed:product.ProductImages[0]]];
    [self.productName setText:product.ProductName];
    [self.productDetail setText:product.ProductDesc];
    [self.productPrice setText:[NSString stringWithFormat:@"￥%0.2lf",product.ProductPrice]];
    [self.productScaleCount setText:[NSString stringWithFormat:@"%d件已售",(int)product.ProductSaleCount]];
}




@end
