//
//  SettlementViewController.m
//  Store
//
//  Created by tangmingming on 15/8/21.
//  Copyright (c) 2015年 tangmingming. All rights reserved.
//

#import "SettlementViewController.h"
#import "ToolsOriginImage.h"
#import "ProductShopCar.h"
#import "SettlementHeadCell.h"
#import "SettlementProductCell.h"
#import "SettlementConfirmView.h"
#import "CustomHUD.h"
#import "AddressViewController.h"
#import "DeliveryTimeViewController.h"
#import "ProductDetailViewController.h"
#import "StoreNavigationBar.h"
#import "StoreOrder.h"
#import "User.h"
#import "StoreDefine.h"
#import "PlayTypeViewController.h"

@interface SettlementViewController ()<UITableViewDataSource,UITableViewDelegate,AddressViewControllerDelegate,MainSreachBarDelegate,StoreNavigationBarDeleagte>


/**
 *  tableView
 */
@property(nonatomic,strong)UITableView *tableView;
/**
 *  屏幕大小
 */
@property(nonatomic,assign)CGSize mainSize;
/**
 *  确认栏
 */
@property(nonatomic,strong)SettlementConfirmView *settlementBar;
/**
 *  指示器
 */
@property(nonatomic,strong)CustomHUD *simpleHud;
/**
 *  默认地址
 */
@property(nonatomic,strong)NSString *defaultAddress;
/**
 *  订单对象
 */
@property(nonatomic,strong)StoreOrder *order;
/**
 *  网络请求路径
 */
@property(nonatomic,strong)NSString *path;


@end

@implementation SettlementViewController

#pragma mark -视图加载后
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self createView];
}


#pragma mark -创建视图
-(void)createView
{
    _order = [StoreOrder new];
    //获取物业编号
    [_order setPMCID:[User sharePmcID]];
   //设置运费
    [_order setOrderFreight:8.0];
    
    _defaultAddress = @"请先填写收货人信息";
    _mainSize = self.view.frame.size;
    
    /**
     导航栏
     */
    [self.navigationController setNavigationBarHidden:YES];
    StoreNavigationBar *navigationBar= [[StoreNavigationBar alloc]initWithFrame:CGRectMake(0, 0, _mainSize.width, 64)];
    [navigationBar setBarDelegate:self];
    [navigationBar.searchBar setHidden:YES];
    [navigationBar.rightBtn setHidden:YES];
    [navigationBar.title setText:@"结算中心"];
    
    [self.view addSubview:navigationBar];
    /**
     初始化tableView
     */
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, _mainSize.width, _mainSize.height-124) style:UITableViewStyleGrouped];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setSectionHeaderHeight:3];
    [_tableView setSectionFooterHeight:3];
    [_tableView setTableHeaderView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, _mainSize.width, 1)]];
    [_tableView registerClass:[SettlementHeadCell class] forCellReuseIdentifier:@"settlementCell"];
    [_tableView registerClass:[SettlementProductCell class] forCellReuseIdentifier:@"settlementProductCell"];
    [self.view addSubview:_tableView];
    
    /**
        确认栏
     */
    SettlementConfirmView *settlementBar = [[SettlementConfirmView alloc]initWithFrame:CGRectMake(0, _mainSize.height-60, _mainSize.width, 60)];
    [settlementBar.settlementBtn addTarget:self action:@selector(settlementBtnClick) forControlEvents:UIControlEventTouchUpInside];
    _settlementBar = settlementBar;
    
    
   
    
    
    
    //计算总金额
    double sumprice =0;
    for (int i =0; i<_productList.count; i++)
    {
          ProductShopCar * product = _productList[i];
          sumprice += product.productRealityPrice*product.bayCount;
    }
    //加上运费
    sumprice +=_order.orderFreight;
    //显示总金额
    [settlementBar.sumPrice setText:[NSString stringWithFormat:@"￥%0.2lf",sumprice]];
    
    [self.view addSubview:settlementBar];
    
    
    /**
     *  设置显示运费
     */
    [settlementBar.freight setText:[NSString stringWithFormat:@"￥%0.2lf",_order.orderFreight]];
    
    
    /**
     添加手势
     */
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftClick)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:swipe];
    
    [self loadUserDefaultAddress];
    
}



