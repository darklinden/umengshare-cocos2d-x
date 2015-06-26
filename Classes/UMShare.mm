//
//  UMShare.cpp
//
//  Created by HanShaokun on 27/6/15.
//
//

#include "UMShare.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"

USING_NS_CC;

static UMShare* _st = nullptr;
UMShare* UMShare::getInstance()
{
    if (!_st) {
        _st = new (std::nothrow) UMShare();
        if (!_st->init()) {
            delete _st;
            _st = nullptr;
        }
    }
    
    return _st;
}

bool UMShare::init()
{
    //设置友盟社会化组件appkey
    [UMSocialData setAppKey:@"5211818556240bc9ee01db2f"];
    
    //打开调试log的开关
    [UMSocialData openLog:YES];
    
    //如果你要支持不同的屏幕方向，需要这样设置，否则在iPhone只支持一个竖屏方向
    [UMSocialConfig setSupportedInterfaceOrientations:UIInterfaceOrientationMaskLandscape];
    
    //设置微信AppId，设置分享url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:@"wx63ca453f3901ea53" appSecret:@"fd02e4eeee50dfeff8b4e554b7faa00d" url:@"http://www.umeng.com/social"];
    
    //打开新浪微博的SSO开关
//    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
//    [UMSocialSinaSSOHandler openNewSinaSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    //打开腾讯微博SSO开关，设置回调地址，只支持32位
    //    [UMSocialTencentWeiboHandler openSSOWithRedirectUrl:@"http://sns.whalecloud.com/tencent2/callback"];
    
    //    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:@"100424468" appKey:@"c7394704798a158208a74ab60104f0ba" url:@"http://www.umeng.com/social"];
    
    return true;
}

void UMShare::setShareCallback(std::function<void(SHARE_TYPE, int)> callback)
{
    UMShare::getInstance()->_callback = callback;
}

void UMShare::share(SHARE_TYPE t,
                    const std::string& title,
                    const std::string& text,
                    const std::string& url,
                    const std::string& image)
{
    NSString* snsName = @"";
    
    switch (t) {
        case WECHAT:
        {
            [UMSocialData defaultData].extConfig.wechatSessionData.title = [NSString stringWithUTF8String:title.c_str()];
            [UMSocialData defaultData].extConfig.wechatSessionData.url = [NSString stringWithUTF8String:url.c_str()];
            
            snsName = UMShareToWechatSession;
        }
            break;
        case WECHAT_CIRCLE:
        {
            [UMSocialData defaultData].extConfig.wechatTimelineData.title = [NSString stringWithUTF8String:title.c_str()];
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = [NSString stringWithUTF8String:url.c_str()];
            snsName = UMShareToWechatTimeline;
        }
            break;
        case QQ:
        {
            [UMSocialData defaultData].extConfig.qqData.title = [NSString stringWithUTF8String:title.c_str()];
            [UMSocialData defaultData].extConfig.qqData.url = [NSString stringWithUTF8String:url.c_str()];
            snsName = UMShareToQQ;
        }
            break;
        case QZONE:
        {
            [UMSocialData defaultData].extConfig.qzoneData.title = [NSString stringWithUTF8String:title.c_str()];
            [UMSocialData defaultData].extConfig.qzoneData.url = [NSString stringWithUTF8String:url.c_str()];
            snsName = UMShareToQzone;
        }
            break;
        case SINA:
        {
//            [UMSocialData defaultData].extConfig.sinaData.title = [NSString stringWithUTF8String:title.c_str()];
//            [UMSocialData defaultData].extConfig.sinaData.url = [NSString stringWithUTF8String:url.c_str()];
            snsName = UMShareToSina;
        }
            break;
        default:
            break;
    }
    
    UMSocialUrlResource *urlResource = nil;
    id imageObj = nil;
    NSString *imageString = [NSString stringWithUTF8String:image.c_str()];
    if ([imageString hasPrefix:@"http://"] || [imageString hasPrefix:@"https://"]) {
        urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:imageString];
        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:imageString];
    } else {
        imageObj = [UIImage imageWithContentsOfFile:[NSString stringWithUTF8String:image.c_str()]];
    }
    
    [UMSocialConfig setSupportedInterfaceOrientations:UIInterfaceOrientationMaskAll];
    
    [[UMSocialDataService defaultDataService] postSNSWithTypes:@[snsName]
                                                       content:[NSString stringWithUTF8String:text.c_str()]
                                                         image:imageObj
                                                      location:nil
                                                   urlResource:urlResource
                                           presentedController:nil
                                                    completion:^(UMSocialResponseEntity *response){
        UMShare::getInstance()->call(StringUtils::toString(t), StringUtils::toString(response.responseCode));
    }];
}

void UMShare::call(const std::string& platform, const std::string& errCode)
{
    cocos2d::log("%s %s", platform.c_str(), errCode.c_str());
    
    if (_callback) {
        _callback((SHARE_TYPE)atoi(platform.c_str()), atoi(errCode.c_str()));
    }
}

void UMShare::passUrl(const std::string &url)
{
    NSURL *nurl = [NSURL URLWithString:[NSString stringWithUTF8String:url.c_str()]];
    [UMSocialSnsService handleOpenURL:nurl];
}


#endif