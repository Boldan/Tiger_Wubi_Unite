--[[
--无障碍版专用脚本
--用途：快捷加词
--如何使用: 请参考群文件，路径[同文无障碍LUA脚本]->同文无障碍版lua脚本使用说明.pdf
--配置说明

第①步 将 快捷加词.lua 文件放置 rime/script 文件夹内

第②步 向主题方案中加入按键
以 XXX.trime.yaml主题方案为例
preset_keys:
  yjjc_lua: {label: 快捷加词, send: function, command: '快捷加词自动编码【定长】/快捷加词自动编码【定长】.lua'}#若使用这个，则需要在lua里修改词库，和"单字码表"
  yjjc_lua: {label: 快捷加词, send: function, command: '快捷加词自动编码【定长】/快捷加词自动编码【定长】.lua', option: "《《命令行》》【【词库名.txt】】【【单字码表名】】"}#词库名称和单字码表名为自定义项，可以不是单字表，但是建议使用单字表，(PS：码表文件太大会卡死
向任意按键加入上述按键既可

]]
require "import"
import "android.widget.*"
import "android.view.*"
import "java.io.File"
import "android.app.AlertDialog"

local 版本号="2.0"
local 参数=(...)
local 词库文件名="xklbXY53_lua_sdjc.txt"
local 单字码表名="xklbXY53.dict.yaml"--单字码表，可以不是单字表，但是建议使用单字表，(PS：码表文件太大会卡死
local 输入法目录=tostring(service.getLuaExtDir(""))
local 脚本目录=输入法目录.."/script"
local 脚本路径=debug.getinfo(1,"S").source:sub(2)--获取Lua脚本的完整路径
local 纯脚本名=File(脚本路径).getName()
local 目录=string.sub(脚本路径,1,#脚本路径-#纯脚本名)
local 脚本相对路径=string.sub(脚本路径,#脚本目录+1)

if 参数!=nil && string.find(参数,"《《命令行》》")!=nil then
	词库文件名 = 参数:match("》》【【(.-)】】【【")
	单字码表名 = 参数:match("】】【【(.-)】】")
end
local 词库文件路径=输入法目录.."/"..词库文件名
local 单字码表路径=输入法目录.."/"..单字码表名



local function 数组去重复(数组)
  local exist = {}
  --把相同的元素覆盖掉
  for v, k in pairs(数组) do
    exist[k] = true
  end
  --重新排序表
  local newTable = {}
  for v, k in pairs(exist) do
    table.insert(newTable, v)
  end
  return newTable
end

local function 获取编码(词条)
	local 词组=""
	local 单字码表内容=io.open(单字码表路径):read("*a")
	for i=1,#词条 do
		if utf8.find(单字码表内容,"\n"..utf8.sub(词条,i,i).."\t")~= nil then
			词组=词组..utf8.sub(词条,i,i)
		end
	end
	local n=utf8.len(词组)
	local 编码组={}
	local a={}
	local b={}
	local q={}
	local f={}
	local e={}
	local i=1
	local k=1
	local d=1
	local p=1
	local m=1
	if n==2 then
		for c in io.lines(单字码表路径) do
			if utf8.match(c,"(.-)\t.*")== utf8.sub(词组,1,1) then
				a[i]=utf8.match(c,"\t([a-z][a-z])")
				i=i+1
			end
			if utf8.match(c,"(.-)\t.*")== utf8.sub(词组,2,2)then
				b[k]=utf8.match(c,"\t([a-z][a-z])")
				k=k+1
			end
		end
		for i =1,#a do
			for n =1,#b do
				e[m]=a[i]..b[n]
				m=m+1
			end
		end
		
		for i=1,#e do
			编码组[i]=e[i]
		end
		
		
	elseif n==3 then
		for c in io.lines(单字码表路径) do
			if utf8.match(c,"(.-)\t.*")== utf8.sub(词组,1,1) then
				a[i]=string.match(c,"\t([a-z][a-z])")
				i=i+1
			end
			if utf8.match(c,"(.-)\t.*")== utf8.sub(词组,2,2) then
				b[k]=string.match(c,"\t([a-z][a-z])")
				k=k+1
			end
			if utf8.match(c,"(.-)\t.*")== utf8.sub(词组,3,3) then
				q[d]=string.match(c,"\t([a-z][a-z])")
				d=d+1
			end
		end
		for i =1,#a do
			for n =1,#b do
				for t =1,#q do
					e[m]=a[i]..b[n]..q[t]
					m=m+1
				end
			end
		end
		
		for i=1,#e do
			编码组[i]=string.sub(e[i],1,1)..string.sub(e[i],3,3)..string.sub(e[i],5,5)
			编码组[#e+i]=string.sub(e[i],1,1)..string.sub(e[i],3,3)..string.sub(e[i],5,6)
		end
		
	elseif n>=4 then
	for c in io.lines(单字码表路径) do
			if utf8.match(c,"(.-)\t.*")== utf8.sub(词组,1,1) then
				a[i]=string.match(c,"\t([a-z][a-z])")
				i=i+1
			end
			if utf8.match(c,"(.-)\t.*")== utf8.sub(词组,2,2) then
				b[k]=string.match(c,"\t(..)")
				k=k+1
			end
			if utf8.match(c,"(.-)\t.*")== utf8.sub(词组,3,3) then
				q[d]=string.match(c,"\t(..)")
				d=d+1
			end
			if utf8.match(c,"(.-)\t.*")== utf8.sub(词组,-1,-1) then
				f[p]=string.match(c,"\t([a-z][a-z])")
				p=p+1
			end
		end
		for i =1,#a do
			for n =1,#b do
				for t =1,#q do
					for s =1,#f do
						e[m]=a[i]..b[n]..q[t]..f[s]
						m=m+1
					end
				end
			end
		end
		
		for i=1,#e do
			编码组[i]=string.sub(e[i],1,1)..string.sub(e[i],3,3)..string.sub(e[i],5,5)..string.sub(e[i],7,7)
		end

	end  --if n>=4 then
	
	编码组=数组去重复(编码组)
	return 编码组
end


local function 刷新方案()
	local 方案组=Rime.getSchemaNames() --返回输入法方案组
	if #方案组==1 then
		print("当前只有1个方案,无法切换,请保证有两个方案")
		return --退出
	end
	local 方案编号=Rime.getSchemaIndex()
	local 切换编号=0
	if 方案编号==0 then 切换编号=1 end
		local 结果=Rime.selectSchema(切换编号)
		Rime.selectSchema(方案编号)
	if 结果==false then print("方案切换失败,请保证有两个方案") end
end

function 写入词库(字符串,词库文件)
	io.open(词库文件,"a+"):write("\n"..字符串):close()
	Toast.makeText(service," 词组【"..字符串.."】 添加成功",2000).show()
	刷新方案()
end

local function 加词位置按照字母表顺序(路径,词条,编码)
    local d={}
	for c in io.lines(路径) do
		if c:find("	")~=nil then
			d[#d+1]=c:match("	(.+)")
		end
	end
	d[#d+1]=编码
	table.sort(d)
	for i=1, #d do
		if d[i]==编码 then
			内容=io.open(路径):read("*a")
			io.open(路径,"w+"):write(tostring(内容:gsub("\t"..d[i-1],"\t"..d[i-1].."\n"..词条.."\t"..编码))):close()
		end
	end
	刷新方案()
end

local function 导入模块(模块,内容)
   dofile_信息表=nil
   dofile_信息表={}
   dofile_信息表.上级脚本=脚本路径
   dofile_信息表.上级脚本所在目录=目录
   dofile_信息表.上级脚本相对路径=脚本相对路径
   dofile_信息表.纯脚本名=纯脚本名:sub(1,-5)
   dofile_信息表.内容=内容
   dofile_信息表.词库=词库文件路径
   dofile(目录..模块)--导入模块
end


layout={
    LinearLayout,
    orientation="vertical",
    {
        LinearLayout,
        layout_width="fill",
        orientation="horizontal",
        layout_height="145",
        gravity="center",
        {
            Button,
            id="citiao",
            text="词条 ：",
            layout_weight="1",
            },
        {
            EditText,
            id="edit",
            layout_weight="20",
            Hint="请在此处输入词条",
            singleLine=true,        --设置单行输入
            }
        },
    {
        LinearLayout,
        layout_width="fill",
        orientation="horizontal",
        layout_height="145",
        gravity="center",
        {
            Button,
            id="bianma",
            text="编码 ：",
            layout_weight="1",
            },
        {
            EditText,
            id="edit2",
            layout_weight="20",
            Hint="请在此处输入编码",
            singleLine=true,        --设置单行输入
            }
        },
    {
        LinearLayout,
        layout_width="fill",
        orientation="horizontal",
        layout_height="145",
        gravity="center",
        {
            Button,
            id="quxiao",
            text="取消",
            layout_weight="1",
            },
        {
            Button,
            id="shengcheng",
            text="生成",
            layout_weight="1",
            },
        {
            Button,
            id="queding",
            text="确定",
            layout_weight="1",
            }
        }
    }





local ids,layout2={},{LinearLayout,
  --键盘高度
  layout_height=service.getLastKeyboardHeight(),
  layout_width=-1,
  --背景颜色，默认透明
  BackgroundColor=0x88ffffff,
  {ListView,
    id="list",
    layout_width=-1}}
layout2=loadlayout(layout2,ids)

local data,item={},{LinearLayout,
  layout_width=-1,
  padding="4dp",
  gravity=3|17,
  {TextView,
    id="a",
    textColor=0xff232323,
    textSize="15dp"},
  {TextView,
    id="b",
    gravity=3|17,
    paddingLeft="4dp",
    --最大显示行数
    MaxLines=3,
    --最小高度
    MinHeight="30dp",
    textColor=0xff232323,
    textSize="25dp"}}
local adp=LuaAdapter(service,data,item)
ids.list.Adapter=adp






local dl=LuaDialog(service)
.setTitle(纯脚本名:sub(1,-5)..版本号)
.setView(loadlayout(layout))
dl.show()
dialog=dl.show()




local function 获取词条和编码()
	local 词条=""
	if service.getClipBoard().toString() ~="[]" then
		词条=service.getClipBoard()[0] --读取剪切板数组"从0开始"
		edit.setHint(service.getClipBoard()[0])
	end
	if edit.getText().toString()~="" then
		词条= edit.getText().toString()
	end
	local 编码=""
	local 编码组0=获取编码(词条)
	if #获取编码(词条)==1 then
		edit2.setText(编码组0[1])
		编码=编码组0[1]
	elseif #获取编码(词条)>1 then
		local 词条编码组={}
		for i =1,#编码组0 do
			词条编码组[i]=词条.."\t"..编码组0[i]
		end
		导入模块("重码选择模块.text",词条编码组)
	end
end

--自动编码提示
获取词条和编码()

shengcheng.onClick=function()
	获取词条和编码()
	return true
end

queding.onClick=function()
	local 词条=edit.getText().toString()
	if 词条==nil or 词条=="" then
		词条=service.getClipBoard()[0] --读取剪切板数组"从0开始"
	end
	local 编码=edit2.getText().toString()
	local 词条和编码=词条.."\t"..编码
	if 词条和编码~="	" and 词条~=nil and 编码~=nil then
		写入词库(词条和编码,词库文件路径)
	end
	dialog.dismiss()
end

citiao.onClick=function()
	edit.setText(service.getClipBoard()[0])
end
quxiao.onClick=function()
	print("取消")
	dialog.dismiss()
end

--自动弹出输入法
task(100,function()
    --让页面上的某个控件获得焦点，比如edit,则可以通过如下代码实现：
  edit.setFocusable(true);
  edit.setFocusableInTouchMode(true);
  edit.requestFocus();
  local imm = service.getSystemService(Context.INPUT_METHOD_SERVICE)
  imm.showSoftInput(edit, 0)
end)--间隔时间间