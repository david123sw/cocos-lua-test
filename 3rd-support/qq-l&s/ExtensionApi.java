package org.extension;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

import org.game.AppActivity;
import org.game.Constant;
import org.game.VibratorUtil;
import org.pay.AlipayFunc;
import org.pay.WxpayFunc;
import org.weixin.WeixinShare;
import org.weixin.WeixinToken;
import org.ynlib.utils.Utils;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import com.tencent.connect.share.QQShare;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;
import com.tencent.tauth.IUiListener;
import com.tencent.tauth.Tencent;
import com.tencent.tauth.UiError;
import com.sevenjzc.ywglzp.qqapi.QQBaseUIListener;
import com.sevenjzc.ywglzp.qqapi.QQShareActivity;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.SystemClock;
import android.net.Uri;
import android.widget.Toast;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.provider.MediaStore;
import android.provider.Settings;
import android.provider.MediaStore.MediaColumns;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.database.Cursor;
import android.app.AlertDialog;
import android.content.ComponentName;
import android.text.ClipboardManager;
import android.text.TextUtils;
import android.util.Log;

/**
 * 
 * @author yangyi
 */ 
public class ExtensionApi {
	public final static String TYPE_WEIXIN_TOKEN = "weixin_token";
    public final static String TYPE_WEIXIN_SHARE = "weixin_share";
    public final static String TYPE_WEIXIN_PAY = "weixin_pay";
    public final static String TYPE_ALI_PAY = "ali_pay";
    public final static String TYPE_QQ_LOGIN = "qq_login";
    public final static String TYPE_QQ_SHARE = "qq_share";
    
    public final static String voice_get_url 		= "voice_url";
    public final static String voice_finish 		= "voice_finish";
    public final static String voice_finish_play 	= "voice_finishplay";
    public final static String voice_init        	= "voice_init";
    
    public final static String close_socket        	= "close_socket";

    public final static String getBattery       	= "getBattery";
    public final static String getNetType           = "getNetType";
    public final static String getLocation          = "location";
    public final static String getClipboard			= "getClipboard";
    
    public final static String downLoadApk          = "apkDownload";
    public final static String urlOpen              = "urlOpen";
	/**
	 * 
	 */
	public static AppActivity appActivity = null;
	
	private static boolean isServerSideLogin = false;
	
	/**
	 * 
	 * @param jsonStr
	 */
	public static void callBackOnGLThread(final String jsonStr) {
		Log.i(Constant.LOG_TAG, jsonStr);
		appActivity.runOnGLThread(new Runnable() {
            @Override
            public void run() {
                Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("extension_callback", jsonStr);
            }
        });
	}
	
