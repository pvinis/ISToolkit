//
// Copyright (c) 2013-2014 InSeven Limited.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import "ISCacheViewController.h"
#import "ISRotatingFlowLayout.h"
#import "ISCacheFile.h"
#import "ISCacheStateFilter.h"
#import "ISSectionHeader.h"

@interface ISCacheViewController () {
  NSUInteger _count;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) ISListViewAdapter *adapter;
@property (nonatomic, strong) ISListViewAdapterConnector *connector;
@property (nonatomic, strong) ISRotatingFlowLayout *flowLayout;
@property (nonatomic, strong) NSMutableDictionary *titleCache;

@end

static NSString *kCacheCollectionViewHeaderReuseIdentifier = @"CacheHeader";
static NSString *kCacheCollectionViewCellReuseIdentifier = @"CacheCell";

@implementation ISCacheViewController


- (id)init
{
  self = [super init];
  if (self) {
    [self _initialize];
  }
  return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self _initialize];
  }
  return self;
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
  [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
  self.collectionView.frame = self.view.frame;
}


- (void)_initialize
{
  self.title = @"Downloads";
  
  self.titleCache = [NSMutableDictionary dictionaryWithCapacity:3];
  
  // Create and configure the flow layout.
  self.flowLayout = [ISRotatingFlowLayout new];
  self.flowLayout.adjustsItemSize = YES;
  self.flowLayout.spacing = 2.0f;
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    self.flowLayout.minimumItemSize = CGSizeMake(283.0, 72.0);
  } else {
    self.flowLayout.minimumItemSize = CGSizeMake(283.0, 72.0);
  }
  self.flowLayout.stickyHeaders = YES;
  self.flowLayout.headerReferenceSize = CGSizeMake(0, 32);
  
  self.collectionView =
  [[UICollectionView alloc] initWithFrame:self.view.bounds
                     collectionViewLayout:self.flowLayout];
  self.collectionView.autoresizingMask =
  UIViewAutoresizingFlexibleWidth |
  UIViewAutoresizingFlexibleHeight;
  self.collectionView.alwaysBounceVertical = YES;
  self.collectionView.delegate = self;
  self.collectionView.dataSource = self;
  [self.view addSubview:self.collectionView];
  
  self.collectionView.backgroundColor = [UIColor whiteColor];
  
  self.adapter = [[ISListViewAdapter alloc] initWithDataSource:self];
  self.connector = [ISListViewAdapterConnector connectorWithAdapter:self.adapter collectionView:self.collectionView];
  
  // Register the views.
  NSBundle* bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"ISToolkit" withExtension:@"bundle"]];
  UINib *nib = [UINib nibWithNibName:@"ISCacheCollectionViewCell" bundle:bundle];
  [self.collectionView registerNib:nib
        forCellWithReuseIdentifier:kCacheCollectionViewCellReuseIdentifier];
  [self.collectionView registerClass:[ISSectionHeader class]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:kCacheCollectionViewHeaderReuseIdentifier];

  [[ISCacheManager defaultManager] setDelegate:self];
}


- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.adapter invalidate];
}


- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [self.connector ready];
}


- (NSString *)titleForItem:(ISCacheItem *)cacheItem
{
  NSString *title = [self.titleCache objectForKey:cacheItem.uid];
  if (title) {
    return title;
  } else if ([self.delegate respondsToSelector:@selector(cacheViewController:titleForItem:)]) {
    title = [self.delegate cacheViewController:self
                                  titleForItem:cacheItem];
    if (title) {
      [self.titleCache setObject:title
                          forKey:cacheItem.uid];
    }
  }
  return title;
}


