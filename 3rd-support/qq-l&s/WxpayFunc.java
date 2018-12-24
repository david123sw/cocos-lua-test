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

/*
//tencent qq pay test url
			@Override
			public void onClick(View v) {
				String url = "https://wxpay.wxutil.com/pub_v2/app/app_pay.php";
				Button payBtn = (Button) findViewById(R.id.appay_btn);
				payBtn.setEnabled(false);
				Toast.makeText(PayActivity.this, "获取订单中...", Toast.LENGTH_SHORT).show();
		        try{
					byte[] buf = Util.httpGet(url);
					if (buf != null && buf.length > 0) {
						String content = new String(buf);
						Log.e("get server pay params:",content);
			        	JSONObject json = new JSONObject(content); 
						if(null != json && !json.has("retcode") ){
							PayReq req = new PayReq();
							//req.appId = "wxf8b4f85f3a794e77";  // 测试用appId
							req.appId			= json.getString("appid");
							req.partnerId		= json.getString("partnerid");
							req.prepayId		= json.getString("prepayid");
							req.nonceStr		= json.getString("noncestr");
							req.timeStamp		= json.getString("timestamp");
							req.packageValue	= json.getString("package");
							req.sign			= json.getString("sign");
							req.extData			= "app data"; // optional
							Toast.makeText(PayActivity.this, "正常调起支付", Toast.LENGTH_SHORT).show();
							// 在支付之前，如果应用没有注册到微信，应该先调用IWXMsg.registerApp将应用注册到微信
							api.sendReq(req);
						}else{
				        	Log.d("PAY_GET", "返回错误"+json.getString("retmsg"));
				        	Toast.makeText(PayActivity.this, "返回错误"+json.getString("retmsg"), Toast.LENGTH_SHORT).show();
						}
					}else{
			        	Log.d("PAY_GET", "服务器请求错误");
			        	Toast.makeText(PayActivity.this, "服务器请求错误", Toast.LENGTH_SHORT).show();
			        }
		        }catch(Exception e){
		        	Log.e("PAY_GET", "异常："+e.getMessage());
		        	Toast.makeText(PayActivity.this, "异常："+e.getMessage(), Toast.LENGTH_SHORT).show();
		        }
		        payBtn.setEnabled(true);
			}
*/

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
