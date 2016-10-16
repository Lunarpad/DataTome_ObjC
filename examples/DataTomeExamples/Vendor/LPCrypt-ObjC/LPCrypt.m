//
//  LPCrypt.m
//  lpcrypt-lib
//
//  Created by Paul Shapiro on 6/23/2014.
//  Copyright (c) 2014 Lunarpad Corporation. All rights reserved.
//

#import "LPCrypt.h"
#import "RNDecryptor.h"
#import "RNEncryptor.h"

@implementation LPCrypt


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors - Decryption

+ (NSData *)decryptedDataFromEncryptedData:(NSData *)encryptedData withPlaintextPassword:(NSString *)password error:(NSError **)errorPointer
{
	RNCryptorSettings encryptionSettings = kRNCryptorAES256Settings;
	NSData *plaintextData = [RNDecryptor decryptData:encryptedData withSettings:encryptionSettings password:password error:errorPointer];
	
	return plaintextData;
}

+ (NSData *)decryptedDataFromEncryptedBase64Data:(NSData *)encryptedBase64Data withPlaintextPassword:(NSString *)password error:(NSError **)errorPointer
{
	RNCryptorSettings encryptionSettings = kRNCryptorAES256Settings;
	NSData *encryptedData = [[NSData alloc] initWithBase64EncodedData:encryptedBase64Data options:0];
	NSData *plaintextData = [RNDecryptor decryptData:encryptedData withSettings:encryptionSettings password:password error:errorPointer];
	
	return plaintextData;
}

+ (NSData *)decryptedDataFromEncryptedBase64String:(NSString *)encryptedBase64String withPlaintextPassword:(NSString *)password error:(NSError **)errorPointer
{
	RNCryptorSettings encryptionSettings = kRNCryptorAES256Settings;
	NSData *encryptedData = [[NSData alloc] initWithBase64EncodedString:encryptedBase64String options:0];
	NSData *plaintextData = [RNDecryptor decryptData:encryptedData withSettings:encryptionSettings password:password error:errorPointer];

	return plaintextData;
}

+ (NSString *)decryptedStringFromEncryptedBase64String:(NSString *)encryptedBase64String withPlaintextPassword:(NSString *)password error:(NSError **)errorPointer
{
	NSData *plaintextData = [self decryptedDataFromEncryptedBase64String:encryptedBase64String withPlaintextPassword:password error:errorPointer];
	NSString *plaintextString = [[NSString alloc] initWithData:plaintextData encoding:NSUTF8StringEncoding];
	
	return plaintextString;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors - Encryption

+ (NSData *)encryptedDataFromPlaintextData:(NSData *)plaintextData withPlaintextPassword:(NSString *)password error:(NSError **)errorPointer
{
	RNCryptorSettings encryptionSettings = kRNCryptorAES256Settings;
	NSData *encryptedData = [RNEncryptor encryptData:plaintextData withSettings:encryptionSettings password:password error:errorPointer];
	
	return encryptedData;
}

+ (NSData *)encryptedBase64DataFromPlaintextData:(NSData *)plaintextData withPlaintextPassword:(NSString *)password error:(NSError **)errorPointer
{
	NSData *encryptedData = [self encryptedDataFromPlaintextData:plaintextData withPlaintextPassword:password error:errorPointer];
	NSData *encryptedBase64Data = [encryptedData base64EncodedDataWithOptions:0];
	
	return encryptedBase64Data;
}

+ (NSData *)encryptedPlaintextDataFromPlaintextString:(NSString *)plaintextString withPlaintextPassword:(NSString *)password error:(NSError **)errorPointer
{
	NSData *plaintextData = [plaintextString dataUsingEncoding:NSUTF8StringEncoding];
	NSData *encryptedData = [self encryptedDataFromPlaintextData:plaintextData withPlaintextPassword:password error:errorPointer];
	
	return encryptedData;
}

+ (NSString *)encryptedBase64StringFromPlaintextString:(NSString *)plaintextString withPlaintextPassword:(NSString *)password error:(NSError **)errorPointer
{
	NSData *encryptedData = [self encryptedPlaintextDataFromPlaintextString:plaintextString withPlaintextPassword:password error:errorPointer];
	NSString *encryptedBase64String = [encryptedData base64EncodedStringWithOptions:0];

	return encryptedBase64String;
}


@end