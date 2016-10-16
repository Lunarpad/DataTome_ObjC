//
//  LPDataTome.m
//  DataTome-ObjC
//
//  Created by Paul Shapiro on 1/28/15.
//  Copyright (c) 2015 Lunarpad Corporation. All rights reserved.
//

#import "LPDataTome.h"



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Macros



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constants

int const LPDataTome_constant_sizeOfLengthOfDataContainingSaltLength = 16;


////////////////////////////////////////////////////////////////////////////////
#pragma mark - C

NSString *NSStringForFinalizedCryptoKey(NSString *rootKey, NSString *rootKeySuffix)
{
    return [NSString stringWithFormat:@"%@%@", rootKey, rootKeySuffix];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Interface

@interface LPDataTome ()

@property (nonatomic, strong, readwrite) NSData *tomeFormattedData;
@property (nonatomic, copy, readwrite) NSString *finalizedDecryptionKey;
@property (nonatomic, strong, readwrite) NSData *decryptableData;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation LPDataTome


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle - Imperatives - Entrypoints

- (id)initWith_tomeFormattedData:(NSData *)tomeFormattedData andRootKey:(NSString *)rootKey
{
    self = [super init];
    if (self) {
        self.tomeFormattedData = tomeFormattedData;
        
        NSUInteger saltLength;
        NSUInteger lengthOfDataContainingSaltLength = sizeof(saltLength);
        {
            [tomeFormattedData getBytes:&saltLength range:NSMakeRange(0, lengthOfDataContainingSaltLength)];
        }

        NSData *dataOfSalt = [tomeFormattedData subdataWithRange:NSMakeRange(LPDataTome_constant_sizeOfLengthOfDataContainingSaltLength, saltLength)];
        NSString *finalizedDecryptionKey;
        {
            NSString *saltAsUTF8_NSString = [[NSString alloc] initWithData:dataOfSalt encoding:NSUTF8StringEncoding];
            finalizedDecryptionKey = NSStringForFinalizedCryptoKey(rootKey, saltAsUTF8_NSString);
        }
        self.finalizedDecryptionKey = finalizedDecryptionKey;

        NSData *decryptableData;
        {
            NSUInteger translatableDataLocation = LPDataTome_constant_sizeOfLengthOfDataContainingSaltLength + saltLength;
            NSUInteger lengthOfTranslatableData = tomeFormattedData.length - translatableDataLocation;
            decryptableData = [tomeFormattedData subdataWithRange:NSMakeRange(translatableDataLocation, lengthOfTranslatableData)];
        }
        self.decryptableData = decryptableData;
    }
    
    return self;
}

- (id)initWith_rootKeySuffixString:(NSString *)rootKeySuffixString encryptedData:(NSData *)encryptedData
{
    self = [super init];
    if (self) {
        NSMutableData *tomeFormattedData = [NSMutableData data];
        { // Constructing the file format…
            NSData *saltAsData = [rootKeySuffixString dataUsingEncoding:NSUTF8StringEncoding];
			//
            // Obtaining the salt bytes length
            NSUInteger saltDataLength = saltAsData.length;
            NSUInteger sizeof_saltDataLength = sizeof(saltDataLength);
            NSMutableData *saltLengthInBytesAsData = [NSMutableData dataWithBytes:&saltDataLength length:sizeof_saltDataLength];
            if (sizeof_saltDataLength < LPDataTome_constant_sizeOfLengthOfDataContainingSaltLength) { // This is important: If the NSUInteger is not large enough to fill the padding (based on platform), we must pad the salt length some more to ensure portability.
                [saltLengthInBytesAsData increaseLengthBy:(LPDataTome_constant_sizeOfLengthOfDataContainingSaltLength - sizeof_saltDataLength)];
            }
			//
			// first append the salt length
            [tomeFormattedData appendData:saltLengthInBytesAsData];
            //
            // then the salt itself
            [tomeFormattedData appendData:saltAsData];
            //
            // then the enciphered data 
            [tomeFormattedData appendData:encryptedData];
        }
        self.tomeFormattedData = tomeFormattedData;
    }
    
    return self;
}

- (void)dealloc
{
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle - Imperatives - Setup


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle - Imperatives - Teardown

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Accessors



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Delegation


@end
