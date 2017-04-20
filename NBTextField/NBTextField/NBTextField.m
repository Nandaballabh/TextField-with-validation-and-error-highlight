//
//  NBTextField.m
//  DemoProject
//
//  Created by Nanda Ballabh on 18/04/17.
//  Copyright © 2017 nandaballabh. All rights reserved.
//



#import "NBTextField.h"

@implementation NSString (Utilities)

- (NSString *) trimmedString {
    
    return [self  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL) isValidateEmail {
    
    NSString *emailRegex = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
    
}

- (BOOL) isValidateMobile {
    
    if(self.length > MOBILE_MAX_LENGTH || self.length < MOBILE_MIN_LENGTH)
        return NO;
    NSString *numberRegEx = @"^[0-9]+";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegEx];
    
    return [numberTest evaluateWithObject:self];
    
}


- (BOOL) isValidateOTP {
    
    if(self.length > OTP_LENGTH)
        return NO;
    NSString *numberRegEx = @"^[0-9]+";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegEx];
    
    return [numberTest evaluateWithObject:self];
    
}

- (BOOL) isValidateName {
    
    if(self.length > TEXT_LENGTH)
        return NO;
    NSString *nameRegEx = @"^[\\p{L}]+([\\p{L} .-]+)*$";
    NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegEx];
    return [nameTest evaluateWithObject:self];
    
}

@end



@interface NBTextField()  <UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    UIPickerView * pickerView;
    UIDatePicker * datePicker;
    NSInteger  selectedIndex;
    UIView * _overLayView;
    
}
@property (strong , nonatomic) UIView * bottomLine;
@property (strong , nonatomic) NSArray * inputPickerDataSource;
@property (nonatomic) NBTextFieldType  type;
@property (strong , nonatomic) NSCharacterSet * allowedCharSet;

@end


@implementation NBTextField

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if(self) {
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        [self commonSetup];
    }
    return self;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    [self commonSetup];
}


- (void) commonSetup {
   
    if(self.errorColor == nil)
        self.errorColor = [UIColor redColor];
    if(self.focusColor == nil)
        self.focusColor = [UIColor greenColor];
    if(self.normalColor == nil)
        self.normalColor = [UIColor lightGrayColor];
    if(self.topBarColor == nil)
        self.topBarColor = [UIColor blueColor];

    self.delegate = self;
    if(self.bottomLine)
        [self.bottomLine removeFromSuperview];
    self.bottomLine = [[UIView alloc] init];
    self.bottomLine.backgroundColor = self.normalColor;
    [self addSubview:self.bottomLine];
    self.borderStyle = UITextBorderStyleNone;
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    selectedIndex = 0;
}



- (void) layoutSubviews {
    [super layoutSubviews];
    self.bottomLine.frame = CGRectMake(0, self.frame.size.height - 1.0f, self.frame.size.width, 1.0f);
}


- (void) setTextFieldType:(NBTextFieldType) type {
   
    self.type = type;
    switch (self.type) {
            
        case NBTextFieldTypeName:
        {
            NSMutableCharacterSet *charSet = [NSMutableCharacterSet letterCharacterSet];
            [charSet formUnionWithCharacterSet:[NSMutableCharacterSet whitespaceCharacterSet]];
            [charSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
            [charSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"_-'"]];
            self.allowedCharSet = charSet;

            break;

        }
        case NBTextFieldTypeMobile:
            self.allowedCharSet = [NSCharacterSet decimalDigitCharacterSet];

            break;
            
        case NBTextFieldTypeOTP:
        {
            self.allowedCharSet = [NSCharacterSet decimalDigitCharacterSet];
            break;
        }
        case NBTextFieldTypeEmail:
        {
            NSMutableCharacterSet *charSet = [NSMutableCharacterSet letterCharacterSet];
            [charSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
            [charSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@".!#$%&'*+-/=?^_{|}~@"]];
            self.allowedCharSet = charSet;
            break;
        }
        case NBTextFieldTypeDatePicker:
        case NBTextFieldTypePicker:
            break;
            
        case NBTextFieldTypeDefault:
            break;
            
    }
}

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    if(self.leftMargin)
        return CGRectInset( bounds , 5 , 0 );
    else
        return CGRectInset( bounds , 0 , 0 );
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    if(self.leftMargin)
        return CGRectInset( bounds , 5 , 0 );
    else
        return CGRectInset( bounds , 0 , 0 );
}

