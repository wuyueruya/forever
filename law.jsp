<%@ page language="java" import="java.util.*"
	contentType="text/html; charset=UTF-8"%>
<%@page import="service.Result"%>
<%@page import="java.util.regex.*"%>
<html>
<head>
<script type="text/javascript">
  	//搜索建议 总数
var length = 10;
//当前选中的搜索建议
var currentSelected = -1;
//获取当前鼠标所获取的行
var currentOut;
var realSuggestValue;
var req;
/**
*	获取搜索提示信息
**/
function getSearchContent( evt )
{
	currentOut=null;
	var text = document.getElementById("search");
	var key = window.event?evt.keyCode:evt.which;
	if( null != currentOut ) 
	{
		suggestOut(currentOut);
	}
		
	//向上键
	if( key == 38 )
	{
		if( currentSelected == -1 )
		{
			currentSelected = 0;
		}
		if( length == 0 )
		{
			currentSelected = 0;
		}
		else
		{
		
			if( currentSelected == 0 )
			{
				currentSelected = length - 1 ;
				var c = document.getElementById("suggset" + ( 0 )  );
				c.className = 'suggest_link';
			}
			else{
				currentSelected = currentSelected - 1 ;
			}	
		}
		if( null != document.getElementById("suggset" + currentSelected ) )
		{
			/** 去除索引的选中颜色 **/
			if( currentSelected == length - 1)
			{
				var c = document.getElementById("suggset" + ( length - 1 )  );
				c.className = 'suggest_link';
			}else
			{
				var c = document.getElementById("suggset" + ( currentSelected  + 1 )  );
				c.className = 'suggest_link';
			}
			var current = document.getElementById("suggset" + currentSelected );
			current.className = "suggest_link_over";
			text.value = current.innerHTML;
		}
		return;
			
	}
	//向下键
	if( key == 40 )
	{
		if( length == 0 )
		{
			currentSelected = 0;
		}
		else{
			//当前选中索引为最后一个时
			if( currentSelected ==  length - 1 )
			{
				//去除索引的选中颜色
				currentSelected = 0;
				var c = document.getElementById("suggset" + ( length - 1 )  );
				c.className = 'suggest_link';
			}
			else
			{
				currentSelected = currentSelected + 1;
			}	
			
		}
		if( null != document.getElementById("suggset" + ( currentSelected  ) ) )
		{
			/** 去除索引的选中颜色 **/
			if( currentSelected == 0)
			{
				var c = document.getElementById("suggset" + ( currentSelected )  );
				c.className = 'suggest_link';
			}else
			{
				var c = document.getElementById("suggset" + ( currentSelected  - 1 )  );
				c.className = 'suggest_link';
			}
			/** 添加索引的选中颜色**/
			var current = document.getElementById("suggset" + ( currentSelected  )  );
			current.className = "suggest_link_over";
			text.value = current.innerHTML;
		}
		return;
	}
	if(key != 38 && key != 40 && key!=13)
	{
		var newText=document.getElementById("search");
		var newValue=newText.value;
		//如果str前存在空格  
	    while(newValue.charAt(0)==' '){  
	    	newValue = newValue.substring(1,newValue.length);  
	    }  
	    //如果str末尾存在空格  
	    while(newValue.charAt(newValue.length-1)==' '){  
	    	newValue = newValue.substring(0,newValue.length-1);  
	    }
		if(newValue.length > 0 )
		{
			//调用ajax方法
			getSuggest(newValue);
		}else{
			currentSelected = -1;
			map = null;
			noShow();
		}
	}else if(key==13){
	    search();
	}

}
//---------/**光标失去焦点 **/
function newChg(){
	noShow();
}

/** 返回结果并显示 **/
function callBack( data )
{
	if( null != data )
	{
		noShow();
		document.getElementById('search_suggest').style.display = '';
		var ss = document.getElementById('search_suggest');
		ss.innerHTML = "";
		length = data.length;
		var height = 10;
		for( var i = 0; i < length; i++ )
		{
			var suggest = '<div id=suggset' + i +' onmouseover="javascript:suggestOver(this);" ';
		    suggest += 'onmouseout="javascript:suggestOut(this);" ';
		    suggest += 'onclick="javascript:setSearch(this.innerHTML);" ';
		    suggest += 'class="suggest_link">' + data[i] + '</div>';
		    ss.innerHTML += suggest;
		    height += 22;
		}
		document.getElementById('search_suggest').style.height = height;
	}
	else{
		document.getElementById('search_suggest').style.display = 'none';
	}
}

