//
//  UMService.cpp
//
//  Created by HanShaokun on 27/6/15.
//
//

#include "UMService.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMessage.h"
#import "MobClick.h"
#include "UMConstants.h"

USING_NS_CC;

//构造&析构
UMService::UMService()
{
    
}

UMService::~UMService()
{
    
}

//单例对象&初始化
static UMService* _st = nullptr;
UMService* UMService::getInstance()
{
    if (!_st) {
        _st = new (std::nothrow) UMService();
    }
    
    return _st;
}

void UMService::sdkinit()
{
    /*########################### 推送 ###########################*/
    [UMessage startWithAppkey:[NSString stringWithUTF8String:UMKEY]
                launchOptions:nil];
    [UMessage setLogEnabled:UMLogEnable];
    [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
     |UIRemoteNotificationTypeSound
     |UIRemoteNotificationTypeAlert];
    [UMessage setChannel:[NSString stringWithUTF8String:CHANNLE_ID]];
    
    /*########################### 社会化分享 ###########################*/
    //设置友盟社会化组件appkey
    [UMSocialData setAppKey:[NSString stringWithUTF8String:UMKEY]];
    
    //打开调试log的开关
    [UMSocialData openLog:UMLogEnable];
    
    //如果你要支持不同的屏幕方向，需要这样设置，否则在iPhone只支持一个竖屏方向
    [UMSocialConfig setSupportedInterfaceOrientations:UIInterfaceOrientationMaskLandscape];
    
    /*########################### 数据统计 ###########################*/
    [MobClick startWithAppkey:[NSString stringWithUTF8String:UMKEY]
                 reportPolicy:ReportPolicy::BATCH
                    channelId:[NSString stringWithUTF8String:CHANNLE_ID]];
    [MobClick setLogEnabled:UMLogEnable];
}

/*########################### 推送 ###########################*/
void UMService::addPushTrackUser(int userId)
{
    [UMessage addAlias:[NSString stringWithFormat:@"%d", userId]
                  type:kUMessageAliasTypeQQ
              response:nil];
}

/*########################### 社会化分享 ###########################*/
void UMService::setShareCallback(std::function<void(SHARE_TYPE, int)> callback)
{
    UMService::getInstance()->_shareCallback = callback;
}

void UMService::share(SHARE_TYPE t,
                    const std::string& title,
                    const std::string& text,
                    const std::string& url,
                    const std::string& image)
{
    NSString* snsName = @"";
    
    switch (t) {
        case WECHAT:
        {
            [UMSocialWechatHandler setWXAppId:[NSString stringWithUTF8String:WXKEY]
                                    appSecret:[NSString stringWithUTF8String:WXSEC]
                                          url:[NSString stringWithUTF8String:url.c_str()]];
            
            [UMSocialData defaultData].extConfig.wechatSessionData.title = [NSString stringWithUTF8String:title.c_str()];
            [UMSocialData defaultData].extConfig.wechatSessionData.url = [NSString stringWithUTF8String:url.c_str()];
            snsName = UMShareToWechatSession;
        }
            break;
        case WECHAT_CIRCLE:
        {
            [UMSocialWechatHandler setWXAppId:[NSString stringWithUTF8String:WXKEY]
                                    appSecret:[NSString stringWithUTF8String:WXSEC]
                                          url:[NSString stringWithUTF8String:url.c_str()]];
            
            [UMSocialData defaultData].extConfig.wechatTimelineData.title = [NSString stringWithUTF8String:title.c_str()];
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = [NSString stringWithUTF8String:url.c_str()];
            snsName = UMShareToWechatTimeline;
        }
            break;
        case QQ:
        {
            [UMSocialQQHandler setQQWithAppId:[NSString stringWithUTF8String:QQKEY]
                                       appKey:[NSString stringWithUTF8String:QQSEC]
                                          url:[NSString stringWithUTF8String:url.c_str()]];
            
            [UMSocialData defaultData].extConfig.qqData.title = [NSString stringWithUTF8String:title.c_str()];
            [UMSocialData defaultData].extConfig.qqData.url = [NSString stringWithUTF8String:url.c_str()];
            snsName = UMShareToQQ;
        }
            break;
        case QZONE:
        {
            [UMSocialQQHandler setQQWithAppId:[NSString stringWithUTF8String:QQKEY]
                                       appKey:[NSString stringWithUTF8String:QQSEC]
                                          url:[NSString stringWithUTF8String:url.c_str()]];
            
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
        UMService::getInstance()->callShareCallback(StringUtils::toString(t), StringUtils::toString(response.responseCode));
    }];
}

void UMService::callShareCallback(const std::string &platform, const std::string &errCode)
{
    cocos2d::log("%s %s", platform.c_str(), errCode.c_str());
    
    if (_shareCallback) {
        _shareCallback((SHARE_TYPE)atoi(platform.c_str()), atoi(errCode.c_str()));
    }
}

void UMService::passUrl(const std::string &url)
{
    NSURL *nurl = [NSURL URLWithString:[NSString stringWithUTF8String:url.c_str()]];
    [UMSocialSnsService handleOpenURL:nurl];
}

/*########################### 数据统计 ###########################*/

void UMService::trackEvent(const std::string& event_label)
{
    [MobClick event:[NSString stringWithUTF8String:EVENT_ID]
              label:[NSString stringWithUTF8String:event_label.c_str()]];
}

#endif