//
//  LPDataTome.h
//  Producer
//
//  Created by Paul Shapiro on 1/28/15.
//  Copyright (c) 2015 Producer. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *NSStringForFinalizedCryptoKey(NSString *rootKey, NSString *rootKeySuffix);

@interface LPDataTome : NSObject


////////////////////////////////////////////////////////////////////////////////

- (id)initWith_tomeFormattedData:(NSData *)tomeFormattedData andRootKey:(NSString *)rootKey; // For reading tomes
// Results of this initializer:
@property (nonatomic, copy, readonly) NSString *finalizedDecryptionKey;
@property (nonatomic, strong, readonly) NSData *decryptableData;


////////////////////////////////////////////////////////////////////////////////

// for creating tomeFormattedData:
- (id)initWith_rootKeySuffixString:(NSString *)rootKeySuffixString encryptedData:(NSData *)encryptedData;
// Results of this initializer:
@property (nonatomic, strong, readonly) NSData *tomeFormattedData;


@end