#pragma mark -查询用户默认地址
-(void)loadUserDefaultAddress
{
    //显示指示器
    [self.simpleHud setHidden:NO];
    [self.simpleHud startSimpleLoad];
    
    //StoreAddress/findDefaultAddressByUserID
    NSString *path = [NSString stringWithFormat:@"%sStoreAddress/findDefaultAddressByUserID?userID=%d",SERVER_ROOT_PATH,(int)[User shareUserID]];
    
   
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *requst = [[NSURLRequest alloc]initWithURL:url];
    //发送请求
    [NSURLConnection sendAsynchronousRequest:requst queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError == nil)
        {
            //将结果转成字典集合
            NSDictionary *dic =(NSDictionary *) [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^
               {
                    [self.simpleHud stopAnimation];
                   if (dic!=nil)//如果有默认地址
                   {
                       [_order setOrderAddress:[NSString stringWithFormat:@"%@%@",dic[@"provinceCityDistrict"],dic[@"addressDetail"]]];
                       [_order setOrderConsignee:dic[@"consignee"]];
                       [_order setOrderTelephone:dic[@"telephone"]];
                       //更新UI
                       [self.tableView reloadData];
                      
                   }
               });
        }
        else
        {
            NSLog(@"%@",connectionError.debugDescription);
        }
    }];

    
    

}




#pragma mark -设置分组
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _productList.count+1;
}

#pragma mark -表格每组行
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row = 2;
    if (section >0) {
        row = 3;
    }
    return row;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section>0&&indexPath.row==1)
    {
        return 70;
    }
    else
    {
        return 40;
    }
}

#pragma mark -表格每行内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*-------------------------head-------------------------------*/
    if (indexPath.section==0)
    {
        //地址和送货时间
        SettlementHeadCell *cell = [[SettlementHeadCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"settlementCell"];
         cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.row==0)
        {
            if (_order.orderAddress ==nil||[_order.orderAddress isEqualToString:@""]) {
                 [cell.icon setImage:[UIImage imageNamed:@"location"]];
                 [cell.name setText:_defaultAddress];
            }
            else
            {
                [cell.icon setImage:[UIImage imageNamed:@"location"]];
                [cell.name setText:_order.orderAddress];
                [cell.name setTextAlignment:NSTextAlignmentLeft];
            }
           
           
        }else if (indexPath.row==1) {
            [cell.icon setImage:[UIImage imageNamed:@"date"]];
            [cell.name setText:@"工作日、双休日与假日均可送货"];
        }
         [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
         return cell;
    }
     /*-------------------------head  end-------------------------------*/
    else
    {
    /*-------------------------product-------------------------------*/
        ProductShopCar * product = _productList[indexPath.section-1];
        
        SettlementProductCell *   cell = [[SettlementProductCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"settlementProductCell"];

        /**
         *  设置属性
         */
        if (indexPath.row==0)//店铺名字
        {
            [cell.name setText:product.productName];
        }else if (indexPath.row==1)//图片与价格数量
        {
            [cell.productImage setImage:_imageList[product.productID]];
            [cell.productName setText:product.productName];
            [cell.price setText:[NSString stringWithFormat:@"￥%0.2lf元",product.productRealityPrice]];
            [cell.productCount setText:[NSString stringWithFormat:@"x%d",(int)product.bayCount]];
        }
        else if (indexPath.row==2)//合计
        {
            [cell.name setText:@"小计"];
            [cell.sumPrice setText:[NSString stringWithFormat:@"￥%0.2lf",product.productRealityPrice*product.bayCount]];
            _order.orderSumPrice +=product.productRealityPrice*product.bayCount;
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
    }
   
}

#pragma mark -确认订单
-(void)settlementBtnClick
{
    //验证地址
    if (_order.orderAddress==nil||_order.orderAddress.length==0)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"亲，收货地址不能为空哦~" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    //显示指示器
    [self.simpleHud setHidden:NO];
    [self.simpleHud startSimpleLoad];
    
    //判断结算类型
    //如果是立即购买
    if (_settlementType == 1)
    {
         ProductShopCar * product = _productList[0];
        self.path =[NSString stringWithFormat:@"%sStoreOrders/addOrderSimple?productID=%@&buyCount=%d",SERVER_ROOT_PATH,product.productID,(int)product.bayCount];
        
        /**
           userID = 用户ID
            orderConsignee = 订单收件人
            orderAddress = 订单地址
            orderTelephone = 电话号码
            rderSumPrice = 总金额
            orderDesc = 订单描述
            pmcID = 物业ID
         
         
            productID = 商品ID
            buyCount = 商品数量
         */
    }
    else if(_settlementType == 2)
        //购物车结算
    {
        
        NSMutableString *shapCarIDs = [NSMutableString new];
        
        for (int i =0; i<_productList.count; i++)
        {
            ProductShopCar * product = _productList[i];
            [shapCarIDs appendString:@"shopCarID="];
            
            [shapCarIDs appendString:product.shopCarID];
            if (i<_productList.count-1)
            {
                 [shapCarIDs appendString:@"&"];
            }
        }
        
        self.path = [NSString stringWithFormat:@"%sStoreOrders/addOrder?%@",SERVER_ROOT_PATH,shapCarIDs] ;
        
        /**
             userID = 用户ID
             orderConsignee = 订单收件人
             orderAddress = 订单地址
             orderTelephone = 电话号码
             orderSumPrice = 总金额
             orderDesc = 订单描述
             pmcID = 物业ID
         
         
             shopCarID = 购物车ID
             [shopCarID = 购物车ID]
         */
    }
    
   
    NSURL *url = [NSURL URLWithString:self.path];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    
    //公共参数
    NSString *str = [NSString stringWithFormat:@"userID=%d&orderConsignee=%@&orderAddress=%@&orderTelephone=%@&orderSumPrice=%0.2lf&orderDesc=%@&pmcID=%d&orderFreight=%0.2lf",(int)[User shareUserID],_order.orderConsignee,_order.orderAddress,_order.orderTelephone,_order.orderSumPrice,@"",(int)_order.pMCID,_order.orderFreight];//设置参数
    
   
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:data];
    
    //发送请求
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (connectionError == nil)
         {
             //将结果转成字典集合
             NSDictionary *dic =(NSDictionary *) [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    //NSLog(@"%@",dic);
                    
                    //成功时
                    if ([dic[@"message"][@"status"] integerValue]==1)
                    {
                       
                        //关闭指示器
                        [self.simpleHud stopAnimation];
                        //push到选择支付方式页面
                        PlayTypeViewController *playTypeView= [[ PlayTypeViewController alloc]init];
                        //传入订单编号
                        [playTypeView setOrderID:dic[@"orderID"]];
                        //传入订单金额
                        [playTypeView setSumprice:_order.orderSumPrice];
                        
                        [self.navigationController pushViewController:playTypeView animated:YES];
                        
                    }
                    //失败时
                    else
                    {
                        [self.simpleHud stopAnimation];
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:dic[@"message"][@"msg"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                        [alertView show];
                    }
                    
                });
         }
         else
         {
          //网络请求出错时
             [self.simpleHud stopAnimation];
             UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:connectionError.debugDescription delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
             [alertView show];

         }
     }];

    
   
}