#pragma mark - UICollectionViewDataSource


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return [self.connector numberOfSections];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
  return [self.connector numberOfItemsInSection:section];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  ISCacheCollectionViewCell *cell
  = [collectionView dequeueReusableCellWithReuseIdentifier:kCacheCollectionViewCellReuseIdentifier forIndexPath:indexPath];

  ISCacheItem *cacheItem = [self.adapter itemForIndexPath:indexPath];
  
  cell.delegate = self;
  cell.cacheItem = cacheItem;
  
  // Title.
  [cell setTitle:[self titleForItem:cacheItem]];
  
  // Image URL.
  if ([self.delegate respondsToSelector:@selector(cacheViewController:imageURLForItem:)]) {
    NSString *url = [self.delegate cacheViewController:self imageURLForItem:cacheItem];
    if (url) {
      [cell.imageView setImageWithIdentifier:url context:ISCacheImageContext placeholderImage:nil block:NULL];
    }
  }
  
  return cell;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
  if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
    ISSectionHeader *header =
    [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                       withReuseIdentifier:kCacheCollectionViewHeaderReuseIdentifier
                                              forIndexPath:indexPath];
    header.textLabel.text = [[self.adapter titleForSection:indexPath.section] uppercaseString];
    return header;
  }
  return nil;
}


#pragma mark - ISListViewAdapterDataSource


- (void)identifiersForAdapter:(ISListViewAdapter *)adapter
              completionBlock:(ISListViewAdapterBlock)completionBlock
{
  // Sort the items.
  // TODO Consider dispatching this onto a separate worker.
  NSArray *items = [[ISCacheManager defaultManager] items];
  items = [items sortedArrayUsingComparator:
           ^NSComparisonResult(ISCacheItem *item1, ISCacheItem *item2) {
             if (item1.state == item2.state) {
               return [[self titleForItem:item1] compare:[self titleForItem:item2]];
             } else if (item1.state < item2.state) {
               return NSOrderedAscending;
             } else {
               return NSOrderedDescending;
             }
           }];
  
  NSMutableArray *identifiers =
  [NSMutableArray arrayWithCapacity:items.count];
  for (ISCacheItem *item in items) {
    [identifiers addObject:item.uid];
  }
  
  completionBlock(identifiers);
}


- (id)adapter:(ISListViewAdapter *)adapter summaryForIdentifier:(id)identifier
{
  return @"";
}


- (NSString *)adapter:(ISListViewAdapter *)adapter sectionForIdentifier:(id)identifier
{
  ISCache *defaultCache = [ISCache defaultCache];
  ISCacheItem *cacheItem = [defaultCache itemForUid:identifier];
  if (cacheItem.state == ISCacheItemStateInProgress) {
    return @"In Progress";
  } else if (cacheItem.state == ISCacheItemStateNotFound) {
    return @"Not Found";
  } else if (cacheItem.state == ISCacheItemStateFound) {
    return @"Downloaded";
  }
  return @"";
}


- (void)adapter:(ISListViewAdapter *)adapter itemForIdentifier:(id)identifier completionBlock:(ISListViewAdapterBlock)completionBlock
{
  ISCache *defaultCache = [ISCache defaultCache];
  completionBlock([defaultCache itemForUid:identifier]);
}


#pragma mark - ISCacheObserver


- (void)managerDidChange:(ISCacheManager *)manager
{
  NSArray *items = [manager items];
  [self willChangeValueForKey:@"count"];
  _count = items.count;
  [self didChangeValueForKey:@"count"];
  [self.adapter invalidate];
}


#pragma mark - UICollectionViewDelegate


- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  ISCacheItem *item = [self.adapter itemForIndexPath:indexPath];
  [self.delegate cacheViewController:self
                  didSelectCacheItem:item];
}


#pragma mark - ISCacheCollectionViewCellDelegate


- (void)cell:(ISCacheCollectionViewCell *)cell
didFetchItem:(ISCacheItem *)item
{
  if ([self.delegate respondsToSelector:@selector(cacheViewController:didFetchCacheItem:)]) {
    [self.delegate cacheViewController:self
                     didFetchCacheItem:item];
  } else {
    [item fetch];
  }
}


- (void)cell:(ISCacheCollectionViewCell *)cell
didRemoveItem:(ISCacheItem *)item
{
  if ([self.delegate respondsToSelector:@selector(cacheViewController:didRemoveCacheItem:)]) {
    [self.delegate cacheViewController:self
                    didRemoveCacheItem:item];
  } else {
    [item remove];
  }
}


- (void)cell:(ISCacheCollectionViewCell *)cell
didCancelItem:(ISCacheItem *)item
{
  if ([self.delegate respondsToSelector:@selector(cacheViewController:didCancelCacheItem:)]) {
    [self.delegate cacheViewController:self
                    didCancelCacheItem:item];
  } else {
    [item cancel];
  }
}


@end
