//
//  UMShare.cpp
//
//  Created by HanShaokun on 27/6/15.
//
//

#include "UMService.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID

#include <jni.h>
#include "platform/android/jni/JniHelper.h"
#include <android/log.h>
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
    JniMethodInfo minfo;
    
    if (JniHelper::getStaticMethodInfo(minfo,
                                       "org/cocos2dx/cpp/JUMService",
                                       "sdkInit",
                                       "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"))
    {
        jobject jumKey = minfo.env->NewStringUTF(UMKEY);
        jobject jumSec = minfo.env->NewStringUTF(UMSEC);
        jobject jchannel = minfo.env->NewStringUTF(CHANNLE_ID);
        
        std::string logEnable = "0";
        if (UMLogEnable) {
            logEnable = "1";
        }
        
        jobject jlogEnable = minfo.env->NewStringUTF(logEnable.c_str());
        minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, jumKey, jumSec, jchannel, jlogEnable);
        minfo.env->DeleteLocalRef(jumKey);
        minfo.env->DeleteLocalRef(jumSec);
        minfo.env->DeleteLocalRef(jchannel);
        minfo.env->DeleteLocalRef(jlogEnable);
    }
    
    //设置key
    {
        JniMethodInfo minfo;
        
        if (JniHelper::getStaticMethodInfo(minfo,
                                           "org/cocos2dx/cpp/JUMService",
                                           "setupQQ",
                                           "(Ljava/lang/String;Ljava/lang/String;)V"))
        {
            jobject jqqkey = minfo.env->NewStringUTF(QQKEY);
            jobject jqqsec = minfo.env->NewStringUTF(QQSEC);
            minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, jqqkey, jqqsec);
            minfo.env->DeleteLocalRef(jqqkey);
            minfo.env->DeleteLocalRef(jqqsec);
        }
    }
    
    {
        JniMethodInfo minfo;
        
        if (JniHelper::getStaticMethodInfo(minfo,
                                           "org/cocos2dx/cpp/JUMService",
                                           "setupWechat",
                                           "(Ljava/lang/String;Ljava/lang/String;)V"))
        {
            jobject jwxkey = minfo.env->NewStringUTF(WXKEY);
            jobject jwxsec = minfo.env->NewStringUTF(WXSEC);
            minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, jwxkey, jwxsec);
            minfo.env->DeleteLocalRef(jwxkey);
            minfo.env->DeleteLocalRef(jwxsec);
        }
    }
}

/*########################### 推送 ###########################*/
void UMService::addPushTrackUser(int userId)
{
    JniMethodInfo minfo;
    
    if (JniHelper::getStaticMethodInfo(minfo,
                                       "org/cocos2dx/cpp/JUMService",
                                       "addAlias",
                                       "(Ljava/lang/String;)V"))
    {
        jobject para1 = minfo.env->NewStringUTF(StringUtils::format("%d", userId).c_str());
        minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, para1);
        minfo.env->DeleteLocalRef(para1);
    }
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
    //设置key
    if (SHARE_TYPE::QQ == t || SHARE_TYPE::QZONE == t) {
        JniMethodInfo minfo;
        
        if (JniHelper::getStaticMethodInfo(minfo,
                                           "org/cocos2dx/cpp/JUMService",
                                           "setupQQ",
                                           "(Ljava/lang/String;Ljava/lang/String;)V"))
        {
            jobject jqqkey = minfo.env->NewStringUTF(QQKEY);
            jobject jqqsec = minfo.env->NewStringUTF(QQSEC);
            minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, jqqkey, jqqsec);
            minfo.env->DeleteLocalRef(jqqkey);
            minfo.env->DeleteLocalRef(jqqsec);
        }
    }
    
    if (SHARE_TYPE::WECHAT == t || SHARE_TYPE::WECHAT_CIRCLE == t) {
        JniMethodInfo minfo;
        
        if (JniHelper::getStaticMethodInfo(minfo,
                                           "org/cocos2dx/cpp/JUMService",
                                           "setupWechat",
                                           "(Ljava/lang/String;Ljava/lang/String;)V"))
        {
            jobject jwxkey = minfo.env->NewStringUTF(WXKEY);
            jobject jwxsec = minfo.env->NewStringUTF(WXSEC);
            minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, jwxkey, jwxsec);
            minfo.env->DeleteLocalRef(jwxkey);
            minfo.env->DeleteLocalRef(jwxsec);
        }
    }
    
    //分享
    {
        JniMethodInfo minfo;
        
        if (JniHelper::getStaticMethodInfo(minfo,
                                           "org/cocos2dx/cpp/JUMService",
                                           "share",
                                           "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"))
        {
            jobject jtype = minfo.env->NewStringUTF(cocos2d::StringUtils::toString(t).c_str());
            jobject jtitle = minfo.env->NewStringUTF(title.c_str());
            jobject jtext = minfo.env->NewStringUTF(text.c_str());
            jobject jurl = minfo.env->NewStringUTF(url.c_str());
            jobject jimg = minfo.env->NewStringUTF(image.c_str());
            minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, jtype, jtitle, jtext, jurl, jimg);
            minfo.env->DeleteLocalRef(jtype);
            minfo.env->DeleteLocalRef(jtitle);
            minfo.env->DeleteLocalRef(jtext);
            minfo.env->DeleteLocalRef(jurl);
            minfo.env->DeleteLocalRef(jimg);
        }
    }

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
    
}

extern "C" {
    
    JNIEXPORT void JNICALL
    Java_org_cocos2dx_cpp_JUMShare_shareCallback(JNIEnv *env,
                                                jobject obj,
                                                jstring jplatform,
                                                jstring jerrCode)
    {
        const char *pl = env->GetStringUTFChars(jplatform, 0);
        char platform[16];
        strcpy(platform, pl);
        env->ReleaseStringUTFChars(jplatform, pl);
        
        const char *ec = env->GetStringUTFChars(jerrCode, 0);
        char errCode[16];
        strcpy(errCode, ec);
        env->ReleaseStringUTFChars(jerrCode, ec);
        
        UMService::getInstance()->callShareCallback(platform, errCode);
    }

}

/*########################### 数据统计 ###########################*/

void UMService::trackEvent(const std::string& event_label)
{
    JniMethodInfo minfo;
    
    if (JniHelper::getStaticMethodInfo(minfo,
                                       "org/cocos2dx/cpp/JUMService",
                                       "trackEvent",
                                       "(Ljava/lang/String;Ljava/lang/String;)V"))
    {
        jobject jevent = minfo.env->NewStringUTF(EVENT_ID);
        jobject jlabel = minfo.env->NewStringUTF(event_label.c_str());
        minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, jevent, jlabel);
        minfo.env->DeleteLocalRef(jevent);
        minfo.env->DeleteLocalRef(jlabel);
    }
}

#endif