	/**
	 * 
	 */
	public static void test() {
		appActivity.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				AlertDialog alertDialog = new AlertDialog.Builder(appActivity).create();
				alertDialog.setTitle("title");
				alertDialog.setMessage("message");
				alertDialog.show();
			}
		});
	}
	 
	public static void getAppDetailSettingIntent(){
        Intent intent = new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
//        if(Build.VERSION.SDK_INT >= 9){
//            intent.setAction("android.settings.APPLICATION_DETAILS_SETTINGS");
//            intent.setData(Uri.fromParts("package", appActivity.getApplicationContext().getPackageName(), null));
//        } else if(Build.VERSION.SDK_INT <= 8){
//            intent.setAction(Intent.ACTION_VIEW);
//            intent.setClassName("com.android.settings","com.android.settings.InstalledAppDetails");
//            intent.putExtra("com.android.settings.ApplicationPkgName", appActivity.getApplicationContext().getPackageName());
//        }
        appActivity.startCustomActivity(intent);
    }
	
	/**
	 * 
	 */
	public static String getDeviceId() {
		return Utils.getDeviceId(appActivity);
	}

    public static String getAppVersion(){
    	return AppActivity.appVersion;
    }
    public static String getRoomId(){
        Log.e(Constant.LOG_TAG, "====JSXXX====roomid:"+ AppActivity.roomid);
        if(AppActivity.roomid != "")
        {
            String roomid = AppActivity.roomid;
            AppActivity.roomid = ""; 
            return roomid;
        }
        else
        {
    		Log.i(Constant.LOG_TAG, "call getRoomId when open");
    		appActivity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                	appActivity.checkSystemClipboard();
                }
            });
        }
        return AppActivity.roomid; 
    }
	 
	/**
	 * 
	 */
	public static void getWeixinToken(final String weixinId) {
		Log.i(Constant.LOG_TAG, "call getWeixinToken:" + weixinId);
		appActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() { 
                new WeixinToken().getWeiXinToken(weixinId);
            }
        });   
	}
    
    static IUiListener qqShareListener = new IUiListener() {
        @Override
        public void onCancel() {
        	Log.i("QQ_SHARE", "onCancel ");
        	appActivity.finishQQShare("cancel", 1 + "");
        }
        @Override
        public void onComplete(Object response) {
    		Log.d("QQ_SHARE", "onComplete " + response.toString());
    		JSONObject resp = (JSONObject)response;
    		try {
        		appActivity.finishQQShare("complete", resp.getString("ret"));
    		}
    		catch(Exception e) {}
        }
        @Override
        public void onError(UiError e) {
        	Log.i("QQ_SHARE", "onError ");
        	appActivity.finishQQShare("error", 1 + "");
        }
    };
    
	public static void qqShareMsg(final String shareText, final String shareImage, final String shareTitle, final String shareDescription, final String shareUrl, final String sharePreviewUrl, final String appIconUrl) {
		Log.i("QQ_SHARE", "qqShareMsg shareText " + shareText);
		Log.i("QQ_SHARE", "qqShareMsg shareImage " + shareImage);
		Log.i("QQ_SHARE", "qqShareMsg shareTitle " + shareTitle);
		Log.i("QQ_SHARE", "qqShareMsg shareDescription " + shareDescription);
		Log.i("QQ_SHARE", "qqShareMsg shareUrl " + shareUrl);
		Log.i("QQ_SHARE", "qqShareMsg sharePreviewUrl " + sharePreviewUrl);
		Log.i("QQ_SHARE", "qqShareMsg appIconUrl " + appIconUrl);
				
		final Bundle params = new Bundle();
		if(!shareText.equals("")) {
	        params.putInt(QQShare.SHARE_TO_QQ_KEY_TYPE, QQShare.SHARE_TO_QQ_TYPE_DEFAULT);
	        params.putString(QQShare.SHARE_TO_QQ_TITLE, shareText);
	        params.putString(QQShare.SHARE_TO_QQ_IMAGE_URL, sharePreviewUrl);
	        params.putString(QQShare.SHARE_TO_QQ_TARGET_URL, appIconUrl);
		}
		else if(!shareImage.equals("")) {
			File fs = new File(shareImage);
			if(fs.exists()) {
				Log.i("QQ_SHARE", "shareImage exist " + fs.length() + " name " + fs.getName());
				appActivity.requestWritePermission();
				params.putInt(QQShare.SHARE_TO_QQ_KEY_TYPE, QQShare.SHARE_TO_QQ_TYPE_IMAGE);
				try {
					String imgUrl = MediaStore.Images.Media.insertImage(appActivity.getContentResolver(), shareImage, fs.getName(), null);
					Uri imgUri = Uri.parse(imgUrl);
					String imgPath;
					String[] imgPathCol = {MediaColumns.DATA};
					Cursor cursor = appActivity.getContentResolver().query(imgUri, imgPathCol, null, null, null);
					cursor.moveToFirst();
					int colIndex = cursor.getColumnIndex(imgPathCol[0]);
					imgPath = cursor.getString(colIndex);
					cursor.close();
					params.putString(QQShare.SHARE_TO_QQ_IMAGE_LOCAL_URL, imgPath);
					AppActivity.mTencent.shareToQQ(appActivity, params, qqShareListener);
					return;
				}catch(FileNotFoundException e) {
					e.printStackTrace();
				}
			}else {
				Log.i("QQ_SHARE", "shareImage not exist ");
				return;
			}
		}
		else if(!shareUrl.equals("")) {
			params.putInt(QQShare.SHARE_TO_QQ_KEY_TYPE, QQShare.SHARE_TO_QQ_TYPE_DEFAULT);
	        params.putString(QQShare.SHARE_TO_QQ_TITLE, shareTitle);
	        params.putString(QQShare.SHARE_TO_QQ_SUMMARY, shareDescription);
	        params.putString(QQShare.SHARE_TO_QQ_IMAGE_URL, sharePreviewUrl);
	        params.putString(QQShare.SHARE_TO_QQ_TARGET_URL, shareUrl);
		}
        AppActivity.mTencent.shareToQQ(appActivity, params, qqShareListener);
	}
	
	public static void requestQQLogin(final String qqAPPID) {
		Log.i("QQ_LOGIN", "call requestQQLogin " + qqAPPID);
		appActivity.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				if(null == AppActivity.mTencent) {
					AppActivity.mTencent = Tencent.createInstance(qqAPPID, appActivity.getApplicationContext());
				}
				String cachedToken = AppActivity.mTencent.getAccessToken();
				String cachedOpenId = AppActivity.mTencent.getOpenId();
				String cachedExpiresIn = AppActivity.mTencent.getExpiresIn() + "";
		        if (!TextUtils.isEmpty(cachedToken) && !TextUtils.isEmpty(cachedOpenId) && !TextUtils.isEmpty(cachedExpiresIn)) {
		        	AppActivity.mTencent.setAccessToken(cachedToken, cachedExpiresIn.toString());
		        	AppActivity.mTencent.setOpenId(cachedOpenId);
		        	appActivity.updateUserInfo();
		        }
		        else {
					if(!AppActivity.mTencent.isSessionValid()) {
						AppActivity.mTencent.login(appActivity, "get_user_info,get_simple_userinfo,add_t", new QQBaseUIListener(appActivity));
						isServerSideLogin = false;
						Log.d("SDKQQAgentPref", "FirstLaunch_SDK1:" + SystemClock.elapsedRealtime());
					}
		        }
			}
		});
	}
	
	/**     
	 * 
	 */
	public static void alipay(final String orderInfo) {
		Log.i(Constant.LOG_TAG, "call alipay");
		appActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
            	new AlipayFunc().startPay(orderInfo);
            }
        });
	}    
	/**
	 * 
	 */
	public static void vibrator(){
		VibratorUtil.Vibrate(appActivity, 100); 		
	}
	
	/** 
	 * 
	 * @return
	 */
	public static boolean checkInstallWeixin() {
		try {
			Log.i(Constant.LOG_TAG, "call WxSimpleFunc begin");
			String weixinId = Utils.getMetaData(ExtensionApi.appActivity, Constant.WX_APPID_KEY);
			IWXAPI api = WXAPIFactory.createWXAPI(ExtensionApi.appActivity, weixinId, false);
			if(api.isWXAppInstalled()) {
				return true;
			}else {
				return false;
			}
		} catch (Exception e) {
			Log.e(Constant.LOG_TAG, e.toString(), e);
		}
		return false;
	}
	 
	/**
	 * 
	 */
	public static void weixinPay(final String orderInfo) {
		Log.i(Constant.LOG_TAG, "call weixinPay");
		appActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
            	new WxpayFunc().startPay(orderInfo);
            }
        });
	} 
	 
	/** 
	 * 
	 */
	public static void weixinShareImg(final String shareTo, final String filePath) {
		Log.i(Constant.LOG_TAG, "call weixinPay");
		
		appActivity.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				new WeixinShare().shareImg(shareTo, filePath);
			}
		});
	}
	 
	/**
	 * 
	 */
	public static void weixinShareApp(
			final String shareTo, 
			final String title, 
			final String message,   
			final String url
	) {
		Log.i(Constant.LOG_TAG, "call weixinShareApp" + ",shareTo=" + shareTo + ",title=" + title + ",message=" + message +",url="+url);
		appActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
            	new WeixinShare().shareAppInfo(shareTo, title, message, url);
            }
        });
	}
	
	public static void openWechat() {
		Intent intent = new Intent(Intent.ACTION_MAIN);
		intent.addCategory(Intent.CATEGORY_LAUNCHER);
		intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		
		ComponentName cmp = new ComponentName("com.tencent.mm","com.tencent.mm.ui.LauncherUI");
		intent.setComponent(cmp);
        appActivity.startActivityForResult(intent, 0);
	}
	
     
    /**
     * 
     * @return
     */
    public static boolean isNetworkAvailable() {
    	return Utils.isNetworkAvailable(appActivity);
    }
    
    /** 
    *    
    */
    public static void voiceInit(String appid) {    	
    	appActivity.initYunvaImSdk(appid, false);
    }
      
    /**  
    *    
    */    
    public static void yayaLogin(String uid, String unick) {   
    	appActivity.yayaLogin(uid, unick);
    }
    
    /**  
     * 
     */
    public static boolean voiceStart() {   
    	return appActivity.voiceStart();
    }
    
    /**
     * 
     */
    public static void voiceStop() {   
    	appActivity.voiceStop();
    } 
       
    /**
     * 
     */
    public static void voiceupload(String path, String time) {   
    	appActivity.voiceupload(path, time);
    }
    
    /**
     * 
     */
    public static void voicePlay(String url) {
    	appActivity.voicePlay(url);
    }    
    
    /**
     * 
     * @return
     */
    public static void SendError(String log) {
    	appActivity.sendError(log);
    }
    
    /**
     * 
     * @return
     */
    public static void GetBattery() {
    	appActivity.getBattery();
    }
    
    /**
     * 
     * @return
     */
    public static void GetNetType() {
    	appActivity.getNet();
    }
    
    /**
     * 
     * @return 
     */
    public static void GetLocation() {
    	Log.e("enter getlocation", "test");
    	appActivity.getLocation();
    }
    
    /**
     * 
     * @return
     */
    public static void downloadApk(String url, String writablePath) {
    	appActivity.DownloadApk(url, writablePath);
    }
    
    public static void copyTextToClipboard(final String str) {
        Runnable runnable = new Runnable() {
            public void run() {
            	ClipboardManager cm = (ClipboardManager) appActivity.getSystemService(Context.CLIPBOARD_SERVICE);
                cm.setText(str);
            }
        };
        appActivity.runOnUiThread(runnable);
    }
    
    public static void getClipboardText() {
        Runnable runnable = new Runnable() {
            public void run() {
            	appActivity.getClipboradText();
            }
        };
        appActivity.runOnUiThread(runnable);
//    	ClipboardManager cm = (ClipboardManager) appActivity.getSystemService(Context.CLIPBOARD_SERVICE);
//        String copyText = (String) cm.getText();
//        Log.i(Constant.LOG_TAG, "call getClipboardText, copyText = " + copyText);
//        return copyText;
    }
    
	public static void copyImageToGallery(final String srcFilePath) {
		appActivity.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				String galleryPath= Environment.getExternalStorageDirectory()
		                + File.separator + Environment.DIRECTORY_DCIM
		                +File.separator+"Camera"+File.separator;
		    	File file = null;
		    	File srcFile = null;
		    	FileOutputStream outStream = null;
		    	FileInputStream inStream = null;
		    	String srcFileName = "";
		    	try {
		    		srcFile = new File(srcFilePath);
		    		if(srcFile.exists()) {
		    			srcFileName = srcFile.getName();
		    		}
		            file = new File(galleryPath, srcFileName);
		            outStream = new FileOutputStream(file);
		            inStream = new FileInputStream(srcFile);
		            int byteread = 0;
		            byte[] buffer = new byte[1024*20];
		            while((byteread = inStream.read(buffer)) != -1){
		            	outStream.write(buffer, 0, byteread);
		            }
		            inStream.close();
		            outStream.close();
		            
		        } catch (Exception e) {
		            e.getStackTrace();
		        } finally {
		            try {
		                if (outStream != null) {
		                    outStream.close();
		                }
		                if (inStream != null) {
		                	inStream.close();
		                }
		            } catch (IOException e) {
		                e.printStackTrace();
		            }
		        }
		    	try {
					MediaStore.Images.Media.insertImage(appActivity.getContentResolver(), galleryPath, srcFileName, null);
				} catch (FileNotFoundException e) {
					e.printStackTrace();
				}
		        Intent intent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
		        Uri uri = Uri.fromFile(file);
		        intent.setData(uri);
		        appActivity.sendBroadcast(intent);
			}
		});
    	
	}
}
