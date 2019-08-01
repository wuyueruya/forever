<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8"%>
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
    <link type="text/css" rel="stylesheet" href="suggest.css" />
	<style type="text/css">
	/**控制css **/
	<!--
	.style1 {color: #008c39; font-size:18px; }
	
	#search{width: 260px;}
	.form{width: 260px;position: absolute;}
	-->
	</style>
	
    <title>法律文本搜索首页</title>
    <meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">
	
  </head>
    <!-- 首先初始化：让弹出框不可见 -->
  <body onload="noShow();" onclick="newChg();">
	<table width="65%" height="70%" align="center">
		<tr>
			<td align="center" height="10%">
	  			<img src="img/timg.jpg">
			</td>
		</tr>
		<tr>
	        <td valign="top" align="center">
	        	<table bgcolor="" align="center" width="66%" height="75%" border="0" bordercolor="" cellpadding="0" cellspacing="0">
	        		<tr align="center">
	        			<td height="45%" align="center" valign="bottom" bgcolor="">
						<!-- 设置弹出框及位置 -->
						<table align="center" border="0" >
	        				<tr>
	        					<td nowrap="nowrap">
	        					<!-- 监听鼠标 -->
	        						<input type="text" name="word" id="search" onkeyup="javascript:getSearchContent(event);" style="font-family:Verdana;font-size:16px;height:1.78em;padding-top:2px;" >
									<input type=button value=搜一下 style="height:2em;width:5.6em;font-size:15px;" onclick="search()">
	        						<br><div id="search_suggest" class="form"></div>
	        					</td>
	        				</tr>
	        			</table>
	        			</td>
	        		</tr>
	        		<tr>
	        			<td align="center">
	        				<input name="sm" type="radio" value="-1" id="accurate" checked>精确搜索&nbsp;|&nbsp;
							<input name="sm" type="radio" value="" id="fuzzy">智能搜索
	        			</td>
	        		</tr>
	        		<tr height="30%">
	        			<td align="center">
	        				<input name=lm type=radio value=0 id="lawer" >找律师
							<input name=lm type=radio value=1 id="lawName">根据名字找律师
							<input name=lm type=radio value=2 id="lawWords">找文案
							<input name=lm type=radio value=3 id="column" >找相似文案
							<input name=lm type=radio value="" id="all" checked>综合查找
	        			</td>
	        		</tr>
	        	</table>
	        </td>
		</tr>
	</table> 
	<table align="center" width="65%" height="20%" border="0">
		<tr>
			<td align="center" valign="bottom">
				<hr size="3" width="100%" color="#CCCCFF"><br>
				<span class="style1"><font face="华文行楷" size=2 color="blue">欢迎进入中华法网智能搜索网</font></span>
			</td>
		</tr>
	</table>
  </body>
</html>
