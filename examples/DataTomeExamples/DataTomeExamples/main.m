//
//  main.m
//  DataTomeExamples
//
//  Created by Paul Shapiro on 10/15/16.
//  Copyright © 2016 Lunarpad Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPDataTome.h"
#import "LPCrypt.h"
//
// Accessors
NSString *Shared_datatome_filePath(void)
{
    NSString *root = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [root stringByAppendingPathComponent:@"message.datatome"];

    return filePath;
}
//
NSString *const Shared_message_plaintextString = @"This is a secret message we will lock up in a tome.";
NSString *const Shared_knownKeyForPersistingFile_prefixForFileData_NSString = @"this is a code-known key we add to the message";
NSString *const Shared_encryption_rootKeyString = @"this is a private key for encryption";
//
//
// Imperatives
void demonstrateDataTome_reading(void);
void demonstrateDataTome_writing(void);
//
// Program entrypoint
int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        demonstrateDataTome_writing(); // NOTE: This will create a file in your user documents directory called message.datatome
        demonstrateDataTome_reading();
    }
    return 0;
}
void demonstrateDataTome_writing(void)
{
    
    NSString *plaintextString = Shared_message_plaintextString;

    NSString *payloadAsString;
    { // We write the file payload with a private key to establish that only someone with the key could have created the file -- unless something extremely unlikely or probably impossible were to occur like the exact same key being generated in the encrypted contents of the file
        payloadAsString = [NSString stringWithFormat:@"%@%@", Shared_knownKeyForPersistingFile_prefixForFileData_NSString, plaintextString];
    }
    NSData *payloadAsData = [payloadAsString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *finalizedDataToWrite;
    {
        // First we need to derive the key for encrypting the data and hang onto the suffix we generate for that key (a kind of salt)
        NSString *rootOfEncryptionKey = Shared_encryption_rootKeyString;
        NSString *rootKeySaltSuffix;
        {
            NSString *tomeUUID;
            { // We create a UUID to assign to this tome as a suffix to add to a code-known "root" of the private key we use for encryption.
                // We put these together with NSStringForFinalizedCryptoKey below
                CFUUIDRef uuid = CFUUIDCreate(NULL);
                tomeUUID = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
                CFRelease(uuid);
            }
            rootKeySaltSuffix = tomeUUID;
        }
        NSString *finalizedWholeEncryptionKey = NSStringForFinalizedCryptoKey(rootOfEncryptionKey, rootKeySaltSuffix); // this is a function from LPDataTome
        //
        NSData *encryptedDataForTome;
        {
            NSError *error = NULL;
            encryptedDataForTome = [LPCrypt encryptedDataFromPlaintextData:payloadAsData
                                                     withPlaintextPassword:finalizedWholeEncryptionKey
                                                                     error:&error];
            //    DDLogInfo(@"encryptedBase64String %@", encryptedBase64String);
            if (error != NULL) {
                NSString *errMsg = [NSString stringWithFormat:@"Error encrypting data to be entomed (a), %@", error.localizedDescription];
                NSLog(@"❌ Potential cracking attempt?: %@", errMsg);
                //
                return;
            }

        }
        LPDataTome *tome = [[LPDataTome alloc] initWith_rootKeySuffixString:rootKeySaltSuffix
                                                              encryptedData:encryptedDataForTome];
        NSData *tomeFormattedData = tome.tomeFormattedData;
        finalizedDataToWrite = tomeFormattedData;
    }
    { // Now we can persist the data tome data
        NSString *filePath = Shared_datatome_filePath();
        BOOL wasSuccessful = [[NSFileManager defaultManager] createFileAtPath:filePath contents:finalizedDataToWrite attributes:nil];
        if (wasSuccessful == NO) {
            NSLog(@"❌ Error writing %lu bytes to %@.", finalizedDataToWrite.length, filePath);
        } else {
            NSLog(@"✅ Wrote encrypted contents to data tome at %@.", filePath);
        }
    }
}
void demonstrateDataTome_reading(void)
{
    NSMutableData *tomeFormattedDataToOpen;
    {
        NSError *error = NULL;
        tomeFormattedDataToOpen = [[NSData dataWithContentsOfFile:Shared_datatome_filePath() options:0 error:&error] mutableCopy];
        if (error) {
            NSLog(@"❌ %@", error);
            return;
        }
    }
    NSData *plaintextData;
    {
        NSString *rootKey = Shared_encryption_rootKeyString;
        LPDataTome *tome = [[LPDataTome alloc] initWith_tomeFormattedData:tomeFormattedDataToOpen
                                                               andRootKey:rootKey];
        NSString *finalizedDecryptionKey = tome.finalizedDecryptionKey; // note how LPDataTome generates the finalized key we can use directly for decryption
        NSData *decryptableData = tome.decryptableData;
        
        NSError *error = NULL;
        plaintextData = [LPCrypt decryptedDataFromEncryptedData:decryptableData withPlaintextPassword:finalizedDecryptionKey error:&error];
        if (error) {
            NSString *errMsg = [NSString stringWithFormat:@"Error encountered while attempting to decrypt data from tome: %@", error.localizedDescription];
            NSLog(@"❌ Potential cracking attempt?: %@", errMsg);
            //
            return;
        }
    }
    NSString *plaintextString = [[NSString alloc] initWithData:plaintextData encoding:NSUTF8StringEncoding];
    //
    // Now that we have the decrypted string, we need to remove that key we added.
    // (Again, we use the payload key to establish that we created this file -- or at least that someone with this key did)
    NSRange rangeOfKnownPrefixKeyString = [plaintextString rangeOfString:Shared_knownKeyForPersistingFile_prefixForFileData_NSString];
    if (rangeOfKnownPrefixKeyString.location != 0) {
        NSString *errMsg = @"Error: This decrypted payload doesn't look like it was created by this program because the known payload key was not located, or at least not at the beginning of the payload as is protocol.";
        NSLog(@"❌ Potential cracking attempt?: %@", errMsg);
        //
        return;
    }
    NSString *actualPayloadContentString = [plaintextString substringFromIndex:Shared_knownKeyForPersistingFile_prefixForFileData_NSString.length]; // remove the prefix
    //
    NSLog(@"✅ Read message from data tome: \"%@\"", actualPayloadContentString);
}