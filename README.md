NKRouter
========

[![Platforms](https://img.shields.io/cocoapods/p/NKRouter.svg?style=flat)](http://cocoapods.org/pods/NKRouter)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/NKRouter.svg)](http://cocoapods.org/pods/NKRouter)


### What is it? 
NKRouter is a powerful URL routing library with simple block-based  and senior operability session API. It is designed to make it very easy to handle complex URL schemes in your application. It is base on matching, rather than traversal, to match URL. 


### Installation 
- Using CocoaPods:
Just add this line to your `Podfile`:
```
pod 'NKRouter'
```
- Manually:
Add the `NKRouter` folder to your project


### Requirements 
NKRouter require iOS 8.0+.


## Basic Usage
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

##### **Notes**:
- `[NKRouter globalRouter]` will be used if the scheme of the URL is empty.
- The host of the URL will not be matched, you can use `myScheme:///app/home/view` to ignore the host. 


## Senior Usage 
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

### Optional Paths
NKRouter supports setting up routes with optional parameters. The optional parameter can match any directory. At the route registration moment, NKRouter will register optional parameter `:option` instead of the directory if it is start of `:`.

For example, the following URL register `app/home/:controller` will be registered as `app/home/:option`.  
That will match the routed URL like `app/home/controller`, `app/home/user`,  `app/home/helper` ...., but can not match URL which other directorys do not matched like `web/home/controller`, `app/user/controller` ..., nerther nor less or more directorys like  `app/home`, `app/home/controller/view`...

NKRouter also supports setting up multiple optional parameters like `app/home/:controller/:view` (matched  `app/home/controller/view`, `app/home/user/info` ... ) and the optional parameters can set in any directory like `app/home/:controller/view` (matched  `app/home/controller/view`, `app/home/user/view` ... )

```objc
[[NKRouter globalRouter] registerUrlPath:@"app/home/:controller/:view" handler:^(NSDictionary * _Nullable parameters) {
    // matched `app/home/controller/view`, `app/home/user/info` ...
}];
```

### Wildcards 

NKRouter supports setting up route with wildcards `*`. That will match an arbitrary number of path components at the end of the routed URL. 

For example, the following route would be triggered for any URL that started with `wildcard/` ( like `wildcard/`, `wildcard/view`, `wildcard/view/subview`, ... ), but would be not trigger the URL like `home/view`.

```objc
[[NKRouter globalRouter] registerUrlPath:@"wildcard/*" handler:^(NSDictionary * _Nullable parameters) {
    // matched wildcard,wildcard/view, wildcard/view/subview...
}];
```


## Match Algorithm
### Algorithm Summary:
- Match algorithm uses `DFS` and `DLR` **non-recursion algorithm**
- URL route request will trigger **once only** by the most exact URL route. 


### Algorithm Detail:
NKRouter matches the most exact URL route. 
- Router matches the same directory firstly, then go to match the next directory if matched. 
- Otherwise router matches the optional parameter secoedly, then go to match the next directory if matched. 
- Router go back to previous directory if neither directorys do not exist. 
- Finally, the routing session, which matched the whole path, will be executed. 

For example, the URL route request `app/home/view` would be triggered for the following registered URL orderly:
- `app/home/view`
- `app/home/:option`
- `app/:option/view`
- `app/:option/:option`
- `:option/home/view`
- `:option/home/:option`
- `:option/:option/view`
- `:option/:option/:option`

Route with wildcards will be matched if the registered URL above can not be found. The match algorithm of wildcards is similar:
- `app/home/view/*`
- `app/home/:option/*`
- `app/home/*`
- `app/:option/*`
- `app/*`
- `:option/*`
- `*`

`Undefined Session` will be triggered if exist and wildcards do not exist neither.

At the end, URL route `completionHandler` called with invalid response parameter, if all of the route above do not exist. 

#### **Notes:** URL route request will trigger **once only**. That mean the route below `app/home/view` will not be triggered if `app/home/view` had been registered, and route to `app/home/view` session.


### License ###
This project is used under the <a href="http://opensource.org/licenses/MIT" target="_blank">MIT</a> license agreement. For more information, see <a href="https://github.com/NearKXH/NKRouter/blob/master/LICENSE">LICENSE</a>.
