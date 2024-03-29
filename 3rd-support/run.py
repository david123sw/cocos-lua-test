#-*- coding:utf-8 -*-
#python2.7
#热更自动比对，生成热更包脚本 by shen
import sys
import locale
import os
import shutil
import codecs
import time
import chardet
import json
from hashlib import md5

def stringMD5Digest(text):
    digest = md5()
    transText = text.encode('utf-8')
    digest.update(transText)
    return digest.hexdigest()
    
def fileMD5Digest(file):
    statinfo = os.stat(file)
    if int(statinfo.st_size) / (1024 * 1024) >= 1000:
        print ("File size > 1000, 文件较大，耗费内存较多...")
    digest = md5()
    with codecs.open(file, 'rb') as fop:
        digest.update(fop.read())
    return digest.hexdigest()

def dirsMD5Digest(dir, resultDescFile, diffFilesDesc):
    print u"当前目录，查看##############" + dir
    print u"修改文件列表，查看##############" + resultDescFile
    with codecs.open(resultDescFile, 'w', 'utf-8') as fop:
        for root, subdirs, files in os.walk(dir):
            for file in files:
                fileFullPath = os.path.join(root, file)
                print fileFullPath
                fileRelPath = os.path.relpath(fileFullPath, dir)
                transFileRelPath = fileRelPath.replace("\\", "/")
                print fileRelPath
                print fileMD5Digest(fileFullPath)
                diffFilesDesc['total'] += 1
                fop.write(transFileRelPath)
                fop.write('\n')

