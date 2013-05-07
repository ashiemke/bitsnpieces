//
//  Util.h
//  Valentine
//
//  Created bt Amadeus Consulting Group on 3/4/13.
//  Copyright (c) 2013 Valentine. All rights reserved.
//
//
//
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

typedef void (^ActionBlock)();

@interface UIControl (UIBlockButton)

- (void)handleControlEvent:(UIControlEvents)event withBlock:(ActionBlock)block;
- (void)callActionBlock:(id)sender;



@end

@implementation UIControl (UIBlockButton)

static char UIButtonBlockKey;
- (void)handleControlEvent:(UIControlEvents)event withBlock:(ActionBlock)block {
    objc_setAssociatedObject(self, &UIButtonBlockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(callActionBlock:) forControlEvents:event];
}

- (void)callActionBlock:(id)sender {
    ActionBlock block = (ActionBlock)objc_getAssociatedObject(self, &UIButtonBlockKey);
    if (block) {
        block();
    }
}

@end

@interface UIColor (colorFromHexString)

+ (UIColor *) colorFromHexString:(NSString *)hexString;

@end

@implementation UIColor (colorFromHexString)

+ (UIColor *) colorFromHexString:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end

@interface NSString (isValidFileName)

+ (BOOL) isValidFileName:(NSString*)fileName;

@end

@implementation NSString (isValidFileName)

+ (BOOL) isValidFileName:(NSString *)fileName {
    //Valid characters
    NSCharacterSet *validCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-"] invertedSet];
    //If everycharacter in the string is valid then return true
    if ([fileName rangeOfCharacterFromSet:validCharacters].location != NSNotFound) {
        
        return false;
    }
    
    return true;
}

@end

#define startMainThread dispatch_async(dispatch_get_main_queue(), ^{
#define endMainThread });

#define loPriQ dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul)
#define hiPriQ dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul)

#define kIsPortrait (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown)

#define kIsiPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define killKeyboard() UITextField *t = [[UITextField alloc] init]; \
[self.view addSubview:t];\
t.alpha = 0;\
[t becomeFirstResponder];\
[t resignFirstResponder];\
[t removeFromSuperview];


#define AppDel ((ValentineAppDelegate*)([UIApplication sharedApplication].delegate))


//dispatch_source_t CreateDispatchTimer(uint64_t interval,
//                                      uint64_t leeway,
//                                      dispatch_queue_t queue,
//                                      dispatch_block_t block)
//{
//    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
//                                                     0, 0, queue);
//    if (timer)
//    {
//        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, leeway);
//        dispatch_source_set_event_handler(timer, block);
//        dispatch_resume(timer);
//    }
//    return timer;
//}






