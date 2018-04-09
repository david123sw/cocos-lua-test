function LoginScene:hasServerMaintainceNotice(owner, isIgnore)
    if gt.hasServerMaintainceNoticeDisplayed then
        return
    end

    gt.showLoadingTips("")

    if owner.xhr == nil then
        owner.xhr = cc.XMLHttpRequest:new()
        owner.xhr.timeout = 30 -- 设置超时时间
    end
    owner.xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    local url = gt.SERVER_MAINTAIN_NOTICE

    owner.xhr:open("GET", url)
    owner.xhr:registerScriptHandler(function ()
        if owner.xhr.readyState == 4 and (owner.xhr.status >= 200 and owner.xhr.status < 207) then

        gt.removeLoadingTips()

        local bit = require("bit")
        local function unicode_to_utf8(convertStr)
            if type(convertStr)~="string" then
                return convertStr
            end

            local resultStr=""
                local i=1
            while true do
                local num1=string.byte(convertStr,i)
                local unicode

                if num1~=nil and string.sub(convertStr,i,i+1)=="\\u" then
                    unicode=tonumber("0x"..string.sub(convertStr,i+2,i+5))
                    i=i+6
                elseif num1~=nil then
                    unicode=num1
                    i=i+1
                else
                    break
                end

                if unicode <= 0x007f then
                    resultStr=resultStr..string.char(bit.band(unicode,0x7f))
                elseif unicode >= 0x0080 and unicode <= 0x07ff then
                    resultStr=resultStr..string.char(bit.bor(0xc0,bit.band(bit.rshift(unicode,6),0x1f)))
                    resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
                elseif unicode >= 0x0800 and unicode <= 0xffff then
                    resultStr=resultStr..string.char(bit.bor(0xe0,bit.band(bit.rshift(unicode,12),0x0f)))
                    resultStr=resultStr..string.char(bit.bor(0x80,bit.band(bit.rshift(unicode,6),0x3f)))
                    resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
                end
            end
            resultStr=resultStr..'\0'
            return resultStr
        end

        require("json")
        local prepare, num = string.gsub(owner.xhr.response, "\\", "\\\\")
        local xhrParsedResp = json.decode(prepare)
        gt.dump(xhrParsedResp, "------------------xxxxxxxxxxxxxxxxxxxxx")
        if xhrParsedResp.open then
            if nil == isIgnore then
                owner.serverNoticeTitle = 0 < #xhrParsedResp.title and unicode_to_utf8(xhrParsedResp.title) or ""
                owner.serverNoticeBody = 0 < #xhrParsedResp.body and unicode_to_utf8(xhrParsedResp.body) or ""
                gt.log("---sziee#owner.serverNoticeBody__:"..#owner.serverNoticeBody)
                gt.log("---sziee_#owner.serverNoticeTitle_:"..#owner.serverNoticeTitle)
                if #owner.serverNoticeBody > 0 then
                    local agreementPanel = require("app/views/ServerNotice"):create(owner.serverNoticeTitle, owner.serverNoticeBody)
                    owner:addChild(agreementPanel, 6)
                    gt.hasServerMaintainceNoticeDisplayed = true
                end	            
            else
                gt.log("登陆时忽略")
            end
        else
            require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0054"), function ()
                cc.Director:getInstance():endToLua()
            end, nil, true)
        end

        elseif owner.xhr.readyState == 1 and owner.xhr.status == 0 then
            -- 网络问题,异常断开
            gt.removeLoadingTips()
        end
        owner.xhr:unregisterScriptHandler()
    end)
    owner.xhr:send()
end