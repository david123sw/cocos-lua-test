package com.sevenjzc.yyjddmj.wxapi;

import org.extension.ExtensionApi;
import org.game.Constant;
import org.ynlib.utils.Utils;

import com.tencent.mm.sdk.constants.ConstantsAPI;
import com.tencent.mm.sdk.modelbase.BaseReq;
import com.tencent.mm.sdk.modelbase.BaseResp;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

public class WXPayEntryActivity extends Activity implements IWXAPIEventHandler{
	
	private static final String TAG = "yyjddmj->WXPayEntryActivity";
	
    private IWXAPI api;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        String wxAppID = Utils.getMetaData(ExtensionApi.appActivity, Constant.WX_APPID_KEY);
    	api = WXAPIFactory.createWXAPI(this, wxAppID, false);
        api.handleIntent(getIntent(), this);
        finish();
    }

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		setIntent(intent);
        api.handleIntent(intent, this);
	}

	@Override
	public void onReq(BaseReq req) {
	}

	@Override
	public void onResp(BaseResp resp) {
		Log.d(TAG, "onPayFinish, errCode = " + resp.errCode);
		if(0 == resp.errCode)
		{
			ExtensionApi.callBackOnGLThread(this.bindMsg(ExtensionApi.TYPE_WEIXIN_PAY, 1, ""));
			Log.d(TAG, "onPayFinish, pay done");
		}else {
			Log.d(TAG, "onPayFinish, pay error");
			ExtensionApi.callBackOnGLThread(this.bindMsg(ExtensionApi.TYPE_WEIXIN_PAY, 0, "" + resp.errCode));
		}
		
	}
	
    private String bindMsg(String type, int status, String code) {
    	return "{\"type\":\"" + type + "\", \"status\":" + status +", \"code\":\""+ code + "\"}";
    }
}
