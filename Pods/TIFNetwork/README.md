# TIFNetwork

[![Language](https://img.shields.io/badge/Language-Swift%204.0-f48041.svg?style=flat)](https://developer.apple.com/swift)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20tvOS%20%7C%20watchOS-red.svg?style=flat)](https://git.triple-it.nl/ios/tif-network)
[![build status](https://git.triple-it.nl/ios/tif-network/badges/master/build.svg)](https://git.triple-it.nl/ios/tif-network)

## Installation

TIFNetwork is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

### RxSwift
```ruby
pod "TIFNetwork/RxSwift"
```

### Combination with Netfox
```ruby
pod "TIFNetwork", :subspecs => ['RxSwift', 'Netfox']
```

### Combining with SSLPinning
```ruby
pod "TIFNetwork", :subspecs => ['RxSwift', 'SSLPinning']
```

#### Swift version vs Pod version
| Swift version | Pod version    |
| ------------- | --------------- |
| 4.X           | >= 9.0.0            |
| 3.X           | >= 7.0.0			|
| 2.3           | 6.0.0			   |

## Usage
All cases are implemented inside the example project. Unit tests make sure everything works after updates, but can also be used as an example for your implementation.

### Request signing
Simply add the following method to your `TIFURLRequestSerializer`:

```swift
func serialize<T>(parameters: inout [String: Any], forToken token: T){
    if token == ExampleAPI.GetCall {
        // Now you can sign only the get call if you want
        defaultParameters["Added_KEY"] = "Added_VALUE"
    }
}
```

As shown in the example, it's possible to sign specific calls only. As `defaultParameters` is an `inout` parameter, you can directly change the content of this dictionary.

### Wrapped responses
Some backends require you to use wrapped responses. An example:

```json
{
"code": 200,
"object": {
    "serverTimestamp": 1325286000
},
"message": "OK"
}
```

You can now simply implement this using the `TIFResponseWrapper` protocol:

```swift
import Foundation

struct IPResponse: Codable {
    let origin: String?
    let message: String

    enum CodingKeys: String, CodingKey {
        case origin = "o"
        case message = "m"
    }
}

```

And implement this Wrapper Class inside your API definition:

```swift
extension ExampleAPI {
    var responseWrapperClass: TIFResponseWrapper.Type? {
        switch self {
        case WrappedResponseCall:
            return WrappedResponseExampleResponse.self
        default:
            return nil
        }
    }
}
```

Inside your API call you can simply define the response object wanted:

```swift
ExampleAPI.GetApps.request()
	.mapResponseTo(responseWrapper: WrappedResponseExampleResponse.self)
    .mapInnerResponse(to: WrapperInnerResponse.self)
    .onNext { (innerResponse) -> () in
        print(innerResponse)
    }.start()
```


## Request stubbing

### Unit Tests
For Unit Tests you can create a seperated provider:

```swift
var TIFStubProvider = TIFReactiveMoyaProvider<ExampleAPI>(requestSerializer:ExampleURLRequestSerializer(), plugins:[ExamplePlugin()], stubClosure: MoyaProvider.ImmediatelyStub)
```

This will return the `sampleResponseCode` and `sampleData` properties if set for a certain target. E.g.:

```swift
var sampleData: NSData {
    switch self {
    case .IPCall:
        return stubbedResponseFromJSONFile("ip")
    default :
        return NSData()
    }
}

var sampleResponseCode:Int {
    switch self {
    case .GetCall:
        return 400
    default:
        return 200
    }
}
```

An example is included in the attached example project.

### UI Tests
When your app is launched with the `TIFStubbedResponsesEnabledKey` key, the TIFProvider wil immediately return the `sampleData` for the specific `TIFAPI` . The idea is that the sampleData is filled with the "happy flow" response for a specific API call.

During UI / Unit testing, you may find the need to customize the repsonses. This is done by creating an array of a `TIFStubbedResponse` objects. Each of these objects will match a apiPath with a NSData response.

```swift
    func testStubbedResponseFromJSON() {
        launchAppWithStubbedResponse([
            TIFStubbedResponse(
                requestPath: "ip",
                responseData: stubbedResponse("ip")
            )])

        let label = XCUIApplication().staticTexts["1.2.3.4"]
        waitForObjectToExist(label)
    }
    func launchAppWithStubbedResponse(stubbedResponse:[TIFStubbedResponse]? = nil) {
        var launchArguments:[String] = [TIFStubbedResponsesEnabledKey]

        if let stubbedResponse = stubbedResponse {
            let data = NSKeyedArchiver.archivedDataWithRootObject(stubbedResponse)
            let dataString = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            launchArguments.append(dataString)
        }

        let app = XCUIApplication()
        app.launchArguments = launchArguments
        app.launch()
    }
```

### SSL Pinning
The subspec SSLPinning contains support for pinning SSL Certificates using a fingerprint. This allows the use of a fallback scenario in case the SSL Certificate is expired. To enable SSL Pinning, a custom `TIFSSLManager` can be added to TIFProvider. This SSLManager should be initialised with TIFSSLSettings. As shown below.

```swift
private let validationKey: String = """
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA2H/spxdN4zScKhJb4r1D
QfBNokqZV6XMUseE18iZA4/24c5A+j7BOODVsRTpi+yTS9ERKBJJiA0k/+TJgqix
0msXFAhcMk++dom0J71/9lvYHUCrdKc36llpCLs+ziRB8PeagqR0P8ygg7tllfTL
UG05B8+a10j7Fw8V6V49JQ21rUA73wI8X6i3NSSS96fCaherP+ZLaxrWUV/P9Gw+
mhge3FxrWfFFvrJNkiOnBIL4pN1VZ2PTdRt351VI7UvzGP4U7jDyTUGnfeCx93WG
3XTBz4Om320vaIF1OQoYs9vSxdwCSFpV3eXUl1f/Wpz3SGkDtl/LbBIk+2OvDeLV
tWPNVWwggiXUkzZdmZMJkBk0x4cD0I5eKU8s+g+PmVA1ewzj9i/dK5YHIOhxOzux
NrY9dFb73bKEdqARPESEAGhX3QrCL+Xhr2Lg8qWQ+KiVKGFF3a94WJehg2Wf6EKB
wt+UM8KK61CX+Cmupn2MwVyJcWwWra6r7RVOLZonw/S5+n5yYuvgModVvqmt0tBx
/kLV947A1CIN01ajkZ8ht2IKhRRWmF1dKRAhbf2SgDX357dtioJzOeQjfgBbqfeU
48/d/e8yUNo0ADa9hjsseIyQr/XWCmflA+txOgt6QQ8MCiL3KERhzmnzrtAVgrSz
VMYEAaS1N6ZONc6qhMn/aOkCAwEAAQ==
"""

private let sslSettings: TIFSSLSettings = TIFSSLSettings(validationHosts: [".wearetriple.com"],
                                                         signedFingerprintUrl: "https://sslvalidation-cdp.triple-it.nl/wearetriple/certificate.txt",
                                                         validationKey: validationKey,
                                                         loggingEnabled: true)

private let sslManager = TIFSSLManager(settings: sslSettings)

var TIFRACSSLProvider = TIFNetworkRACProvider<ExampleAPI>(requestSerializer:ExampleURLRequestSerializer(), plugins:[ExamplePlugin(), TIFNetfoxPlugin()], manager: sslManager)
```

TIFSSLSettings has a few properties that should be configured.
An array of hosts that should be validated needs to be added. These hosts wil be checked with the fingerprint specified or retrieved.
A publicKeyUrl is required. In case the specified fingerprint is no longer valid, this location will be checked in order to retrieve a new fingerprint.
The validationKey is used to validate the newly downloaded fingerprint to ensure it matches the SSL Certificate.
The defaultFingerpint is the starting point. This is the current (valid) fingerprint for the SSL Certificate.
Logging can be enabled by changing the loggingEnabled boolean value.

These settings should be constructed and with these settings a TIFSSLManager needs to be initialised wich will be passed to the TIFProvider.

The working of the SSL validation can be tested using charles. Network calls to the specified hosts should only work when ssl proxying is disabled with charles or charles is closed. When the network call succeeds with charles and SSL proxying enabled you configuration is wrong.

## Author

Triple.

## License

TIFNetwork is available under the MIT license. See the LICENSE file for more info.
