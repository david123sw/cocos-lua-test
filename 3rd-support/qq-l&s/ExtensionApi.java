package org.extension;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.lang.reflect.Method;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

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
// import com.tencent.mm.sdk.openapi.IWXAPI;
// import com.tencent.mm.sdk.openapi.WXAPIFactory;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;
import com.tencent.mm.opensdk.modelbiz.WXLaunchMiniProgram;

import com.tencent.tauth.IUiListener;
import com.tencent.tauth.Tencent;
import com.tencent.tauth.UiError;
import com.sevenjzc.cnklds.qqapi.QQBaseUIListener;
import com.sevenjzc.cnklds.qqapi.QQShareActivity;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.BatteryManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.SystemClock;
import android.net.Uri;
import android.widget.Toast;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.provider.ContactsContract;
import android.provider.MediaStore;
import android.provider.Settings;
import android.provider.MediaStore.MediaColumns;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.content.res.Resources;
import android.database.Cursor;
import android.annotation.TargetApi;
import android.app.AlertDialog;
import android.content.ComponentName;
import android.content.ContentResolver;
import android.text.ClipboardManager;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Display;
import android.view.ViewConfiguration;
import android.view.WindowManager;
import android.view.View;
import android.view.ViewGroup;
import android.telephony.TelephonyManager;

import com.android.dingtalk.share.ddsharemodule.DDShareApiFactory;
import com.android.dingtalk.share.ddsharemodule.IDDShareApi;
import com.android.dingtalk.share.ddsharemodule.message.DDImageMessage;
import com.android.dingtalk.share.ddsharemodule.message.DDMediaMessage;
import com.android.dingtalk.share.ddsharemodule.message.DDTextMessage;
import com.android.dingtalk.share.ddsharemodule.message.DDWebpageMessage;
import com.android.dingtalk.share.ddsharemodule.message.DDZhiFuBaoMesseage;
import com.android.dingtalk.share.ddsharemodule.message.SendAuth;
import com.android.dingtalk.share.ddsharemodule.message.SendMessageToDD;
import com.android.dingtalk.share.ddsharemodule.plugin.SignatureCheck;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Point;

import org.xianliao.im.sdk.api.ISGAPI;
import org.xianliao.im.sdk.api.SGAPIFactory;
import org.xianliao.im.sdk.constants.SGConstants;
import org.xianliao.im.sdk.modelmsg.SGGameObject;
import org.xianliao.im.sdk.modelmsg.SGImageObject;
import org.xianliao.im.sdk.modelmsg.SGMediaMessage;
import org.xianliao.im.sdk.modelmsg.SGTextObject;
import org.xianliao.im.sdk.modelmsg.SendMessageToSG;

import com.alipay.share.sdk.openapi.APAPIFactory;
import com.alipay.share.sdk.openapi.APImageObject;
import com.alipay.share.sdk.openapi.APMediaMessage;
import com.alipay.share.sdk.openapi.APTextObject;
import com.alipay.share.sdk.openapi.APWebPageObject;
import com.alipay.share.sdk.openapi.IAPApi;
import com.alipay.share.sdk.openapi.SendMessageToZFB;

