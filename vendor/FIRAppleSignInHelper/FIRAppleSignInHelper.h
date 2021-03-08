#import <Foundation/Foundation.h>

#import <CommonCrypto/CommonCrypto.h>

@interface FIRAppleSignInHelper : NSObject

- (NSString *)randomNonce:(NSInteger)length;

- (NSString *)stringBySha256HashingString:(NSString *)input;

@end
