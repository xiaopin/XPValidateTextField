//
//  XPValidateTextField.m
//  https://github.com/xiaopin/XPValidateTextField.git
//
//  Created by xiaopin on 2020/4/3.
//

#import "XPValidateTextField.h"
#import <objc/runtime.h>

static char const kXPValidateTextFieldDelegateKey = '\0';

@interface XPValidateTextField ()<UITextFieldDelegate>

@end

@implementation XPValidateTextField

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self standardInitialization];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self standardInitialization];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self];
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [self.delegate textFieldShouldBeginEditing:textField];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [self.delegate textFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        return [self.delegate textFieldShouldEndEditing:textField];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [self.delegate textFieldDidEndEditing:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason API_AVAILABLE(ios(10.0)) {
    if ([self.delegate respondsToSelector:@selector(textFieldDidEndEditing:reason:)]) {
        [self.delegate textFieldDidEndEditing:textField reason:reason];
    } else if ([self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [self.delegate textFieldDidEndEditing:textField];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        BOOL result = [self.delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
        if (!result) return NO;
    }
    if (!range.length) { // Add some characters
        NSInteger currentTextLength = textField.text.length;
        NSInteger expectTextLength = currentTextLength + string.length;
        switch (self.validateMode) {
            case XPTextFieldValidateModeNone: break;
            case XPTextFieldValidateModeIDCard: {
                if (expectTextLength > 18) return NO;
                if (currentTextLength == 0) {
                    if ([[string substringToIndex:1] isEqualToString:@"0"]) {
                        return NO;
                    }
                }
                if (![self isIntegerNumberString:string]) {
                    if (expectTextLength != 18) return NO;
                    NSString *expectText = [textField.text stringByAppendingString:string];
                    NSString *regexp = @"[1-9]\\d{16}[\\dX]";
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES[cd] %@", regexp];
                    return [predicate evaluateWithObject:expectText];
                }
                break;
            }
            case XPTextFieldValidateModePhone: {
                if (expectTextLength > 11 || ![self isIntegerNumberString:string]) return NO;
                if (currentTextLength == 0) {
                    return [[string substringToIndex:1] isEqualToString:@"1"];
                }
                break;
            }
            case XPTextFieldValidateModeBankCard: {
                if (expectTextLength > 19 || ![self isIntegerNumberString:string]) return NO;
                if (currentTextLength == 0) {
                    return ![[string substringToIndex:1] isEqualToString:@"0"];
                }
                break;
            }
        }
    }
    return YES;
}

- (void)textFieldDidChangeSelection:(UITextField *)textField API_AVAILABLE(ios(13.0), tvos(13.0)) {
    if ([self.delegate respondsToSelector:@selector(textFieldDidChangeSelection:)]) {
        [self.delegate textFieldDidChangeSelection:textField];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        return [self.delegate textFieldShouldClear:textField];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [self.delegate textFieldShouldReturn:textField];
    }
    if (self.validateMode != XPTextFieldValidateModeNone) {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - Actions

- (void)xp_textFieldTextDidChangeNotification:(NSNotification *)sender {
    // Get split location
    NSArray *lengths = nil;
    switch (self.validateMode) {
        case XPTextFieldValidateModeNone: return;
        case XPTextFieldValidateModeIDCard:
            lengths = @[@(6), @(4), @(4), @(4)];
            break;
        case XPTextFieldValidateModePhone:
            lengths = @[@(3), @(4), @(4)];
            break;
        case XPTextFieldValidateModeBankCard:
            lengths = @[@(4), @(4), @(4), @(4), @(3)];
            break;
    }
    // Split string with space character
    NSMutableArray<NSString *> *substrs = [NSMutableArray array];
    NSString * const text = [self.text copy];
    NSInteger start = 0;
    for (NSNumber *number in lengths) {
        NSInteger expectLength = [number integerValue];
        NSInteger length = MIN(text.length - start, expectLength);
        if (!length) break;
        NSRange range = NSMakeRange(start, length);
        [substrs addObject:[text substringWithRange:range]];
        start += length;
        if (start >= text.length) break;
    }
    [super setText:[substrs componentsJoinedByString:@" "]];
}

#pragma mark - Private

- (void)standardInitialization {
    [super setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xp_textFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:self];
}

- (BOOL)isIntegerNumberString:(NSString *)string {
    NSString *regexp = @"\\d+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexp];
    return [predicate evaluateWithObject:string];
}

#pragma mark - setter & getter

- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
    objc_setAssociatedObject(self, &kXPValidateTextFieldDelegateKey, delegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<UITextFieldDelegate>)delegate {
    return objc_getAssociatedObject(self, &kXPValidateTextFieldDelegateKey);
}

- (void)setSecureTextEntry:(BOOL)secureTextEntry {
    [super setSecureTextEntry:NO];
}

- (void)setText:(NSString *)text {
    NSString *regexp = nil;
    switch (self.validateMode) {
        case XPTextFieldValidateModeNone:
            [super setText:text];
            return;
        case XPTextFieldValidateModeIDCard:
            regexp = @"^[1-9]\\d{16}[\\dX]$";
            break;
        case XPTextFieldValidateModePhone:
            regexp = @"^1\\d{10}$";
            break;
        case XPTextFieldValidateModeBankCard:
            regexp = @"^[1-9]\\d{15,18}$";
            break;
    }
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES[cd] %@", regexp];
    if ([predicate evaluateWithObject:text]) {
        [super setText:text];
        [self xp_textFieldTextDidChangeNotification:nil];
    }
}

- (NSString *)text {
    switch (self.validateMode) {
        case XPTextFieldValidateModeNone: return super.text;
        case XPTextFieldValidateModeIDCard:
        case XPTextFieldValidateModePhone:
        case XPTextFieldValidateModeBankCard:
            return [super.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
}

- (void)setValidateMode:(XPTextFieldValidateMode)validateMode {
    _validateMode = validateMode;
    switch (validateMode) {
        case XPTextFieldValidateModeNone:
            self.keyboardType = UIKeyboardTypeDefault;
            break;
        case XPTextFieldValidateModeIDCard:
            self.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            break;
        case XPTextFieldValidateModePhone:
        case XPTextFieldValidateModeBankCard:
            self.keyboardType = UIKeyboardTypeNumberPad;
            break;
    }
    self.autocorrectionType = (validateMode == XPTextFieldValidateModeNone) ? UITextAutocorrectionTypeYes : UITextAutocorrectionTypeNo;
}

@end
