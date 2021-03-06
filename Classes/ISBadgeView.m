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

#import "ISBadgeView.h"

@interface ISBadgeView ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic) UIEdgeInsets insets;

@end

@implementation ISBadgeView


- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self _initialize];
  }
  return self;
}


- (void)awakeFromNib
{
  [super awakeFromNib];
  [self _initialize];
}


- (void)_initialize
{
  self.backgroundColor = [UIColor clearColor];
  self.label = [[UILabel alloc] initWithFrame:self.bounds];
  self.label.textAlignment = NSTextAlignmentCenter;
  self.insets = UIEdgeInsetsMake(2.0f,
                                 5.0f,
                                 2.0f,
                                 5.0f);
  self.label.textColor = [UIColor whiteColor];
  [self addSubview:self.label];
}


- (void)layoutSubviews
{
  self.label.frame =
  CGRectMake(self.insets.left,
             self.insets.top,
             CGRectGetWidth(self.bounds) - self.insets.left - self.insets.right,
             CGRectGetHeight(self.bounds) - self.insets.top - self.insets.bottom);
}


- (CGSize)intrinsicContentSize
{
  return [self sizeThatFits:CGSizeZero];
}


- (CGSize)sizeThatFits:(CGSize)size
{
  CGSize labelSize = [self.label sizeThatFits:size];
  labelSize = CGSizeMake(MAX(labelSize.width, labelSize.height),
                         labelSize.height);
  return CGSizeMake(labelSize.width + self.insets.left + self.insets.right,
                    labelSize.height + self.insets.top + self.insets.bottom);
}


- (void)sizeToFit
{
  [super sizeToFit];
  [self setNeedsDisplay];
}


- (void)setInsets:(UIEdgeInsets)insets
{
  if (!UIEdgeInsetsEqualToEdgeInsets(_insets, insets)) {
    _insets = insets;
    [self setNeedsLayout];
  }
}


- (void)drawRect:(CGRect)rect
{
  if (self.text == nil ||
      [self.text isEqualToString:@""]) {
    return;
  }

  CGContextRef context = UIGraphicsGetCurrentContext();

  CGColorRef color = [self.tintColor CGColor];
  CGContextSetFillColorWithColor(context, color);
  CGContextSetStrokeColorWithColor(context, color);
  
  CGRect target = self.bounds;
  CGFloat radius = CGRectGetHeight(target) / 2.0f;
  
  CGContextBeginPath(context);
  CGContextAddArc(context,
                  CGRectGetWidth(target) - radius,
                  radius,
                  radius,
                  -M_PI_2,
                  M_PI_2,
                  0);
  CGContextAddArc(context,
                  radius,
                  radius,
                  radius,
                  M_PI_2,
                  -M_PI_2,
                  0);
  CGContextFillPath(context);
}


- (void)setText:(NSString *)text
{
  self.label.text = text;
  [self invalidateIntrinsicContentSize];
  [self setNeedsDisplay];
}


- (NSString *)text
{
  return self.label.text;
}


- (void)tintColorDidChange
{
  [super tintColorDidChange];
  [self setNeedsDisplay];
}


@end
