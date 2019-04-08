/****************************************************************************
 Copyright (c) 2012      greathqy
 Copyright (c) 2012      cocos2d-x.org
 Copyright (c) 2013-2017 Chukong Technologies Inc.
 
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

#include "network/HttpClient.h"
#include <queue>
#include <errno.h>
#include <curl/curl.h>
#include "base/CCDirector.h"
#include "platform/CCFileUtils.h"
#include <math.h>
#include <cocos2d.h>
#include "platform/CCPlatformMacros.h"
#include <base\ZipUtils.h>

NS_CC_BEGIN

namespace network {

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
typedef int int32_t;
#endif

static HttpClient* _httpClient = nullptr; // pointer to singleton

typedef size_t (*write_callback)(void *ptr, size_t size, size_t nmemb, void *stream);

// Callback function used by libcurl for collect response data
static size_t writeData(void *ptr, size_t size, size_t nmemb, void *stream)
{
    std::vector<char> *recvBuffer = (std::vector<char>*)stream;
    size_t sizes = size * nmemb;
    
    // add data to the end of recvBuffer
    // write data maybe called more than once in a single request
    recvBuffer->insert(recvBuffer->end(), (char*)ptr, (char*)ptr+sizes);
				
	if (nullptr != _httpClient)
	{
		long downloadedSize = _httpClient->getDownloadingFileSizeCount();
		downloadedSize += sizes;
		_httpClient->setDownloadingFileSizeCount(downloadedSize);
		long totalSize = _httpClient->getFileSizeCount();
		double sizeRatio = 0 == totalSize ? 0.0f : (downloadedSize * 1.0) / totalSize;
		int perRatio = floor(sizeRatio * 100);
		bool progressFlag = _httpClient->getProgressEnabledFlag();
		std::string fetchUrl = _httpClient->getFileFetchUrl();
		std::string fetchSize = _httpClient->calcUniformCapacity(totalSize * 1.0f);
		if (progressFlag)
		{
			if (NULL == _httpClient->_fop)
			{
				std::string fPath = _httpClient->getDownloadPath();
				std::string fFetchUrl = _httpClient->getFileFetchUrl();
				std::string fName = fFetchUrl.substr(fFetchUrl.find_last_of("/") + 1);
				std::string fSavePath = fPath + fName;
				// CCLOG("download file url is:%s", fFetchUrl.c_str());
				// CCLOG("download file path is:%s", fSavePath.c_str());
				ApplicationProtocol::Platform target = Application::getInstance()->getTargetPlatform();
				if (target == ApplicationProtocol::Platform::OS_WINDOWS)
				{
					_httpClient->stringReplace(fSavePath, "/", "\\\\");
				}
				_httpClient->_curSectionDownloadPath = fSavePath;
				_httpClient->_fop = fopen(fSavePath.c_str(), "wb+");
			}
			size_t writtenSize = fwrite(ptr, size, nmemb, _httpClient->_fop);
			if (downloadedSize == totalSize)
			{
				fclose(_httpClient->_fop);
				_httpClient->_fop = NULL;
			}

			Scheduler *scheduler = Director::getInstance()->getScheduler();
			//CCLOG("download perRatio is:%d", perRatio);
			//CCLOG("download _prevPerRatioMarked is:%d", _httpClient->_prevPerRatioMarked);
			if (nullptr != scheduler && (perRatio - _httpClient->_prevPerRatioMarked >= (RandomHelper::random_int(2, 6)) || 100 == perRatio))
			{
				scheduler->performFunctionInCocosThread([fetchUrl, perRatio, fetchSize]{
					EventDispatcher* dispatcher = Director::getInstance()->getEventDispatcher();
					std::string data("{\"url\":\"");
					data += fetchUrl + "\",\"percent\":\"";
					data += std::to_string(perRatio) + "\",\"size\":\"";
					data += fetchSize + "\"}";
					dispatcher->dispatchCustomEvent("URL_FETCH_PROGRESS", (void*)(data.c_str()));
				});
				_httpClient->_prevPerRatioMarked = perRatio;
				if (100 == perRatio)
				{
					_httpClient->_fileDownloadingSizeCount = 0;
					_httpClient->_fileSizeCount = 0;
					_httpClient->_prevPerRatioMarked = 0;
				}
			}
		}
	}

    return sizes;
}

// Callback function used by libcurl for collect header data
static size_t writeHeaderData(void *ptr, size_t size, size_t nmemb, void *stream)
{
    std::vector<char> *recvBuffer = (std::vector<char>*)stream;
    size_t sizes = size * nmemb;
    
    // add data to the end of recvBuffer
    // write data maybe called more than once in a single request
    recvBuffer->insert(recvBuffer->end(), (char*)ptr, (char*)ptr+sizes);
    
    return sizes;
}


static int processGetTask(HttpClient* client, HttpRequest* request, write_callback callback, void *stream, long *errorCode, write_callback headerCallback, void *headerStream, char* errorBuffer);
static int processPostTask(HttpClient* client, HttpRequest* request, write_callback callback, void *stream, long *errorCode, write_callback headerCallback, void *headerStream, char* errorBuffer);
static int processPutTask(HttpClient* client,  HttpRequest* request, write_callback callback, void *stream, long *errorCode, write_callback headerCallback, void *headerStream, char* errorBuffer);
static int processDeleteTask(HttpClient* client,  HttpRequest* request, write_callback callback, void *stream, long *errorCode, write_callback headerCallback, void *headerStream, char* errorBuffer);
// int processDownloadTask(HttpRequest *task, write_callback callback, void *stream, int32_t *errorCode);

// Worker thread
void HttpClient::networkThread()
{
    increaseThreadCount();

    while (true)
    {
        HttpRequest *request;

        // step 1: send http request if the requestQueue isn't empty
        {
            std::lock_guard<std::mutex> lock(_requestQueueMutex);
            while (_requestQueue.empty())
            {
                _sleepCondition.wait(_requestQueueMutex);
            }
            request = _requestQueue.at(0);
            _requestQueue.erase(0);
        }

        if (request == _requestSentinel) {
            break;
        }

        // step 2: libcurl sync access
        
        // Create a HttpResponse object, the default setting is http access failed
        HttpResponse *response = new (std::nothrow) HttpResponse(request);

        processResponse(response, _responseMessage);

        // add response packet into queue
        _responseQueueMutex.lock();
        _responseQueue.pushBack(response);
        _responseQueueMutex.unlock();

        _schedulerMutex.lock();
        if (nullptr != _scheduler)
        {
            _scheduler->performFunctionInCocosThread(CC_CALLBACK_0(HttpClient::dispatchResponseCallbacks, this));
        }
        _schedulerMutex.unlock();
    }
    
    // cleanup: if worker thread received quit signal, clean up un-completed request queue
    _requestQueueMutex.lock();
    _requestQueue.clear();
    _requestQueueMutex.unlock();

    _responseQueueMutex.lock();
    _responseQueue.clear();
    _responseQueueMutex.unlock();

    decreaseThreadCountAndMayDeleteThis();
}

// Worker thread
void HttpClient::networkThreadAlone(HttpRequest* request, HttpResponse* response)
{
    increaseThreadCount();

    char responseMessage[RESPONSE_BUFFER_SIZE] = { 0 };
    processResponse(response, responseMessage);

    _schedulerMutex.lock();
    if (nullptr != _scheduler)
    {
        _scheduler->performFunctionInCocosThread([this, response, request]{
            const ccHttpRequestCallback& callback = request->getCallback();
            Ref* pTarget = request->getTarget();
            SEL_HttpResponse pSelector = request->getSelector();

            if (callback != nullptr)
            {
				bool downloadPathSet = false;
				if (nullptr != _httpClient)
				{
					downloadPathSet = _httpClient->getDownloadPath().length() > 0;
				}

				if (downloadPathSet)
				{
					std::vector<char> success = {};
					std::string targetZipFile = _httpClient->_curSectionDownloadPath;
					std::string targetFileUrl = _httpClient->getFileFetchUrl();
					if (std::string::npos != targetZipFile.find(".zip"))
					{
						bool isGzip = ZipUtils::unZipFile(targetZipFile.c_str(), _httpClient->getDownloadPath().c_str());
						if (!isGzip)
						{
							success = { 'f', 'a', 'i', 'l', 'u', 'r', 'e'};
						}
						else
						{
							for (int i = 0; i < targetFileUrl.size(); ++i)
							{
								success.push_back(targetFileUrl[i]);
							}
						}
						FileUtils::getInstance()->removeFile(targetZipFile.c_str());
					}

					_curSectionCount += 1;
					// std::string strSection = std::to_string(_curSectionCount);
					
					response->setResponseData(&success);
					callback(this, response);
				}
				else
				{
					callback(this, response);
				}				
            }
            else if (pTarget && pSelector)
            {
                (pTarget->*pSelector)(this, response);
            }
            response->release();
            // do not release in other thread
            request->release();
        });
    }
    _schedulerMutex.unlock();

    decreaseThreadCountAndMayDeleteThis();
}

//Configure curl's timeout property
static bool configureCURL(HttpClient* client, CURL* handle, char* errorBuffer)
{
    if (!handle) {
        return false;
    }
    
    int32_t code;
    code = curl_easy_setopt(handle, CURLOPT_ERRORBUFFER, errorBuffer);
    if (code != CURLE_OK) {
        return false;
    }
    code = curl_easy_setopt(handle, CURLOPT_TIMEOUT, HttpClient::getInstance()->getTimeoutForRead());
    if (code != CURLE_OK) {
        return false;
    }
    code = curl_easy_setopt(handle, CURLOPT_CONNECTTIMEOUT, HttpClient::getInstance()->getTimeoutForConnect());
    if (code != CURLE_OK) {
        return false;
    }

    std::string sslCaFilename = client->getSSLVerification();
    if (sslCaFilename.empty()) {
        curl_easy_setopt(handle, CURLOPT_SSL_VERIFYPEER, 0L);
        curl_easy_setopt(handle, CURLOPT_SSL_VERIFYHOST, 0L);
    } else {
        curl_easy_setopt(handle, CURLOPT_SSL_VERIFYPEER, 1L);
        curl_easy_setopt(handle, CURLOPT_SSL_VERIFYHOST, 2L);
        curl_easy_setopt(handle, CURLOPT_CAINFO, sslCaFilename.c_str());
    }
    
    // FIXED #3224: The subthread of CCHttpClient interrupts main thread if timeout comes.
    // Document is here: http://curl.haxx.se/libcurl/c/curl_easy_setopt.html#CURLOPTNOSIGNAL 
    curl_easy_setopt(handle, CURLOPT_NOSIGNAL, 1L);

    curl_easy_setopt(handle, CURLOPT_ACCEPT_ENCODING, "");

	if (client->getDownloadSpeedLimit() > 0)
	{
		curl_easy_setopt(handle, CURLOPT_MAX_RECV_SPEED_LARGE, (curl_off_t)client->getDownloadSpeedLimit() * 1024);
	}

    return true;
}

class CURLRaii
{
    /// Instance of CURL
    CURL *_curl;
    /// Keeps custom header data
    curl_slist *_headers;

public:
    CURLRaii()
        : _curl(curl_easy_init())
        , _headers(nullptr)
    {
    }

    ~CURLRaii()
    {
        if (_curl)
            curl_easy_cleanup(_curl);
        /* free the linked list for header data */
        if (_headers)
            curl_slist_free_all(_headers);
    }

    template <class T>
    bool setOption(CURLoption option, T data)
    {
        return CURLE_OK == curl_easy_setopt(_curl, option, data);
    }

    /**
     * @brief Inits CURL instance for common usage
     * @param request Null not allowed
     * @param callback Response write callback
     * @param stream Response write stream
     */
    bool init(HttpClient* client, HttpRequest* request, write_callback callback, void* stream, write_callback headerCallback, void* headerStream, char* errorBuffer)
    {
        if (!_curl)
            return false;
        if (!configureCURL(client, _curl, errorBuffer))
            return false;

        /* get custom header data (if set) */
        std::vector<std::string> headers=request->getHeaders();
        if(!headers.empty())
        {
            /* append custom headers one by one */
            for (auto& header : headers)
                _headers = curl_slist_append(_headers,header.c_str());
            /* set custom headers for curl */
            if (!setOption(CURLOPT_HTTPHEADER, _headers))
                return false;
        }
        std::string cookieFilename = client->getCookieFilename();
        if (!cookieFilename.empty()) {
            if (!setOption(CURLOPT_COOKIEFILE, cookieFilename.c_str())) {
                return false;
            }
            if (!setOption(CURLOPT_COOKIEJAR, cookieFilename.c_str())) {
                return false;
            }
        }

        return setOption(CURLOPT_URL, request->getUrl())
                && setOption(CURLOPT_WRITEFUNCTION, callback)
                && setOption(CURLOPT_WRITEDATA, stream)
                && setOption(CURLOPT_HEADERFUNCTION, headerCallback)
                && setOption(CURLOPT_HEADERDATA, headerStream); 
    }

	bool getSize(HttpClient *client, HttpRequest* request)
	{
		client->setProgressEnabledFlag(false);
		client->setDownloadPath("");
		std::vector<std::string> headers = request->getHeaders();
		if (!headers.empty())
		{
			std::size_t findPos = std::string::npos;
			for (auto& header : headers)
			{
				if (std::string::npos != (findPos = header.find("download_path")))
				{
					std::string path = header.substr(findPos + strlen("download_path") + 2);
					//CCLOG("current downloading file path:%s\n", path.c_str());
					client->setDownloadPath(path);
					if (!FileUtils::getInstance()->isDirectoryExist(path.c_str()))
					{
						FileUtils::getInstance()->createDirectory(path.c_str());
					}
				}

				if (std::string::npos != (findPos = header.find("section")))
				{
					std::string count = header.substr(findPos + strlen("section") + 2);
					//CCLOG("current downloading file section:%s\n", count.c_str());
					client->setDownloadSectionCount(std::stol(count, nullptr, 10));
				}

				if (std::string::npos != (findPos = header.find("speed_limit")))
				{
					std::string speed = header.substr(findPos + strlen("speed_limit") + 2);
					//CCLOG("current downloading file speed limit:%s\n", speed.c_str());
					client->setDownloadSpeedLimit(std::stol(speed, nullptr, 10));
				}

				if (0 == strcmp(header.c_str(), "progress: true"))
				{
					client->setProgressEnabledFlag(true);
					client->setFileFetchUrl(std::string(request->getUrl()));
					CURL *handler = curl_easy_init();
					curl_easy_setopt(handler, CURLOPT_URL, request->getUrl());
					curl_easy_setopt(handler, CURLOPT_CUSTOMREQUEST, "GET");
					curl_easy_setopt(handler, CURLOPT_NOBODY, 1);
					CURLcode retCode = curl_easy_perform(handler);
					long retCode2 = 0;
					double retCode3 = 0;
					if (retCode == CURLE_OK) {
						retCode = curl_easy_getinfo(handler, CURLINFO_RESPONSE_CODE, &retCode2);
						if (retCode != CURLE_OK) {
							client->setFileSizeCount(0);
							client->setDownloadingFileSizeCount(0);
							curl_easy_cleanup(handler);
						}
						curl_easy_getinfo(handler, CURLINFO_CONTENT_LENGTH_DOWNLOAD, &retCode3);
						client->setFileSizeCount(long(retCode3));
						client->setDownloadingFileSizeCount(0);
						curl_easy_cleanup(handler);
					}
					else {
						client->setFileSizeCount(0);
						client->setDownloadingFileSizeCount(0);
						curl_easy_cleanup(handler);
					}
				}
			}
		}
		return true;
	}

    /// @param responseCode Null not allowed
    bool perform(long *responseCode)
    {
        if (CURLE_OK != curl_easy_perform(_curl))
            return false;
        CURLcode code = curl_easy_getinfo(_curl, CURLINFO_RESPONSE_CODE, responseCode);
        if (code != CURLE_OK || !(*responseCode >= 200 && *responseCode < 300)) {
            CCLOGERROR("Curl curl_easy_getinfo failed: %s", curl_easy_strerror(code));
            return false;
        }
        // Get some mor data.

        return true;
    }
};

