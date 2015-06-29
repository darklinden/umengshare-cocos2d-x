package org.cocos2dx.cpp;

import java.io.IOException;
import java.io.InputStream;

import android.app.Activity;
import android.content.Intent;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.widget.Toast;

import com.umeng.socialize.bean.SHARE_MEDIA;
import com.umeng.socialize.bean.SocializeEntity;
import com.umeng.socialize.controller.UMServiceFactory;
import com.umeng.socialize.controller.UMSocialService;
import com.umeng.socialize.controller.listener.SocializeListeners.SnsPostListener;
import com.umeng.socialize.media.QQShareContent;
import com.umeng.socialize.media.QZoneShareContent;
import com.umeng.socialize.media.SinaShareContent;
import com.umeng.socialize.media.UMImage;
import com.umeng.socialize.sso.QZoneSsoHandler;
import com.umeng.socialize.sso.SinaSsoHandler;
import com.umeng.socialize.sso.UMQQSsoHandler;
import com.umeng.socialize.sso.UMSsoHandler;
import com.umeng.socialize.weixin.controller.UMWXHandler;
import com.umeng.socialize.weixin.media.CircleShareContent;
import com.umeng.socialize.weixin.media.WeiXinShareContent;

public class JUMService {

	private static Activity _act = null;
	private static UMSocialService _mController = null;
	
	private static String _wxKey = "";
	private static String _wxSec = "";
	private static String _qqKey = "";
	private static String _qqSec = "";

	public static void onActivityResult(int requestCode, int resultCode,
			Intent data) {
		// 根据requestCode获取对应的SsoHandler
		UMSsoHandler ssoHandler = _mController.getConfig().getSsoHandler(
				requestCode);
		if (ssoHandler != null) {
			ssoHandler.authorizeCallBack(requestCode, resultCode, data);
		}
	}
	
	public static void setupWechat(String key, String sec)
	{
		_wxKey = key;
		_wxSec = sec;
	}
	
	public static void setupQQ(String key, String sec)
	{
		_qqKey = key;
		_qqSec = sec;
	}

	public static void sdkInit(Activity act) {
		_act = act;
		_mController = UMServiceFactory.getUMSocialService("com.umeng.share");
		_mController.getConfig().setSsoHandler(new SinaSsoHandler());
	}

	public native static void shareCallback(String pl, String ec);

	public static void share(final String ps, final String title,
			final String text, final String url, final String image) {
		int p = Integer.parseInt(ps);
		SHARE_MEDIA platform = SHARE_MEDIA.QQ;
		if (1 == p) {
			platform = SHARE_MEDIA.WEIXIN;
		} else if (2 == p) {
			platform = SHARE_MEDIA.WEIXIN_CIRCLE;
		} else if (3 == p) {
			platform = SHARE_MEDIA.QQ;
		} else if (4 == p) {
			platform = SHARE_MEDIA.QZONE;
		} else if (5 == p) {
			platform = SHARE_MEDIA.SINA;
		}

		directShare(platform, title, text, url, image);
	}