def Main():
    #info
    #example:   python run.py 100 101 ver1.0.15 release
    #100 svn开始版本号
    #101 svn结束版本号
    #release debug:测试服，release:正式服
    #full 完整包diff;part剔除子游戏目录部分diff
    #参数顺序严格限定

    if 4 > len(sys.argv):
        print u"参数至少4个, python run.py 100 101 ver1.0.1 [release|debug] [full|part]"
        return

    cmdParams = {}
    cmdParams['svnFromVer'] = sys.argv[1]
    cmdParams['svnToVer'] = sys.argv[2]
    cmdParams['nextVersion'] = u'' + sys.argv[3]
    cmdParams['release'] = 6 == len(sys.argv) and sys.argv[4] == "release"
    cmdParams['full'] = 6 == len(sys.argv) and sys.argv[5] == "full"

    #外网测试服地址
    qaIPAddr = '47.98.47.131'
    #外网正式服地址
    releaseIPAddr = 'patch1.apps.9you.net'
    #记录日志文件
    updateLogFile = 'update.log'
    workDirs = os.getcwd() + r'\data'
    svnProjectDevDirs = r'https://192.168.36.242/svn/game_project/client/HHLlqp/android'
    projectDevDirs = r'D:\David-dev-workspace\MyWorkspace\game_project_hhllqp\android'
    cocosCompileCmd = r'%NEWER_COCOS_VER%\cocos luacompile -s ' + workDirs + r'\srcLua -d ' + workDirs + r'\src' + r' -e -k 30042d8d1190098e -b hhllqp --disable-compile'
    svnCmd = 'svn diff -r ' + str(cmdParams['svnFromVer']) + ':' + str(cmdParams['svnToVer']) + ' --summarize ' + svnProjectDevDirs
    print u"*******************************************************************使用方式见文件开头example说明***********************************************************"
    print u"更新包生成中..." + "\n[当前项目操作目录----------->" + projectDevDirs + "]"
    #info

    print u"Step(0/5)开始获取子游戏目录"
    subGamePathList = []
    if False == cmdParams['full']:
        # 不需要自动清目录
        # if os.path.exists(workDirs):
        #     shutil.rmtree(workDirs)
        #     time.sleep(0.5)
        #     os.makedirs(workDirs)
        # else:
        #     os.makedirs(workDirs)
        with codecs.open(r'' + os.getcwd() + r'\sub_game_paths.txt', 'r') as fop:
            subGamePath = fop.readlines()
        for sgp in subGamePath:
            subGamePathList.append(sgp.strip())
        print subGamePathList

    print u"Step(1/5)开始获取更新文件"
    diffContent = os.popen(svnCmd).read()
    contentSplits = diffContent.split('\n')
    validContentSplitsNum = 0

    print u"Step(2/5)计算文件MD5值"
    hasSvnRecordDeletedFiles = False
    allDiffFilePathAndMD5Dict = {}
    for path in contentSplits:
        resIndex = path.find(r'/res')
        srcIndex = path.find(r'/src')
        if len(path) > 0 and (-1 < resIndex or -1 < srcIndex):
            print "svn:" + path
            realPath = path.replace(svnProjectDevDirs, projectDevDirs)
            realPath = realPath.replace(r'/', '\\')
            print "svn status:" + realPath[0]
            if 'D' == realPath[0]:
                hasSvnRecordDeletedFiles = True
            else:                
                realPath = realPath.replace('M       ', '')
                realPath = realPath.replace('A       ', '')
                workDirFilePath = realPath.replace(projectDevDirs, workDirs)
                workFilePath, workFileName = os.path.split(workDirFilePath)
                ignoreSubGame = -1
                if False == cmdParams['full']:
                    print u"子游戏文件"
                    for sgp in subGamePathList:
                        ignoreSubGame = path.find(sgp)
                        if -1 < ignoreSubGame:
                            break
                if not os.path.exists(workFilePath):
                    os.makedirs(workFilePath)
                print u"复制文件 " + workFileName
                ignoreFramework = path.find(r'/frameworks')
                if -1 < ignoreFramework:
                    print u"忽略该文件 " + realPath
                checkMode = os.path.isfile(realPath) and (-1 == ignoreFramework)
                if False == cmdParams['full']:
                    checkMode = os.path.isfile(realPath) and (-1 == ignoreFramework) and (-1 == ignoreSubGame)
                    if -1 < ignoreSubGame:
                        print u"忽略该子游戏文件"
                if checkMode:
                    validContentSplitsNum += 1
                    shutil.copyfile(realPath, workDirFilePath)
                    fileRelativePath = path.replace('M       ', '')
                    fileRelativePath = fileRelativePath.replace('A       ', '')
                    fileRelativePath = fileRelativePath.replace(svnProjectDevDirs + '/', '')
                    fileMD5Value = fileMD5Digest(r'' + workDirFilePath)
                    fileExt = os.path.splitext(r'' + workDirFilePath)
                    if ".lua" == fileExt[1]:
                        changeName = fileRelativePath.replace(".lua", ".luac")
                        allDiffFilePathAndMD5Dict[changeName] = workDirFilePath.replace('.lua', '.luac')
                    else:
                        allDiffFilePathAndMD5Dict[fileRelativePath] = fileMD5Value
                    print "local: " + workDirFilePath
                    print "md5: " + fileMD5Value
    # print allDiffFilePathAndMD5Dict
    print u"所有变动文件数目 " + str(validContentSplitsNum)

    print u"Step(3/5)代码加密"
    if os.path.isdir(os.getcwd() + r'\data\src'):
        os.rename(u'data\\src', u'data\\srcLua')
        os.system(cocosCompileCmd)
        time.sleep(2.5)
        for file in allDiffFilePathAndMD5Dict:
            if file[-5:] == '.luac':
                allDiffFilePathAndMD5Dict[file] = fileMD5Digest(r'' + allDiffFilePathAndMD5Dict[file])
        # print allDiffFilePathAndMD5Dict

    print u"Step(4/5)更新project.manifest"
    manifest2Json = ''
    with codecs.open(r'' + workDirs + r'\project.manifest', 'rb') as fop:
        manifestFileData =  fop.read()
        manifest2Json = json.loads(manifestFileData, 'utf-8')

    with codecs.open(r'' + workDirs + r'\project.manifest', 'w', 'utf-8') as fop:
        manifest2Json[u'version'] = cmdParams['nextVersion'][3:]
        manifestAssets =  manifest2Json[u'assets']

        for file in allDiffFilePathAndMD5Dict:
            fullFile = u'' + file
            if manifestAssets.has_key(fullFile):
                fullFileDesc = manifestAssets[fullFile]
                fullFileDesc[u'path'] = u'' + cmdParams['nextVersion'] + '/' + file
                fullFileDesc[u'md5'] = u'' + allDiffFilePathAndMD5Dict[file]
            else:
                manifestAssets[fullFile] = {}
                manifestAssets[fullFile][u'path'] = u'' + cmdParams['nextVersion'] + '/' + file
                manifestAssets[fullFile][u'md5'] = u'' + allDiffFilePathAndMD5Dict[file]

        if True == cmdParams['release']:
            manifest2Json[u'packageUrl'] = manifest2Json[u'packageUrl'].replace(u'' + qaIPAddr, u'' + releaseIPAddr)
            manifest2Json[u'remoteVersionUrl'] = manifest2Json[u'remoteVersionUrl'].replace(u'' + qaIPAddr, u'' + releaseIPAddr)
            manifest2Json[u'remoteManifestUrl'] = manifest2Json[u'remoteManifestUrl'].replace(u'' + qaIPAddr, u'' + releaseIPAddr)
        fop.write(json.dumps(manifest2Json))

    print u"Step(5/5)更新version.manifest"
    manifest2Json2 = ''
    with codecs.open(r'' + workDirs + r'\version.manifest', 'rb') as fop:
        manifestFileData2 =  fop.read()
        manifest2Json2 = json.loads(manifestFileData2, 'utf-8')

    with codecs.open(r'' + workDirs + r'\version.manifest', 'w', 'utf-8') as fop:
        manifest2Json2[u'version'] = cmdParams['nextVersion'][3:]
        if True == cmdParams['release']:
            manifest2Json2[u'packageUrl'] = manifest2Json2[u'packageUrl'].replace(u'' + qaIPAddr, u'' + releaseIPAddr)
            manifest2Json2[u'remoteVersionUrl'] = manifest2Json2[u'remoteVersionUrl'].replace(u'' + qaIPAddr, u'' + releaseIPAddr)
            manifest2Json2[u'remoteManifestUrl'] = manifest2Json2[u'remoteManifestUrl'].replace(u'' + qaIPAddr, u'' + releaseIPAddr)
        fop.write(json.dumps(manifest2Json2))

    if True == hasSvnRecordDeletedFiles:
        print u"****************************SVN上记录有文件已被删除****************************"

    #更新
    outputHotfixDir = workDirs + u"\\" + cmdParams['nextVersion']
    if not os.path.exists(outputHotfixDir):
        os.makedirs(outputHotfixDir)
    outDirsList = ['src', 'res']
    for outDir in outDirsList:
        fullOutDir = workDirs + u'\\' + outDir
        if os.path.exists(fullOutDir):
            shutil.copytree(fullOutDir, outputHotfixDir + u'\\' + outDir)

    with codecs.open(os.getcwd() + u'\\' + updateLogFile, 'a+', 'utf-8') as fop:
        fop.write(cmdParams['nextVersion'])
        fop.write('\tsvn:from ')
        fop.write(cmdParams['svnFromVer'])
        fop.write('\tsvn:to ')
        fop.write(cmdParams['svnToVer'])
        fop.write('\tdate: ')
        fop.write(time.ctime())
        if True == cmdParams['release']:
            fop.write('\trelease')
        fop.write('\r\n')

if __name__=="__main__":
    reload(sys)
    sys.setdefaultencoding('utf-8')
    Main()