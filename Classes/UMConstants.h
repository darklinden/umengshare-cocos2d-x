//
//  UMConstants.h
//  umeng_share
//
//  Created by HanShaokun on 29/6/15.
//
//

#ifndef umeng_share_UMConstants_h
#define umeng_share_UMConstants_h

#include "cocos2d.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID

#define UMKEY       "4f83c5d852701564c0000011"
#define UMSEC       ""

#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS

#define UMKEY       "4eeb0c7b527015643b000003"
#define UMSEC       ""

#endif

#if COCOS2D_DEBUG

#define UMLogEnable true

#else

#define UMLogEnable false

#endif

#define WXKEY       "wxd930ea5d5a258f4f"
#define WXSEC       "db426a9829e4b49a0dcac7b4162da6b6"

#define QQKEY       "100424468"
#define QQSEC       "c7394704798a158208a74ab60104f0ba"

#define CHANNLE_ID  "CHANNLE_ID"

#define EVENT_ID    "e_custom"

#endif
