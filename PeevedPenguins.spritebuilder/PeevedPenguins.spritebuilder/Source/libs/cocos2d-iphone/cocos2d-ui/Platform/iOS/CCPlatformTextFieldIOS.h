//
//  CCPlatformTextFieldIOS.h
//  cocos2d-osx
//
//  Created by Sergey Klimov on 7/1/14.
//
//

#import <UIKit/UIKit.h>
#import "CCPlatformTextField.h"
#import "CCTextField.h"

@interface CCPlatformTextFieldIOS : CCPlatformTextField <CCPlatformTextFieldDelegate, CCLabelProtocol>

@end
