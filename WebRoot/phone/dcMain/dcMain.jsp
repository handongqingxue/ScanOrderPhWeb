<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0;" name="viewport">
<link href="<%=path %>/phone/dcMain/css/dcMain.css" rel="stylesheet" type="text/css" />
<script src="<%=path %>/phone/js/jquery-1.8.2.min.js"></script>
<script type="text/javascript">
var path='<%=path %>';
var strJiaCai='${param.jiacai}';
var orderNumber='${sessionScope.orderNumber}';
var foodMount = 0;
//var shopId='82';
var shopId='${sessionScope.shopId}';
var token='${sessionScope.token}';
var goodsListArr=[];
var categoryListLength=0;
$(function(){
	getShopShowInfoById();
	getCategoryList();
	resetTagSize();
});

function resetTagSize(){
	var bw=$("body").css("width");
	bw=bw.substring(0,bw.length-2);
	var cldw=$("#categoryList_div").css("width");
	cldw=cldw.substring(0,cldw.length-2);
	$("#goodsList_div").css("width",(bw-cldw)+"px");
}

function getShopShowInfoById(){
	$.post(path+"/phoneAction_getShopShowInfoById.action",
		{shopId: shopId},
		function(res){
			var result=res.result;
			if (result.code == 100){
				$("#logoUrl_img").attr("src",result.data.logoUrl);
				$("#shopName_div").text(result.data.shopName);
				$("#locationAddress_div").text(result.data.locationAddress);
			}
		}
	);
}

function getCategoryList(){
   $.post(path+"/phoneAction_getCategoryList.action",
		  {shopId: shopId},
		  function(res){
			  var result=res.result;
			  if (result.code == 100){
				var categoryListDiv=$("#categoryList_div");   					  
				var categoryList=result.data;
				categoryListLength=categoryList.length;
				for(var i=0;i<categoryListLength;i++){
					categoryListDiv.append("<div class=\"item selected\" id=\"category"+categoryList[i].id+"\" onclick=\"getGoodsListByCategoryId(this.id)\">"
						+categoryList[i].categoryName
						+"</div>");
					getGoodsListByCategoryId("category"+categoryList[i].id);
				}
			  }
		  }
   );
}
	
function initFoodQuantity(foodsList1){
	var foodsList=convertHtmlToArr(foodsList1);
	if(strJiaCai=="jiacai"){
      $.post(path+"/phoneAction_getOrderDetailsByOrderNumberOL.action",
   		  {orderNumber: orderNumber, shopId: shopId, token:token},
   		  function(result){
   			if (result.code == 100){
   				var productList = result.data.productList;
	            for (var i = 0; i < foodsList.length; i++){
	              var food = foodsList[i];
	              for (var j = 0; j < productList.length; j++) {
	                var product = productList[j];
	                //console.log(food.id);
	                if ((food.categoryId == product.categoryId) & (food.id == product.id)) {
		                //console.log(product);
	                  //food.quantity = product.quantity;
	                  var div=$("<div></div>");
	                  div.append(goodsListArr[food.categoryId]);
	                  div.find("div[id='item"+product.id+"'] input[class='count_input']").attr("value",product.quantity);
	                  goodsListArr[food.categoryId]=div.html();
	                  //console.log(goodsListArr[food.categoryId]);
	                  //$("#goodsList_div div[id='"+product.id+"'] .count_input").val(product.quantity);
	                  break;
	                }
	              }
	            }
   			}

   	 	    getGoodsListByCategoryId("");
	   	    calulateMoneyAndAmount();
   		  }
	  );
    }
    else{
      $.post(path+"/phoneAction_getOrderDetailsByOrderNumber.action",
   		  {orderNumber: orderNumber, shopId: shopId, token:token},
   		  function(res){
   			var result=res.result;
		    if (result.code == 100){
		    	var productList = result.data.productList;
	            for (var i = 0; i < foodsList.length; i++){
	              var food = foodsList[i];
	              for (var j = 0; j < productList.length; j++) {
	                var product = productList[j];
	                if ((food.categoryId == product.categoryId) & (food.id == product.id)) {
	                  //food.quantity = product.quantity;
	                  $("#goodsList_div div[id='"+product.id+"'] .count_input").val(product.quantity);
	                  break;
	                }
	              }
	            }
		    }
		    
		    getGoodsListByCategoryId("");
	        calulateMoneyAndAmount();
   		  }
	  );	
    }
}

