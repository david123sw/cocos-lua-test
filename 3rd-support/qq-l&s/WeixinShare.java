package org.weixin;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.nio.IntBuffer;

import javax.microedition.khronos.opengles.GL10;

import org.extension.ExtensionApi;
import org.game.Constant;
import org.ynlib.utils.Utils;


import com.sevenjzc.cnklds.R;
import com.tencent.mm.sdk.modelmsg.SendMessageToWX;
import com.tencent.mm.sdk.modelmsg.WXImageObject;
import com.tencent.mm.sdk.modelmsg.WXMediaMessage;
import com.tencent.mm.sdk.modelmsg.WXTextObject;
import com.tencent.mm.sdk.modelmsg.WXWebpageObject;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.util.DisplayMetrics;
import android.util.Log;

public class WeixinShare {
	private static final int THUMB_SIZE = 140;
	private IWXAPI api;

	public WeixinShare() {
		this.api = WXAPIFactory.createWXAPI(ExtensionApi.appActivity,
				Utils.getMetaData(ExtensionApi.appActivity, Constant.WX_APPID_KEY), false);
		api.registerApp(Utils.getMetaData(ExtensionApi.appActivity, Constant.WX_APPID_KEY));
	}

	/**
	 *
	 *
	 *
	 * @param w
	 * @param h
	 * @param gl
	 * @return
	 */
	private Bitmap getBitmapFromGL(int w, int h, GL10 gl) {
		int bitmapBuffer[] = new int[w * h];
		int bitmapSource[] = new int[w * h];
		IntBuffer intBuffer = IntBuffer.wrap(bitmapBuffer);
		intBuffer.position(0);
		gl.glReadPixels(0, 0, w, h, GL10.GL_RGBA, GL10.GL_UNSIGNED_BYTE, intBuffer);
		int offset1, offset2;
		for (int i = 0; i < h; i++) {
			offset1 = i * w;
			offset2 = (h - i - 1) * w;
			for (int j = 0; j < w; j++) {
				int texturePixel = bitmapBuffer[offset1 + j];
				int blue = (texturePixel >> 16) & 0xff;
				int red = (texturePixel << 16) & 0x00ff0000;
				int pixel = (texturePixel & 0xff00ff00) | red | blue;
				bitmapSource[offset2 + j] = pixel;
			}
		}
		return Bitmap.createBitmap(bitmapSource, w, h, Bitmap.Config.RGB_565);
	}

	public Bitmap takeScreenShot(GL10 gl) {
		Context context = ExtensionApi.appActivity;
		DisplayMetrics displayMetrics = context.getResources().getDisplayMetrics();
		Bitmap bitmap = getBitmapFromGL(displayMetrics.widthPixels, displayMetrics.heightPixels, gl);
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		bitmap.compress(Bitmap.CompressFormat.JPEG, 60, out);
		bitmap.recycle();
		BitmapFactory.Options newOpts = new BitmapFactory.Options();
		int be = 2;
		newOpts.inSampleSize = be;
		ByteArrayInputStream isBm = new ByteArrayInputStream(out.toByteArray());
		Bitmap retBitmap = BitmapFactory.decodeStream(isBm, null, null);
		return retBitmap;
	}

	public void shareImg(final String shareTo, final String filePath) {
		try {
			Bitmap bmp = null;
			try  
		    {  
		        File file = new File(filePath);  
		        if(file.exists())  
		        {  
		        	bmp = BitmapFactory.decodeFile(filePath);  
		        }  
		    } catch (Exception e)  
		    {  
		    	Log.e(Constant.LOG_TAG, " share image not exist", e);
		    	return;
		    }  
			
			WXImageObject imgObj = new WXImageObject(bmp);
			WXMediaMessage msg = new WXMediaMessage();
			msg.mediaObject = imgObj;
			int w = bmp.getWidth() * WeixinShare.THUMB_SIZE / bmp.getHeight();
			Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, w, WeixinShare.THUMB_SIZE, true);
			msg.thumbData = Utils.bmpToByteArray(thumbBmp, true);

			SendMessageToWX.Req req = new SendMessageToWX.Req();
			req.transaction = this.buildTransaction("img");
			req.message = msg;
			if (shareTo.equals("timeline")) {
				req.scene = SendMessageToWX.Req.WXSceneTimeline;
				Log.i(Constant.LOG_TAG, "call WXSceneTimeline--->");
			} else {
				req.scene = SendMessageToWX.Req.WXSceneSession;
				Log.i(Constant.LOG_TAG, "call WXSceneSession--->");
			}
			api.sendReq(req);
			bmp.recycle();
		} catch (Exception e) {
			Log.e(Constant.LOG_TAG, "WeixinImageMessage->", e);
		}
	}


	public String buildTransaction(final String type) {
		return (type == null) ? String.valueOf(System.currentTimeMillis()) : type + System.currentTimeMillis();
	}

	/**
	 *
	 * 
	 * @param appInfo
	 */
	public void shareAppInfo(final String shareTo, final String title, final String message, final String url) {
		if(title.equals("") && url.equals("")) {
			WXTextObject textObject = new WXTextObject();
			textObject.text = message;
			WXMediaMessage msg = new WXMediaMessage();
			msg.mediaObject = textObject;
			msg.description = " ";
			SendMessageToWX.Req req = new SendMessageToWX.Req();
			req.message = msg;
			req.transaction = this.buildTransaction("text");
			if (shareTo.equals("timeline")) {
				req.scene = SendMessageToWX.Req.WXSceneTimeline;
				Log.i(Constant.LOG_TAG, "call WXSceneTimeline--->");
			} else {
				req.scene = SendMessageToWX.Req.WXSceneSession;
				Log.i(Constant.LOG_TAG, "call WXSceneSession--->");
			}
			api.sendReq(req);
		}else {
			WXWebpageObject webpage = new WXWebpageObject();
			webpage.webpageUrl = url;
			WXMediaMessage msg = new WXMediaMessage(webpage);
			msg.title = title;
			msg.description = message;
			Bitmap thumb = BitmapFactory.decodeResource(ExtensionApi.appActivity.getResources(), R.drawable.icon);
			Bitmap transThumb = Constant.changeColor(thumb);
			msg.thumbData = Utils.bmpToByteArray(transThumb, true);
			SendMessageToWX.Req req = new SendMessageToWX.Req();
			req.transaction = String.valueOf(System.currentTimeMillis());
			req.message = msg;
			if (shareTo.equals("timeline")) {
				req.scene = SendMessageToWX.Req.WXSceneTimeline;
				Log.i(Constant.LOG_TAG, "call WXSceneTimeline--->");
			} else {
				req.scene = SendMessageToWX.Req.WXSceneSession;
				Log.i(Constant.LOG_TAG, "call WXSceneSession--->");
			}
			api.sendReq(req);
		}
	}
}
