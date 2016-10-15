# DataTome\_ObjC

**Platforms:** MacOS and iOS

**Language:** Objective-C

In our apps, we've often found the need to keep certain bits of data secret, or tamper-evident. This almost always indicates encryption. However, it's usually not sufficient to simply encrypt your data with some singular passphrase. Encryption best practices include, for example, incorporating a [salt](http://crypto.stackexchange.com/questions/1776/can-you-help-me-understand-what-a-cryptographic-salt-is) into your passphrases.

However, salts probably should be generated on a per-message basis to be effective. This means that even if the program has a known passphrase, the salt may need to be stored along with the encrypted message. As a consequence, as salts may be of different byte lengths, the length itself may also need to be included with the encrypted message and salt, so that the salt can be pulled off from the message.

For this purpose, we standardized a format for storing this information and called such files "data tomes". Data tomes store information in the following format:

`[salt length][plaintext salt][salted-key-encrypted message data]`

`LPDataTome` ensures the ability to read and write the `salt length` across platforms with different integer sizes by checking the size of an `NSUInteger` and padding the `salt length` component when necessary to fill 16 bytes.


## Use cases include

Secrecy and tamper-evidence in

* Persisting NSData to disk
* Passing NSData through sockets


## Installation

To install, simply download the source for this module and include `./DataTome-ObjC` in your Xcode project. 

You'll also want to use a good system for symmetric encryption. We tend to use `RNCryptor` as it implements best practices at the moment and we have corresponding implementations across the other platforms like Node.JS.


## Usage

`LPDataTome` leaves the actual encryption and decryption to you but provides initializers and corresponding generated properties for the two use cases of unpacking and creating data tomes as well as a function for generating a standardized salted key.

### Reading data tomes

	- (id)initWith_tomeFormattedData:(NSData *)tomeFormattedData andRootKey:(NSString *)rootKey;

	@property (nonatomic, copy, readonly) NSString *finalizedDecryptionKey;
	@property (nonatomic, strong, readonly) NSData *decryptableData;
	
With this initializer, `LPDataTome` takes the data tome-formatted data and the unsalted key with which its message was encrypted. It then provides you with the complete key, `finalizedDecryptionKey`, which can be used to decrypt the encrypted message data, `decryptableData`.


### Creating data tomes

	- (id)initWith_rootKeySuffixString:(NSString *)rootKeySuffixString encryptedData:(NSData *)encryptedData;

	@property (nonatomic, strong, readonly) NSData *tomeFormattedData;

With this initializer, `LPDataTome` takes the salt and the encrypted message data and provides you with the data tome-formatted data, `tomeFormattedData`.

### Constructing finalized keys for encryption/decryption

	extern NSString *NSStringForFinalizedCryptoKey(NSString *rootKey, NSString *rootKeySuffix)


## Examples

We have provided a full working example as a Mac binary within `examples/DataTomeExamples`.

To begin, open up the .xcodeproject file and simply build & run. Output is printed to the console.

Please be aware that this example when run will create an inert file in your user Documents directory called `message.datatome`.

This example includes demonstrations of:

* reading and writing data tomes;
* generating a salt; and
* the potentially desirable practice of prefixing your plaintext message with a known private key.

**Important:** Please note that this example uses and embeds an out-dated version of RNCryptor. For security purposes, please do not copy the embedded version of RNCryptor from this repository, and instead grab it from the most up-to-date source ([RNCryptor/RNCryptor](https://github.com/RNCryptor/RNCryptor)).