//Process Get Request
static int processGetTask(HttpClient* client, HttpRequest* request, write_callback callback, void* stream, long* responseCode, write_callback headerCallback, void* headerStream, char* errorBuffer)
{
	CURLRaii curlPreLoaded;
	curlPreLoaded.getSize(client, request);
    CURLRaii curl;
    bool ok = curl.init(client, request, callback, stream, headerCallback, headerStream, errorBuffer)
            && curl.setOption(CURLOPT_FOLLOWLOCATION, true)
			&& curl.perform(responseCode);
    return ok ? 0 : 1;
}

//Process POST Request
static int processPostTask(HttpClient* client, HttpRequest* request, write_callback callback, void* stream, long* responseCode, write_callback headerCallback, void* headerStream, char* errorBuffer)
{
    CURLRaii curl;
    bool ok = curl.init(client, request, callback, stream, headerCallback, headerStream, errorBuffer)
            && curl.setOption(CURLOPT_POST, 1)
            && curl.setOption(CURLOPT_POSTFIELDS, request->getRequestData())
            && curl.setOption(CURLOPT_POSTFIELDSIZE, request->getRequestDataSize())
            && curl.perform(responseCode);
    return ok ? 0 : 1;
}

//Process PUT Request
static int processPutTask(HttpClient* client, HttpRequest* request, write_callback callback, void* stream, long* responseCode, write_callback headerCallback, void* headerStream, char* errorBuffer)
{
    CURLRaii curl;
    bool ok = curl.init(client, request, callback, stream, headerCallback, headerStream, errorBuffer)
            && curl.setOption(CURLOPT_CUSTOMREQUEST, "PUT")
            && curl.setOption(CURLOPT_POSTFIELDS, request->getRequestData())
            && curl.setOption(CURLOPT_POSTFIELDSIZE, request->getRequestDataSize())
            && curl.perform(responseCode);
    return ok ? 0 : 1;
}

