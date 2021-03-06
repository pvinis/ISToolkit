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

#import "ISTextField.h"

@implementation ISTextField

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    if (UIDevice.currentDevice.systemVersion.integerValue != 10) {
        return [super editingRectForBounds:bounds];
    }

    CGFloat const scale = UIScreen.mainScreen.scale;
    CGFloat const preferred = self.attributedText.size.height;
    CGFloat const delta = ceil(preferred) - preferred;
    CGFloat const adjustment = -MIN(1, floor(delta * scale)) / scale;

    CGRect const superEditingRect = [super editingRectForBounds:bounds];
    CGRect editingRect = CGRectOffset(superEditingRect, 0.0, adjustment);

    // height correction for emoji or other taller characters
    if (self.attributedText.length > 0) {
        NSMutableAttributedString *regularHeightString = self.attributedText.mutableCopy;
        [regularHeightString replaceCharactersInRange:NSMakeRange(0, regularHeightString.length-1)
                                           withString:[self.text stringByTrimmingCharactersInSet:NSCharacterSet.alphanumericCharacterSet.invertedSet]];
        CGFloat const regularHeight = [regularHeightString boundingRectWithSize:CGSizeMake(300, 10000)
                                                                        options:NSStringDrawingUsesDeviceMetrics
                                                                        context:nil].size.height;
        CGFloat const currentHeight = [self.attributedText boundingRectWithSize:CGSizeMake(300, 10000)
                                                                        options:NSStringDrawingUsesDeviceMetrics
                                                                        context:nil].size.height;
        CGFloat const heightDiff = currentHeight - regularHeight;
        CGFloat const heightCorrection = -floor(heightDiff * scale) / scale;

        editingRect = CGRectInset(editingRect, 0.0, heightCorrection);
    }

    return editingRect;
}

@end
