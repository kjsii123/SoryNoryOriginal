//
//  CNPPopupController.h
//  CNPPopupController
//
//  Created by Carson Perrotti on 2014-09-28.
//  Copyright (c) 2014 Carson Perrotti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNPPopupTheme.h"

@protocol CNPPopupControllerDelegate;

@interface CNPPopupController : UIView

@property (nonatomic, strong) NSAttributedString *popupTitle;
@property (nonatomic, strong) NSArray *contents;
@property (nonatomic, strong) NSArray *buttonTitles;
@property (nonatomic, strong) NSAttributedString *destructiveButtonTitle;

@property (nonatomic, strong) CNPPopupTheme *theme;

@property (nonatomic, strong) id <CNPPopupControllerDelegate> delegate;

- (instancetype)initWithTitle:(NSAttributedString *)popupTitle
                     contents:(NSArray *)contents
                  buttonTitles:(NSArray *)buttonTitles
       destructiveButtonTitle:(NSAttributedString *)destructiveButtonTitle;

- (UILabel *)presentPopupControllerAnimated:(BOOL)flag;
- (void)dismissPopupControllerAnimated:(BOOL)flag;

@end

@protocol CNPPopupControllerDelegate <NSObject>

@optional
- (void)popupControllerWillPresent:(CNPPopupController *)controller;
- (void)popupControllerDidPresent:(CNPPopupController *)controller;
- (void)popupController:(CNPPopupController *)controller willDismissWithButtonTitle:(NSString *)title;
- (void)popupController:(CNPPopupController *)controller didDismissWithButtonTitle:(NSString *)title;

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net