import com.sevenjzc.cnklds.R;
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
    public final static String TYPE_SCREEN_HORIZONTAL_FLIP = "horizontal_flip";
    public final static String TYPE_POWER_CHARGING_STATUS = "power_charging_status";
    
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
		Log.d(Constant.LOG_TAG, jsonStr);
		appActivity.runOnGLThread(new Runnable() {
            @Override
            public void run() {
                Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("extension_callback", jsonStr);
            }
        });
	}
	
	/**
	 *Ignored
	 */
	public static void test(final String msg) {
		appActivity.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				AlertDialog alertDialog = new AlertDialog.Builder(appActivity).create();
				alertDialog.setTitle("Alert");
				alertDialog.setMessage(msg);
				alertDialog.show();
			}
		});
	}
	
	public static void setRequestedOrientation(final String so) {
		appActivity.setRequestedOrientation(so);
	}
	
	public static void openOrientationChecker() {
		appActivity.initOrientationChecker();
	}
	
	public static boolean isEmulator() {
		String[] known_pipes={
			"/dev/socket/qemud",
			"/dev/qemu_pipe"
		};
	
		String[] known_qemu_drivers = {
			"goldfish"
		};
	
		String[] known_files = {
			// vbox模拟器文件
            "/data/youwave_id",
            "/dev/vboxguest",
            "/dev/vboxuser",
            "/mnt/prebundledapps/bluestacks.prop.orig",
            "/mnt/prebundledapps/propfiles/ics.bluestacks.prop.note",
            "/mnt/prebundledapps/propfiles/ics.bluestacks.prop.s2",
            "/mnt/prebundledapps/propfiles/ics.bluestacks.prop.s3",
            "/mnt/sdcard/bstfolder/InputMapper/com.bluestacks.appmart.cfg",
            "/mnt/sdcard/buildroid-gapps-ics-20120317-signed.tgz",
            "/mnt/sdcard/windows/InputMapper/com.bluestacks.appmart.cfg",
            "/proc/irq/9/vboxguest",
            "/sys/bus/pci/drivers/vboxguest",
            "/sys/bus/pci/drivers/vboxguest/0000:00:04.0",
            "/sys/bus/pci/drivers/vboxguest/bind",
            "/sys/bus/pci/drivers/vboxguest/module",
            "/sys/bus/pci/drivers/vboxguest/new_id",
            "/sys/bus/pci/drivers/vboxguest/remove_id",
            "/sys/bus/pci/drivers/vboxguest/uevent",
            "/sys/bus/pci/drivers/vboxguest/unbind",
            "/sys/bus/platform/drivers/qemu_pipe",
            "/sys/bus/platform/drivers/qemu_trace",
            "/sys/class/bdi/vboxsf-c",
            "/sys/class/misc/vboxguest",
            "/sys/class/misc/vboxuser",
            "/sys/devices/virtual/bdi/vboxsf-c",
            "/sys/devices/virtual/misc/vboxguest",
            "/sys/devices/virtual/misc/vboxguest/dev",
            "/sys/devices/virtual/misc/vboxguest/power",
            "/sys/devices/virtual/misc/vboxguest/subsystem",
            "/sys/devices/virtual/misc/vboxguest/uevent",
            "/sys/devices/virtual/misc/vboxuser",
            "/sys/devices/virtual/misc/vboxuser/dev",
            "/sys/devices/virtual/misc/vboxuser/power",
            "/sys/devices/virtual/misc/vboxuser/subsystem",
            "/sys/devices/virtual/misc/vboxuser/uevent",
            "/sys/module/vboxguest",
            "/sys/module/vboxguest/coresize",
            "/sys/module/vboxguest/drivers",
            "/sys/module/vboxguest/drivers/pci:vboxguest",
            "/sys/module/vboxguest/holders",
            "/sys/module/vboxguest/holders/vboxsf",
            "/sys/module/vboxguest/initsize",
            "/sys/module/vboxguest/initstate",
            "/sys/module/vboxguest/notes",
            "/sys/module/vboxguest/notes/.note.gnu.build-id",
            "/sys/module/vboxguest/parameters",
            "/sys/module/vboxguest/parameters/log",
            "/sys/module/vboxguest/parameters/log_dest",
            "/sys/module/vboxguest/parameters/log_flags",
            "/sys/module/vboxguest/refcnt",
            "/sys/module/vboxguest/sections",
            "/sys/module/vboxguest/sections/.altinstructions",
            "/sys/module/vboxguest/sections/.altinstr_replacement",
            "/sys/module/vboxguest/sections/.bss",
            "/sys/module/vboxguest/sections/.data",
            "/sys/module/vboxguest/sections/.devinit.data",
            "/sys/module/vboxguest/sections/.exit.text",
            "/sys/module/vboxguest/sections/.fixup",
            "/sys/module/vboxguest/sections/.gnu.linkonce.this_module",
            "/sys/module/vboxguest/sections/.init.text",
            "/sys/module/vboxguest/sections/.note.gnu.build-id",
            "/sys/module/vboxguest/sections/.rodata",
            "/sys/module/vboxguest/sections/.rodata.str1.1",
            "/sys/module/vboxguest/sections/.smp_locks",
            "/sys/module/vboxguest/sections/.strtab",
            "/sys/module/vboxguest/sections/.symtab",
            "/sys/module/vboxguest/sections/.text",
            "/sys/module/vboxguest/sections/__ex_table",
            "/sys/module/vboxguest/sections/__ksymtab",
            "/sys/module/vboxguest/sections/__ksymtab_strings",
            "/sys/module/vboxguest/sections/__param",
            "/sys/module/vboxguest/srcversion",
            "/sys/module/vboxguest/taint",
            "/sys/module/vboxguest/uevent",
            "/sys/module/vboxguest/version",
            "/sys/module/vboxsf",
            "/sys/module/vboxsf/coresize",
            "/sys/module/vboxsf/holders",
            "/sys/module/vboxsf/initsize",
            "/sys/module/vboxsf/initstate",
            "/sys/module/vboxsf/notes",
            "/sys/module/vboxsf/notes/.note.gnu.build-id",
            "/sys/module/vboxsf/refcnt",
            "/sys/module/vboxsf/sections",
            "/sys/module/vboxsf/sections/.bss",
            "/sys/module/vboxsf/sections/.data",
            "/sys/module/vboxsf/sections/.exit.text",
            "/sys/module/vboxsf/sections/.gnu.linkonce.this_module",
            "/sys/module/vboxsf/sections/.init.text",
            "/sys/module/vboxsf/sections/.note.gnu.build-id",
            "/sys/module/vboxsf/sections/.rodata",
            "/sys/module/vboxsf/sections/.rodata.str1.1",
            "/sys/module/vboxsf/sections/.smp_locks",
            "/sys/module/vboxsf/sections/.strtab",
            "/sys/module/vboxsf/sections/.symtab",
            "/sys/module/vboxsf/sections/.text",
            "/sys/module/vboxsf/sections/__bug_table",
            "/sys/module/vboxsf/sections/__param",
            "/sys/module/vboxsf/srcversion",
            "/sys/module/vboxsf/taint",
            "/sys/module/vboxsf/uevent",
            "/sys/module/vboxsf/version",
            "/sys/module/vboxvideo",
            "/sys/module/vboxvideo/coresize",
            "/sys/module/vboxvideo/holders",
            "/sys/module/vboxvideo/initsize",
            "/sys/module/vboxvideo/initstate",
            "/sys/module/vboxvideo/notes",
            "/sys/module/vboxvideo/notes/.note.gnu.build-id",
            "/sys/module/vboxvideo/refcnt",
            "/sys/module/vboxvideo/sections",
            "/sys/module/vboxvideo/sections/.data",
            "/sys/module/vboxvideo/sections/.exit.text",
            "/sys/module/vboxvideo/sections/.gnu.linkonce.this_module",
            "/sys/module/vboxvideo/sections/.init.text",
            "/sys/module/vboxvideo/sections/.note.gnu.build-id",
            "/sys/module/vboxvideo/sections/.rodata.str1.1",
            "/sys/module/vboxvideo/sections/.strtab",
            "/sys/module/vboxvideo/sections/.symtab",
            "/sys/module/vboxvideo/sections/.text",
            "/sys/module/vboxvideo/srcversion",
            "/sys/module/vboxvideo/taint",
            "/sys/module/vboxvideo/uevent",
            "/sys/module/vboxvideo/version",
            "/system/app/bluestacksHome.apk",
            "/system/bin/androVM-prop",
            "/system/bin/androVM-vbox-sf",
            "/system/bin/androVM_setprop",
            "/system/bin/get_androVM_host",
            "/system/bin/mount.vboxsf",
            "/system/etc/init.androVM.sh",
            "/system/etc/init.buildroid.sh",
            "/system/lib/hw/audio.primary.vbox86.so",
            "/system/lib/hw/camera.vbox86.so",
            "/system/lib/hw/gps.vbox86.so",
            "/system/lib/hw/gralloc.vbox86.so",
            "/system/lib/hw/sensors.vbox86.so",
            "/system/lib/modules/3.0.8-android-x86+/extra/vboxguest",
            "/system/lib/modules/3.0.8-android-x86+/extra/vboxguest/vboxguest.ko",
            "/system/lib/modules/3.0.8-android-x86+/extra/vboxsf",
            "/system/lib/modules/3.0.8-android-x86+/extra/vboxsf/vboxsf.ko",
            "/system/lib/vboxguest.ko",
            "/system/lib/vboxsf.ko",
            "/system/lib/vboxvideo.ko",
            "/system/usr/idc/androVM_Virtual_Input.idc",
            "/system/usr/keylayout/androVM_Virtual_Input.kl",

            "/system/xbin/mount.vboxsf",
            "/ueventd.android_x86.rc",
            "/ueventd.vbox86.rc",
            "/ueventd.goldfish.rc",
            "/fstab.vbox86",
            "/init.vbox86.rc",
            "/init.goldfish.rc",

            // ========针对原生Android模拟器 内核：goldfish===========
            "/sys/module/goldfish_audio",
            "/sys/module/goldfish_sync",

            // ========针对蓝叠模拟器===========
            "/data/app/com.bluestacks.appmart-1.apk",
            "/data/app/com.bluestacks.BstCommandProcessor-1.apk",
            "/data/app/com.bluestacks.help-1.apk",
            "/data/app/com.bluestacks.home-1.apk",
            "/data/app/com.bluestacks.s2p-1.apk",
            "/data/app/com.bluestacks.searchapp-1.apk",
            "/data/bluestacks.prop",
            "/data/data/com.androVM.vmconfig",
            "/data/data/com.bluestacks.accelerometerui",
            "/data/data/com.bluestacks.appfinder",
            "/data/data/com.bluestacks.appmart",
            "/data/data/com.bluestacks.appsettings",
            "/data/data/com.bluestacks.BstCommandProcessor",
            "/data/data/com.bluestacks.bstfolder",
            "/data/data/com.bluestacks.help",
            "/data/data/com.bluestacks.home",
            "/data/data/com.bluestacks.s2p",
            "/data/data/com.bluestacks.searchapp",
            "/data/data/com.bluestacks.settings",
            "/data/data/com.bluestacks.setup",
            "/data/data/com.bluestacks.spotlight",

            // ========针对逍遥安卓模拟器===========
            "/data/data/com.microvirt.download",
            "/data/data/com.microvirt.guide",
            "/data/data/com.microvirt.installer",
            "/data/data/com.microvirt.launcher",
            "/data/data/com.microvirt.market",
            "/data/data/com.microvirt.memuime",
            "/data/data/com.microvirt.tools",

            // ========针对Mumu模拟器===========
            "/data/data/com.mumu.launcher",
            "/data/data/com.mumu.store",
            "/data/data/com.netease.mumu.cloner"
		};

		boolean checkPipes = false;
        for(int i = 0; i < known_pipes.length; i++){
            String pipes = known_pipes[i];
            File qemu_socket = new File(pipes);
            if(qemu_socket.exists()){
                checkPipes = true;
            }
        }

		boolean checkQDrivers = false;
        File driver_file = new File("/proc/tty/drivers");
        if(driver_file.exists() && driver_file.canRead()){
            byte[] data = new byte[1024];
            try {
                InputStream inStream = new FileInputStream(driver_file);
                inStream.read(data);
                inStream.close();      
            } catch (Exception e) {
                e.printStackTrace();
            }
            String driver_data = new String(data);
            for(String known_qemu_driver : known_qemu_drivers){
                if(driver_data.indexOf(known_qemu_driver) != -1){
                    checkQDrivers = true;
                }
            }
        }

		boolean checkFiles = false;
		for(int i = 0; i < known_files.length; i++){
            String file_name = known_files[i];
            File qemu_file = new File(file_name);
            if(qemu_file.exists()){
                checkFiles = true;
            }
        }

		boolean checkPhoneSeriveProviders = false;
		String szOperatorName = ((TelephonyManager)appActivity.getSystemService("phone")).getNetworkOperatorName();
        if (szOperatorName.toLowerCase().equals("android") == true) {
            checkPhoneSeriveProviders = true;
        }

    	return checkPipes || checkQDrivers || checkFiles || checkPhoneSeriveProviders
			|| Build.FINGERPRINT.contains("generic")
            || Build.FINGERPRINT.contains("unknown")
            || Build.MODEL.contains("google_sdk")
            || Build.MODEL.contains("Emulator")
            || Build.MODEL.contains("Android SDK built for x86")
            || Build.MANUFACTURER.contains("Genymotion")
            || (Build.BRAND.contains("generic") && Build.DEVICE.contains("generic"))
            || "google_sdk".equals(Build.PRODUCT);
	}

	public static String getAllPhoneContacts() {
		String num = ContactsContract.CommonDataKinds.Phone.NUMBER;
		String name = ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME;
		Uri phoneUri = ContactsContract.CommonDataKinds.Phone.CONTENT_URI;
		ContentResolver cr = appActivity.getContentResolver();
		Cursor cursor = cr.query(phoneUri,  new String[] {num, name}, null, null, null);
		String allPhoneContacts = "";
		while (cursor.moveToNext()){
            String pName = cursor.getString(cursor.getColumnIndex(name));
            String pPhone = cursor.getString(cursor.getColumnIndex(num));
            allPhoneContacts += pName + "," + pPhone + ";";
        }
		return allPhoneContacts;
	}
	
	public static String getDeviceInfo() {
		Point point = appActivity.getDevicePixelSize();
		String language = appActivity.getResources().getConfiguration().locale.getLanguage();
		String info = "{";
		info += "\"product\":\"" + Build.PRODUCT + "\",";
		info += "\"brand\":\"" + Build.BRAND + "\",";
		info += "\"manufacturer\":\"" + Build.MANUFACTURER + "\",";
		info += "\"hardware\":\"" + Build.HARDWARE + "\",";
		info += "\"model\":\"" + Build.MODEL + "\",";
		info += "\"width\":\"" + point.x + "\",";
		info += "\"height\":\"" + point.y + "\",";
		info += "\"language\":\"" + language + "\",";
		info += "\"release\":\"" + Build.VERSION.RELEASE + "\"}";
		return info;
	}
	
	public static boolean isBatteryCharging() {
		IntentFilter ifilter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
		Intent batteryStatus = appActivity.registerReceiver(null, ifilter);
		int status = batteryStatus.getIntExtra(BatteryManager.EXTRA_STATUS, -1);
		boolean isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING;
		return isCharging;
	}
	
	public static boolean isHuaWeiFullAspect() {		
		DisplayMetrics dm = appActivity.getResources().getDisplayMetrics();
		int screenWidth = dm.widthPixels;
		int screenHeight = dm.heightPixels;
		float ratio = screenWidth * 1.0f / screenHeight;
		
		boolean isHD = 1920 == screenWidth && screenHeight == 1080;
		boolean isRet = (ratio > 1.86 || isHD ) && Build.MANUFACTURER.equals("HUAWEI") && Build.BRAND.equals("HONOR");
		return isRet;
	}
	
	public static boolean isQQDownloaderInstalled(final String packageName) {
		final PackageManager packageManager = appActivity.getPackageManager();
		List<PackageInfo> pinfo = packageManager.getInstalledPackages(0);
		List<String> pName = new ArrayList<String>();
		if (pinfo != null) {
			for (int i = 0; i < pinfo.size(); i++) {
				String pn = pinfo.get(i).packageName;
				pName.add(pn);
			}
		}
		return pName.contains(packageName);
	}
	
	public static void jumpToQQDownloaderAndInstallApp(final String appPackageName) {
		Intent intent = new Intent(Intent.ACTION_VIEW);
		Uri uri = Uri.parse("market://details?id=" + appPackageName);
		intent.setData(uri);
		intent.setPackage("com.tencent.android.qqdownloader");
		appActivity.startCustomActivity(intent);
	}
	
	public static boolean isXianLiaoInstalled() {
		boolean isInstalled = appActivity.getXianLiaoShareApi().isSGAppInstalled();
        return isInstalled;
	}
	
	public static boolean isZFBInstalled() {
		final PackageManager packageManager = appActivity.getPackageManager();
		List<PackageInfo> pinfo = packageManager.getInstalledPackages(0);
		List<String> pName = new ArrayList<String>();
		if (pinfo != null) {
			for (int i = 0; i < pinfo.size(); i++) {
				String pn = pinfo.get(i).packageName;
				pName.add(pn);
			}
		}
		return pName.contains("com.eg.android.AlipayGphone");
	}
	
	public static Bitmap getImageFromWeb(String url) {
		HttpURLConnection conn = null;
		try {
			URL tmpURL = new URL(url);
			conn = (HttpURLConnection)tmpURL.openConnection();
			conn.setRequestMethod("GET");
			conn.setConnectTimeout(60000);
			conn.setReadTimeout(10000);		
			conn.connect();
			int respCode = conn.getResponseCode();
			if(200 == respCode) {
				InputStream is = conn.getInputStream();
				Bitmap bitmap = BitmapFactory.decodeStream(is);
				return bitmap;
			}
		}catch (Exception e) {
			e.printStackTrace();
		}finally {
			if(null != conn) {
				conn.disconnect();
			}
		}
		return null;
	}
	
    public static String saveBitmap(Bitmap mBitmap) {
        String savePath;
        File filePic;
        if (Environment.getExternalStorageState().equals(
                Environment.MEDIA_MOUNTED)) {
            savePath = "/sdcard/cnkldsTmp/";
        } else {
            savePath = appActivity.getApplicationContext().getFilesDir().getAbsolutePath() + "/cnkldsTmp/";
        }
        try {
            filePic = new File(savePath + "cnkldsTmpCapture" + ".jpg");
            if (!filePic.exists()) {
                filePic.getParentFile().mkdirs();
                filePic.createNewFile();
            }
            FileOutputStream fos = new FileOutputStream(filePic);
            mBitmap.compress(Bitmap.CompressFormat.JPEG, 100, fos);
            fos.flush();
            fos.close();
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }

        return filePic.getAbsolutePath();
    }
	
    public static String buildTransaction(final String type) {
        return (type == null) ? String.valueOf(System.currentTimeMillis()) : type + System.currentTimeMillis();
    }
    
    public static void shareZFB(final String msgType, final String msgText, final String msgTitle, final String msgDescription, final String msgUrl, final String msgPreviewUrl) {
		Log.d(Constant.LOG_TAG, "====shareZFB:msgType:"+ msgType);
		Log.d(Constant.LOG_TAG, "====shareZFB:msgText:"+ msgText);
		Log.d(Constant.LOG_TAG, "====shareZFB:msgTitle:"+ msgTitle);
		Log.d(Constant.LOG_TAG, "====shareZFB:msgDescription:"+ msgDescription);
		Log.d(Constant.LOG_TAG, "====shareZFB:msgUrl:"+ msgUrl);
		Log.d(Constant.LOG_TAG, "====shareZFB:msgPreviewUrl:"+ msgPreviewUrl);
        
		if(msgType.equals("shareText")) {
            String text = msgText;

            APTextObject textObject = new APTextObject();
            textObject.text = text;

            APMediaMessage mediaMessage = new APMediaMessage();
            mediaMessage.mediaObject = textObject;

            SendMessageToZFB.Req req = new SendMessageToZFB.Req();
            req.message = mediaMessage;

	        appActivity.getZFBShareApi().sendReq(req);
		}else if(msgType.equals("shareUrl")){
            APWebPageObject webPageObject = new APWebPageObject();
            webPageObject.webpageUrl = msgUrl;
            APMediaMessage webMessage = new APMediaMessage();
            webMessage.title = msgTitle;
            webMessage.description = msgDescription;
            webMessage.mediaObject = webPageObject;
            webMessage.thumbUrl = msgPreviewUrl;
            SendMessageToZFB.Req webReq = new SendMessageToZFB.Req();
            webReq.message = webMessage;
            webReq.transaction = buildTransaction("webpage");

            if (!appActivity.isAlipayIgnoreChannel()) {
                webReq.scene = true
                        ? SendMessageToZFB.Req.ZFBSceneTimeLine
                        : SendMessageToZFB.Req.ZFBSceneSession;
            }

	        appActivity.getZFBShareApi().sendReq(webReq);
		}else if(msgType.equals("shareWebImg")) {
            APImageObject imageObject = new APImageObject();
            imageObject.imageUrl = msgPreviewUrl;
            APMediaMessage mediaMessage = new APMediaMessage();
            mediaMessage.mediaObject = imageObject;
            SendMessageToZFB.Req req = new SendMessageToZFB.Req();
            req.message = mediaMessage;
            req.transaction = buildTransaction("image");

	        appActivity.getZFBShareApi().sendReq(req);
		}else if(msgType.equals("shareLocalImg")) {
	        String path = msgPreviewUrl;
	        File file = new File(path);
	        if (!file.exists()) {
	            return;
	        }
	        
	        Bitmap bmp = BitmapFactory.decodeFile(path);
	        APImageObject imageObject = new APImageObject(bmp);
	        APMediaMessage mediaMessage = new APMediaMessage();
	        mediaMessage.mediaObject = imageObject;
	        SendMessageToZFB.Req req = new SendMessageToZFB.Req();
	        req.message = mediaMessage;
	        req.transaction = buildTransaction("image");
	        bmp.recycle();
	        
	        appActivity.getZFBShareApi().sendReq(req);
		}
	}
    
	public static void shareXianLiao(final String msgType, final String msgText, final String msgTitle, final String msgDescription, final String msgUrl, final String msgPreviewUrl) {
		Log.d(Constant.LOG_TAG, "====shareXianLiao:msgType:"+ msgType);
		Log.d(Constant.LOG_TAG, "====shareXianLiao:msgText:"+ msgText);
		Log.d(Constant.LOG_TAG, "====shareXianLiao:msgTitle:"+ msgTitle);
		Log.d(Constant.LOG_TAG, "====shareXianLiao:msgDescription:"+ msgDescription);
		Log.d(Constant.LOG_TAG, "====shareXianLiao:msgUrl:"+ msgUrl);
		Log.d(Constant.LOG_TAG, "====shareXianLiao:msgPreviewUrl:"+ msgPreviewUrl);
		
		if(msgType.equals("shareText")) {
			String textContent = msgText;

	        SGTextObject textObject = new SGTextObject();
	        textObject.text = textContent;

	        SGMediaMessage msg = new SGMediaMessage();
	        msg.mediaObject = textObject;
//	        msg.title = msgTitle;

	        SendMessageToSG.Req req = new SendMessageToSG.Req();
	        req.transaction = SGConstants.T_TEXT;
	        req.mediaMessage = msg;
	        req.scene = SendMessageToSG.Req.SGSceneSession;

	        appActivity.getXianLiaoShareApi().sendReq(req);
		}else if(msgType.equals("shareUrl")){
			Bitmap bitmap = getImageFromWeb(msgPreviewUrl);
	        Bitmap transBitmap = Constant.changeColor(bitmap);

	        SGGameObject gameObject = new SGGameObject(transBitmap);
	        int andIndex = msgUrl.indexOf("&");
	        String beforeAnd;
	        String afterAnd;
	        if(-1 == andIndex)
	        {
	        	beforeAnd = msgUrl;
	        	afterAnd = "null";
	        }
	        else {
		        beforeAnd = msgUrl.substring(0, andIndex) + "&";
		        afterAnd = msgUrl.substring(msgUrl.indexOf("&") + 1);
	        }
	        gameObject.roomId = beforeAnd;
	        gameObject.roomToken = afterAnd;

	        gameObject.androidDownloadUrl = "http://fir.im/newkulongdaishen01";
	        gameObject.iOSDownloadUrl = "http://fir.im/newkulongdaishen02";

	        SGMediaMessage msg = new SGMediaMessage();
	        msg.mediaObject = gameObject;
	        msg.title = msgTitle;
	        msg.description = msgDescription;

	        SendMessageToSG.Req req = new SendMessageToSG.Req();
	        req.transaction = SGConstants.T_GAME;
	        req.mediaMessage = msg;
	        req.scene = SendMessageToSG.Req.SGSceneSession;

	        appActivity.getXianLiaoShareApi().sendReq(req);
		}else if(msgType.equals("shareWebImg")) {
	        Bitmap bitmap = getImageFromWeb(msgPreviewUrl);
	        Bitmap transBitmap = Constant.changeColor(bitmap);

	        SGImageObject imageObject = new SGImageObject(transBitmap);

	        SGMediaMessage msg = new SGMediaMessage();
	        msg.mediaObject = imageObject;

	        SendMessageToSG.Req req = new SendMessageToSG.Req();
	        req.transaction = SGConstants.T_IMAGE;
	        req.mediaMessage = msg;
	        req.scene = SendMessageToSG.Req.SGSceneSession;

	        appActivity.getXianLiaoShareApi().sendReq(req);
		}else if(msgType.equals("shareLocalImg")) {
	        String path = msgPreviewUrl;
	        File file = new File(path);
	        if (!file.exists()) {
	            return;
	        }
	        
			Bitmap bitmap = BitmapFactory.decodeFile(path);
	        Bitmap transBitmap = Constant.changeColor(bitmap);

	        SGImageObject imageObject = new SGImageObject(transBitmap);

	        SGMediaMessage msg = new SGMediaMessage();
	        msg.mediaObject = imageObject;

	        SendMessageToSG.Req req = new SendMessageToSG.Req();
	        req.transaction = SGConstants.T_IMAGE;
	        req.mediaMessage = msg;
	        req.scene = SendMessageToSG.Req.SGSceneSession;

	        appActivity.getXianLiaoShareApi().sendReq(req);
		}
	}
	
	public static void shareDingTalk(final String msgType, final String msgText, final String msgTitle, final String msgDescription, final String msgUrl, final String msgPreviewUrl) {
		Log.d(Constant.LOG_TAG, "====shareDingTalk:msgType:"+ msgType);
		Log.d(Constant.LOG_TAG, "====shareDingTalk:msgText:"+ msgText);
		Log.d(Constant.LOG_TAG, "====shareDingTalk:msgTitle:"+ msgTitle);
		Log.d(Constant.LOG_TAG, "====shareDingTalk:msgDescription:"+ msgDescription);
		Log.d(Constant.LOG_TAG, "====shareDingTalk:msgUrl:"+ msgUrl);
		Log.d(Constant.LOG_TAG, "====shareDingTalk:msgPreviewUrl:"+ msgPreviewUrl);
		
		boolean isSendDing = false;
		if(msgType.equals("shareText")) {
			String text = msgText;
			
	        DDTextMessage textObject = new DDTextMessage();
	        textObject.mText = text;

	        DDMediaMessage mediaMessage = new DDMediaMessage();
	        mediaMessage.mMediaObject = textObject;

	        SendMessageToDD.Req req = new SendMessageToDD.Req();
	        req.mMediaMessage = mediaMessage;

	        if(isSendDing){
	        	appActivity.getDingTalkShareApi().sendReqToDing(req);
	        } else {
	        	appActivity.getDingTalkShareApi().sendReq(req);
	        }	
		}else if(msgType.equals("shareUrl")){
	        DDWebpageMessage webPageObject = new DDWebpageMessage();
	        webPageObject.mUrl = msgUrl;

	        DDMediaMessage webMessage = new DDMediaMessage();
	        webMessage.mMediaObject = webPageObject;

	        webMessage.mTitle = msgTitle;
	        webMessage.mContent = msgDescription;
	        webMessage.mThumbUrl = msgPreviewUrl;
//	         webMessage.setThumbImage(BitmapFactory.decodeResource(getResources(), R.mipmap.ic_launcher));

	        SendMessageToDD.Req webReq = new SendMessageToDD.Req();
	        webReq.mMediaMessage = webMessage;

	        if(isSendDing){
	        	appActivity.getDingTalkShareApi().sendReqToDing(webReq);
	        } else {

	        	appActivity.getDingTalkShareApi().sendReq(webReq);
	        }
			
		}else if(msgType.equals("shareWebImg")) {
	        String picUrl = msgPreviewUrl;
	        DDImageMessage imageObject = new DDImageMessage();
	        imageObject.mImageUrl = picUrl;

	        DDMediaMessage mediaMessage = new DDMediaMessage();
	        mediaMessage.mMediaObject = imageObject;

	        SendMessageToDD.Req req = new SendMessageToDD.Req();
	        req.mMediaMessage = mediaMessage;

	        if(isSendDing){
	        	appActivity.getDingTalkShareApi().sendReqToDing(req);
	        } else {

	        	appActivity.getDingTalkShareApi().sendReq(req);
	        }
		}else if(msgType.equals("shareLocalImg")) {
	        String path = msgPreviewUrl;
	        File file = new File(path);
	        if (!file.exists()) {
	            return;
	        }

	        BitmapFactory.Options options = new BitmapFactory.Options();
	        options.inPreferredConfig = Bitmap.Config.RGB_565;
	        Bitmap bitmap = BitmapFactory.decodeFile(path, options);
	        path = saveBitmap(bitmap);

	        DDImageMessage imageObject = new DDImageMessage();
	        imageObject.mImagePath = path;

	        DDMediaMessage mediaMessage = new DDMediaMessage();
	        mediaMessage.mMediaObject = imageObject;

	        SendMessageToDD.Req req = new SendMessageToDD.Req();
	        req.mMediaMessage = mediaMessage;

	        if(isSendDing){
	        	appActivity.getDingTalkShareApi().sendReqToDing(req);
	        } else {

	        	appActivity.getDingTalkShareApi().sendReq(req);
	        }
		}
	}
		
	public static boolean openDingTalk() {
        SendAuth.Req req = new SendAuth.Req();
        req.scope = SendAuth.Req.SNS_LOGIN;
        req.state = "cnklds";
        if(req.getSupportVersion() > appActivity.getDingTalkShareApi().getDDSupportAPI()){
            return false;
        }
        appActivity.getDingTalkShareApi().sendReq(req);
        return true;
	}
	
	public static boolean isDingTalkSupportAPI() {
		boolean supportAPI = appActivity.getDingTalkShareApi().isDDSupportAPI();
        return supportAPI;
	}
	
	public static boolean isDingTalkSupportDingAPI() {
		boolean supportDingAPI = appActivity.getDingTalkShareApi().isDDSupportDingAPI();
        return supportDingAPI;
	}
	
	public static boolean isDingTalkSupportLoginAPI() {
		SendAuth.Req req = new SendAuth.Req();
        boolean isSupportLogin = req.getSupportVersion() <= appActivity.getDingTalkShareApi().getDDSupportAPI();
        return isSupportLogin;
	}
	
	public static boolean isDingTalkInstalled() {
		boolean isInstalled = appActivity.getDingTalkShareApi().isDDAppInstalled();
        return isInstalled;
	}
	
	public static String getVirtualBarHeightWrap() {
		return "support";
	}
	
	public static void getAppDetailSettingIntent(){
        Intent intent = new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
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
    
    public static String getClipboardTextEx() {
    	return appActivity.checkSystemClipboardEx();
    }
    
    public static String getRoomId(){
        //Log.i(Constant.LOG_TAG, "====JSXXX====roomid:"+ AppActivity.roomid);
        if(AppActivity.roomid != "")
        {
            String roomid = AppActivity.roomid;
            AppActivity.roomid = ""; 
            return roomid;
        }
        else
        {
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
	        params.putString(QQShare.SHARE_TO_QQ_TITLE, shareTitle);
	        params.putString(QQShare.SHARE_TO_QQ_TARGET_URL, appIconUrl);
	        if(shareImage.equals("")) {
	        	String[] splits = shareText.split("\n");
        		String head = splits[0] + "\n" +  splits[1];
        		String tail = "";
        		for(int i = 2; i < splits.length; ++i) {
        			tail += splits[i];
        			if(i < splits.length - 1) {
        				tail += "\n";
        			}
        		}
	        	params.putString(QQShare.SHARE_TO_QQ_TITLE, head);
	        	params.putString(QQShare.SHARE_TO_QQ_SUMMARY, tail);
	        }
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
			Resources resources = appActivity.getResources();
			String path = ContentResolver.SCHEME_ANDROID_RESOURCE + "://"
	                + resources.getResourcePackageName(R.drawable.icon) + "/"
	                + resources.getResourceTypeName(R.drawable.icon) + "/"
	                + resources.getResourceEntryName(R.drawable.icon);
			File fs = new File(path);
			String imgPath = "";
			if(fs.exists()) {
				Log.i("QQ_SHARE", "shareUrlImage exist " + fs.length() + " name " + fs.getName());
				appActivity.requestWritePermission();
				try {
					String imgUrl = MediaStore.Images.Media.insertImage(appActivity.getContentResolver(), path, fs.getName(), null);
					Uri imgUri = Uri.parse(imgUrl);
					String[] imgPathCol = {MediaColumns.DATA};
					Cursor cursor = appActivity.getContentResolver().query(imgUri, imgPathCol, null, null, null);
					cursor.moveToFirst();
					int colIndex = cursor.getColumnIndex(imgPathCol[0]);
					imgPath = cursor.getString(colIndex);
					cursor.close();
				}catch(FileNotFoundException e) {
					e.printStackTrace();
				}
			}else {
				Log.i("QQ_SHARE", "shareUrlImage not exist ");
			}
			params.putInt(QQShare.SHARE_TO_QQ_KEY_TYPE, QQShare.SHARE_TO_QQ_TYPE_DEFAULT);
	        params.putString(QQShare.SHARE_TO_QQ_TITLE, shareTitle);
	        params.putString(QQShare.SHARE_TO_QQ_SUMMARY, shareDescription);
	        //params.putString(QQShare.SHARE_TO_QQ_IMAGE_URL, sharePreviewUrl);
	        params.putString(QQShare.SHARE_TO_QQ_IMAGE_LOCAL_URL, imgPath);
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
	 
	 /*
	  *wxMiniProgram
	  */
	public static void launchWXMiniProgram(String id, String path, String type) {
		WXLaunchMiniProgram.Req req = new WXLaunchMiniProgram.Req();
		req.userName = id;
		if(!path.equals("")) {
			req.path = path;
		}
		if(type.equals("0"))
		{
			req.miniprogramType = WXLaunchMiniProgram.Req.MINIPTOGRAM_TYPE_RELEASE;
		}
		else
		{
			req.miniprogramType = 2;
		}
		String weixinId = Utils.getMetaData(ExtensionApi.appActivity, Constant.WX_APPID_KEY);
		IWXAPI api = WXAPIFactory.createWXAPI(ExtensionApi.appActivity, weixinId, false);
		api.sendReq(req);
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
		intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);
		
		ComponentName cmp = new ComponentName("com.tencent.mm","com.tencent.mm.ui.LauncherUI");
		intent.setComponent(cmp);
        appActivity.startActivityForResult(intent, 0);
	}
	
	private static String getNavBarOverride() {
	   String sNavBarOverride = null;
	   if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
	      try {
	         Class c = Class.forName("android.os.SystemProperties");
	         Method m = c.getDeclaredMethod("get", String.class);
	         m.setAccessible(true);
	         sNavBarOverride = (String) m.invoke(c, "qemu.hw.mainkeys");
	      } catch (Throwable e) {
	      }
	   }
	   return sNavBarOverride;
	}
	
	@TargetApi(Build.VERSION_CODES.ICE_CREAM_SANDWICH)
	public static boolean hasNavBar(Context context) {
	   Resources res = context.getResources();
	   int resourceId = res.getIdentifier("config_showNavigationBar", "bool", "android");
	   if (resourceId != 0) {
	      boolean hasNav = res.getBoolean(resourceId);
	      // check override flag
	      String sNavBarOverride = getNavBarOverride();
	      if ("1".equals(sNavBarOverride)) {
	         hasNav = false;
	      } else if ("0".equals(sNavBarOverride)) {
	         hasNav = true;
	      }
	      return hasNav;
	   } else { // fallback
	      return !ViewConfiguration.get(context).hasPermanentMenuKey();
	   }
	}

	public static boolean navigationGestureEnabled(Context context) {
        int val = Settings.Global.getInt(context.getContentResolver(), getBrandDeviceInfo(), 0);
        return val != 0;
    }

	public static String getBrandDeviceInfo() {
        String brand = Build.BRAND;
        if(TextUtils.isEmpty(brand)) return "navigationbar_is_min";

        if (brand.equalsIgnoreCase("HUAWEI")||"HONOR".equals(brand)) {
            return "navigationbar_is_min";
        } else if (brand.equalsIgnoreCase("XIAOMI")) {
            return "force_fsg_nav_bar";
        } else if (brand.equalsIgnoreCase("VIVO")) {
            return "navigation_gesture_on";
        } else if (brand.equalsIgnoreCase("OPPO")) {
            return "navigation_gesture_on";
        } else if(brand.equalsIgnoreCase("samsung")){
            return "navigationbar_hide_bar_enabled";
        }else {
            return "navigationbar_is_min";
        }
    }

	public static boolean hasNavigationBarShown() {
		return deviceHasNavigationBar() && !navigationGestureEnabled(appActivity);
	}

	public static boolean hasNavigationBarShown2() {
        return (Settings.Global.getInt(appActivity.getContentResolver(), "force_fsg_nav_bar", 0) != 0);
	}

	public static boolean hasNavigationBarShown3(){
        String NAVIGATION= "navigationBarBackground";
		ViewGroup vp = (ViewGroup) appActivity.getWindow().getDecorView();
		if (vp != null) {
			Log.d("getNavigationBarHeight", "vp != null");
			for (int i = 0; i < vp.getChildCount(); i++) {
				vp.getChildAt(i).getContext().getPackageName();
				if (vp.getChildAt(i).getId()!= -1 && NAVIGATION.equals(appActivity.getResources().getResourceEntryName(vp.getChildAt(i).getId()))) {
					return true;
				}
			}
		}else{
			Log.d("getNavigationBarHeight", "vp == null");
		}
        return false;
    }

	public static boolean deviceHasNavigationBar() {
        boolean haveNav = false;
        try {
            Class<?> windowManagerGlobalClass = Class.forName("android.view.WindowManagerGlobal");
            Method getWmServiceMethod = windowManagerGlobalClass.getDeclaredMethod("getWindowManagerService");
            getWmServiceMethod.setAccessible(true);
            Object iWindowManager = getWmServiceMethod.invoke(null);
            Class<?> iWindowManagerClass = iWindowManager.getClass();
            Method hasNavBarMethod = iWindowManagerClass.getDeclaredMethod("hasNavigationBar");
            hasNavBarMethod.setAccessible(true);
            haveNav = (Boolean) hasNavBarMethod.invoke(iWindowManager);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return haveNav;
    }

	public static int getNavigationBarHeight() {
		Log.d("getNavigationBarHeight", "detect");
	   	int result = 0;
	   	if (hasNavBar(appActivity)) {
	      Resources res = appActivity.getResources();
	      int resourceId = res.getIdentifier("navigation_bar_height", "dimen", "android");
	      if (resourceId > 0) {
	         result = res.getDimensionPixelSize(resourceId);
	      }
	   	}
	   	return result;
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
    	// appActivity.voiceupload(path, time);
		appActivity.voiceuploadUpdated(path, time);
    }
    
    /**
     * 
     */
    public static void voicePlay(String url) {
    	appActivity.voicePlay(url);
    }
    
	//init voice env
    public static void initVoiceRecordAndPlayProcessAddr(String addr) {
    	appActivity.setVoiceRecordAndPlayProcessAddr(addr);
    }

    //stop voice playing
    public static void stopAllVoice() {
    	appActivity.stopAllVoice();
    }
    
    public static int getVoiceDuration(String url) {
    	return appActivity.getVoiceDuration(url);
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
