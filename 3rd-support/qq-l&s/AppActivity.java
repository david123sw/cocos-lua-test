/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2011      Zynga Inc.
Copyright (c) 2013-2014 Chukong Technologies Inc.
 
http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package org.game;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.microedition.khronos.opengles.GL10;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;
import org.extension.ExtensionApi;
import org.ynlib.utils.Utils;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.content.res.Configuration;
import android.hardware.SensorManager;
import android.location.Address;
import android.location.Geocoder;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.BatteryManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Debug;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.os.PowerManager;
import android.text.ClipboardManager;
import android.text.TextUtils;
import android.util.Log;
import android.view.OrientationEventListener;
import android.widget.Toast;
import android.os.SystemClock;
import android.support.v4.app.ActivityCompat;
//import android.support.v7.appcompat.*;
import org.game.PowerConnectionReceiver;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationClientOption.AMapLocationMode;
import com.amap.api.location.AMapLocationClientOption.AMapLocationProtocol;
import com.tendcloud.tenddata.TalkingDataGA;
import com.amap.api.location.AMapLocationListener;
import com.yunva.im.sdk.lib.core.YunvaImSdk;
import com.yunva.im.sdk.lib.event.MessageEvent;
import com.yunva.im.sdk.lib.event.MessageEventListener;
import com.yunva.im.sdk.lib.event.MessageEventSource;
import com.yunva.im.sdk.lib.event.RespInfo;
import com.yunva.im.sdk.lib.event.msgtype.MessageType;
import com.yunva.im.sdk.lib.model.tool.ImAudioRecordResp;
import com.yunva.im.sdk.lib.model.tool.ImUploadFileResp;

import android.media.*;

import com.tencent.connect.UnionInfo;
import com.tencent.connect.UserInfo;
import com.tencent.connect.common.Constants;
import com.tencent.connect.share.QQShare;
import com.tencent.tauth.IUiListener;
import com.tencent.tauth.UiError;
import com.tencent.tauth.Tencent;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.sevenjzc.ywglzp.ddshare.DDShareActivity;
import com.sevenjzc.ywglzp.qqapi.QQBaseUIListener;
import com.sevenjzc.ywglzp.qqapi.QQUtil;
import com.sevenjzc.ywglzp.qqapi.QQShareActivity;
import com.android.dingtalk.share.ddsharemodule.DDShareApiFactory;
import com.android.dingtalk.share.ddsharemodule.IDDShareApi;
import com.android.dingtalk.share.ddsharemodule.ShareConstant;
import com.android.dingtalk.share.ddsharemodule.message.BaseReq;
import com.android.dingtalk.share.ddsharemodule.message.BaseResp;
import com.android.dingtalk.share.ddsharemodule.message.DDImageMessage;
import com.android.dingtalk.share.ddsharemodule.message.DDMediaMessage;
import com.android.dingtalk.share.ddsharemodule.message.DDTextMessage;
import com.android.dingtalk.share.ddsharemodule.message.DDWebpageMessage;
import com.android.dingtalk.share.ddsharemodule.message.DDZhiFuBaoMesseage;
import com.android.dingtalk.share.ddsharemodule.message.SendAuth;
import com.android.dingtalk.share.ddsharemodule.message.SendMessageToDD;
import com.android.dingtalk.share.ddsharemodule.plugin.SignatureCheck;
import com.android.dingtalk.share.ddsharemodule.IDDAPIEventHandler;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Point;

import org.xianliao.im.sdk.api.ISGAPI;
import org.xianliao.im.sdk.api.SGAPIFactory;
import org.xianliao.im.sdk.constants.SGConstants;
import org.xianliao.im.sdk.modelmsg.SGGameObject;
import org.xianliao.im.sdk.modelmsg.SGMediaMessage;
import org.xianliao.im.sdk.modelmsg.SendMessageToSG;

public class AppActivity extends Cocos2dxActivity implements MessageEventListener{
	public static GL10 gl10;
	private int intLevel; 
    private int intScale;   
	private String mProviderName = null;
	private PowerManager.WakeLock wakeLock;
	
	private AMapLocationClient locationClient = null;
	private AMapLocationClientOption locationOption = new AMapLocationClientOption();
	private String locationInfo ="";
	public static String roomid = "";
	public static String appVersion = "1.0.0";
	
	public MediaPlayer audioMP = null;
	public MediaRecorder audioMR = null;
	public long mpBeginTm = 0;
	public long mpEndTm = 0;
	public String audioPrepath =Environment.getExternalStorageDirectory().toString() + "/amr_";
	public int sdkVerNum = 0;
	public boolean is8SDK = false;
	
	private UserInfo mInfo;
	public static Tencent mTencent;
    private static Intent mPrizeIntent = null;
    private static boolean isServerSideLogin = false;
    OrientationEventListener mOrientationListener;
    private boolean isYvSDKInitSuccess = false;
    private boolean ignoreCopyAssets = false;
    
    private IDDShareApi iddShareApi = null;
    private DDShareActivity iddContainer = null;
    private IDDAPIEventHandler iddAPIEventHandler = null;
    private PowerConnectionReceiver pcr = null;
    