function convertHtmlToArr(foodsList1){
	var foodsList=[];
	$("#categoryList_div div[id^='category']").each(function(){
		var categoryId=$(this).attr("id").substring(8);
		var div=$("<div></div>");
		div.append(foodsList1[categoryId]);
		div.find("div[id^='item']").each(function(){
			var id=$(this).attr("id");
			if(id!=undefined)
				id=id.substring(4);
			//console.log($(foodsList1[categoryId]).find("div").html());
			//console.log(id);
			var food={categoryId:categoryId,id:id};
			foodsList.push(food);
		});
	});
	return foodsList;
}
	
function getGoodsListByCategoryId(categoryId){
	$(".categoryList_div div[id^='category']").each(function(){
		if($(this).attr("id")==categoryId){
			//$(this).css("color","#639DCB");
			$(this).css("background-color","#fff");
		}
		else{
			//$(this).css("color","#505050");
			$(this).css("background-color","#f0f4f3");
		}
	});
	if(categoryId==""){
		$(".categoryList_div div[id^='category']").eq(0).css("background-color","#fff");
		categoryId = $("#categoryList_div .item").eq(0).attr("id").substring(8);
	}
	else
    	categoryId = categoryId.substring(8);
	var goodsListDiv=$("#goodsList_div");
	goodsListDiv.empty();
    if(goodsListArr[categoryId]==undefined){
       $.ajaxSetup({async:false});
       $.post(path+"/phoneAction_getGoodsListByCategoryId.action",
   		{categoryId: categoryId, token: token},
   		function(res){
		  	  var result=res.result;
			  if (result.code == 100){
				  var goodsList = result.data;
				  var goodsDiv=$("<div></div>");
	                 for (var i = 0; i < goodsList.length; i++) {
	                   //goodsList[j].quantity = 0;
	                   //goodsList[j].display = "none";
	                   
		               	goodsDiv.append("<div class=\"item\" id=\"item"+goodsList[i].id+"\" categoryId=\""+goodsList[i].categoryId+"\" categoryName=\""+goodsList[i].categoryName+"\">"
			               	+"<img class=\"goods_img\" src=\""+goodsList[i].imgUrl+"\" onclick=\"goGoodsdetail('"+goodsList[i].id+"','"+goodsList[i].productName+"','"+goodsList[i].imgUrl+"','"+goodsList[i].monthlySalesVolume+"','"+goodsList[i].price+"','"+goodsList[i].collectState+"','"+goodsList[i].grade+"','"+goodsList[i].categoryId+"','"+goodsList[i].categoryName+"')\"></img>"
			               	+"<div class=\"productName_div\">"+goodsList[i].productName+"</div>"
			                +"<div class=\"price_div\">￥"+goodsList[i].price+"</div>"
			   		        +"<div class=\"option_div\">"
			   		        +"<img class=\"remove_img\" src=\""+path+"/phone/image/002.png\" ontouchstart=\"removeGood('"+goodsList[i].id+"')\"></img>"
			   		        +"<input class=\"count_input\" id=\"count_input"+goodsList[i].id+"\" value=\"0\"></input>"
			   		        +"<img class=\"add_img\" src=\""+path+"/phone/image/003.png\" ontouchstart=\"addGood('"+goodsList[i].id+"')\"></img>"
			   		        +"</div>"
			   		        +"</div>");
	                 }
	                 
	                 goodsListArr[categoryId]=goodsDiv.html();
			  }
			  if($("#categoryList_div .item").length==categoryListLength){
				  initFoodQuantity(goodsListArr);			  
			  }
       	}
       );
    }
    else{
    	goodsListDiv.html(goodsListArr[categoryId]);
    }
}

function goGoodsdetail(id,productName,imgUrl,monthlySalesVolume,price,collectState,grade,categoryId,categoryName){
	var quantity=$("input[id='count_input"+id+"']").val();
	location.href=path+"/phone/goodDetail/goodDetail.jsp?id="+id+"&productName="+productName+"&imgUrl="+imgUrl+"&monthlySalesVolume="+monthlySalesVolume+"&price="+price+"&collectState="+collectState+"&grade="+grade+"&categoryId="+categoryId+"&categoryName="+categoryName+"&quantity="+quantity;
}

function addGood(id){
	var countInp=$("#goodsList_div #item"+id+" .count_input");
	var count=countInp.val();
	countInp.val(++count);
	chooseGood(id,count);
	showModify();
}

function removeGood(id){
	var countInp=$("#goodsList_div #item"+id+" .count_input");
	var count=countInp.val();
	if(count<=0)
		return;
	else
		countInp.val(--count);
	chooseGood(id,count);
	showModify();
}

