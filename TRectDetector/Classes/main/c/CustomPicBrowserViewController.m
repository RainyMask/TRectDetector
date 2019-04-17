//
//  CustomPicBrowserViewController.m
//  YKYClient
//
//  Created by tao on 2018/8/14.
//  Copyright © 2018年 tao. All rights reserved.
//

#import "CustomPicBrowserViewController.h"
#import "PictureCollectionCell.h"


@interface CustomPicBrowserViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger index;

@end

@implementation CustomPicBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTargat:self action:@selector(dismissAction) image:@"back" highImage:@"back"];
    
    [self.view addSubview:self.collectionView];
    
    //滚动到指定位置
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.index + 1 > self.imagesArr.count) {
            self.title = [NSString stringWithFormat:@"1/%ld", self.imagesArr.count];
        } else {
            self.title = [NSString stringWithFormat:@"%ld/%ld",self.index + 1, self.imagesArr.count];
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.index inSection:0] atScrollPosition:(UICollectionViewScrollPositionNone) animated:NO];
        }
    });
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)dismissAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(kScreenWidth, kScreenHeight - kIPhoneXNavHeight - kIPhoneXBarOffset + 20);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kIPhoneXNavHeight - kIPhoneXBarOffset + 20) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[PictureCollectionCell class] forCellWithReuseIdentifier:@"cell"];
        
    }
    return _collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imagesArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PictureCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if ([self.imagesArr[indexPath.row] isKindOfClass:[UIImage class]]) {
        cell.imageView.image = self.imagesArr[indexPath.row];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    // 立即调用layoutSubviews 方法更新布局
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / kScreenWidth;
    self.title = [NSString stringWithFormat:@"%ld/%ld", index + 1, self.imagesArr.count];
}



- (void)setImagesArr:(NSArray<UIImage *> *)imagesArr atIndex:(NSInteger)index {

    self.imagesArr = imagesArr;
    self.index = index;
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