//Process DELETE Request
static int processDeleteTask(HttpClient* client, HttpRequest* request, write_callback callback, void* stream, long* responseCode, write_callback headerCallback, void* headerStream, char* errorBuffer)
{
    CURLRaii curl;
    bool ok = curl.init(client, request, callback, stream, headerCallback, headerStream, errorBuffer)
            && curl.setOption(CURLOPT_CUSTOMREQUEST, "DELETE")
            && curl.setOption(CURLOPT_FOLLOWLOCATION, true)
            && curl.perform(responseCode);
    return ok ? 0 : 1;
}

// HttpClient implementation
HttpClient* HttpClient::getInstance()
{
    if (_httpClient == nullptr)
    {
        _httpClient = new (std::nothrow) HttpClient();
    }
    
    return _httpClient;
}

void HttpClient::destroyInstance()
{
    if (nullptr == _httpClient)
    {
        CCLOG("HttpClient singleton is nullptr");
        return;
    }

    CCLOG("HttpClient::destroyInstance begin");
    auto thiz = _httpClient;
    _httpClient = nullptr;

    thiz->_scheduler->unscheduleAllForTarget(thiz);
    thiz->_schedulerMutex.lock();
    thiz->_scheduler = nullptr;
    thiz->_schedulerMutex.unlock();

    thiz->_requestQueueMutex.lock();
    thiz->_requestQueue.pushBack(thiz->_requestSentinel);
    thiz->_requestQueueMutex.unlock();

    thiz->_sleepCondition.notify_one();
    thiz->decreaseThreadCountAndMayDeleteThis();

    CCLOG("HttpClient::destroyInstance() finished!");
}

