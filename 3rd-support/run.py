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
				
def bigFileMD5Digest(file):
    digest = md5()
    with codecs.open(file, 'rb') as fop:
        buffer = 8192
        while True:
            chunk = fop.read(buffer)
            if not chunk : break
            digest.update(chunk)
    return digest.hexdigest()

def Main():
    #info
    #example:   python run.py 100 101 ver1.0.15 release
    #100 svn开始版本号
    #101 svn结束版本号
    #ver1.0.15 下一个热更包版本号
    #release 默认可以不填是外网测试服，填了代表外网正式服
	#svn check modified files and commit cmd:
	#	svn st | grep "M" | cut -c 8->modified.txt
	#	svn ci -m "log:just for test" --targets modified.txt
    #参数顺序不能乱
	
	if 4 > len(sys.argv):
        print u"参数数至少4个, python run.py 100 101 ver1.0.1 [optional:release]"
        return
	
    cmdParams = {}
    cmdParams['svnFromVer'] = sys.argv[1]
    cmdParams['svnToVer'] = sys.argv[2]
    cmdParams['nextVersion'] = u'' + sys.argv[3]
    cmdParams['release'] = 5 == len(sys.argv) and sys.argv[4] == "release"

    #外网测试服地址
    qaIPAddr = '0.0.0.0'
    #外网正式服地址
    releaseIPAddr = '0.0.0.0'
    #记录日志文件
    updateLogFile = 'update.log'
    workDirs = os.getcwd() + r'\data'
    svnProjectDevDirs = r'https://0.0.0.0/svn/game_project/client/Code/???'
    projectDevDirs = r'D:\David-dev-workspace\MyWorkspace\game_project_branch_dev'
    cocosCompileCmd = r'%NEWER_COCOS_VER%\cocos luacompile -s ' + workDirs + r'\srcLua -d ' + workDirs + r'\src' + r' -e -k ? -b ? --disable-compile'
    svnCmd = 'svn diff -r ' + str(cmdParams['svnFromVer']) + ':' + str(cmdParams['svnToVer']) + ' --summarize ' + svnProjectDevDirs
    print u"*******************************************************************使用方式见文件开头example说明***********************************************************"
    print u"更新包生成中..." + "\n[当前项目操作目录----------->" + projectDevDirs + "]"
    #info

    print u"Step(1/5)开始获取更新文件"
    diffContent = os.popen(svnCmd).read()
    contentSplits = diffContent.split('\n')
    validContentSplitsNum = 0

    print u"Step(2/5)计算文件MD5值"
    hasSvnRecordDeletedFiles = False
    allDiffFilePathAndMD5Dict = {}
    for path in contentSplits:
        if len(path) > 0:
            validContentSplitsNum += 1
            realPath = path.replace(svnProjectDevDirs, projectDevDirs)
            # print "svn:" + path
            realPath = realPath.replace(r'/', '\\')
            print "svn status:" + realPath[0]
            if 'D' == realPath[0]:
                hasSvnRecordDeletedFiles = True
            else:                
                realPath = realPath.replace('M       ', '')
                realPath = realPath.replace('A       ', '')
                workDirFilePath = realPath.replace(projectDevDirs, workDirs)
                workFilePath, workFileName = os.path.split(workDirFilePath)
                if not os.path.exists(workFilePath):
                    os.makedirs(workFilePath)
                print u"复制文件 " + workFileName 
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
	else:
		print ur"data\src文件夹不存在"

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

    # #test
    # # diffFilesDesc = {'total':0, 'diff':0}
    # # beginTime = time.time()
    # # print beginTime
    # # dirsMD5Digest(r'D:\David-dev-workspace\hotfix_diff_tools\data', r'D:\David-dev-workspace\hotfix_diff_tools\diff_files.txt', diffFilesDesc)
    # # endTime = time.time()
    # # print endTime
    # # print u"总共耗时:" + str((endTime - beginTime)) + "s"
    # # print u"总文件描述:"
    # # print diffFilesDesc
    # #test

    #test
    # text = u"this is just a test测试"
    # print stringMD5Digest(text)
    # print fileMD5Digest(r'D:\David-dev-workspace\DevTools\MD5\ttt.txt')
    #test
if __name__=="__main__":
    reload(sys)
    sys.setdefaultencoding('utf-8')
    Main()