function chooseGood(id,count){
	var categoryId=$("#goodsList_div #item"+id).attr("categoryId");
	$(goodsListArr[categoryId]).each(function(){
		var goodsId=$(this).attr("id").substring(4);
		if(id==goodsId){
			var html=$(this).html();
			$(this).find("input[class='count_input']").attr("value",count);
			goodsListArr[categoryId]=goodsListArr[categoryId].replace(html,$(this).html());
			//console.log("==="+($(goodsListArr[categoryId]).eq(0).html()==html));
		}
	});
	//console.log(goodsListArr[categoryId]);
}

function showModify(){
	foodMount = 0;
	calulateMoneyAndAmount();
}

function calulateMoneyAndAmount(){
	var mount = 0, price = 0;

	$("#categoryList_div .item").each(function(){
		var categoryId=$(this).attr("id").substring(8);
		//var goods=$("#goodsList_div .item[categoryid='"+categoryId+"']");
		var goods=$(goodsListArr[categoryId]);
		$(goods).each(function(i){
			mount += parseInt($(this).find("input[class='count_input']").val());
		    price += $(this).find("div[class='price_div']").text().substring(1)*parseInt($(this).find("input[class='count_input']").val());
		});
	});
	if(mount==0){
		$("#gwc_img").removeAttr("onclick");
	}
	else{
		$("#gwc_img").attr("onclick","showOrderedListDiv()");
	}
	$("#ftm_div").text(mount);
	$("#sum_price_div").text("￥"+price);
}

function quJieSuan(){
	var gsList=[];
	$("#categoryList_div .item").each(function(){
		var categoryId=$(this).attr("id").substring(8);
		var goods=$(goodsListArr[categoryId]);
		$(goods).each(function(){
			var g = { categoryId: "", categoryName: "", id: "", quantity: "", imgUrl: "", price: "", productName:""};
			g.categoryId=categoryId;
			g.categoryName=$(this).attr("categoryName");
		    g.id=$(this).attr("id").substring(4);
		    g.quantity = $(this).find("input[class='count_input']").val();
		    g.imgUrl=$(this).find("img[class='goods_img']").attr("src");
		    g.price=$(this).find("div[class='price_div']").text().substring(1);
		    g.productName=$(this).find("div[class='productName_div']").text();
			//console.log(g);
			if(g.quantity>0)
		    	gsList.push(g);
		});
		
	});
	addFoodToList(gsList);
}

function addFoodToList(goodsList){
	checkIfAlreadyExistOrder(goodsList);
}

function checkIfAlreadyExistOrder(gsList){
	
	$.post(path+"/phoneAction_checkIfAlreadyExistOrder.action",
		{shopId: shopId, token:token},
		function(res){
		  var result=res.result;
		  //console.log(result.code);
		  if (result.code == 100){
			nextAction(gsList,"xiadan");
		  }
		  else{
			nextAction(gsList,"tiaodan");
		  }
		}
	);
}

function nextAction(gsList, type){
	//console.log(JSON.stringify(gsList));
	var gsStr=JSON.stringify(gsList);
	var re = new RegExp("\"","g"); 
	//console.log("==="+gsStr.replace(re,"'"));
	gsStr=gsStr.replace(re,"\\\"");
	$.post(path+"/phoneAction_nextAction.action",
		{goodsJAStr:gsStr},
		function(res){
			var result=res.result;
			if(result==1)
				location.href=path+"/phoneAction_toOrderedList.action?type="+type;
		}
	);
}

function showOrderedListDiv(){
	var orderedListDiv=$("#orderedList_div");
	if(orderedListDiv.css("display")=="none"){
		orderedListDiv.css("display","block");
		orderedListDiv.find("div[id^='item']").remove();
		
		$("#categoryList_div .item").each(function(){
			var categoryId=$(this).attr("id").substring(8);
			var goods=$(goodsListArr[categoryId]);
			$(goods).each(function(i){
				var id=$(this).attr("id").substring(4);
				var quantity=$(this).find("input[class='count_input']").val();
				var productName=$(this).find("div[class='productName_div']").text();
				var price=$(this).find("div[class='price_div']").text();
				if(quantity>0){
					orderedListDiv.append("<div id=\"item"+id+"\" style=\"width: 100%;height: 40px;line-height: 40px;\">"
						+"<div style=\"margin-left: 20px;float: left;width: 150px;color:#494949;\">"+productName+"</div>"
						+"<div style=\"margin-left: 0px;float: left;width: 70px;color:#ec6c09;\">"+price+"</div>"
						+"<div style=\"height: 30px;line-height: 30px;float:right;margin-top:10px;margin-right:20px;\">"
						+"<img src=\""+path+"/phone/image/002.png\" ontouchstart=\"reduceProduct("+id+")\" style=\"width:20px;height:20px;\"></img>"
						+"<div class=\"quantity_div\" style=\"width:30px;margin-top: -25px;margin-left:20px;text-align:center;position:absolute;\">"+quantity+"</div>"
						+"<img src=\""+path+"/phone/image/003.png\" ontouchstart=\"plusProduct("+id+")\" style=\"width:20px;height:20px;margin-top: -30px;margin-left:30px;\"></img>"
						+"</div>"
						+"</div>");
				}
			});
		});
	}
	else{
		orderedListDiv.css("display","none");
		orderedListDiv.find("div[id^='item']").remove();
	}
}

