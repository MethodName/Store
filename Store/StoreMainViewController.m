//
//  StoreMainViewController.m
//  Store
//
//  Created by tangmingming on 15/8/13.
//  Copyright (c) 2015年 tangmingming. All rights reserved.
//

#import "StoreMainViewController.h"
#import "MainADScrollVIew.h"
#import "MainMeunView.h"
#import "TopProductsView.h"
#import "MJRefresh.h"
#import "MainProductCell.h"
#import "ProductListTableViewController.h"
#import "ToolsOriginImage.h"
#import "ProductDetailViewController.h"
#import "ProductTypes.h"
#import "ShopCarViewController.h"
#import "CustomHUD.h"
#import "ShopCarButton.h"
#import "MessageListViewController.h"
#import "Product.h"
#import "StoreDefine.h"
#import "User.h"
#import "StoreNavigationBar.h"


@interface StoreMainViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,MainMeunViewDelegate,MainSreachBarDelegate,TopProductsViewDelegate,MainADScrollVIewDelegate,MainProductCellDelegate,UIGestureRecognizerDelegate,StoreNavigationBarDeleagte>

/**
 *  屏幕大小
 */
@property(assign,nonatomic)CGSize mainSize;
/**
 *  tableView
 */
@property(strong,nonatomic)UITableView *tableView;

/**
 *  底部ScrollView
 */
@property(nonatomic,strong)UIView *headView;

/**
 *  广告图片数组
 */
@property(strong,nonatomic)NSMutableArray *adImages;
/**
 *  结束主页数据的字典
 */
@property(nonatomic,strong)NSDictionary *dataDic;
/**
 *  广告图片ScrollView
 */
@property(strong,nonatomic)MainADScrollVIew *ad;
/**
 *  分类View
 */
@property(nonatomic,strong)MainMeunView *meunView;
/**
 *  置顶商品View
 */
@property(nonatomic,weak)TopProductsView *topProductsView;
/**
 *  类型数组
 */
@property(strong,nonatomic)NSMutableArray *productTypes;
/**
 *  置顶商品数组
 */
@property(strong,nonatomic)NSMutableArray *proTopArray;
/**
 *  热销商品数组
 */
@property(nonatomic,strong)NSMutableArray *hotProductList;
/**
 *  商品图片数组
 */
@property(nonatomic,strong)NSMutableDictionary *productImageList;
/**
 *  加载指示器
 */
@property(nonatomic,strong)CustomHUD *hud;
/**
 *  添加指示器
 */
@property(nonatomic,strong)CustomHUD *addshopHud;
/**
 *  购物车按钮
 */
@property(nonatomic,strong)ShopCarButton *shopCar;
/**
 *  广告page
 */
@property(nonatomic,weak)UIPageControl *page;
/**
 *商品列表页面
 */
@property(nonatomic,weak) ProductListTableViewController *productListTableView;
/**
 *  自定义导航栏
 */
@property(nonatomic,weak)StoreNavigationBar *customNavigationBar;

@end


@implementation StoreMainViewController


#pragma mark -视图加载后
- (void)viewDidLoad
{
   
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor orangeColor]];
    _mainSize = self.view.frame.size;
    
    
    //设置用户ID
    [User setShacreUserID:1];
    
    //设置物业ID
    [User setShacrePmcID:1];
    
    [self createView];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
}



#pragma mark -创建视图
-(void)createView
{

#pragma mark -导航栏
    [self.navigationController setNavigationBarHidden:YES];
    StoreNavigationBar *navigationBar= [[StoreNavigationBar alloc]initWithFrame:CGRectMake(0, 0, _mainSize.width, 64)];
    [navigationBar setBarDelegate:self];
    [self.view addSubview:navigationBar];
    [navigationBar.searchBar setDelegate:self];
    _customNavigationBar = navigationBar;
    
#pragma mark -tableView
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, _mainSize.width, _mainSize.height-64) style:UITableViewStylePlain];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:_tableView];
    [self.tableView registerClass:[MainProductCell class] forCellReuseIdentifier:@"mainProductCell"];
    [self.tableView setRowHeight:100];
    
#pragma mark -headView
    
    _headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _mainSize.width, _mainSize.height)];
    [_headView setBackgroundColor:[UIColor colorWithRed:(220/255.0) green:(220.0/255.0) blue:(220.0/255.0) alpha:1.0]];
    