void HttpClient::enableCookies(const char* cookieFile)
{
    std::lock_guard<std::mutex> lock(_cookieFileMutex);
    if (cookieFile)
    {
        _cookieFilename = std::string(cookieFile);
    }
    else
    {
        _cookieFilename = (FileUtils::getInstance()->getWritablePath() + "cookieFile.txt");
    }
}
    
void HttpClient::setSSLVerification(const std::string& caFile)
{
    std::lock_guard<std::mutex> lock(_sslCaFileMutex);
    _sslCaFilename = caFile;
}

HttpClient::HttpClient()
: _isInited(false)
, _timeoutForConnect(300)
, _timeoutForRead(600)
, _threadCount(0)
, _cookie(nullptr)
, _fileSizeCount(0)
, _fileDownloadingSizeCount(0)
, _fileFetchUrl("")
, _progressEnabledFlag(false)
, _downloadPath("")
, _downloadSectionCount(0)
, _curSectionCount(0)
, _curSectionDownloadPath("")
, _fop(NULL)
, _prevPerRatioMarked(0)
, _downloadSpeedLimit(0)
, _requestSentinel(new HttpRequest())
{
    CCLOG("In the constructor of HttpClient!");
    memset(_responseMessage, 0, RESPONSE_BUFFER_SIZE * sizeof(char));
    _scheduler = Director::getInstance()->getScheduler();
    increaseThreadCount();
}