    ISGAPI xLApi;
    String xLRoomToken;
    String xLRoomId;
	
    private BroadcastReceiver mBatInfoReveiver = new BroadcastReceiver() {
        @Override 
        public void onReceive(Context context, Intent intent) { 
            // TODO Auto-generated method stub 
            String action = intent.getAction(); 
            if (Intent.ACTION_BATTERY_CHANGED.equals(action)) { 
                intLevel = intent.getIntExtra("level", 0);
                intScale = intent.getIntExtra("scale", 100);
                onBatteryInfoReceiver(intLevel, intScale);
            }
        }
    };
    
    @Override
    public Cocos2dxGLSurfaceView onCreateView() {
        Cocos2dxGLSurfaceView glSurfaceView = new Cocos2dxGLSurfaceView(this);
        // TestCpp should create stencil buffer
        glSurfaceView.setEGLConfigChooser(5, 6, 5, 0, 16, 8);
        ExtensionApi.appActivity = this;
        return glSurfaceView;
    }     
          
    @Override  
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);	
		keepScreenOn(this, true);
		getAppVersion();
		initLocation();
		getURLParame();
		
		this.checkSystemClipboard();
		TalkingDataGA.init(this, Constant.APP_TALKINGDATA_KEY, Constant.APP_DIST_DESC);
		this.copyAssetsFile("project.manifest");
		this.copyAssetsFile("version.manifest");
		sdkVerNum = Build.VERSION.SDK_INT;
		is8SDK = sdkVerNum >= 26;
		
        //this.initOrientationChecker();
        this.initDingTalkShareApi();
        this.initXianLiaoShareApi();
        this.initQQShareApi();
        this.initBatteryChargingChecker();
        Log.d("ywglzp>>>>>>>>>>>>>>>>>>>>>>>>>", "onCreate");
    }

    public void setRequestedOrientation(final String so) {
		if(so.equals("landscape")) {
			setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
		}else if(so.equals("portrait")) {
			setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
		}else if(so.equals("sensorLandscape")) {
			setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);
		}else if(so.equals("sensorPortrait")) {
			setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT);
		}
    }
    
    public void initBatteryChargingChecker()
    {
    	if(null == pcr){
    		pcr = new PowerConnectionReceiver();
    	}
    }
    
    public void initQQShareApi() {
		if(null == mTencent) {
			mTencent = Tencent.createInstance(Constant.QQ_APPID, this.getApplicationContext());
		}
    }
    
    public void initXianLiaoShareApi() {
    	if(null == xLApi) {
    		xLApi = SGAPIFactory.createSGAPI(this, Constant.APP_XIAN_LIAO_KEY);
    	}
    }
    
    public ISGAPI getXianLiaoShareApi() {
    	return xLApi;
    }
    
    public void initDingTalkShareApi() {
		if(null == iddShareApi) {
			iddShareApi = DDShareApiFactory.createDDShareApi(this, Constant.APP_DING_TALK_KEY, true);
		}
    }
    
    public IDDShareApi getDingTalkShareApi() {		
    	return iddShareApi;
    }
    
	public Point getDevicePixelSize() {
    	Point point = new Point();
		getWindowManager().getDefaultDisplay().getRealSize(point);
		return point;
    }
	
    public void initOrientationChecker() {
		mOrientationListener = new OrientationEventListener(this, SensorManager.SENSOR_DELAY_NORMAL){
            @Override  
            public void onOrientationChanged(int orientation) {  
               if (orientation == OrientationEventListener.ORIENTATION_UNKNOWN){
            	   Log.d("OrientationEventListener", "Unknown");
            	   return;
               }
//               Log.d("OrientationEventListener", "" + orientation);
               if (orientation > 350 || orientation < 10) {
            	   orientation = 0;
	           } else if (orientation > 80 && orientation < 100) {
	        	   ExtensionApi.callBackOnGLThread(ExtensionApi.appActivity.bindMsg(ExtensionApi.TYPE_SCREEN_HORIZONTAL_FLIP, 1, "90"));
	           } else if (orientation > 170 && orientation < 190) {
	        	   orientation = 180;
        	   } else if (orientation > 260 && orientation < 280) {
        		   ExtensionApi.callBackOnGLThread(ExtensionApi.appActivity.bindMsg(ExtensionApi.TYPE_SCREEN_HORIZONTAL_FLIP, 1, "270"));
    		   } else {
    			   return;
			   }
           }
		};
	    if (mOrientationListener.canDetectOrientation()) {  
           mOrientationListener.enable(); 
	    } else {
           mOrientationListener.disable();
	    }
    }
    
    @Override  
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
    }
    
	Handler mHandler = new Handler() {
		@Override
		public void handleMessage(Message msg) {
			Log.d("QQ_LOGIN", "mHandler " + msg.what);
			JSONObject response = (JSONObject) msg.obj;
			Log.d("QQ_LOGIN", "response " + response.toString());
			if (msg.what == 0) {
				Iterator<String> it = response.keys();
				String combineStr = "";
				while(it.hasNext()) {
					try {
						String key = it.next();
						String value = response.getString(key);
						if(value == null) {
							int valueInt = response.getInt(key);
							combineStr += key + "|" + valueInt + "|";
						}
						else{
							combineStr += key + "|" + value + "|";
						}
						
					}catch(Exception e)
					{}
				}
				combineStr = combineStr.substring(0, combineStr.length() - 1);
				combineStr += "";
				ExtensionApi.callBackOnGLThread(ExtensionApi.appActivity.bindMsg(ExtensionApi.TYPE_QQ_LOGIN, 1, combineStr));
			}else if(msg.what == 1){
				ExtensionApi.callBackOnGLThread(ExtensionApi.appActivity.bindMsg(ExtensionApi.TYPE_QQ_LOGIN, 0, ""));
			}
		}
	};
	
    public void updateUserInfo() {
		if (mTencent != null && mTencent.isSessionValid()) {
			IUiListener listener = new IUiListener() {
				@Override
				public void onError(UiError e) {

				}

				@Override
				public void onComplete(final Object response) {
					Log.d("QQ_LOGIN", "updateUserInfo::onComplete");
					Message msg = new Message();
					msg.obj = response;
					msg.what = 0;
					mHandler.sendMessage(msg);
				}

				@Override
				public void onCancel() {
					Log.d("QQ_LOGIN", "updateUserInfo::onCancel");
					Message msg = new Message();
					msg.obj = null;
					msg.what = 1;
					mHandler.sendMessage(msg);
				}
			};
			mInfo = new UserInfo(this, mTencent.getQQToken());
			mInfo.getUserInfo(listener);
		} else {
			Log.i("QQ_LOGIN", "mTencent == null");
		}
	}
	
    public void finishQQShare(final String status, final String retCode) {
    	if(status.equals("complete")) {
    		ExtensionApi.callBackOnGLThread(this.bindMsg(ExtensionApi.TYPE_QQ_SHARE, 1, retCode));
    	}
    	else {
    		ExtensionApi.callBackOnGLThread(this.bindMsg(ExtensionApi.TYPE_QQ_SHARE, 0, "-1"));
    	}
    }
    
	public void initOpenidAndToken(JSONObject jsonObject) {
		String cachedToken = mTencent.getAccessToken();
		String cachedOpenId = mTencent.getOpenId();
		String cachedExpiresIn = mTencent.getExpiresIn() + "";
        if (!TextUtils.isEmpty(cachedToken) && !TextUtils.isEmpty(cachedOpenId) && !TextUtils.isEmpty(cachedExpiresIn)) {
            mTencent.setAccessToken(cachedToken, cachedExpiresIn.toString());
            mTencent.setOpenId(cachedOpenId);
        }else
        {
            try {
            	Log.d("QQ_LOGIN", "initOpenidAndToken");
                String token = jsonObject.getString(Constants.PARAM_ACCESS_TOKEN);
                String expires = jsonObject.getString(Constants.PARAM_EXPIRES_IN);
                String openId = jsonObject.getString(Constants.PARAM_OPEN_ID);
                if (!TextUtils.isEmpty(token) && !TextUtils.isEmpty(expires)
                        && !TextUtils.isEmpty(openId)) {
                    mTencent.setAccessToken(token, expires);
                    mTencent.setOpenId(openId);
                }
            } catch(Exception e) {}	
        }
        
        this.updateUserInfo();
    }
    
    IUiListener qqShareListener = new IUiListener() {
        @Override
        public void onCancel() {
        	Log.i("QQ_SHARE2", "onCancel ");
        }
        @Override
        public void onComplete(Object response) {
    		Log.d("QQ_SHARE2", "onComplete " + response.toString());
        }
        @Override
        public void onError(UiError e) {
        	Log.i("QQ_SHARE2", "onError ");
        }
    };
    
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
	    Log.d(Constant.LOG_TAG, "-->onActivityResult " + requestCode  + " resultCode=" + resultCode);
	    super.onActivityResult(requestCode, resultCode, data);
	    
	    if (requestCode == Constants.REQUEST_LOGIN || requestCode == Constants.REQUEST_APPBAR) {
	    	Tencent.onActivityResultData(requestCode,resultCode,data,new QQBaseUIListener(this));
	    }
	    
        if (requestCode == Constants.REQUEST_QQ_SHARE) {
        	Tencent.onActivityResultData(requestCode,resultCode,data,qqShareListener);
        }
	}
	
	public String getAppCacheFilePath() {
		return getCacheDir().getAbsolutePath();
	}
	
	public AssetManager getAppAssets() {
		return getAssets();
	}
	
    public String jsonReaderVer(File file) {
    	String jsonStr = null;
    	String version = "";
        try {
            if (file.isFile() && file.exists()) {
                InputStreamReader read = new InputStreamReader(new FileInputStream(file), "UTF-8");
                BufferedReader bufferedReader = new BufferedReader(read);
                String lineTxt = bufferedReader.readLine();
                String totalLineTxt = "";
                while (lineTxt != null) {
                	totalLineTxt += lineTxt;
                	lineTxt = bufferedReader.readLine();
                }
                jsonStr = totalLineTxt;
                if(null != bufferedReader) {
                	bufferedReader.close();
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        
        if(null != jsonStr) {
        	try {
            	JSONObject jsonObj = new JSONObject(jsonStr);
            	version = jsonObj.getString("version");
        	}
        	catch(JSONException e) {
        		Log.d("Exception::", "jsonReaderVer");
        	}
        }
        return version;
    }
    
    public String jsonReaderVerEx(final String srcFile) {
    	String jsonStr = null;
    	String version = "";
		try {
			AssetManager am = getAssets();
			InputStream is = am.open("res/" + srcFile);
			InputStreamReader read = new InputStreamReader(is, "UTF-8");
            BufferedReader bufferedReader = new BufferedReader(read);
            String lineTxt = bufferedReader.readLine();
            String totalLineTxt = "";
            while (lineTxt != null) {
            	totalLineTxt += lineTxt;
            	lineTxt = bufferedReader.readLine();
            }
            jsonStr = totalLineTxt;
            if(null != bufferedReader) {
            	bufferedReader.close();
            }
		} catch (IOException e) {
			e.printStackTrace();
		}
		
        if(null != jsonStr) {
        	try {
            	JSONObject jsonObj = new JSONObject(jsonStr);
            	version = jsonObj.getString("version");
        	}
        	catch(JSONException e) {
        		Log.d("Exception::", "jsonReaderVerEx");
        	}
        }
        return version;
    }
    
    public static void deleteDirWihtFiles(File dir) {
        if (dir.isFile()) {
            dir.delete();
            return;
        }

        if (dir.isDirectory()) {
            File[] subFiles = dir.listFiles();
            if(subFiles == null || 0 == subFiles.length) {
                dir.delete();
                return;
            }

            for(int i = 0; i < subFiles.length; ++i)
            {
                deleteDirWihtFiles(subFiles[i]);
            }
            dir.delete();
        }
    }
    
    public void copyAssetsFile(final String srcFile) {
    	final File fs = new File(getFilesDir(), srcFile);
    	boolean copyFlag = false;
    	if(fs.exists())
    	{
    		Log.d(Constant.LOG_TAG, "fs manifest exist");
    		String version1 = this.jsonReaderVer(fs);
    		String version2 = this.jsonReaderVerEx(srcFile);
    		
        	version1 = version1.replace(".", "");
        	version2 = version2.replace(".", "");	  	
        	if(Integer.parseInt(version1) < Integer.parseInt(version2)) {
        		if(srcFile == "project.manifest") {
                    Log.d(Constant.LOG_TAG, "full pack update");
                    File filesDir = new File(getFilesDir(), "");
                    deleteDirWihtFiles(filesDir);
                    copyFlag = true;
                }else {
                	copyFlag = true;
                }
        	}
        	else
        	{
        		return;
        	}
    	}else {
    		copyFlag = true;
    	}
    	
    	if(copyFlag) {
    		new Thread() {
        		public void run() {
        			Log.d(Constant.LOG_TAG, "manifest copy");
        			try {
        				AssetManager am = getAssets();
        				InputStream is = am.open("res/" + srcFile);
        				FileOutputStream fos = new FileOutputStream(fs);
        				byte[] buffer = new byte[512];
        				int len = 0;
        				while((len=is.read(buffer)) != -1) {
        					fos.write(buffer, 0, len);
        				}
        				fos.close();
        				is.close();
        			} catch (Exception e) {
        				e.printStackTrace();
        			}
        		}
        	}.start();	
    	}
    }
    
    public void startCustomActivity(Intent intent) {
    	startActivityForResult(intent, 0);
    }
    
    @Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		Log.d("ywglzp>>>>>>>>>>>>>>>>>>>>>>>>>", "onNewIntent");
		setIntent(intent);
		if(getIntent() != null){
			getURLParame();
		}
	}
    
    private void getAppVersion(){
    	try {
	    	PackageManager pm = this.getApplicationContext().getPackageManager();  
	        PackageInfo pi = pm.getPackageInfo(this.getApplicationContext().getPackageName(), 0);  
	        appVersion = pi.versionName; 
		} catch (Exception e) {
			e.printStackTrace();
		}
    }

	private void getURLParame(){
	    Intent intent = getIntent();
	    String action = intent.getAction();
	    boolean isValid = Intent.ACTION_VIEW.equals(action);
	    if(null != intent) {
		    Uri deeplink = intent.getData();
		    if(deeplink != null){
		    	String roomid = deeplink.getQueryParameter("roomid");
		    	String replayCode = deeplink.getQueryParameter("replayCode");
		    	String guildID = deeplink.getQueryParameter("guildID");
		    	if(roomid == null) {
		    		roomid = "";
		    	}
		    	if(replayCode == null) {
		    		replayCode = "";
		    	}
		    	if(guildID == null) {
		    		guildID = "";
		    	}
		    	AppActivity.roomid = "roomid="+roomid+"#replayCode="+replayCode+"#guildID="+guildID;
		    }
	    }
	}

	public void checkSystemClipboard() {
		ClipboardManager cbm = (ClipboardManager)getSystemService(Context.CLIPBOARD_SERVICE);
		if(null != cbm.getText())
		{
			String linkUrl = this.getCompleteUrl(cbm.getText().toString());
			if("" != linkUrl)
			{
				String roomid = Uri.parse(linkUrl).getQueryParameter("roomid");
		    	String replayCode = Uri.parse(linkUrl).getQueryParameter("replayCode");
		    	String guildID = Uri.parse(linkUrl).getQueryParameter("guildID");
		    	if(roomid == null) {
		    		roomid = "";
		    	}
		    	if(replayCode == null) {
		    		replayCode = "";
		    	}
		    	if(guildID == null) {
		    		guildID = "";
		    	}
		    	AppActivity.roomid = "roomid="+roomid+"#replayCode="+replayCode+"#guildID="+guildID;
				cbm.setText("");	
			}
		}
	}
	
	public String getCompleteUrl(String text) {
	    Pattern p = Pattern.compile("((http|ftp|https)://)(([a-zA-Z0-9\\._-]+\\.[a-zA-Z]{2,6})|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9\\&%_\\./-~-]*)?", Pattern.CASE_INSENSITIVE);
	    Matcher matcher = p.matcher(text);
	    return matcher.find() ? matcher.group() : "";
	}
 
    private void initLocation(){
        locationClient = new AMapLocationClient(this.getApplicationContext());
        locationClient.setLocationOption(getDefaultOption());  
        locationClient.setLocationListener(locationListener);   
        locationClient.startLocation();  
    }

	AMapLocationListener locationListener = new AMapLocationListener() {  
        @Override  
        public void onLocationChanged(AMapLocation location) {  
            if (location == null) 
            	return;
            
        	if (location.getErrorCode() != 0)
        	{
                Log.e("AmapError","location Error, ErrCode:"  
                    + location.getErrorCode() + ", errInfo:"  
                    + location.getErrorInfo()); 
                locationInfo = "";
                return;
        	}

        	try
            {
                String str = "";
                String detailStr = "";
                str = java.net.URLEncoder.encode(String.valueOf(location.getLatitude()),"utf-8") + "#";
                str = str + java.net.URLEncoder.encode(String.valueOf(location.getLongitude()),"utf-8") + "#";
                detailStr = java.net.URLDecoder.decode(location.getDistrict() + location.getStreet(),"utf-8");
                str = str + detailStr + "#";
                locationInfo = str;
                Log.d("LOC", str);  
            } catch (Exception e)
            {
            	e.printStackTrace();
            }

        } 
         
    };
	
    private AMapLocationClientOption getDefaultOption(){  
        AMapLocationClientOption mOption = new AMapLocationClientOption();  
        mOption.setLocationMode(AMapLocationMode.Hight_Accuracy);
        mOption.setGpsFirst(false);
        mOption.setHttpTimeOut(30000);
        mOption.setInterval(10000);
        mOption.setNeedAddress(true);
        mOption.setOnceLocation(false);
        mOption.setOnceLocationLatest(false);
        AMapLocationClientOption.setLocationProtocol(AMapLocationProtocol.HTTP);
        mOption.setSensorEnable(false);
        mOption.setWifiScan(true);
        mOption.setLocationCacheEnable(true);
        return mOption;  
    }   
	@Override 
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		TalkingDataGA.onResume(this);
		
		Log.d("ywglzp>>>>>>>>>>>>>>>>>>>>>>>>>", "onResume");
	}

	@Override
	protected void onPause() {
		// TODO Auto-generated method stub
		super.onPause();
		TalkingDataGA.onPause(this);
		
		Log.d("ywglzp>>>>>>>>>>>>>>>>>>>>>>>>>", "onPause");
	}

	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();  
		Log.d("ywglzp>>>>>>>>>>>>>>>>>>>>>>>>>", "onDestroy");
		keepScreenOn(this, false);  
		
		if(true == isYvSDKInitSuccess) {
			MessageEventSource.getSingleton().removeLinstener(this);
			YunvaImSdk.getInstance().clearCache();
			YunvaImSdk.getInstance().release();
		}
		
		if(locationClient != null){
            locationClient.onDestroy();
            locationClient = null;
        }
		
		if(mOrientationListener != null) {
			mOrientationListener.disable();	
		}
	} 
	
	@Override
	public void handleMessageEvent(MessageEvent event) {
		RespInfo  msg=event.getMessage();
		Message chatmsg=new Message();
		switch (event.getbCode()) {
		case MessageType.IM_THIRD_LOGIN_RESP:
			break; 
			     
		case MessageType.IM_RECORD_STOP_RESP:			
			ImAudioRecordResp imAudioRecordResp = (ImAudioRecordResp) event.getMessage().getResultBody();
			 
			if (imAudioRecordResp != null){
				String path = imAudioRecordResp.getStrfilepath();
				int time = imAudioRecordResp.getTime();
				  
				String code = path + "#" + time;
				Log.d("d-debug", "IM_RECORD_STOP_RESP:" + code);
				ExtensionApi.callBackOnGLThread(this.bindMsg(ExtensionApi.voice_finish, 1, code));
			}else{
				Toast.makeText(this, "null", Toast.LENGTH_SHORT).show();
			} 
			     
			break; 
			 
		case MessageType.IM_UPLOAD_FILE_RESP:			
			ImUploadFileResp imuploadFileResp = (ImUploadFileResp) event.getMessage().getResultBody();
			
			if (imuploadFileResp != null && 0 != imuploadFileResp.getPercent() ){
				String code = imuploadFileResp.getFileUrl() + "#" + imuploadFileResp.getFileId();
				ExtensionApi.callBackOnGLThread(this.bindMsg(ExtensionApi.voice_get_url, 1, code));
				
			}else{
			}
				 
			break; 
			 
		case MessageType.IM_SPEECH_STOP_RESP:
			break;
		case MessageType.IM_NET_STATE_NOTIFY:
			break;
						
		case MessageType.IM_RECORD_PLAY_PERCENT_NOTIFY:
			break;		
			 
		case MessageType.IM_RECORD_FINISHPLAY_RESP:
			ExtensionApi.callBackOnGLThread(this.bindMsg(ExtensionApi.voice_finish_play, 1, "0"));
			break;
		 
			 
		default:
			break;     
		} 
	}  
	  
    public void initYunvaImSdk(String appid, boolean istest) { 
    	com.yunva.im.sdk.lib.YvLoginInit.context = this;
		com.yunva.im.sdk.lib.YvLoginInit.initApplicationOnCreate(
				this.getApplication(), appid);
		  
    	String path =Environment.getExternalStorageDirectory().toString() + "/yunva_sdk_lite";
    	String voice_path = path + "/voice";
    	boolean m = YunvaImSdk.getInstance().init(this, appid, voice_path, istest);
    	if (m != true) {
    		Log.w("Voice", "YunvaImSdk init fail");  
    	}
    	isYvSDKInitSuccess = m;
    	YunvaImSdk.getInstance().setRecordMaxDuration(20, false);
    	MessageEventSource.getSingleton().addLinstener(	MessageType.IM_THIRD_LOGIN_RESP, this);
    	MessageEventSource.getSingleton().addLinstener(	MessageType.IM_LOGIN_RESP, this);
		MessageEventSource.getSingleton().addLinstener( MessageType.IM_THIRD_LOGIN_RESP, this);
		MessageEventSource.getSingleton().addLinstener( MessageType.IM_RECORD_STOP_RESP, this);
		MessageEventSource.getSingleton().addLinstener( MessageType.IM_UPLOAD_FILE_RESP, this);
		MessageEventSource.getSingleton().addLinstener( MessageType.IM_RECORD_FINISHPLAY_RESP, this);
		MessageEventSource.getSingleton().addLinstener( MessageType.IM_RECORD_PLAY_PERCENT_NOTIFY, this);
    }     
          
    public boolean startAudioRecording() {
    	audioPrepath = audioPrepath + System.currentTimeMillis() + ".amr";
    	File file = new File(audioPrepath);
    	if(file.exists()) {
    		if(file.delete())
    		{
    			try {
    				file.createNewFile();
    			}catch(IOException e) {
    				e.printStackTrace();
    			}
    		}else {
    			try {
    				file.createNewFile();
    			}catch(IOException e) {
    				e.printStackTrace();
    			}
    		}
    	}
    	
    	audioMR = new MediaRecorder();
    	audioMR.setAudioSource(MediaRecorder.AudioSource.MIC);
    	audioMR.setOutputFormat(MediaRecorder.OutputFormat.AMR_NB);
    	audioMR.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);
    	audioMR.setOutputFile(audioPrepath);
    	audioMR.setMaxDuration(20000);
    	
    	try {
    		audioMR.prepare();
    	}catch(IOException e) {
    		e.printStackTrace();
    		return false;
    	}
    	
    	audioMR.start();
    	mpBeginTm = System.currentTimeMillis();
    	return true;
    }
    
    public boolean stopAudioRecording() {
    	if(null != audioMR) {
    		mpEndTm = System.currentTimeMillis();
    		try {
    			audioMR.stop();
    		}
    		catch(IllegalStateException e) {
    			audioMR = null;
    			audioMR = new MediaRecorder();
    		}
    		audioMR.reset();
    		audioMR.release();
    		audioMR = null;
    	}
    	return true;
    }
    
    public void playAudioRecording(final String extraUrl) {
    	audioMP = new MediaPlayer();
    	try {
    		if("" != extraUrl) {
    			audioMP.reset();
    			audioMP.setDataSource(extraUrl);
    			audioMP.setAudioStreamType(AudioManager.STREAM_MUSIC);
    			audioMP.prepareAsync();
    			audioMP.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
					
					@Override
					public void onPrepared(MediaPlayer mp) {
						audioMP.start();
					}
				});
    			audioMP.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
					
					@Override
					public void onCompletion(MediaPlayer mp) {
						audioMP.release();
			    		audioMP = null;
						ExtensionApi.callBackOnGLThread(ExtensionApi.appActivity.bindMsg(ExtensionApi.voice_finish_play, 1, "0"));
					}
				});
    		}
    		else {
    			audioMP.setDataSource(audioPrepath);
    			audioMP.prepare();
    			audioMP.start();
    		}
    		audioMP.setVolume(1.0f, 1.0f);
    	}catch(IOException e) {
    		e.printStackTrace();
    	}
    }
    
    public void stopPlayAudioRecording() {
    	if(null != audioMP) {
    		
    		try {
    			audioMP.stop();
    		}
    		catch(IllegalStateException e) {
    			audioMP = null;
    			audioMP = new MediaPlayer();
    		}
    		
    		audioMP.release();
    		audioMP = null;
    	}
    }
    
    public boolean voiceStart() { 
    	boolean start = false;
    	if(is8SDK) {
    		start = this.startAudioRecording();
    	}else {
        	start = YunvaImSdk.getInstance().startAudioRecord("", "lite", (byte)0);
    	}
    	if (!start){
    		Log.d("d-debug", "voiceStart failed");
    	} 
    	return start;
    }      
           
    public boolean voiceStop() {
    	if(is8SDK) {
        	this.stopAudioRecording();
        	long duration = mpEndTm - mpBeginTm;
    		String code = audioPrepath + "#" + duration;
    		ExtensionApi.callBackOnGLThread(this.bindMsg(ExtensionApi.voice_finish, 1, code));	
    	}
    	else
    	{
        	boolean retAutio = YunvaImSdk.getInstance().stopPlayAudio();
        	boolean retRecord = YunvaImSdk.getInstance().stopAudioRecord();	
    	}
    	audioPrepath =Environment.getExternalStorageDirectory().toString() + "/amr_";
    	return true;
    }   
    
    public void voiceupload(String path, String time) {
    	YunvaImSdk.getInstance().uploadFile(path, time);
    }
      
    public void voicePlay(String url) {
    	if(is8SDK) {
    		Log.d("d-voicePlay", "is8SDK");
        	this.stopPlayAudioRecording();
        	this.playAudioRecording(url);
    	}else {
    		Log.d("d-voicePlay", "not is8SDK");
        	YunvaImSdk.getInstance().stopPlayAudio();
        	YunvaImSdk.getInstance().playAudio(url, "", "");
    	}
    }
    
    public void stopAllVoice() {
    	if(is8SDK) {
    		Log.d("d-stopAllVoice", "is8SDK");
        	this.stopPlayAudioRecording();
    	}else {
    		Log.d("d-stopAllVoice", "not is8SDK");
        	YunvaImSdk.getInstance().stopPlayAudio();
    	}
    }
    
    public int getVoiceDuration(String url) {
    	MediaPlayer player = new MediaPlayer(); 
        try {
            player.setDataSource(url);
            player.prepare(); 
        } catch (IOException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
        int duration= player.getDuration();
        Log.d("getVoiceDuration", "### duration: " + duration);
        player.release();
        return duration;
    }
    
    public void yayaLogin(String uid, String unick) {
    	String tt = "{\"uid\":\""+ uid + "\",\"nickname\"" + unick + "\"}";
    	YunvaImSdk.getInstance().Binding(tt, "1", null);
    }
    
    public String bindMsg(String type, int status, String code) {
    	return "{\"type\":\"" + type + "\", \"status\":" + status +", \"code\":\""+ code + "\"}";
    }
    
    public void sendError(String log) {
    }
    
    public void getBattery(){
    	registerReceiver(mBatInfoReveiver, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
    }
    
    public void onBatteryInfoReceiver(int intLevel, int intScale) {  
    	String code = intLevel+"";  
	    unregisterReceiver(mBatInfoReveiver);
    	ExtensionApi.callBackOnGLThread(this.bindMsg(ExtensionApi.getBattery, 1, code)); 
    };  
    
    public void getClipboradText() {  
    	ClipboardManager cm = (ClipboardManager) this.getSystemService(Context.CLIPBOARD_SERVICE);
        String copyText = "";
        if(cm.hasText()) {
        	copyText = cm.getText().toString();
        	if(copyText.indexOf("吆玩") != -1) {
        		String pattern = "房号\\\\s+|\\\\S+【\\\\d+】";
        		Pattern r = Pattern.compile(pattern);
        		Matcher m = r.matcher(copyText);
        		if (m.find()) {
        			copyText = m.group(0);
        		}else {
        			pattern = "回放码:\\\\s+|\\\\S+\\\\d+";
        			r = Pattern.compile(pattern);
        			m = r.matcher(copyText);
        			if (m.find()) {
            			copyText = m.group(0);
        			}
        		}
        		cm.setText("");
                Log.i(Constant.LOG_TAG, "call getClipboardText, copyText = " + copyText);
                ExtensionApi.callBackOnGLThread(this.bindMsg(ExtensionApi.getClipboard, 1, copyText)); 
        	}
        }
    };

    public void getNet() {
        ConnectivityManager cm = (ConnectivityManager) this
                .getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo networkINfo = cm.getActiveNetworkInfo();
        if (networkINfo != null
                && networkINfo.getType() == ConnectivityManager.TYPE_WIFI) {
        	ExtensionApi.callBackOnGLThread(this.bindMsg(ExtensionApi.getNetType, 1, "0")); 
        }else if (networkINfo != null
            && networkINfo.getType() == ConnectivityManager.TYPE_MOBILE) {
    		String subTypeName = networkINfo.getSubtypeName();
    		if(subTypeName.equals("GPRS") || subTypeName.equals("EDGE") || subTypeName.equals("CDMA") || subTypeName.equals("1xRTT") 
    		|| subTypeName.equals("IDEN")){
    			ExtensionApi.callBackOnGLThread(this.bindMsg(ExtensionApi.getNetType, 1, "1")); 
    		};
    		if(subTypeName.equals("UMTS")|| subTypeName.equals("EVDO_0") || subTypeName.equals("EVDO_A") || subTypeName.equals("HSDPA")
            || subTypeName.equals("HSUPA")|| subTypeName.equals("HSPA")|| subTypeName.equals("EVDO_B") || subTypeName.equals("EHRPD")
            || subTypeName.equals("HSPAP")){
    			ExtensionApi.callBackOnGLThread(this.bindMsg(ExtensionApi.getNetType, 1, "2")); 
    		};
    		if(subTypeName.equals("LTE")){
    			ExtensionApi.callBackOnGLThread(this.bindMsg(ExtensionApi.getNetType, 1, "3")); 
    		};
        }else{
        	ExtensionApi.callBackOnGLThread(this.bindMsg(ExtensionApi.getNetType, 1, "-1")); 
        }  
    }
      
    public void getLocation() {  
        int status = 1;
        if (locationInfo == "")
        	status = -1;
        String code = locationInfo;
        Log.d("getLocation-----------------:", code);
        ExtensionApi.callBackOnGLThread(this.bindMsg(ExtensionApi.getLocation, status, code));
    }
    
    public void keepScreenOn(Context context, boolean on) {  
        if (on) {  
            PowerManager pm = (PowerManager) context.getSystemService(Context.POWER_SERVICE);  
            wakeLock = pm.newWakeLock(PowerManager.SCREEN_BRIGHT_WAKE_LOCK | PowerManager.ON_AFTER_RELEASE, "==KeepScreenOn==");  
            wakeLock.acquire();  
        } else {  
            if (wakeLock != null) {  
                wakeLock.release();  
                wakeLock = null;  
            }  
        }  
    }  
    
	public void DownloadApk(final String url, final String save_path) {
		new Thread(new Runnable() {
			@Override
			public void run() {
				InstallApk(DownLoadFile(url, save_path));
			}
		}).start();
	} 
 
	protected File DownLoadFile(final String httpUrl, final String save_path) {
		// TODO Auto-generated method stub
		final String fileName = "updata.apk";
        File tmpFile = new File("/sdcard/"+this.getPackageName());
        if (!tmpFile.exists()) {
                tmpFile.mkdir();
        }
        final File file = new File(tmpFile + "/" + fileName);

		try {
			URL url = new URL(httpUrl);
			try {
				HttpURLConnection conn = (HttpURLConnection) url
						.openConnection();
				InputStream is = conn.getInputStream();
				if (is == null) {
					throw new RuntimeException("");
				}
				int filesize = conn.getContentLength();
				if (filesize <= 0) {
					throw new RuntimeException("");
				}
				FileOutputStream fos = new FileOutputStream(file);
				byte[] buf = new byte[512];
				conn.connect();
				double count = 0;
				if (conn.getResponseCode() >= 400) {
					ExtensionApi.callBackOnGLThread(this.bindMsg(ExtensionApi.downLoadApk, 3, ""));
				} else {
					int numread;
					int old_persent = 0;
					while ((numread = is.read(buf)) != -1) {
						fos.write(buf, 0, numread);
						count += numread;
						int persent = (int) (((float) (count) / (float) (filesize)) * 100);
						if (old_persent != persent) {
							ExtensionApi.callBackOnGLThread(this.bindMsg(ExtensionApi.downLoadApk, 1, String.valueOf(persent))); 
							old_persent = persent;
						} 

						if (persent == 100) {
							ExtensionApi.callBackOnGLThread(this.bindMsg(ExtensionApi.downLoadApk, 2, ""));
						} 
					}
					conn.disconnect();
					fos.close();
					is.close();
				}
			} catch (IOException e) {
				e.printStackTrace();
				ExtensionApi.callBackOnGLThread(this.bindMsg(ExtensionApi.downLoadApk, -1, "")); 
			}
		} catch (MalformedURLException e) {
			e.printStackTrace();
			ExtensionApi.callBackOnGLThread(this.bindMsg(ExtensionApi.downLoadApk, -1, "")); 
		}

		return file;
	}

	private void InstallApk(File file) {
		Intent intent = new Intent();
		intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		intent.setAction(android.content.Intent.ACTION_VIEW);
		intent.setDataAndType(Uri.fromFile(file),
				"application/vnd.android.package-archive");
		startActivity(intent);
	}
	
	public void requestWritePermission(){
	    if(ActivityCompat.checkSelfPermission(this,Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED){
	    	ActivityCompat.requestPermissions(this,new String[]{Manifest.permission.READ_EXTERNAL_STORAGE,
	                Manifest.permission.WRITE_EXTERNAL_STORAGE},0x01);
	    }
	}
}   
                                     