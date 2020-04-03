# XPValidateTextField

一个用于格式化身份证号码、手机号、银行卡的 UITextField 控件

## 效果图

[![JPG](./preview.jpg)]()

## 用法

- 将`XPValidateTextField.{h/m}`文件拖入你的项目中
- 将类名从 UITextField 改成 `XPValidateTextField`
- 根据需求设置对应的 `XPTextFieldValidateMode`

```ObjC
XPValidateTextField *textField = [[XPValidateTextField alloc] init];
textField.validateMode = XPTextFieldValidateModePhone;
textField.delegate = self;
```

## TODO
待优化

- 删除字符时光标的位置
- 粘贴时光标的位置

## 协议

许可在 MIT 协议下使用，查阅`LICENSE`文件来获得更多信息。