HttpClient::~HttpClient()
{
    CC_SAFE_RELEASE(_requestSentinel);
    CCLOG("HttpClient destructor");
}

//reserved
void HttpClient::dispatchProgress()
{
	increaseThreadCount();
	while (_httpClient->getDownloadingFileSizeCount() <= _httpClient->getFileSizeCount())
	{
		long size = _httpClient->getDownloadingFileSizeCount();
		long totalSize = _httpClient->getFileSizeCount();
		double sizeRatio = 0 == totalSize ? 0.0f : (size * 1.0) / totalSize;
		int perRatio = ceil(sizeRatio * 100);
		bool progressFlag = _httpClient->getProgressEnabledFlag();
		std::string fetchUrl = _httpClient->getFileFetchUrl();
		if (progressFlag)
		{
			EventDispatcher* dispatcher = Director::getInstance()->getEventDispatcher();
			std::string data("{\"url\":\"");
			data += fetchUrl + "\",\"percent\":\"";
			data += std::to_string(perRatio) + "\"}";
			dispatcher->dispatchCustomEvent("URL_FETCH_PROGRESS", (void*)(data.c_str()));
			if (100 == perRatio)
			{
				break;
			}
		}
	}
	decreaseThreadCountAndMayDeleteThis();
}

int HttpClient::stringReplace(std::string &out, const std::string &in1, const std::string &in2)
{
	std::string::size_type pos = 0;
	std::string::size_type in1Size = in1.size();
	std::string::size_type in2Size = in2.size();
	while ((pos = out.find(in1, pos)) != std::string::npos)
	{
		out.replace(pos, in1Size, in2);
		pos += in1Size;
	}
	return 0;
}

