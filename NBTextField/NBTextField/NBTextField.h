//
//  NBTextField.h
//  DemoProject
//
//  Created by Nanda Ballabh on 18/04/17.
//  Copyright © 2017 nandaballabh. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NBTextFieldType) {
    
    NBTextFieldTypeName = 1100,
    NBTextFieldTypeMobile,
    NBTextFieldTypeOTP,
    NBTextFieldTypeEmail,
    NBTextFieldTypePicker,
    NBTextFieldTypeDatePicker,
    NBTextFieldTypeDefault
};

#define TEXT_LENGTH 35
#define OTP_LENGTH 6
#define MOBILE_MAX_LENGTH 17
#define MOBILE_MIN_LENGTH 6

@protocol NBTextFieldDelegate;

@interface NBTextField : UITextField

@property (strong,nonatomic) IBInspectable UIColor * errorColor;

@property (strong,nonatomic) IBInspectable UIColor * normalColor;

@property (strong,nonatomic) IBInspectable UIColor * focusColor;

@property (strong,nonatomic) IBInspectable UIColor * topBarColor; // for picker tabbar

@property (strong,nonatomic) NSString * dateTextFormat; // text date format for the date picker on selection

@property (nonatomic) IBInspectable BOOL  leftMargin;

@property (nonatomic) IBInspectable BOOL  isOptional;

@property (weak,nonatomic) id<NBTextFieldDelegate> nbDelegate;


- (void) setTextFieldType:(NBTextFieldType) type;// Set TextField type

- (void) addPickerWithSource:(NSArray *)dataSource andDownArrow:(UIImage *) arrowImage; // Add Picker as inputview

- (UIDatePicker *) addDatePickerWithMode:(UIDatePickerMode)pickerMode andDownArrow:(UIImage *) arrowImage; // Add Date picker as inputview

- (void) markTextField; // Mark error in TextField

- (void) clearTextField; // Clear error marking in TextField

- (void) focusTextField; // Focus on start editing  in TextField

- (NSString *)checkForValidation; // Final check for validation on textField end editing

- (void) setDownArrowAsRightView:(UIImage*) arrowImage; // Set Down Arrow

@end

@protocol NBTextFieldDelegate <NSObject>

@optional

- (BOOL)nb_textFieldShouldBeginEditing:(NBTextField *)textField;
// return NO to disallow editing.

- (void)nb_textFieldDidBeginEditing:(NBTextField *)textField;
// became first responder

- (BOOL)nb_textFieldShouldEndEditing:(NBTextField *)textField;
// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end

- (void)nb_textFieldDidEndEditing:(NBTextField *)textField;
// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called

- (BOOL)nb_extField:(NBTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string isValidString:(BOOL) isValidText;
// return NO to not change text and having pre validation

@end