/** 使用上下键选择搜索提示**/
function onKeySelect()
{
	if( null != document.getElementById("suggset" + currentSelected ))
	{
		var current = document.getElementById("suggset" + currentSelected );
		setSearch(current.innerHTML);
	}
}

/** 初始化 不显示div **/
function noShow()
{
	document.getElementById('search_suggest').style.display = 'none';
	req=null;
	currentOut=null;
	realSuggestValue=null;
}
//获取鼠标
function suggestOver(div_value) 
{
	currentOut = div_value;
	var current = document.getElementById("suggset" + ( currentSelected  )  );
	if( null != current )
	{
		current.className = 'suggest_link';
	}
	currentOut.className = 'suggest_link_over';
	currentSelected = -1;
}

//失去鼠标
function suggestOut(div_value) 
{
	div_value.className = 'suggest_link';
}

//显示选中的信息
function setSearch(value) 
{
	document.getElementById('search').value = value;
	document.getElementById('search_suggest').innerHTML = '';
	noShow();
}
//控制复选框的全选或反选
function CheckAll(elementsA,elementsB) {
	var len=elementsA;
	if(len.length>0){
		for(var i=0;i<len.length;i++){
			elementA[i].checked=true;
		}
		if(elementsB.checked==false){
			for(var j=0;j<len.length;j++){
				elementsA[j].checked=false;
			}
		}
	}
}
//AJAX请求
function getSuggest(userInput) {
 var href=window.location.href;
        var checked="accurate";
    	var kind=document.getElementById("fuzzy");
    	if(kind.checked==true){
    		checked="fuzzy";
    	}
    	var kindChecked="all";
    	var c1=document.getElementById("lawer");
    	var c2=document.getElementById("lawName");
    	var c4=document.getElementById("column");
    	var c5=document.getElementById("all");
    	if(c1.checked==true){
    		kindChecked="lawer";
    	}else if(c2.checked==true){
    		kindChecked="lawName";
    	}else if(c4.checked==true){
    		kindChecked="colunm";
    	}else{
    		kindChecked="all";
    	}
  var url = href.substring(0, href.lastIndexOf("/", 0))+"service/servlets/SuggestServlet?userInput="+userInput+"&checked="+checked+"&kindChecked="+kindChecked;
  req=null;
  if (window.XMLHttpRequest) {
          req = new XMLHttpRequest();
  }else if (window.ActiveXObject) {
          req = new ActiveXObject("Microsoft.XMLHTTP");
  }
  if(req !=null){
          req.open("GET",url, true);
          req.onreadystatechange = complete;
          req.send(null);
  }
}
function complete(){
  if (req.readyState == 4) {
          if (req.status == 200) {
        	      realSuggestValue=null;
                  var suggestings = req.responseXML.getElementsByTagName("suggest");
                  if(suggestings.length>0){
                	  realSuggestValue=new Array();
                  }
                  for(var i=0;i<suggestings.length;i++){
                	  realSuggestValue[i]=suggestings[i].firstChild.data;
                  }
                  callBack(realSuggestValue);//realSuggestValue为全局
                  currentSelected = -1;
      			  onKeySelect();
          }
  }
}
//查询
function search(){
	var newText=document.getElementById("search");
	var newValue=newText.value;
	//如果str前存在空格  
    while(newValue.charAt(0)==' '){  
    	newValue = newValue.substring(1,newValue.length);  
    }  
    //如果str末尾存在空格  
    while(newValue.charAt(newValue.length-1)==' '){  
    	newValue = newValue.substring(0,newValue.length-1);  
    }
    if(newValue.length==0){
    	alert("输入内容不能为空！");
    }else{
        newValue=newValue.replace(new RegExp("[`~!@#$%^&*()+=|{}':;',\\[\\].<>/?~！@#￥《》\"%……&*（）——+|{}【】‘；：”“’。，、？]","gm"),"");
    if(newValue!=null && newValue.length>0){
    	    var checked="accurate";
    	var kind=document.getElementById("fuzzy");
    	if(kind.checked==true){
    		checked="fuzzy";
    	}
    	var kindChecked="all";
    	var c1=document.getElementById("lawer");
    	var c2=document.getElementById("lawName");
    	var c3=document.getElementById("lawWords");
    	var c4=document.getElementById("column");
    	var c5=document.getElementById("all");
    	if(c1.checked==true){
    		kindChecked="lawer";
    	}else if(c2.checked==true){
    		kindChecked="lawName";
    	}else if(c3.checked==true){
    		kindChecked="lawWords";
    	}else if(c4.checked==true){
    		kindChecked="column";
    	}else{
    		kindChecked="all";
    	}
    	var href=window.location.href;
    	var path=href.substring(0, href.lastIndexOf("/", 0)-1)+"service/servlets/SearchServlet?condition="+newValue+"&checked="+checked+"&kindChecked="+kindChecked;
    	window.location.href=path;
      }
    }
}
  	</script>
