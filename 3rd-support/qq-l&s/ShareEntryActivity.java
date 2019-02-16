package com.sevenjzc.hhllqp.apshare;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import com.alipay.share.sdk.openapi.*;

import org.game.Constant;
import org.game.AppActivity;

public class ShareEntryActivity extends Activity implements IAPAPIEventHandler {
    private IAPApi api;

    /**
     * Called when the activity is first created.
     */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        api = APAPIFactory.createZFBApi(this, Constant.APP_ZFB_KEY, false);
        Intent intent = getIntent();
        api.handleIntent(intent, this);
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        api.handleIntent(intent, this);
    }

    @Override
    public void onReq(BaseReq baseReq) {

    }

    @Override
    public void onResp(BaseResp baseResp) {
        int result = -1;

        switch (baseResp.errCode) {
            case BaseResp.ErrCode.ERR_OK:
            	result = 0;
                break;
            case BaseResp.ErrCode.ERR_USER_CANCEL:
            	result = 1;
                break;
            case BaseResp.ErrCode.ERR_AUTH_DENIED:
            	result = 2;
                break;
            case BaseResp.ErrCode.ERR_SENT_FAILED:
            	result = 3;
                break;
            default:
                break;
        }
        Log.d("zfb" , "Share result "+result);
        finish();
    }
}