std::string HttpClient::calcUniformCapacity(double size)
{
	std::string unit = "";
	char tsize[10] = "";
	if (size > 1024 * 1024 * 1024)
	{
		unit = "G";
		size /= 1024 * 1024 * 1024;
	}
	else if (size > 1024 * 1024)
	{
		unit = "M";
		size /= 1024 * 1024;
	}
	else if (size > 1024)
	{
		unit = "KB";
		size /= 1024;
	}
	sprintf(tsize, "%.1f", size);
	std::string res = tsize + unit;
	return res;
}

long HttpClient::getDownloadSpeedLimit()
{
	return _downloadSpeedLimit;
}

void HttpClient::setDownloadSpeedLimit(long speed)
{
	_downloadSpeedLimit = speed;
}

long HttpClient::getDownloadSectionCount()
{
	return _downloadSectionCount;
}

void HttpClient::setDownloadSectionCount(long section)
{
	_downloadSectionCount = section;
}

std::string HttpClient::getDownloadPath()
{
	return _downloadPath;
}

void HttpClient::setDownloadPath(std::string path)
{
	_downloadPath = path;
}

void HttpClient::setProgressEnabledFlag(bool flag)
{
	_progressEnabledFlag = flag;
}

bool HttpClient::getProgressEnabledFlag()
{
	return _progressEnabledFlag;
}

long HttpClient::getFileSizeCount()
{
	return _fileSizeCount;
}

void HttpClient::setFileSizeCount(long size)
{
	_fileSizeCount = size;
}

std::string HttpClient::getFileFetchUrl()
{
	return _fileFetchUrl;
}

void HttpClient::setFileFetchUrl(std::string url)
{
	_fileFetchUrl = url;
}

long HttpClient::getDownloadingFileSizeCount()
{
	return _fileDownloadingSizeCount;
}

void HttpClient::setDownloadingFileSizeCount(long size)
{
	_fileDownloadingSizeCount = size;
}

//Lazy create semaphore & mutex & thread
bool HttpClient::lazyInitThreadSemaphore()
{
    if (_isInited)
    {
        return true;
    }
    else
    {
        auto t = std::thread(CC_CALLBACK_0(HttpClient::networkThread, this));
        t.detach();
        _isInited = true;
    }
    
    return true;
}

//Add a get task to queue
void HttpClient::send(HttpRequest* request)
{	
    if (false == lazyInitThreadSemaphore())
    {
        return;
    }
    
    if (!request)
    {
        return;
    }
	
    request->retain();
	_fileSizeCount = 0;
	_fileDownloadingSizeCount = 0;
	_curSectionCount = 0;
	_curSectionDownloadPath = "";
	_prevPerRatioMarked = 0;
	_downloadSpeedLimit = 0;
	
    _requestQueueMutex.lock();
    _requestQueue.pushBack(request);
    _requestQueueMutex.unlock();

    // Notify thread start to work
    _sleepCondition.notify_one();
}

