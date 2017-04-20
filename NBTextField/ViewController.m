//
//  ViewController.m
//  Platform-iOS-Demo
//
//  Created by Nanda Ballabh on 18/04/17.
//  Copyright © 2017 Magnasoft. All rights reserved.
//

#import "ViewController.h"
#import "NBTextField.h"

@interface ViewController ()<NBTextFieldDelegate>
@property (weak, nonatomic) IBOutlet NBTextField *textfield1;
@property (weak, nonatomic) IBOutlet NBTextField *textfield2;
@property (weak, nonatomic) IBOutlet NBTextField *textfield3;
@property (weak, nonatomic) IBOutlet NBTextField *textfield4;
@property (weak, nonatomic) IBOutlet NBTextField *textfield5;
@property (weak, nonatomic) IBOutlet NBTextField *textfield6;
@property (weak, nonatomic) IBOutlet NBTextField *textfield7;
@property (weak, nonatomic) IBOutlet NBTextField *textfield8;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.textfield1 setTextFieldType:NBTextFieldTypeName];
    [self.textfield2 setTextFieldType:NBTextFieldTypeMobile];
    [self.textfield3 setTextFieldType:NBTextFieldTypeOTP];
    [self.textfield4 setTextFieldType:NBTextFieldTypeEmail];
    [self.textfield5 addPickerWithSource:@[@"GL",@"RCB",@"MI",@"KXIP",@"KKR",@"RPS",@"DD"] andDownArrow:[UIImage imageNamed:@"ic_down"]];
    [self.textfield6 addDatePickerWithMode:UIDatePickerModeDate andDownArrow:[UIImage imageNamed:@"ic_down"]]; // optiona date picker
    [self.textfield7 setTextFieldType:NBTextFieldTypeEmail];
    [self.textfield8 setTextFieldType:NBTextFieldTypeDefault];// No validation
    [self.textfield8 setDownArrowAsRightView:[UIImage imageNamed:@"ic_down"]];
    
    self.textfield3.nbDelegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)submitTapped:(id)sender {
    
    BOOL isValid = YES;
    NSString * messageString = @"";
    for (NBTextField * textView in @[self.textfield1,self.textfield2,self.textfield3,self.textfield4,self.textfield5,self.textfield6,self.textfield7]) {
        
        NSString * errorString = [textView checkForValidation];
        if(errorString.length != 0) {
            messageString = [messageString stringByAppendingFormat:@"* %@\n",errorString];
            isValid = NO;
        }
    }
    
    if(!isValid) {
        [[[UIAlertView alloc] initWithTitle:@"Text Input Error" message:messageString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Text Input Validated" message:@"Good to go" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    
}

- (BOOL)nb_textFieldShouldBeginEditing:(NBTextField *)textField{return YES;};
// return NO to disallow editing.

- (void)nb_textFieldDidBeginEditing:(NBTextField *)textField{};
// became first responder

- (BOOL)nb_textFieldShouldEndEditing:(NBTextField *)textField{return YES;};
// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end

- (void)nb_textFieldDidEndEditing:(NBTextField *)textField{};
// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called

- (BOOL)nb_extField:(NBTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string isValidString:(BOOL) isValidText{return isValidText;};
// return NO to not change text and having pre validation

@end