- (UIDatePicker *) addDatePickerWithMode:(UIDatePickerMode)pickerMode andDownArrow:(UIImage *) arrowImage {
    
    datePicker = [[UIDatePicker alloc]init];
    datePicker.datePickerMode = pickerMode;
    datePicker.layer.borderColor = [UIColor colorWithRed:187.0f/255.0f green:187.0f/255.0f blue:187.0f/255.0f alpha:1.0f].CGColor;
    datePicker.layer.borderWidth = 1.0f;
    
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0,CGRectGetWidth([UIScreen mainScreen].bounds), 44)];
    [toolBar setBarTintColor:self.topBarColor];
    [toolBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Done", @"").capitalizedString style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel", @"").capitalizedString style:UIBarButtonItemStylePlain target:self action:@selector(cencelButtonTapped)];
    toolBar.items = @[cancelBtn,space,doneBtn];
    toolBar.tintColor = [UIColor whiteColor];
    [self setInputAccessoryView:toolBar];
    self.inputView = datePicker;
    self.type = NBTextFieldTypeDatePicker;
    if(arrowImage) {
        UIView * arrowView = [[UIView alloc]initWithFrame:CGRectMake(0.0f,0.0f,20.0f,20.0f)];
        UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(0.0f,0.0f,13.0f,13.0f)];
        imageview.center = arrowView.center;
        [imageview setImage:arrowImage];
        [arrowView addSubview:imageview];
        self.rightViewMode = UITextFieldViewModeAlways;
        self.rightView = arrowView;
        self.clearButtonMode = UITextFieldViewModeNever;
    }
    return datePicker;
}

- (void) addPickerWithSource:(NSArray *)dataSource andDownArrow:(UIImage *) arrowImage {
    
    self.inputPickerDataSource = dataSource;
    pickerView = [[UIPickerView alloc]init];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.layer.borderColor = [UIColor colorWithRed:187.0f/255.0f green:187.0f/255.0f blue:187.0f/255.0f alpha:1.0f].CGColor;
    pickerView.layer.borderWidth = 1.0f;
    
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0,CGRectGetWidth([UIScreen mainScreen].bounds), 44)];
    [toolBar setBarTintColor:self.topBarColor];
    [toolBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Done", @"").capitalizedString style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel", @"").capitalizedString style:UIBarButtonItemStylePlain target:self action:@selector(cencelButtonTapped)];
    toolBar.items = @[cancelBtn,space,doneBtn];
    toolBar.tintColor = [UIColor whiteColor];
    [self setInputAccessoryView:toolBar];
    self.inputView = pickerView;
    self.type = NBTextFieldTypePicker;
    if(arrowImage) {
        UIView * arrowView = [[UIView alloc]initWithFrame:CGRectMake(0.0f,0.0f,20.0f,20.0f)];
        UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(0.0f,0.0f,13.0f,13.0f)];
        imageview.center = arrowView.center;
        [imageview setImage:arrowImage];
        [arrowView addSubview:imageview];
        self.rightViewMode = UITextFieldViewModeAlways;
        self.rightView = arrowView;
        self.clearButtonMode = UITextFieldViewModeNever;
    }
}



- (void) doneButtonTapped {
    
    if(self.type == NBTextFieldTypeDatePicker) {
        
        NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = self.dateTextFormat;
        self.text = [formatter stringFromDate:datePicker.date];
        if(self.text.length == 0)
            self.text = [NSString stringWithFormat:@"%@",datePicker.date];
        
    } else if(self.type == NBTextFieldTypePicker) {
        if(self.inputPickerDataSource.count > 0)
            self.text = self.inputPickerDataSource[selectedIndex];
    }
    [self resignFirstResponder];
}

- (void) cencelButtonTapped {
    [self resignFirstResponder];
}

- (void) setDownArrowAsRightView:(UIImage*) arrowImage {
    
    UIView * arrowView = [[UIView alloc]initWithFrame:CGRectMake(0.0f,0.0f,20.0f,20.0f)];
    UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(0.0f,0.0f,13.0f,13.0f)];
    imageview.center = arrowView.center;
    [imageview setImage:arrowImage];
    [arrowView addSubview:imageview];
    self.rightViewMode = UITextFieldViewModeAlways;
    self.rightView = arrowView;
    self.clearButtonMode = UITextFieldViewModeNever;
}


#pragma mark - UIPickerView UIPickerViewDataSource method

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.inputPickerDataSource.count;
}

#pragma mark - UIPickerView UIPickerViewDelegate method

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;
{
    UILabel* rowView = (UILabel*)view;
    if (!rowView)
    {
        rowView = [[UILabel alloc] init];
        rowView.textAlignment = NSTextAlignmentCenter;
    }
    // Fill the label text here
    rowView.text = [self.inputPickerDataSource objectAtIndex:row];
    return rowView;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    selectedIndex = row;
}


#pragma mark - TextField Error  highlighte methods

- (void) markTextField {
    
    self.bottomLine.backgroundColor = self.errorColor;
    
}

