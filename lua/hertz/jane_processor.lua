--数据状态保留
local snapshot={
	input="",
	caret_pos=0,
	segs={},
}
local function comp_iter(comp)
	return function()
		if comp:empty()==false then
			local seg=comp:back()
			comp:pop_back()
			return seg
		end
	end
end
--保存
function snapshot:save(env)
	local ctx=env.engine.context
	snapshot.input=ctx.input
	snapshot.caret_pos=ctx.caret_pos
	snapshot.segs={}
	local comp=ctx.composition
	if comp:empty()==false then
		for seg in comp_iter(comp) do
			table.insert(snapshot.segs,seg)
		end
	end
end
--恢复
function snapshot:restore(env)
	if (snapshot.input ~= "") then
		local ctx=env.engine.context
		ctx.input=snapshot.input
		ctx.caret_pos=snapshot.caret_pos
		local comp=ctx.composition
		for _,seg in ipairs(snapshot.segs) do
			comp:push_back(seg)
		end
		ctx:refresh_non_confirmed_composition ()
		--重置
		snapshot.input = ""
		return true
	end
	return false
end
--获取单个字符长度
local function getCharSize(char)
    if not char then
        return 0
    elseif char > 239 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end
--获取中文字符长度
local function getUtf8Len(str)
    local len = 0
    local currentIndex = 1
    while currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + getCharSize(char)
        len = len + 1
    end
    return len
end

--截取中文字符串
local function strUtf8Sub(str, startChar, numChars)
    local startIndex = 1
    while startChar > 1 do
        local char = string.byte(str, startIndex)
        startIndex = startIndex + getCharSize(char)
        startChar = startChar - 1
    end

    local currentIndex = startIndex

    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + getCharSize(char)
        numChars = numChars - 1
    end

    return string.sub(str, startIndex, currentIndex - 1)
end


--遍历字符串
local function strUtf8Ipairs(str)
    local startIndex = 1;
    local key = 0
    local _str = str;

    return function()
        if str == nil or #str == 0 then
            return nil
        end
        local char = string.byte(str, startIndex)
        local len = getCharSize(char)
        if len == 0 then
            return nil
        end
        local currentIndex = startIndex + len;
        local value = _str:sub(startIndex, currentIndex - 1)
        startIndex = startIndex + len
        key = key + 1;
        return key, value
    end
end