<script type="text/javascript">
  	function showii(msg,i){
	var t=document.getElementById("sii"+i);
	msg=replaceAll(msg,'#','\n');
	t.bgColor="#99cccc";
	t.title=msg;
}
function clearWords(){
    var t=document.getElementById("words");
    t.title="";
}
function replaceAll(text,replacement,target){
        if(text==null || text=="") return text;
        if(replacement==null || replacement=="") return text;
        if(target==null) target="";
        var returnString="";
        var index=text.indexOf(replacement);
        while(index!=-1){
                if(index!=0) returnString+=text.substring(0,index)+target;
                text=text.substring(index+replacement.length);
                index=text.indexOf(replacement);
        }
        if(text!="") returnString+=text;
        return returnString;
}
function kii(i){
    var t=document.getElementById("sii"+i);
	t.bgColor="";
	t.title="";
}
function jump(){
var href=window.location.href;
window.location=href.substring(0, href.lastIndexOf("/", 0)-1)+"/lawWordsSearcher/main.jsp";
}
function ts(){
var t=document.getElementById("back");
	t.title="返回主页";
}
function ts2(){
var t=document.getElementById("back2");
	t.title="返回主页";
}
function ts3(i){
var t=document.getElementById("jtdownload"+i);
	t.title="下载简体版";
}
function ts4(i){
var t=document.getElementById("ftdownload"+i);
	t.title="下载繁体版";
}
function pxts(){
var t=document.getElementById("px");
	t.title="每次点击按照不同方式排序";
}
function listpx(condition,checked,kindChecked,pageNo,sortsign){
       var href=window.location.href;
    	var path=href.substring(0, href.lastIndexOf("/", 0)-1)+"service/servlets/SortByTimeServlet?condition="+condition+"&checked="+checked+"&kindChecked="+kindChecked+"&page="+pageNo+"&sign="+sortsign;
    	window.location.href=path;
}
  	</script>
<link type="text/css" rel="stylesheet" href="suggest.css" />
<style type="text/css">
.style1 {
	color: #008c39;
	font-size: 18px;
}

#search {
	width: 260px;
}

.form {
	width: 260px;
	position: absolute;
}
</style>

<title>lrc搜索结果</title>
</head>
<%
	String nowCondition = (String) request.getSession().getAttribute(
			"nowCondition");
	String nowChecked = (String) request.getSession().getAttribute(
			"nowChecked");
	String nowKindChecked = (String) request.getSession().getAttribute(
			"nowKindChecked");
	int total = (Integer) request.getSession().getAttribute("total");
	int nowpage = (Integer) request.getSession()
			.getAttribute("nowPage");
	int totalpage = (Integer) request.getSession().getAttribute(
			"totalPage");
	ArrayList<Result> list = (ArrayList<Result>) request.getSession().getAttribute("list");
	int sign = (Integer) request.getSession().getAttribute("sign");
	sign = (++sign) % 3;
	if (nowChecked == null) {
		nowChecked = "fuzzy";
	}
	if (nowKindChecked == null) {
		nowKindChecked = "all";
	}
	if (nowCondition == null) {
		nowCondition = "";
	}
