package org.weixin;

import org.extension.ExtensionApi;
import org.game.Constant;
import org.ynlib.utils.Utils;

import com.tencent.mm.sdk.modelmsg.SendAuth;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

import android.app.Activity;
import android.util.Log;

public class WeixinToken {
	public void getWeiXinToken(String weixinId) {
		try {
			Log.i(Constant.LOG_TAG, "call LoginWx begin");
			Activity appActivity = ExtensionApi.appActivity;
			IWXAPI api = WXAPIFactory.createWXAPI(appActivity, weixinId, false);
			api.registerApp(weixinId);
			SendAuth.Req req = new SendAuth.Req();
			req.scope = "snsapi_userinfo";
			req.state = "cnklds";
			api.sendReq(req);

			Log.i(Constant.LOG_TAG, "call LoginWx end");
			
		} catch (Exception e) {
			Log.e(Constant.LOG_TAG, e.toString(), e);
		}
	}
}