---
---解析编码
---@param input string 输入编码
---@return table 编码集合
---
local function analyze(input)
    -- 字符串拆分集合
    local list = {}

    -- 拆分下标
    local index = 1;

    --执行拆分
    while index <= #input do
        local char = input:sub(index, index);
        if char == "\"" then
            -- 如果遇到引号，则取三个字符
            table.insert(list, input:sub(index, index + 2))
            index = index + 3
        else
            if (index + 1 <= #input) then
                -- 否则取两个字符
                table.insert(list, input:sub(index, index + 1))
                index = index + 2
            else
                table.insert(list, input:sub(index, index))
                index = index + 1
            end
        end
    end

    -- 拆分匹配
    local matches = {}
    local code = ""
    for i, item in ipairs(list) do
        local res = string.match(item, "^[A-Z][A-Z]")
        if (res == nil) then
            -- 如果遇到声韵码，则添加进匹配表
            if (code ~= "") then
                table.insert(matches, code)
            end
            -- 重置编码
            code = item
        else
            -- 组合编码
            code = code .. item
        end
    end

    --补齐最后的编码
    if (code ~= "") then
        table.insert(matches, code)
    end

    return matches
end

--检查一击词
local function word(input, keyCode)
    if (input == "") then
        return ""
    end

    --检查空格组合
    local text = input:sub(#input - 1, #input)

    --左组合
    local lFlag = false
    local lArray = {
        "\"a", "\"A", "\"b", "\"B", "\"c", "\"C", "\"d", "\"D", "\"e", "\"E", "\"f", "\"F", "\"g", "\"G",
        "\"h", "\"H", "\"i", "\"I", "\"j", "\"J", "\"k", "\"K", "\"l", "\"L", "\"m", "\"M", "\"n", "\"N",
        "\"o", "\"O", "\"p", "\"P", "\"q", "\"Q", "\"r", "\"R", "\"s", "\"S", "\"t", "\"T",
        "\"u", "\"U", "\"v", "\"V", "\"w", "\"W", "\"x", "\"X", "\"y", "\"Y", "\"z", "\"Z",
        "\"1", "\"2", "\"3", "\"4", "\"5", "\"6", "\"7", "\"8", "\"9", "\"0",
        "\",", "\"^", "\"/", "\"\\", "\"!", "\"?", "\";", "\":", "\"@", "\"$", "\"%", "\".",
        "\"[", "\"]", "\"(", "\")", "\"<", "\">", "\"~", "\"|", "\"*", "\"+", "\"&", "\"#", "\"'", "\"`", "\"}", "\"{", "\"-", "\"="
    }

    for i = 1, #lArray do
        if (text == lArray[i]) then
            lFlag = true
            break
        end
    end

    if (lFlag) then
        if (keyCode == 95) then
            return text .. "_"
        end
    end


    --右组合
    local rFlag = false
    local rArray = {
        97, 65, 98, 66, 99, 67, 100, 68, 101, 69, 102, 70, 103, 71,
        104, 72, 105, 73, 106, 74, 107, 75, 108, 76, 109, 77, 110, 78,
        111, 79, 112, 80, 113, 81, 114, 82, 115, 83, 116, 84,
        117, 85, 118, 86, 119, 87, 120, 88, 121, 89, 122, 90,
        49, 50, 51, 52, 53, 54, 55, 56, 57, 48,
        44, 94, 47, 92, 33, 63, 59, 58, 64, 36, 37, 46,
        91, 93, 40, 41, 60, 62, 126, 124, 42, 43, 38, 35, 39, 96, 125, 123, 45, 61
    }

    local mapArray = {
        "a", "A", "b", "B", "c", "C", "d", "D", "e", "E", "f", "F", "g", "G",
        "h", "H", "i", "I", "j", "J", "k", "K", "l", "L", "m", "M", "n", "N",
        "o", "O", "p", "P", "q", "Q", "r", "R", "s", "S", "t", "T",
        "u", "U", "v", "V", "w", "W", "x", "X", "y", "Y", "z", "Z",
        "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
        ",", "^", "/", "\\", "!", "?", ";", ":", "@", "$", "%", ".",
        "[", "]", "(", ")", "<", ">", "~", "|", "*", "+", "&", "#", "'", "`", "}", "{", "-", "="
    }

    if (text == "\"_") then
        for i = 1, #rArray do
            if (keyCode == rArray[i]) then
                rFlag = true
                break
            end
        end
    end

    if (rFlag) then
        local str = ""
        for i = 1, #rArray do
            if (keyCode == rArray[i]) then
                str = mapArray[i]
            end
        end
        return "\"_" .. str
    end

    -- 拆分编码集合
    --[[
	local groups = {}
    for each in string.gmatch(scriptText, "%S+") do
        table.insert(groups, each)
    end
    local last = groups[#groups]
	]]
    local groups = analyze(input)
    local last = groups[#groups]
	
    -- 判断编码
    if (last ~= nil) then
        if (#last % 2 == 0) then
            --正常编码
            return ""
        end
    end



    --检查常规组合
    text = input:sub(#input, #input)

    --有下划线直接允许
    if (text ~= "") then
        if (text == "_") then
            -- "__"双下划线
            if (keyCode == 95) then
                return "__"
				--return ""
            end

            local str = ""
            for i = 1, #rArray do
                if (keyCode == rArray[i]) then
                    str = mapArray[i]
                end
            end
            return "_" .. str
        elseif (text ~= "\"") then
            if (keyCode == 95) then
                return text .. "_"
            end
        end
    end

    local array = {
        "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
        ",", "^", "/", "\\", "!", "?", ";", ":", "@", "$", "%", ".",
        "[", "]", "(", ")", "<", ">", "~", "|", "*", "+", "&", "#", "'", "`", "}", "{", "-", "="
    }

    --左组合
    local llArray = {
        49, 50, 51, 52, 53, 54, 55, 56, 57, 48,
        44, 94, 47, 92, 33, 63, 59, 58, 64, 36, 37, 46,
        91, 93, 40, 41, 60, 62, 126, 124, 42, 43, 38, 35, 39, 96, 125, 123, 45, 61
    }

    for i = 1, #llArray do
        if (keyCode == llArray[i]) then
            local str = ""
            for j = 1, #llArray do
                if (keyCode == llArray[j]) then
                    str = array[j]
                end
            end
            if (text == "\"") then
                return ""
            end
            return text .. str
        end
    end

    --右组合
    local rrArray = {
        "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
        ",", "^", "/", "\\", "!", "?", ";", ":", "@", "$", "%", ".",
        "[", "]", "(", ")", "<", ">", "~", "|", "*", "+", "&", "#", "'", "`", "}", "{", "-", "="
    }
    for i = 1, #rrArray do
        if (text == rrArray[i]) then
            local str = ""
            for j = 1, #rArray do
                if (keyCode == rArray[j]) then
                    str = mapArray[j]
                    return text .. str
                end
            end
        end
    end

    --非一击词
    return ""
end

---
---选择
---@param index string 下标
---
local function getCand(index,context,segment,flag)
	-- 删除一位编码
	if (flag) then
		context:pop_input(1)
	end
	-- 选择候选
	segment.selected_index = index
	segment.status = 3
	-- 返回
	local cand = segment:get_candidate_at(index)
	if (cand) then
		return cand.text
	end
	return ""
end

---
---初始化
---@param env object 上下文对象
---
local function init(env)
    --创建对象
    env.mem = Memory(env.engine, env.engine.schema)
    --引号正反标识
    env.flag = true
	--最后输入
	env.laststr = ""
end

---
---初始化
---@param key_event table 按键对象
---@param env table 上下文对象
---
local function processor(key_event, env)
    local engine = env.engine
    local context = engine.context
    local input = context.input
    local text = context:get_script_text()
	local composition = context.composition
	local segment = nil
	if(not composition:empty()) then
		segment = composition:back()
	end
	
	--最后输入
	local lasttext = context.commit_history:latest_text()
	if (lasttext ~= "") then
		env.laststr = lasttext
	end
	
	--判断白名单
	if (#input > 2) then
		if (input:sub(1, 2) == "au") then
			return 2
		elseif (input:sub(1, 2) == "at") then
			return 2
		elseif (input:sub(1, 2) == "aq") then
			return 2
		end
	end

    --检查一击词
    local code = word(input, key_event.keycode)

    --[[
    engine:commit_text(" =")
    engine:commit_text("input:"..input..",")
    engine:commit_text("text:"..text..",")
    engine:commit_text("keycode:"..key_event.keycode..",")
    engine:commit_text("code:"..code)
    engine:commit_text("= ")
    ]]

    --判断以击词
    if (code ~= "") then
		-- 判断小写字母
		if (string.find(code, "\"") == nil and (string.match(code, "%l") ~= nil and string.find(code, "_") ~= nil)) then
			context:pop_input(1)
			return 1
		end
		
        --上屏候选词
		if (#input > 1) then
			local found = string.find(input, "\"")
			if (found) then
				if (found > 1) then
					context:pop_input(1)
					local candidate = getCand(0,context,segment,true)
					if (candidate ~= "") then
						engine:commit_text(candidate)
					end
				end
			else 
				local candidate = getCand(0,context,segment,true)
				if (candidate ~= "") then
					engine:commit_text(candidate)
				end
			end
		end
		
	
        --检查特殊编码
        if (code == "#_") then
            engine:commit_text("#")
        elseif (code == "__") then
            engine:commit_text(env.laststr)
        else
            env.mem:dict_lookup(code, false, 1)
            -- 遍历字典
            for entry in env.mem:iter_dict() do
                engine:commit_text(entry.text)
            end
        end
		
		--清除编码
		context:clear_previous_segment()
		context:clear()
		return 1
    end

    return 2
end

return { init = init, func = processor }
