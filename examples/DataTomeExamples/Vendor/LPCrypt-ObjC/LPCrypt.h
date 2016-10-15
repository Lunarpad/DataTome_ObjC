//
//  LPCrypt.h
//  lpcrypt-lib
//
//  Created by Paul Shapiro on 6/23/2014.
//  Copyright (c) 2014 Producer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LPCrypt : NSObject


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Decryption

+ (NSData *)decryptedDataFromEncryptedData:(NSData *)encryptedData
					 withPlaintextPassword:(NSString *)password
									 error:(NSError **)errorPointer;

+ (NSData *)decryptedDataFromEncryptedBase64Data:(NSData *)encryptedBase64Data
						   withPlaintextPassword:(NSString *)password
										   error:(NSError **)errorPointer;

+ (NSData *)decryptedDataFromEncryptedBase64String:(NSString *)encryptedBase64String
							 withPlaintextPassword:(NSString *)password
											 error:(NSError **)errorPointer;

+ (NSString *)decryptedStringFromEncryptedBase64String:(NSString *)encryptedBase64String
								 withPlaintextPassword:(NSString *)password
												 error:(NSError **)errorPointer;


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Encryption

+ (NSData *)encryptedDataFromPlaintextData:(NSData *)plaintextData
					 withPlaintextPassword:(NSString *)password
									 error:(NSError **)errorPointer;

+ (NSData *)encryptedBase64DataFromPlaintextData:(NSData *)plaintextData
						   withPlaintextPassword:(NSString *)password
										   error:(NSError **)errorPointer;

+ (NSData *)encryptedPlaintextDataFromPlaintextString:(NSString *)plaintextString
								withPlaintextPassword:(NSString *)password
												error:(NSError **)errorPointer;

+ (NSString *)encryptedBase64StringFromPlaintextString:(NSString *)plaintextString
								 withPlaintextPassword:(NSString *)password
												 error:(NSError **)errorPointer;

@end