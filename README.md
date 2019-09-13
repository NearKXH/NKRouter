NKRouter
========



### What is it? ###
NKRouter is a powerful URL routing library with simple block-based  and senior operability session API. It is designed to make it very easy to handle complex URL schemes in your application. It is base on matching, rather than traversal, to match URL. 


### Installation ###
- Using CocoaPods:
Just add this line to your `Podfile`:
```
pod 'NKRouter'
```
- Manually:
Add the `NKRouter` folder to your project


### Requirements ###
NKRouter require iOS 8.0+.


## Getting Started ##
### Basic Usage
```objc
- (void)registerUrl {
    [[NKRouter globalRouter] registerUrlPath:@"app/home/view" handler:^(NSDictionary * _Nullable parameters) {
        // Do what you want...

    }];
}

- (void)routeUrl {
    [[NKRouter globalRouter] routeUrl:@"app/home/view" completionHandler:^(NKRouterResponse * _Nonnull response) {
        // called when routing finished
        // you can check this url routing status here to find out if this routing is succeed and get the error message
        // you can also get the response object which set by this url routing session/handler. 

    }];
}
```

Routers can also register and route with custom scheme using `[NKRouter routerForScheme:@"myScheme"]` or just using suger syntax below:
```objc
[NKRouter registerUrl:@"myScheme://host/app/home/view" handler:^(NSDictionary * _Nullable parameters) {
    // Do what you want...
}];

[NKRouter routeUrl:@"myScheme://host/app/home/view" completionHandler:^(NKRouterResponse * _Nonnull response) {
    // call back when routing finished
}];
```

###### Notes:
- `[NKRouter globalRouter]` will be used if the scheme of the URL is empty.
- The host of the URL will not be matched, you can use `myScheme:///app/home/view` to ignore the host. 


## More Complex Example ##
### Custom Session Operation
NKRouter supports setting up router with custom session. Session  inherited `NKRouterSession` and override method `sessionRequest:completionHandler:` can be registered to router.
```objc
MySession *mySession = MySession.new;

[[NKRouter globalRouter] registerUrlPath:@"app/home/view" session:mySession];
```
or
```objc
[NKRouter registerUrl:@"sheme://host/app/home/view" session:mySession];
```

The method `sessionRequest:completionHandler:`  of custom session will be called when URL routing match. The parameters: 
- `request` request info model, including `requestUrl`, `parameters`, `matchPath`, `matchType` ...
- `completionHandler` session should call the `completionHandler` as soon as it has finished performing that operation, to notify the URL routing requester whether this operation is succeed and respond the `responseObject` or `error`.
```objc
@interface MySession : NKRouterSession

@end

@implementation MySession
- (void)sessionRequest:(NKRouterRequest *)request completionHandler:(void (^)(BOOL, NSDictionary * _Nullable, NSError * _Nullable))completionHandler {
    // Do what you want here
    // get routing info from request
    // must call completionHandler once when this operation is finished
}

@end
```

### License ###
This project is used under the <a href="http://opensource.org/licenses/MIT" target="_blank">MIT</a> license agreement. For more information, see <a href="https://github.com/NearKXH/NKRouter/blob/master/LICENSE">LICENSE</a>.