#pragma mark -广告ScrollView
    
    _ad = [[MainADScrollVIew alloc]initWithFrame:CGRectMake(0, 0, _mainSize.width, _mainSize.width*0.6)];
    [_ad setSreachBarDelegate:self];
    [_ad setImageMoveDelegate:self];
    [_ad setDelegate:self];
    [_headView addSubview:_ad];
    //ADpage
    UIPageControl *page = [[UIPageControl alloc]initWithFrame:CGRectMake(_ad.frame.size.width-100, _ad.frame.size.height-20, 100,20)];
    [page setCurrentPage:0];
    _page = page;
    [page setCurrentPageIndicatorTintColor:[UIColor orangeColor]];
    [page setPageIndicatorTintColor:[UIColor grayColor]];
    [_headView addSubview:page];
    
    
#pragma mark  -类别
    
    _meunView = [[MainMeunView alloc]initWithFrame:CGRectMake(0, _ad.frame.origin.y+_ad.frame.size.height, _mainSize.width,80)];
    [_meunView setDelegate:self];
    [_headView addSubview:_meunView];
   
  
    
#pragma mark -置顶商品
    
    TopProductsView *topProductsView = [[TopProductsView alloc]initWithFrame:CGRectMake(0, _meunView.frame.origin.y+_meunView.frame.size.height+10, _mainSize.width, 150)];
    [_headView addSubview:topProductsView];
    _topProductsView = topProductsView;
    [topProductsView setDelegate:self];

#pragma mark -重新设置headview大小
    
    [_headView setFrame:CGRectMake(0, 0, _mainSize.width, topProductsView.frame.origin.y+topProductsView.frame.size.height+2)];
  
    
#pragma mark -购物车按钮
    
    _shopCar = [[ShopCarButton alloc]initWithFrame:CGRectMake(15, _mainSize.height-45, 44, 44)];
    [_shopCar addTarget:self action:@selector(pushToShopCarView) forControlEvents:UIControlEventTouchUpInside];
    [_shopCar setShopcarCountWithNum:0];
    [self.view addSubview:_shopCar];
    
#pragma mark -刷新控件
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    // 设置普通状态的动画图片
    NSMutableArray *images1 = [NSMutableArray new];
    for (int i =0; i<28; i++) {
        NSString *path =[NSString stringWithFormat:@"Image.bundle/loading/%d.png",i+1];
        UIImage *img =[UIImage imageNamed:path];
        [images1 addObject:[UIImage imageWithCGImage:[img CGImage] scale:4.0 orientation:UIImageOrientationUp]];
    }
    [header setImages:images1 forState:MJRefreshStateIdle];
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    [header setImages:images1 forState:MJRefreshStatePulling];
    // 设置正在刷新状态的动画图片
    [header setImages:images1 forState:MJRefreshStateRefreshing];
    // 设置header
    self.tableView.header = header;
    
#pragma mark -指示器
    CustomHUD *hud = [CustomHUD defaultCustomHUDWithFrame:self.view.frame];
    [self.view addSubview:hud];
    [hud startLoad];
    _hud = hud;
    
    
    if (_productImageList==nil)
    {
        _productImageList = [NSMutableDictionary new];
    }
//加载数据
    [self loadData];
}


