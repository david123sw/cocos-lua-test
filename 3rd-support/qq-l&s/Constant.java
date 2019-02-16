package org.game;

import android.graphics.Bitmap;
import android.graphics.Color;

public class Constant {
	/** log tag **/
	public final static String LOG_TAG = "hhllqp------------------->";
	
	public final static String WX_APPID_KEY = "WX_APPID";
	
	public final static String APP_TALKINGDATA_KEY = "3E9B04EC6A1044019833A6DDD6D2BC35";
	
	public final static String QQ_APPID = "101542064";
	
	//DingTalk
	public final static String APP_DING_TALK_KEY = "dingoadt8tpio87sfiftta";
	public final static String APP_DING_TALK_PACKAGE_NAME = "com.sevenjzc.hhllqp";
	public final static String APP_DING_TALK_SIG = "g2rKXhOYJ6EDUtCDjWy9fXo2cVdPH7fxNISOnkoGmlH-7J5_GcAaJ6aHs6iVzp7x";
	public final static String APP_DING_TALK_CURRENT_USING_KEY = "dingoadt8tpio87sfiftta";
	
	//XL
	public final static String APP_XIAN_LIAO_KEY = "BZ6dpUzG0ULM0FG0";
	public final static String APP_XIAN_LIAO_SCT = "837WH36C7YCwu9el";
	
	//ZFB
	public final static String APP_ZFB_KEY = "2019011563014654";
	
	public final static String APP_DIST_DESC = "Android_Origin_Channel";
	
    public static Bitmap changeColor(Bitmap bitmap) {
        if (bitmap == null) {
            return null;
        }
        int w = bitmap.getWidth();
        int h = bitmap.getHeight();
        int[] colorArray = new int[w * h];
        int n = 0;
        for (int i = 0; i < h; i++) {
            for (int j = 0; j < w; j++) {
                int color = getMixtureWhite(bitmap.getPixel(j, i));
                colorArray[n++] = color;
            }
        }
        return Bitmap.createBitmap(colorArray, w, h, Bitmap.Config.ARGB_8888);
    };

    public static int getMixtureWhite(int color) {
        int alpha = Color.alpha(color);
        int red = Color.red(color);
        int green = Color.green(color);
        int blue = Color.blue(color);
        return Color.rgb(getSingleMixtureWhite(red, alpha), getSingleMixtureWhite(green, alpha), getSingleMixtureWhite(blue, alpha));
    };

    public static int getSingleMixtureWhite(int color, int alpha) {
        int newColor = color * alpha / 255 + 255 - alpha;
        return newColor > 255 ? 255 : newColor;
    }
}