#pragma mark -重新加载默认地址
-(void)reLoadDefaultAddress
{
    [self loadUserDefaultAddress];
}




#pragma mark -CustomHUD 懒加载
-(CustomHUD *)simpleHud
{
    if (_simpleHud == nil) {
        _simpleHud= [CustomHUD defaultCustomHUDSimpleWithFrame:self.view.frame];
        [self.view addSubview:_simpleHud];
        [_simpleHud setHidden:YES];
    }
    return _simpleHud;
}

#pragma mark -tableView行点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //选择地址
    if (indexPath.section ==0&&indexPath.row==0)
    {
        AddressViewController *addressView  =[[AddressViewController alloc]init];
        [addressView setDelegate:self];
        [self.navigationController pushViewController:addressView animated:YES];
    }
    else if(indexPath.section ==0&&indexPath.row==1)
    {
        DeliveryTimeViewController *deliveryTimeView  =[[DeliveryTimeViewController alloc]init];
        [self.navigationController pushViewController:deliveryTimeView animated:YES];
    }
    
    
}

#pragma mark -选择订单代理方法
-(void)selectRowWithProvinceCityDistrict:(NSString *)provinceCityDistrict AddressDetail:(NSString *)addressDetail Consignee:(NSString *)consignee Telephone:(NSString *)telephone
{
   // _order set
    //订单地址
    [_order setOrderAddress:[NSString stringWithFormat:@"%@%@",provinceCityDistrict,addressDetail]];
    //收货人
    [_order setOrderConsignee:consignee];
    //联系电话
    [_order setOrderTelephone:telephone];
    
    
    //地址行显示内容
    _defaultAddress = [NSString stringWithFormat:@"%@%@--%@",provinceCityDistrict,addressDetail,consignee];
    
    //更新行
    NSIndexPath *newIndex = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[newIndex] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark -返回上层
-(void)leftClick
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
