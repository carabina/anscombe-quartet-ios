//
//  AQChartViewController.m
//  anscombe-quartet-ios
//
//  Created by Terry Worona on 6/9/14.
//  Copyright (c) 2014 Jawbone. All rights reserved.
//

#import "AQChartViewController.h"

// Views
#import <JBLineChartView.h>

// Enums
typedef NS_ENUM(NSInteger, AQChartViewChartType){
    AQChartViewChartType1,
	AQChartViewChartType2,
    AQChartViewChartType3,
    AQChartViewChartType4,
    AQChartViewChartTypeCount
};

// Numerics (AQChartLegendView)
CGFloat static const kAQChartLegendViewMarginSize = 15.0f;

// Numerics (AQChartGridView)
CGFloat static const kAQChartGridViewPadding = 5.0f;

@interface AQChartLegendView : UIView

@end

@interface AQChartView : UIView

@property (nonatomic, strong) JBLineChartView *lineChartView;
@property (nonatomic, strong) AQChartLegendView *chartLegendView;

@end

@interface AQChartGridView : UIView

@property (nonatomic, strong) NSArray *chartViews;

- (void)reloadData;

@end

@interface AQChartViewController () <JBLineChartViewDataSource, JBLineChartViewDelegate>

@property (nonatomic, strong) AQChartGridView *chartGridView;
@property (nonatomic, strong) NSDictionary *dataModel;

- (void)initDataModel;

@end

@implementation AQChartViewController

#pragma mark - Alloc/Init

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initDataModel];
    }
    return self;
}

#pragma mark - Data

- (void)initDataModel
{
    NSMutableDictionary *mutableDataModel = [NSMutableDictionary dictionary];
    self.dataModel = [NSMutableDictionary dictionaryWithDictionary:mutableDataModel];
}

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.chartGridView = [[AQChartGridView alloc] initWithFrame:self.view.bounds];
    self.view = self.chartGridView;
    
    NSMutableArray *mutableChartGrids = [[NSMutableArray alloc] init];
    for (int chartIndex=0; chartIndex<AQChartViewChartTypeCount; chartIndex++)
    {
        AQChartView *chartView = [[AQChartView alloc] init];
        chartView.lineChartView.delegate = self;
        chartView.lineChartView.dataSource = self;
        chartView.lineChartView.tag = chartIndex;
        chartView.backgroundColor = [UIColor redColor];
        [mutableChartGrids addObject:chartView];
    }
    self.chartGridView.chartViews = [NSArray arrayWithArray:mutableChartGrids];
    
    [self.chartGridView reloadData];
}

#pragma mark - JBLineChartViewDataSource

- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView;
{
    return 0;
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    return 0;
}

#pragma mark - JBLineChartViewDelegate

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return 0;
}

@end

@implementation AQChartLegendView

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}

@end

@implementation AQChartView

#pragma mark - Alloc/Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        _chartLegendView = [[AQChartLegendView alloc] init];
        _chartLegendView.backgroundColor = [UIColor blueColor];
        [self addSubview:_chartLegendView];
        
        _lineChartView = [[JBLineChartView alloc] init];
        _lineChartView.backgroundColor = kJBColorBaseBackgroundColor;
        [self addSubview:_lineChartView];
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.chartLegendView.frame = self.bounds;
    self.lineChartView.frame = CGRectMake(kAQChartLegendViewMarginSize, self.bounds.origin.y, self.bounds.size.width - kAQChartLegendViewMarginSize, self.bounds.size.height - kAQChartLegendViewMarginSize);
}

@end

@implementation AQChartGridView

#pragma mark - Alloc/Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = kJBColorBaseBackgroundColor;
    }
    return self;
}

#pragma mark - Data

- (void)reloadData
{
    for (AQChartView *chartView in self.chartViews)
    {
        if ([chartView isKindOfClass:[AQChartView class]])
        {
            [chartView.lineChartView reloadData];
        }
    }
    
    [self setNeedsLayout];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([self.chartViews count] > 0)
    {
        // Layout assumes max 4 charts
        NSAssert([self.chartViews count] == 4, @"AQChartGridView // layout supports exactly 4 charts.");
        
        CGFloat chartWidth = ceil((self.bounds.size.width - (kAQChartGridViewPadding * 3)) * 0.5f);
        CGFloat chartHeight = ceil((self.bounds.size.height - (kAQChartGridViewPadding * 3)) * 0.5f);
        
        CGFloat xOffset = kAQChartGridViewPadding;
        CGFloat yOffset = kAQChartGridViewPadding;
        
        for (AQChartView *chartView in self.chartViews)
        {
            chartView.frame = CGRectMake(xOffset, yOffset, chartWidth, chartHeight);
            
            if (chartView.lineChartView.tag == AQChartViewChartType2)
            {
                yOffset += chartHeight + kAQChartGridViewPadding;
                xOffset = kAQChartGridViewPadding;
            }
            else
            {
                xOffset += chartWidth + kAQChartGridViewPadding;
            }
        }
    }
}

#pragma mark - Setters

- (void)setChartViews:(NSArray *)chartViews
{
    for (AQChartView *oldChartView in self.chartViews)
    {
        [oldChartView removeFromSuperview];
    }
    
    for (AQChartView *newChartView in chartViews)
    {
        [self addSubview:newChartView];
    }
    
    _chartViews = chartViews;
    
    [self setNeedsLayout];
}

@end
