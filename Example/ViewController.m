//
//  ViewController.m
//  Example
//
//  Created by NHope on 2020/4/3.
//

#import "ViewController.h"
#import "XPValidateTextField.h"

@interface ViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet XPValidateTextField *bankCardTextField;
@property (weak, nonatomic) IBOutlet XPValidateTextField *phoneTextField;
@property (weak, nonatomic) IBOutlet XPValidateTextField *idcardTextField;

@end

@implementation ViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bankCardTextField.validateMode = XPTextFieldValidateModeBankCard;
    self.phoneTextField.validateMode = XPTextFieldValidateModePhone;
    self.idcardTextField.validateMode = XPTextFieldValidateModeIDCard;
}

#pragma mark - <UITextFieldDelegate>

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"%@", textField.text);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"4"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