void HttpClient::sendImmediate(HttpRequest* request)
{
    if(!request)
    {
        return;
    }

    request->retain();
    // Create a HttpResponse object, the default setting is http access failed
    HttpResponse *response = new (std::nothrow) HttpResponse(request);

    auto t = std::thread(&HttpClient::networkThreadAlone, this, request, response);
    t.detach();
}

// Poll and notify main thread if responses exists in queue
void HttpClient::dispatchResponseCallbacks()
{
    // log("CCHttpClient::dispatchResponseCallbacks is running");
    //occurs when cocos thread fires but the network thread has already quited
    HttpResponse* response = nullptr;

    _responseQueueMutex.lock();
    if (!_responseQueue.empty())
    {
        response = _responseQueue.at(0);
        _responseQueue.erase(0);
    }
    _responseQueueMutex.unlock();
    
    if (response)
    {
        HttpRequest *request = response->getHttpRequest();
        const ccHttpRequestCallback& callback = request->getCallback();
        Ref* pTarget = request->getTarget();
        SEL_HttpResponse pSelector = request->getSelector();

        if (callback != nullptr)
        {
            callback(this, response);
        }
        else if (pTarget && pSelector)
        {
            (pTarget->*pSelector)(this, response);
        }
        
        response->release();
        // do not release in other thread
        request->release();
    }
}

// Process Response
void HttpClient::processResponse(HttpResponse* response, char* responseMessage)
{
    auto request = response->getHttpRequest();
    long responseCode = -1;
    int retValue = 0;

    // Process the request -> get response packet
    switch (request->getRequestType())
    {
    case HttpRequest::Type::GET: // HTTP GET
        retValue = processGetTask(this, request,
            writeData,
            response->getResponseData(),
            &responseCode,
            writeHeaderData,
            response->getResponseHeader(),
            responseMessage);
        break;

    case HttpRequest::Type::POST: // HTTP POST
        retValue = processPostTask(this, request,
            writeData,
            response->getResponseData(),
            &responseCode,
            writeHeaderData,
            response->getResponseHeader(),
            responseMessage);
        break;

    case HttpRequest::Type::PUT:
        retValue = processPutTask(this, request,
            writeData,
            response->getResponseData(),
            &responseCode,
            writeHeaderData,
            response->getResponseHeader(),
            responseMessage);
        break;

    case HttpRequest::Type::DELETE:
        retValue = processDeleteTask(this, request,
            writeData,
            response->getResponseData(),
            &responseCode,
            writeHeaderData,
            response->getResponseHeader(),
            responseMessage);
        break;

    default:
        CCASSERT(false, "CCHttpClient: unknown request type, only GET, POST, PUT or DELETE is supported");
        break;
    }

    // write data to HttpResponse
    response->setResponseCode(responseCode);
    if (retValue != 0)
    {
        response->setSucceed(false);
        response->setErrorBuffer(responseMessage);
    }
    else
    {
        response->setSucceed(true);
    }
}

void HttpClient::increaseThreadCount()
{
    _threadCountMutex.lock();
    ++_threadCount;
    _threadCountMutex.unlock();
}

void HttpClient::decreaseThreadCountAndMayDeleteThis()
{
    bool needDeleteThis = false;
    _threadCountMutex.lock();
    --_threadCount;
    if (0 == _threadCount)
    {
        needDeleteThis = true;
    }

    _threadCountMutex.unlock();
    if (needDeleteThis)
    {
        delete this;
    }
}

void HttpClient::setTimeoutForConnect(int value)
{
    std::lock_guard<std::mutex> lock(_timeoutForConnectMutex);
    _timeoutForConnect = value;
}
    
int HttpClient::getTimeoutForConnect()
{
    std::lock_guard<std::mutex> lock(_timeoutForConnectMutex);
    return _timeoutForConnect;
}
    
void HttpClient::setTimeoutForRead(int value)
{
    std::lock_guard<std::mutex> lock(_timeoutForReadMutex);
    _timeoutForRead = value;
}
    
int HttpClient::getTimeoutForRead()
{
    std::lock_guard<std::mutex> lock(_timeoutForReadMutex);
    return _timeoutForRead;
}
    
const std::string& HttpClient::getCookieFilename()
{
    std::lock_guard<std::mutex> lock(_cookieFileMutex);
    return _cookieFilename;
}
    
const std::string& HttpClient::getSSLVerification()
{
    std::lock_guard<std::mutex> lock(_sslCaFileMutex);
    return _sslCaFilename;
}

}

NS_CC_END


