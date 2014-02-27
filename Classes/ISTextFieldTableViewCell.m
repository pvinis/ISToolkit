//
// Copyright (c) 2013 InSeven Limited.
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

#import "ISTextFieldTableViewCell.h"
#import "ISOwnerProxy.h"

@interface ISTextFieldTableViewCell ()

@property (strong, nonatomic) NSString *identifier;

- (void)textFieldDidChange:(NSNotification *)notification;

@end

@implementation ISTextFieldTableViewCell

+ (ISTextFieldTableViewCell *)textFieldCell
{
  ISOwnerProxy *proxy =
  [ISOwnerProxy proxyWithBundleName:@"ISToolkit"
                            nibName:@"ISTextFieldTableViewCell"];
  return (ISTextFieldTableViewCell *)proxy.view;
}


+ (ISTextFieldTableViewCell *) textFieldCellWithIdentifier:(NSString *)identifier
{
  ISTextFieldTableViewCell *cell = [self textFieldCell];
  cell.identifier = identifier;
  return cell;
}


- (void) awakeFromNib
{
  [super awakeFromNib];
  self.textField.textColor = [UIColor colorWithRed:0.200
                                             green:0.290
                                              blue:0.459
                                             alpha:1.000];
  
  // Observe changes to the text field.
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center addObserver:self
             selector:@selector(textFieldDidChange:)
                 name:UITextFieldTextDidChangeNotification
               object:self.textField];
}


- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)textFieldDidChange:(NSNotification *)notification
{
  [self.delegate textFieldCellDidChange:self];
}


- (NSString *) reuseIdentifier
{
  return self.identifier;
}

@end