%>
<!-- 首先初始化：让弹出框不可见 -->
<body onload="noShow();" onclick="newChg();">
	<table align="center" width="80%" height="70%" bgcolor="" border="0"
		bordercolor="" cellspacing="0" cellpadding="0">
		<tr>
			<td><hr size="3" width="100%" color="#CCCCFF">
			</td>
		</tr>
		<tr height="10%">
			<td>
				<table width="80%" bgcolor="" border="0" bordercolor="">
					<tr>
						<td width="30%" rowspan="2" nowrap="nowrap"><img width="100%"
							src="img/timg.jpg"
							onclick="jump()" onmouseover="ts()" id="back" title="">
						</td>
						<td>
							<!-- 设置弹出框及位置 -->
							<table border="0" bordercolor="">
								<tr>
									<td nowrap="nowrap"><input type="text" name="word"
										id="search" onkeyup="javascript:getSearchContent(event);"
										style="font-family:Verdana;font-size:16px;height:1.78em;padding-top:2px;"
										value="<%=nowCondition%>"> <input type=button
										value=搜一下 style="height:2em;width:5.6em;font-size:15px;"
										onclick="search()"> <%
 	if (nowChecked.equals("accurate")) {
 %> <input name="sm" type="radio" value="1"
										checked="checked" id="accurate">精确搜索&nbsp;&nbsp;|&nbsp;&nbsp;
										<input name="sm" type="radio" value="1" id="fuzzy">智能搜索
										<%
											} else {
										%> <input name="sm" type="radio" value="1" id="accurate">精确搜索&nbsp;&nbsp;|&nbsp;&nbsp;
										<input name="sm" type="radio" value="1" checked="checked"
										id="fuzzy">智能搜索 <%
											}
										%>
									</td>
								</tr>
								<tr>
									<td>
										<div id="search_suggest" class="form"></div>
									</td>
								</tr>
							</table></td>
					</tr>
					<tr>
						<td colspan="3" rowspan="2">搜索范围: <%
							if (nowKindChecked.equals("lawer")) {
						%> <input name=lm type=radio value=1 id="lawer"
							checked>律师 <input name=lm type=radio value=-1
							id="lawName">文案名 <input name=lm type=radio value=-1
							id="lawWords">文案内容 <input name=lm type=radio value=0
							id="column">案例专辑 <input name=lm type=radio value=""
							id="all">综合 <%
 	} else if (nowKindChecked.equals("lawName")) {
 %> <input name=lm type=radio value=1 id="lawer">律师
							<input name=lm type=radio value=-1 id="lawName" checked>文案名
							<input name=lm type=radio value=-1 id="lawWords">文案内容 <input
							name=lm type=radio value=0 id="column">案例专辑 <input name=lm
							type=radio value="" id="all">综合 <%
 	} else if (nowKindChecked.equals("column")) {
 %> <input name=lm type=radio value=1 id="lawer">律师
							<input name=lm type=radio value=-1 id="lawName">文案名 <input
							name=lm type=radio value=-1 id="lawWords">文案内容 <input
							name=lm type=radio value=0 id="column" checked>案例专辑 <input
							name=lm type=radio value="" id="all">综合 <%
 	} else if (nowKindChecked.equals("lawWords")) {
 %> <input name=lm type=radio value=1 id="lawer">律师
							<input name=lm type=radio value=-1 id="lawName">文案名 <input
							name=lm type=radio value=-1 id="lawWords" checked>文案内容 <input
							name=lm type=radio value=0 id="column">案例专辑 <input name=lm
							type=radio value="" id="all">综合 <%
 	} else if (nowKindChecked.equals("all")) {
 %> <input name=lm type=radio value=1 id="lawer">律师
							<input name=lm type=radio value=-1 id="lawName">文案名 <input
							name=lm type=radio value=-1 id="lawWords">文案内容 <input
							name=lm type=radio value=0 id="column">案例专辑 <input name=lm
							type=radio value="" id="all" checked>综合 <%
 	} else {
 %> <input name=lm type=radio value=1 id="lawer">律师
							<input name=lm type=radio value=-1 id="lawName">文案名 <input
							name=lm type=radio value=-1 id="lawWords">文案内容 <input
							name=lm type=radio value=0 id="column">案例专辑 <input name=lm
							type=radio value="" id="all" checked>综合 <%
 	}
 %>
						</td>
					</tr>
				</table></td>
		</tr>
		
		<tr height="100%" bgcolor="">
			<td valign="top">
				<div>
					<table width="100%" border="0" bordercolor="black" height="100%">
						<tr>
							<td width="100%" valign="top">
								<table align="left" width="100%" border="0" bordercolor=""
									cellspacing="2">
									<tr bgcolor="#ececff">
										<th width="30%" nowrap="nowrap"><font face="楷体" size="4">文案名</font>
										</th>
										<th width="" nowrap="nowrap"><font face="楷体" size="4">案例专辑</font>
										</th>
										<th width="" nowrap="nowrap"><font face="楷体" size="4">律师</font>
										</th>
										<th width="" nowrap="nowrap"><font face="楷体" size="4">格式</font>
										</th>
										<th width="" nowrap="nowrap"><font face="楷体" size="4">时间</font>
										</th>
										<th width="" colspan="2" nowrap="nowrap"><span><font
												face="楷体" size="4">法律文案</font>
										</span><br> <span><font face="楷体" size="2">简</font>
												&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp; <font
												face="楷体" size="2">繁</font>
										</span></th>
									</tr>
									<%
										for (int i = 1; list != null && i <= list.size(); i++) {
											Result r = list.get(i - 1);
											String column = r.getColumn();
											String lawer = r.getLawer();
											String contentis = r.getContent();
											String lawName = r.getSongName();

											String regEx_html = "<[^>]+>";

											Pattern p_html = Pattern.compile(regEx_html,
													Pattern.CASE_INSENSITIVE);

											if (column != null) {
												Matcher m1 = p_html.matcher(column);
												column = m1.replaceAll("");
											}
											if (lawer != null) {
												Matcher m2 = p_html.matcher(lawer);
												lawer = m2.replaceAll("");
											}
											if (contentis != null) {
												String showwords = "";
												String cc[] = contentis.split("#");
												for (int c = 0; c < cc.length; c++) {
													if (cc[c].length() > 0) {
														int index = cc[c].lastIndexOf("]");
														String temp = cc[c].substring(index + 1).trim();
														if (temp != null && temp.length() > 0) {
															showwords += (temp + " # ");
														} else if (temp != null
																&& (cc[c].contains("ti:")
																		|| cc[c].contains("ar:")
																		|| cc[c].contains("al:") || cc[c]
																			.contains("by:"))) {
															showwords += (cc[c] + " # ");
														}
													}
												}

												Matcher m3 = p_html.matcher(showwords);
												contentis = m3.replaceAll("");
											}
											if (lawName != null) {
												Matcher m4 = p_html.matcher(lawName);
												lawName = m4.replaceAll("");
											}
									%>
									<tr bgcolor=""
										onmouseover="showii('<%=contentis%>','<%=i%>')"
										onmouseout="kii('<%=i%>')" id="sii<%=i%>" title="">
										<td align="center">
											<div>
												<a
													href="<%=request.getContextPath()%>/showContents.jsp?docNo=<%=15 * (nowpage - 1) + i%>"><%=r.getSongName()%></a>
											</div></td>
										<td align="center" nowrap="nowrap"><a
											href="<%=request.getContextPath()%>/service/servlets/SearchServlet?condition=<%=column%>&checked=accurate&kindChecked=column">《<%=r.getColumn()%>》</a>
										</td>
										<td align="center" nowrap="nowrap"><a
											href="<%=request.getContextPath()%>/service/servlets/SearchServlet?condition=<%=lawer%>&checked=accurate&kindChecked=lawer"><%=r.getLawer()%></a>
										</td>
										<td align="center" nowrap="nowrap"><font size=4>lrc</font>
										</td>
										<td align="center" nowrap="nowrap"><%=r.getLastTime()%></td>
										<td align="center" nowrap="nowrap"><a
											href="<%=request.getContextPath()%>/service/servlets/DownloadServlet?docNo=<%=r.getDocID()%>&kind=jt"
											name="smple"><img
												src="<%=request.getContextPath()%>/image/down-29.gif"
												onmouseover="ts3(<%=i%>)" id="jtdownload<%=i%>" title="">
										</a>
										</td>
										<td align="center" nowrap="nowrap"><a
											href="<%=request.getContextPath()%>/service/servlets/DownloadServlet?docNo=<%=r.getDocID()%>&kind=ft"
											name="competition"><img
												src="<%=request.getContextPath()%>/image/down-27.gif"
												onmouseover="ts4(<%=i%>)" id="ftdownload<%=i%>" title="">
										</a>
										</td>
									</tr>
									<tr>
										<td colspan="7">
											<hr></td>
									</tr>
									<%
										}
										if (list.size() == 0 || list == null) {
									%>
									<tr>
										<td colspan="7">
											<div>
												<table width="100%" height="100%">
													<tr>
														<td align="center"><br>
														<br>
														<br>
														<br>
														<br>
														<br>
														<br>
														<b><font size=4 color=red>暂无结果，您可以尝试其他方式搜索</font>
														</b><br>
														<br>
														<br>
														<br>
														<br>
														<br>
														<br>
														<br>
														<br>
														<br>
														<br>
														<br>
														<br></td>
													</tr>
												</table>
											</div></td>
									</tr>

									<%
										}
									%>
									<tr>
										<td colspan="4" bgcolor="#ececff" align="center">

											<div class="bar-search-count gray" id="searchCount"
												align="center">
												<font face="楷体" size="3" color="#660000">找到相关结果<%=total%>个&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font>
												<%
													if (totalpage > 1) {
														if (nowpage == totalpage) {
												%>
												<a class="page-next"
													href="<%=request.getContextPath()%>/service/servlets/SearchByPageNumServlet?condition=<%=nowCondition%>&checked=<%=nowChecked%>&kindChecked=<%=nowKindChecked%>&page=<%=(nowpage - 1)%>">上一页</a>&nbsp;
												<span class="page-num">&nbsp;&nbsp;当前第:<%=nowpage%>页&nbsp;&nbsp;</span>&nbsp;
												下一页
												<%
													} else if (nowpage == 1) {
												%>
												上一页&nbsp; <span class="page-num">&nbsp;&nbsp;当前第:<%=nowpage%>页&nbsp;&nbsp;</span>&nbsp;
												<a class="page-next"
													href="<%=request.getContextPath()%>/service/servlets/SearchByPageNumServlet?condition=<%=nowCondition%>&checked=<%=nowChecked%>&kindChecked=<%=nowKindChecked%>&page=<%=(nowpage + 1)%>">下一页</a>
												<%
													} else {
												%>
												<a class="page-next"
													href="<%=request.getContextPath()%>/service/servlets/SearchByPageNumServlet?condition=<%=nowCondition%>&checked=<%=nowChecked%>&kindChecked=<%=nowKindChecked%>&page=<%=(nowpage - 1)%>">上一页</a>&nbsp;
												<span class="page-num">&nbsp;&nbsp;当前第:<%=nowpage%>页&nbsp;&nbsp;</span>&nbsp;
												<a class="page-next"
													href="<%=request.getContextPath()%>/service/servlets/SearchByPageNumServlet?condition=<%=nowCondition%>&checked=<%=nowChecked%>&kindChecked=<%=nowKindChecked%>&page=<%=(nowpage + 1)%>">下一页</a>
												<%
													}
													} else {
												%>
												上一页&nbsp; <span class="page-num">&nbsp;&nbsp;当前第:<%=nowpage%>页&nbsp;&nbsp;</span>&nbsp;
												下一页
												<%
 	}
 %>
												&nbsp;&nbsp;&nbsp;&nbsp;共<%=totalpage%>页
											</div></td>
										<td align="left" bgcolor="#ececff" colspan="3">
											<%
												if (list != null && list.size() > 3) {
											%>
											<div>
												<input type="button"
													onclick="listpx('<%=nowCondition%>','<%=nowChecked%>','<%=nowKindChecked%>','<%=nowpage%>','<%=sign%>')"
													value="时间排序" onmouseover="pxts()" title="" id="px">
											</div> <%
 	}
 %>
										</td >

									</tr>
								</TABLE></td>
						</tr>
						<tr valign="bottom">
							<td align="right">
								<div>
									<%
										if (list != null && list.size() > 0) {
									%>
									<font size=2 color="#666600">如果没有您想要的结果，您还可以尝试更多种类方式的搜索
										!</font>
									<%
										}
									%>
								</div></td>
						</tr>
						<tr>
							<td align="center" valign="bottom">
								<hr size="3" width="100%" color="#CCCCFF">
								<br> <font color="#008c39" face="华文行楷" size=2 color="blue">欢迎进入中华法网智能搜索网</font>
							</td>
						</tr>
					</table>
				</div>
			</td>
		</tr>
	</table>
</body>
</html>