function reduceProduct(id){
	var div=$("#orderedList_div #item"+id).find("div[class^='quantity_div']");
	var quantity=div.text();
	quantity--;
	if (quantity<1){
		$("#orderedList_div #item"+id).remove();
	}
    else{
    	div.text(quantity);
    }
	removeGood(id);
}

function plusProduct(id){
	var div=$("#orderedList_div #item"+id).find("div[class^='quantity_div']");
	var quantity=div.text();
	quantity++;
	div.text(quantity);
	addGood(id);
}

function clearAllFoodList(){
	if(confirm("清空购物车?")){
		$.post(path+"/phoneAction_clearAllFoodList.action",
			{shopId: '${sessionScope.shopId}'},
			function(result){
				if (result.code == 100){
					location.href=location.href;
				}
			}
		);
	}
}

function goOrder(){
	location.href=path+"/phone/orderDetail/orderDetail.jsp";
}
</script>
<title>点餐</title>
</head>
<body style="margin: 0px;">
<div class="main_div">
  <div class="logo_div">
    <img class="logoUrl_img" id="logoUrl_img"></img>
    <div class="shopName_div" id="shopName_div"></div>
    <div class="locationAddress_div" id="locationAddress_div"></div>
  </div>
  <div class="categoryList_div" id="categoryList_div"  wx:for-items="{{categoryList}}">
    <!-- 
    <div class="item selected" id="category{{item.id}}" catchtap='getGoodsListByCategoryId'>
      {{item.categoryName}}
    </div>
     -->
  </div>
    <div class="goodsList_div" id="goodsList_div" wx:for-items="{{goodsList}}">
      <!-- 
      <div class="item" categoryId="{{item.categoryId}}" style='display:{{item.display}};' data-categoryId='{{item.categoryId}}'>
        <img class="goods_img" src="{{item.imgUrl}}" data-index='{{index}}' catchtap='goGoodsdetail'></img>
        <div class="productName_div">{{item.productName}}</div>
        <div class="price_div">￥{{item.price}}</div>
        <div class="option_div">
          <img class="remove_img" src="<%=path %>/phone/image/002.png" data-index='{{index}}' catchtap='removeGood'></img>
          <input class="count_input" value='{{item.quantity}}'></input>
          <img class="add_img" src="<%=path %>/phone/image/003.png" data-index='{{index}}' catchtap='addGood'></img>
        </div>
      </div>
       -->
    </div>
  <div class='space_div'></div>
  <div class='bottom_div'>
    <img class="gwc_img" id="gwc_img" src="<%=path %>/phone/image/004.png" onclick="showOrderedListDiv();"></img>
    <div class="ftm_div" id="ftm_div">
    </div>
    <div class='qjs_div' onclick="quJieSuan()">
    去结算
    </div>
    <div class="sum_price_div" id="sum_price_div">
    </div>
  </div>
  <!-- 
  <div class='bottom2_div'>
    <div class='but_div'>
      <div class='dc_div'>
        <div class='dc_img_div'>
          <img class='dc_img' src="<%=path %>/phone/image/022.png"></img>
        </div>
        <div class='dc_text_div'>
          点菜
        </div>
      </div>
      <div class='dd_div' onclick="goOrder()">
        <div class='dd_img_div'>
          <img class='dd_img' src="<%=path %>/phone/image/023.png"></img>
        </div>
        <div class='dd_text_div'>
          订单
        </div>
      </div>
    </div>
  </div>
   -->
</div>

<div id="orderedList_div" style="width: 100%;height:400px;background-color: #fff;position: fixed;bottom: 60px;display: none;overflow-y:auto;">
	<div style="width: 100%;height: 40px;line-height: 40px;text-align: center;background-color: #dd5911;">
		<span style="margin-left: 20px;float: left;color: #fff;">已选商品</span>
		<span style="margin-right: 20px;float: right;color: #fff;" onclick="clearAllFoodList();">清空</span>
	</div>
</div>
</body>
</html>