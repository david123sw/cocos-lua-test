package org.pay;

import org.extension.ExtensionApi;
import org.game.Constant;
import org.json.JSONException;
import org.json.JSONObject;
import org.ynlib.utils.Utils;

import com.tencent.mm.sdk.modelbase.BaseReq;
import com.tencent.mm.sdk.modelbase.BaseResp;
import com.tencent.mm.sdk.modelpay.PayReq;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

import android.util.Log;

public class WxpayFunc /*implements IWXAPIEventHandler*/{
	public void startPay(final String orderInfo) {
		try {
			JSONObject data = new JSONObject(orderInfo);
			try{
				Log.i(Constant.LOG_TAG, orderInfo);
				PayReq req = new PayReq();
				req.appId = data.getString("appid");
				Log.i(Constant.LOG_TAG, req.appId);
				req.partnerId = data.getString("partnerid");
				Log.i(Constant.LOG_TAG, req.partnerId);
				req.prepayId = data.getString("prepayid");
				Log.i(Constant.LOG_TAG, req.prepayId);
				req.packageValue = data.getString("package");
				Log.i(Constant.LOG_TAG, req.packageValue);
				req.nonceStr = data.getString("noncestr");
				Log.i(Constant.LOG_TAG, req.nonceStr);
				req.timeStamp = data.getString("timestamp");
				Log.i(Constant.LOG_TAG, req.timeStamp);
				req.sign = data.getString("sign");
				Log.i(Constant.LOG_TAG, req.sign);
				String weixinId = Utils.getMetaData(ExtensionApi.appActivity, Constant.WX_APPID_KEY);
				IWXAPI msgApi = WXAPIFactory.createWXAPI(ExtensionApi.appActivity, weixinId, false);
				msgApi.sendReq(req);
			} catch (Exception e) {
				Log.e(Constant.LOG_TAG, e.toString(), e);
			}
		} catch (JSONException e) {
			e.printStackTrace();
			Log.e(Constant.LOG_TAG, e.toString(), e);
		}
	}
}
