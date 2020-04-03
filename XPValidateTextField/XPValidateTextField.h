//
//  XPValidateTextField.h
//  https://github.com/xiaopin/XPValidateTextField.git
//
//  Created by xiaopin on 2020/4/3.
//

#import <UIKit/UIKit.h>

/// 验证模式
typedef NS_ENUM(NSInteger, XPTextFieldValidateMode) {
    XPTextFieldValidateModeNone,        // none
    XPTextFieldValidateModeIDCard,      // 身份证
    XPTextFieldValidateModePhone,       // 手机号码
    XPTextFieldValidateModeBankCard,    // 银行卡
};

/// 一个用于格式化身份证号码、手机号、银行卡的 UITextField 控件
@interface XPValidateTextField : UITextField

/// 验证模式, 默认`XPTextFieldValidateModeNone`
@property (nonatomic, assign) XPTextFieldValidateMode validateMode;

@end