#pragma mark -加载数据
-(void)loadData
{
    
    
    //置顶商品集合
    if (_proTopArray == nil)
    {
        _proTopArray = [NSMutableArray new];
    }
   
    
    //热销商品集合
    if (_hotProductList == nil)
    {
        _hotProductList = [NSMutableArray new];
    }
   
    
#pragma mark -异步获取数据
    
    //确定路径
    NSString *path =[NSString stringWithFormat: @"%sStoreProduct/StoreHomePage?pmcID=%d",SERVER_ROOT_PATH,1];
    NSURL *url = [NSURL URLWithString:path];
    
    //NSLog(@"%@",path);
    NSURLRequest *requst = [NSURLRequest requestWithURL:url];
    //发送请求
    
    
    [NSURLConnection sendAsynchronousRequest:requst queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
    {
        if (connectionError == nil)
        {
              NSDictionary *dic =(NSDictionary *) [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            //NSLog(@"%@",dic);
            //获取广告图片资源
            NSArray *ads = dic[@"adImages"];
          
            //设置page页数
            [_page setNumberOfPages:ads.count];
            //广告集合
            if(_adImages==nil)
            {
                _adImages = [[NSMutableArray alloc]init];
                for (int i =0; i<ads.count; i++)
                {
                    [_adImages addObject:ads[i]];
                }
                //主线程更新UI
                dispatch_async(dispatch_get_main_queue(), ^
               {
                   //广告
                   [_ad setImages:_adImages];
               });

            }
            
            //分类集合
            if (_productTypes == nil)
            {
                _productTypes = [NSMutableArray new];
                //获取商品分类分类信息
                NSArray *types = dic[@"productTypes"];
                for (int i =0; i<types.count; i++)
                {
                    ProductTypes *type = [ProductTypes new];
                    [type setValuesForKeysWithDictionary:types[i]];
                    [_productTypes addObject:type];
                }
                //主线程更新UI
                dispatch_async(dispatch_get_main_queue(), ^
               {
                   //获取商品类型个数
                   NSInteger maxRow = (types.count+1)/4+1;
                   //重新改变大小
                   [_meunView setFrame:CGRectMake(0, _ad.frame.origin.y+_ad.frame.size.height, _mainSize.width,maxRow*80)];
                   [_topProductsView setFrame:CGRectMake(0, _meunView.frame.origin.y+_meunView.frame.size.height+10, _mainSize.width, 150)];
                   
                   [_headView setFrame:CGRectMake(0, 0, _mainSize.width, _topProductsView.frame.origin.y+_topProductsView.frame.size.height+2)];
                   [_tableView setTableHeaderView:_headView];
                   
                   //商品类别信息
                   [_meunView setMenuItems:_productTypes];
                });
               
            }
            
            [_proTopArray removeAllObjects];
            //置顶商品集合
            NSArray *proTopList = dic[@"recommends"];
            for (int i=0; i<proTopList.count; i++)
            {
                Product *topProduct = [Product new];
                [topProduct setValuesForKeysWithDictionary:proTopList[i]];
                [_proTopArray addObject:topProduct];
            }
            
            
            [_hotProductList removeAllObjects];
            //热销商品集合
            NSArray * hotProductList = dic[@"hotSelling"];
            //NSLog(@"%d",hotProductList.count);
            for (int i=0; i<hotProductList.count; i++)
            {
                Product *topProduct = [Product new];
                [topProduct setValuesForKeysWithDictionary:hotProductList[i]];
                [_hotProductList addObject:topProduct];
            }
            
            //主线程更新UI
            dispatch_async(dispatch_get_main_queue(), ^
               {
                  
                   //置顶商品
                   [_topProductsView setProducts:_proTopArray];
                   //商品列表信息
                   [self.tableView reloadData];
                   //停止刷新控件刷新
                   [self.tableView.header endRefreshing];
                   //隐藏加载动画
                   [_hud loadHide];
               });

        }
    }];
    
    
    //获取购物车用户购物车中商品数量
    NSString *shopaCarPath = [NSString stringWithFormat:@"%sStoreShopCar/findShopCarCountByUserID?userID=%d",SERVER_ROOT_PATH,(int)[User shareUserID]];

    NSURL *shopCarUrl = [NSURL URLWithString:shopaCarPath];
    NSURLRequest *shopCarRequst = [NSURLRequest requestWithURL:shopCarUrl];
    //发送请求
    [NSURLConnection sendAsynchronousRequest:shopCarRequst queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
    {
        if (connectionError == nil)
        {
            NSDictionary *dic =(NSDictionary *) [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //主线程更新购物车显示数量
                 [_shopCar setShopcarCountWithNum:[dic[@"count"] integerValue]];
            });
        }
    }];
}




#pragma mark -设置表格行
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _hotProductList.count;
}