	public static void directShare(final SHARE_MEDIA platform,
			final String title, final String text, final String url,
			final String image) {
		_act.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				
				if (!(_wxKey.length() > 0 && _wxSec.length() > 0 && _qqKey.length() > 0 && _qqSec.length() > 0)) {
					Toast.makeText(_act, "请先配置微信和qq！", Toast.LENGTH_LONG).show();
					return;
				}

				setShareContent(platform, title, text, url, image);

				// _mController.postShare(mContext, mPlatform,
				_mController.postShare(_act, platform, new SnsPostListener() {

					@Override
					public void onStart() {
						Toast.makeText(_act, "开始分享.", Toast.LENGTH_SHORT)
								.show();
					}

					@Override
					public void onComplete(SHARE_MEDIA platform, int eCode,
							SocializeEntity entity) {
						int p = 0;
						if (SHARE_MEDIA.WEIXIN == platform) {
							p = 1;
						} else if (SHARE_MEDIA.WEIXIN_CIRCLE == platform) {
							p = 2;
						} else if (SHARE_MEDIA.QQ == platform) {
							p = 3;
						} else if (SHARE_MEDIA.QZONE == platform) {
							p = 4;
						} else if (SHARE_MEDIA.SINA == platform) {
							p = 5;
						}
						shareCallback("" + p, "" + eCode);

						if (eCode == 200) {
							Toast.makeText(_act, "分享成功.", Toast.LENGTH_SHORT)
									.show();
						} else {
							String eMsg = "";
							if (eCode == -101) {
								eMsg = "没有授权";
							}
							Toast.makeText(_act, "分享失败[" + eCode + "] " + eMsg,
									Toast.LENGTH_SHORT).show();
						}
					}
				});
			}
		});
	}

	public static void setShareContent(SHARE_MEDIA platform, String title,
			String text, String url, String image) {
		
		UMImage imageObj = null;
		if (image.contains("assets/")) {
			int len = "assets/".length();
			String path = image.substring(len, image.length());
			
			Bitmap bitimg = null;
			AssetManager am = _act.getResources().getAssets();
			try {
				InputStream is = am.open(path);
				bitimg = BitmapFactory.decodeStream(is);
				is.close();
				
				imageObj = new UMImage(_act, bitimg);
			}
			catch (IOException e) {
				e.printStackTrace();
			}
		}
		else if (image.contains("http")) {
			imageObj = new UMImage(_act, image);
		}
				
		if (SHARE_MEDIA.WEIXIN == platform) {
			// wechat
			_mController.getConfig().removeSsoHandler(SHARE_MEDIA.WEIXIN);
			UMWXHandler wxHandler = new UMWXHandler(_act, _wxKey, _wxSec);
			wxHandler.addToSocialSDK();
			
			WeiXinShareContent weixinContent = new WeiXinShareContent();
			weixinContent.setShareContent(text);
			weixinContent.setTitle(title);
			weixinContent.setTargetUrl(url);
			weixinContent.setShareImage(imageObj);
			_mController.setShareMedia(weixinContent);
		} else if (SHARE_MEDIA.WEIXIN_CIRCLE == platform) {
			// 设置朋友圈分享的内容
			_mController.getConfig().removeSsoHandler(SHARE_MEDIA.WEIXIN_CIRCLE);
			UMWXHandler wxCircleHandler = new UMWXHandler(_act, _wxKey, _wxSec);
			wxCircleHandler.setToCircle(true);
			wxCircleHandler.addToSocialSDK();
			
			CircleShareContent circleMedia = new CircleShareContent();
			circleMedia.setShareContent(text);
			circleMedia.setTitle(title);
			circleMedia.setShareImage(imageObj);
			circleMedia.setTargetUrl(url);
			_mController.setShareMedia(circleMedia);
		} else if (SHARE_MEDIA.QQ == platform) {
			// qq 分享
			_mController.getConfig().removeSsoHandler(SHARE_MEDIA.QQ);
			UMQQSsoHandler qqSsoHandler = new UMQQSsoHandler(_act, _qqKey, _qqSec);
			qqSsoHandler.setTargetUrl(url);
			qqSsoHandler.addToSocialSDK();
			
			QQShareContent qqShareContent = new QQShareContent();
			qqShareContent.setShareContent(text);
			qqShareContent.setTitle(title);
			qqShareContent.setShareImage(imageObj);
			qqShareContent.setTargetUrl(url);
			_mController.setShareMedia(qqShareContent);
		} else if (SHARE_MEDIA.QZONE == platform) {
			// 设置QQ空间分享内容
			_mController.getConfig().removeSsoHandler(SHARE_MEDIA.QZONE);
			QZoneSsoHandler qZoneSsoHandler = new QZoneSsoHandler(_act, _qqKey, _qqSec);
			qZoneSsoHandler.addToSocialSDK();
			
			QZoneShareContent qzone = new QZoneShareContent();
			qzone.setShareContent(text);
			qzone.setTargetUrl(url);
			qzone.setTitle(title);
			qzone.setShareImage(imageObj);
			// qzone.setShareMedia(uMusic);
			_mController.setShareMedia(qzone);
		} else if (SHARE_MEDIA.SINA == platform) {
			// sina
			SinaShareContent sinaContent = new SinaShareContent();
			sinaContent.setShareContent(text);
			sinaContent.setShareImage(imageObj);
			sinaContent.setTitle(title);
			sinaContent.setTargetUrl(url);
			_mController.setShareMedia(sinaContent);
		}
	}
}
