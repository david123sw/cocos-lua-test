apktool d demo.apk
apktool b demofile -o demo_mod.apk
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore key.keystore -storepass password demo_mod.apk alias