#pragma mark -设置表格行内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Product *product = _hotProductList[indexPath.row];
    
    MainProductCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mainProductCell"];
    if (cell.productImage == nil)
    {
        cell = [[MainProductCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mainProductCell"];
    }
    if (_productImageList == nil)
    {
        _productImageList = [NSMutableDictionary new];
    }
    //如果存放图片的集合中没有当前商品的图片
    if (_productImageList[product.productID]==nil)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //将图片路径分割出来
            NSArray *imageArr = [product.productImages  componentsSeparatedByString:@","];
            //确定图片的路径
            NSURL *photourl = [NSURL URLWithString:[NSString stringWithFormat:@"%s%@",SERVER_IMAGES_ROOT_PATH,imageArr[0]]];
            //通过网络url获取uiimage
            UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:photourl]];
            if (img==nil)
            {
                //如果图片为nil，使用占位图片
                [_productImageList setObject:[UIImage imageNamed:@"placeholderImage"] forKey:product.productID];
            }
            else
            {
                [_productImageList setObject:img forKey:product.productID];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                //更新UI
                [cell.productImage setImage:img];
            });
        });
    }
    else//图片集合中有当前商品的图片，直接使用集合中的图片，不去加载网络资源
    {
        [cell.productImage setImage:_productImageList[product.productID]];
    }
   [cell setCellDataWithProduct:product];
    //设置Cell代理
    [cell setDelegate:self];
    
    return cell;
}

#pragma mark -热销商品跳转到商品详情
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   //隐藏seachBar
    
    Product *product = _hotProductList[indexPath.row];
    ProductDetailViewController *productDetail = [[ProductDetailViewController alloc]init];
    [productDetail setDelegate:self];
    productDetail.productID =product.productID;
    [self.navigationController pushViewController:productDetail animated:YES];
}



#pragma mark -置顶商品跳转详细信息
-(void)productDetailWithProductID:(NSString *)proid
{
    ProductDetailViewController *productDetail = [[ProductDetailViewController alloc]init];
    [productDetail setDelegate:self];
    [productDetail setProductID:proid];
    [self.navigationController pushViewController:productDetail animated:YES];
}

#pragma mark -搜索
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    ProductListTableViewController *productListTableView = [[ProductListTableViewController alloc]init];
    [productListTableView setDelegate:self];
    [productListTableView setProductName:_customNavigationBar.searchBar.text];
    [self.navigationController pushViewController:productListTableView animated:YES];
}

#pragma mark -商品类别搜索
-(void)productListWithType:(NSInteger)type
{
    //商品列表页面
    ProductListTableViewController *productListTableView = [[ProductListTableViewController alloc]init];
    [productListTableView setDelegate:self];
    _productListTableView = productListTableView;
    //传入商品类型编号
    [productListTableView setPtID:type];
    [productListTableView setProductName:@""];
    //push页面
    [self.navigationController pushViewController:productListTableView animated:YES];
}

#pragma mark -加入购物车（cell代理方法）
-(void)addShopCarCWithProductID:(NSString *)productID
{
    [self.addshopHud setHidden:NO];
    [self.addshopHud startSimpleLoad];
    //确定路径  StoreShopCar/addStoreShopCar?userID=1&productID=SP201508210004
    NSString *path = [NSString stringWithFormat:@"%s%@%@%@%d",SERVER_ROOT_PATH,@"StoreShopCar/addStoreShopCar?productID=",productID,@"&userID=",(int)[User shareUserID]];
  
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *requst = [[NSURLRequest alloc]initWithURL:url];
    //发送请求
    [NSURLConnection sendAsynchronousRequest:requst queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError == nil)
        {
            //将结果转成字典集合
            NSDictionary *dic =(NSDictionary *) [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([dic[@"status"] intValue] == 1)//成功
                {
                    //显示成功
                    [self.addshopHud simpleComplete];
                }
                else//失败
                {
                    //提示失败
                    [self.addshopHud stopAnimation];
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:dic[@"msg"]  delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alertView show];
                }
            });
        }
        else
        {
            NSLog(@"%@",connectionError.debugDescription);
        }
    }];
}

#pragma mark -跳转到购物车
-(void)pushToShopCarView
{
    //购物车
    ShopCarViewController *shopCar = [[ShopCarViewController alloc]init];
    //传入用户ID
    [shopCar setUserID:10];
    //push页面
    [self.navigationController pushViewController:shopCar animated:YES];
}






#pragma mark -CustomHUD 懒加载
-(CustomHUD *)addshopHud
{
    if (_addshopHud == nil) {
        _addshopHud= [CustomHUD defaultCustomHUDSimpleWithFrame:self.view.frame];
        [self.view addSubview:_addshopHud];
        [_addshopHud setHidden:YES];
    }
    return _addshopHud;
}

#pragma mark -PageControl显示当前页代理
-(void)imageMoveWithIndex:(NSInteger)index
{
    [_page setCurrentPage:index];
}


#pragma mark -sreachBar结算编辑状态
-(void)searchBarEndEditing
{
    [_customNavigationBar.searchBar endEditing:YES];
}


