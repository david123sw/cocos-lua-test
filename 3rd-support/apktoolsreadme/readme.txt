apktool d demo.apk
apktool b demmfile -o demo_mod.apk
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore key.keystore -storepass password out.apk alias