- (void) clearTextField {
    
    self.bottomLine.backgroundColor = self.normalColor;
    
}

- (void) focusTextField {
    self.bottomLine.backgroundColor = self.focusColor;
}


#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if([self.nbDelegate respondsToSelector:@selector(nb_textFieldShouldBeginEditing:)])
        return [self.nbDelegate nb_textFieldShouldBeginEditing:(NBTextField *)textField];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self focusTextField];
    if([self.nbDelegate respondsToSelector:@selector(nb_textFieldDidBeginEditing:)])
        [self.nbDelegate nb_textFieldDidBeginEditing:(NBTextField *)textField];
}



- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if([self.nbDelegate respondsToSelector:@selector(nb_textFieldShouldEndEditing:)])
        return [self.nbDelegate nb_textFieldShouldEndEditing:(NBTextField *)textField];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self checkForValidation];
    
    if([self.nbDelegate respondsToSelector:@selector(nb_textFieldDidEndEditing:)])
        [self.nbDelegate nb_textFieldDidEndEditing:(NBTextField *)textField];

}

- (BOOL)textField:(NBTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    BOOL isValidText = YES;
    
    switch (textField.type) {
        
        case NBTextFieldTypeName:
            if(newString.length > TEXT_LENGTH)
                isValidText = NO;
            break;
            
        case NBTextFieldTypeMobile:
            if(newString.length > MOBILE_MAX_LENGTH)
                isValidText = NO;
            break;
            
        case NBTextFieldTypeOTP:
            if(newString.length > OTP_LENGTH)
                isValidText = NO;
            break;
            
        case NBTextFieldTypeEmail:
            if(newString.length > TEXT_LENGTH)
                isValidText = NO;
            break;
            
        case NBTextFieldTypeDatePicker:
        case NBTextFieldTypePicker:
            if(newString.length > TEXT_LENGTH)
                isValidText = NO;
            break;
            
        case NBTextFieldTypeDefault:
            isValidText = YES;
            break;
            
    }
    
    
    if(textField.allowedCharSet && isValidText)
        isValidText = [string rangeOfCharacterFromSet:[textField.allowedCharSet invertedSet]].location == NSNotFound;
    
    if([self.nbDelegate respondsToSelector:@selector(nb_extField:shouldChangeCharactersInRange:replacementString: isValidString:)]) {
        
        return [self.nbDelegate nb_extField:(NBTextField *)textField shouldChangeCharactersInRange:range replacementString:string isValidString:isValidText];
    }
    
    return isValidText;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    
    if (nextResponder) {
        [textField resignFirstResponder];
        [nextResponder becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return NO;
}

#pragma mark - Final Validation check

- (NSString *)checkForValidation {

    NSString *errorString = @"";
    
    switch (self.type) {
            
        case NBTextFieldTypeName:
        {

            if((self.isOptional && self.text.length > 0 && ![self.text isValidateName]) || (!self.isOptional && self.text.length <= 0 && ![self.text isValidateName])) {
                errorString = @"Name is not valid Name is not valid";
                [self markTextField];
            } else {
                [self clearTextField];
            }
            break;
        }
        case NBTextFieldTypeMobile:
            if((self.isOptional && self.text.length > 0 && ![self.text isValidateMobile]) || (!self.isOptional && self.text.length <= 0 && ![self.text isValidateMobile])) {
                errorString = @"Mobile number is not valid";
                [self markTextField];
            }
            break;
            
        case NBTextFieldTypeOTP:

            if((self.text.length > 0 && [self.text isValidateOTP]) || (self.isOptional && self.text.length == 0)) {
                
                [self clearTextField];
                
            } else {
                errorString = [NSString stringWithFormat:@"OTP should be %d digit number",OTP_LENGTH];
                [self markTextField];
            }
            break;
            
            
            
        case NBTextFieldTypeEmail:
            
            if((self.text.length > 0 && [self.text isValidateEmail]) || (self.isOptional && self.text.length == 0)) {
                
                [self clearTextField];

            } else {
                errorString = @"Email is not valid";
                [self markTextField];
            }
            break;
            
        case NBTextFieldTypeDatePicker:
            if(self.text.length <= 0 && !self.isOptional) {
                errorString = @"Date Picker's selected option is not valid";
                [self markTextField];
            } else {
                [self clearTextField];
            }
            break;

        case NBTextFieldTypePicker:
            if(self.text.length <= 0 && !self.isOptional) {
                errorString = @"Picker's selected option is not valid";
                [self markTextField];

            } else {
                [self clearTextField];
            }
            break;

        case NBTextFieldTypeDefault:
            errorString = @"";
            [self clearTextField];
            break;

        default:
            errorString = @"";
            [self clearTextField];
            break;

    }
    
    return errorString;
}

@end