#pragma mark - 左边按钮
-(void)leftClick
{
   // NSLog(@"xxxxx");
}

#pragma mark -右边按钮点击
-(void)rightClick
{
    
    //消息中心
    MessageListViewController *messageListView = [[MessageListViewController alloc]init];
    [messageListView setDelegate:self];
    //push页面
    [self.navigationController pushViewController:messageListView animated:YES];
}

#pragma mark -开始返回时
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.navigationController.viewControllers.count==1)
    {
        return NO;
    }
    
    return YES;
}

@end



#pragma mark -以下为程序神秘加成部分
/**
 *
 * ━━━━━━神兽出没━━━━━━
 * 　　　┏┓　　　┏┓
 * 　　┏┛┻━━━┛┻┓
 * 　　┃　　　　　　　┃
 * 　　┃　　　━　　　┃
 * 　　┃　┳┛　┗┳　┃
 * 　　┃　　　　　　　┃
 * 　　┃　　　┻　　　┃
 * 　　┃　　　　　　　┃
 * 　　┗━┓　　　┏━┛Code is far away from bug with the animal protecting
 * 　　　　┃　　　┃    神兽保佑,代码无bug
 * 　　　　┃　　　┃
 * 　　　　┃　　　┗━━━┓
 * 　　　　┃　　　　　　　┣┓
 * 　　　　┃　　　　　　　┏┛
 * 　　　　┗┓┓┏━┳┓┏┛
 * 　　　　　┃┫┫　┃┫┫
 * 　　　　　┗┻┛　┗┻┛
 *
 * ━━━━━━感觉萌萌哒━━━━━━
 */

/**
 * 　　　　　　　　┏┓　　　┏┓
 * 　　　　　　　┏┛┻━━━┛┻┓
 * 　　　　　　　┃　　　　　　　┃
 * 　　　　　　　┃　　　━　　　┃
 * 　　　　　　　┃　＞　　　＜　┃
 * 　　　　　　　┃　　　　　　　┃
 * 　　　　　　　┃    ...　⌒　...　 ┃
 * 　　　　　　　┃　　　　　　　┃
 * 　　　　　　　┗━┓　　　┏━┛
 * 　　　　　　　　　┃　　　┃　Code is far away from bug with the animal protecting
 * 　　　　　　　　　┃　　　┃   神兽保佑,代码无bug
 * 　　　　　　　　　┃　　　┃
 * 　　　　　　　　　┃　　　┃
 * 　　　　　　　　　┃　　　┃
 * 　　　　　　　　　┃　　　┃
 * 　　　　　　　　　┃　　　┗━━━┓
 * 　　　　　　　　　┃　　　　　　　┣┓
 * 　　　　　　　　　┃　　　　　　　┏┛
 * 　　　　　　　　　┗┓┓┏━┳┓┏┛
 * 　　　　　　　　　　┃┫┫　┃┫┫
 * 　　　　　　　　　　┗┻┛　┗┻┛
 */

/**
 *　　　　　　　　┏┓　　　┏┓+ +
 *　　　　　　　┏┛┻━━━┛┻┓ + +
 *　　　　　　　┃　　　　　　　┃
 *　　　　　　　┃　　　━　　　┃ ++ + + +
 *　　　　　　 ████━████ ┃+
 *　　　　　　　┃　　　　　　　┃ +
 *　　　　　　　┃　　　┻　　　┃
 *　　　　　　　┃　　　　　　　┃ + +
 *　　　　　　　┗━┓　　　┏━┛
 *　　　　　　　　　┃　　　┃
 *　　　　　　　　　┃　　　┃ + + + +
 *　　　　　　　　　┃　　　┃　　　　Code is far away from bug with the animal protecting
 *　　　　　　　　　┃　　　┃ + 　　　　神兽保佑,代码无bug
 *　　　　　　　　　┃　　　┃
 *　　　　　　　　　┃　　　┃　　+
 *　　　　　　　　　┃　 　　┗━━━┓ + +
 *　　　　　　　　　┃ 　　　　　　　┣┓
 *　　　　　　　　　┃ 　　　　　　　┏┛
 *　　　　　　　　　┗┓┓┏━┳┓┏┛ + + + +
 *　　　　　　　　　　┃┫┫　┃┫┫
 *　　　　　　　　　　┗┻┛　┗┻┛+ + + +
 */
