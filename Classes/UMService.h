//
//  UMShare.h
//
//  Created by HanShaokun on 27/6/15.
//
//

#ifndef __BYFISHGAME__UMShare__
#define __BYFISHGAME__UMShare__

#include "cocos2d.h"

class UMService {
    
public:
    
    //构造&析构
    UMService();
    ~UMService();
    
    //单例对象&初始化
    static UMService* getInstance();
    void sdkinit();
    
    /*########################### 推送 ###########################*/
    static void addPushTrackUser(int userId);
    
    /*########################### 社会化分享 ###########################*/
    typedef enum : int {
        WECHAT = 1,
        WECHAT_CIRCLE = 2,
        QQ = 3,
        QZONE = 4,
        SINA = 5
    } SHARE_TYPE;
    
    static void setShareCallback(std::function<void(SHARE_TYPE, int)> callback);
    
    static void share(SHARE_TYPE,
                      const std::string& title,
                      const std::string& text,
                      const std::string& url,
                      const std::string& image);
    
    static void passUrl(const std::string& url);
    
    std::function<void(SHARE_TYPE, int)> _shareCallback;
    
    void callShareCallback(const std::string& platform, const std::string& errCode);
    
    /*########################### 数据统计 ###########################*/
    
    static void trackEvent(const std::string& userId);
    
};


#endif /* defined(__BYFISHGAME__UMShare__) */
