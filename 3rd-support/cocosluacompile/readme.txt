%NEWER_COCOS_VER%\cocos compile -p android -m release -ap=android-19 --lua-encrypt --lua-encrypt-key ???? --lua-encrypt-sign ???? --disable-compile
%NEWER_COCOS_VER%\cocos luacompile -s src -d src2 -e -k ????-b ????--disable-compile

COCOS_ROOT="/Users/glyn/Documents/DevTools/cocos2d-x-3.16/tools/cocos2d-console/bin"
echo ${COCOS_ROOT}
echo ${BUILT_PRODUCTS_DIR}
echo ${TARGET_NAME}
SRC="${SRCROOT}/../../../src"
DST=${BUILT_PRODUCTS_DIR}"/"${TARGET_NAME}".app/src"
rm -rf ${DST}
${COCOS_ROOT}"/cocos" luacompile -s ${SRC} -d ${DST} --disable-compile
echo "OVER"
