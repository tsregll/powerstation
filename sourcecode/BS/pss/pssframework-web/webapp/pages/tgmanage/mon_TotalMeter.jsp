<%@page contentType="text/html; charset=UTF-8"%>
<%@include file="../../commons/taglibs.jsp"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>总表监测</title>
<link type="text/css" rel="stylesheet" href="<pss:path type="bgcolor"/>/css/content.css" />
<script type="text/javascript" src="<pss:path type="webapp"/>/scripts/jquery.js"></script>
<script type="text/javascript" src="<pss:path type="webapp"/>/scripts/FusionChartsJSClass/FusionCharts.js"></script>
<script type="text/javascript">
var cntMonitor = 0;
$(document).ready(function() {
    setTimeout("chgRadioChart('01');", 1000);
});

function chgRadioChart(index) {
    for(var i = 1; i <= 5; i++) {
        if(('0' + i) == index) {
            $("#divChart0" + i).css("display", "block");
        }
        else {
            $("#divChart0" + i).css("display", "none");
        }
    }
}

function startMonitoring() {
    cntMonitor = 10;
    monitor();
}

function endMonitoring() {
    cntMonitor = 0;
}

function StringBuffer() {
    this.data = [];
}

StringBuffer.prototype.append = function() {
    this.data.push(arguments[0]);
    return this;
}

StringBuffer.prototype.toString = function() {
    return this.data.join("");
}

function monitor() {
    var sb_dto = new StringBuffer();
    sb_dto.append('{');
    sb_dto.append('"collectObjects":').append('[');
    sb_dto.append('{');
    sb_dto.append('"logicalAddr":"' + $("#logicalAddr").val() + '"').append(',');
    sb_dto.append('"equipProtocol":"' + $("#protocolNo").val() + '"').append(',');
    sb_dto.append('"channelType":"1"').append(',');
    sb_dto.append('"pwAlgorith":"0"').append(',');
    sb_dto.append('"pwContent":"8888"').append(',');
    sb_dto.append('"mpExpressMode":"3"').append(',');
    sb_dto.append('"mpSn":["' + $("#gpSn").val() + '"]').append(',');
    sb_dto.append('"commandItems":').append('[').append('{');
    sb_dto.append('"identifier":"100C0025"');
    sb_dto.append('}').append(']');
    sb_dto.append('}');
    sb_dto.append(']}');
    
    var params = {
            "dto": sb_dto.toString(),
            "mtoType": $("#protocolNo").val(),
            "monType": "TotalMeter",
            "random": Math.random()
    };
    
    var url = '<pss:path type="webapp"/>/tgmanage/tgmon/down.json';
    $.ajax({
        type: 'POST',
        url: url,
        data: jQuery.param(params),
        dataType: 'json',
        success: function(data) {
            //alert(data.collectId);
            //alert(data.fetchCount);
            setTimeout("fetchReturnResult(" + data.collectId + ", " + data.fetchCount + ")", 3000);
        },
        error: function() {
        }
    });
}

function fetchReturnResult(collectId, fetchCount) {
    var params = {
            "collectId": collectId,
            "monType": "TotalMeter",
            "logicalAddr": $("#logicalAddr").val(),
            "gpSn": $("#gpSn").val(),
            "commandItem": "100C0025",
            "chartHistoryValues01": $("#chartValues01").val(),
            "chartHistoryValues02": $("#chartValues02").val(),
            "chartHistoryValues03": $("#chartValues03").val(),
            "chartHistoryValues04": $("#chartValues04").val(),
            "chartHistoryValues05": $("#chartValues05").val(),
            "random": Math.random()
    };
    
    var url = '<pss:path type="webapp"/>/tgmanage/tgmon/up.json';
    $.ajax({
        type: "POST",
        url: url,
        data: jQuery.param(params),
        dataType: 'json',
        success: function(data) {
            if(data.returnFlag) {
                $("#chartValues01").val(data.chartValues01);
                $("#chartValues02").val(data.chartValues02);
                $("#chartValues03").val(data.chartValues03);
                $("#chartValues04").val(data.chartValues04);
                $("#chartValues05").val(data.chartValues05);
                refreshChart("chart01", data.chartXML01);
                refreshChart("chart02", data.chartXML02);
                refreshChart("chart03", data.chartXML03);
                refreshChart("chart04", data.chartXML04);
                refreshChart("chart05", data.chartXML05);
                if(cntMonitor > 0) {
                    cntMonitor--;
                    setTimeout("monitor()", 5000);
                }
                else {
                    parent.endMonitoring0();
                }
            }
            else if(!data.returnFlag && fetchCount > 0) {
                setTimeout("fetchReturnResult(" + collectId + ", " + (fetchCount - 1) + ")", 3000);
            }
            else {
                if(cntMonitor > 0) {
                    cntMonitor--;
                    setTimeout("monitor()", 5000);
                }
                else {
                    parent.endMonitoring0();
                }
            }
        },
        error: function(){
            //alert("error")
        }
    });
}

function refreshChart(chartId, chartXML) {
    var chartObj = getChartFromId(chartId);
    chartObj.setDataXML(chartXML);
}
</script>
</head>
<body>
<div style="text-align: right; padding-right: 10px; height: 25px; vertical-align: middle;">
  <input type="hidden" id="gpId" name="gpId" value="${param.gpId}" />
  <input type="hidden" id="logicalAddr" name="logicalAddr" value="${param.logicalAddr}" />
  <input type="hidden" id="protocolNo" name="protocolNo" value="${param.protocolNo}" />
  <input type="hidden" id="gpSn" name="gpSn" value="${param.gpSn}" />
  <input type="hidden" id="chartValues01" name="chartValues01" value="" />
  <input type="hidden" id="chartValues02" name="chartValues02" value="" />
  <input type="hidden" id="chartValues03" name="chartValues03" value="" />
  <input type="hidden" id="chartValues04" name="chartValues04" value="" />
  <input type="hidden" id="chartValues05" name="chartValues05" value="" />
  <input type="radio" id="radioChart01" name="radioChart" value="01" onclick="chgRadioChart('01')" checked="checked" />电压曲线
  <input type="radio" id="radioChart02" name="radioChart" value="02" onclick="chgRadioChart('02')" />电流曲线
  <input type="radio" id="radioChart03" name="radioChart" value="03" onclick="chgRadioChart('03')" />有功功率曲线
  <input type="radio" id="radioChart04" name="radioChart" value="04" onclick="chgRadioChart('04')" />无功功率曲线
  <input type="radio" id="radioChart05" name="radioChart" value="05" onclick="chgRadioChart('05')" />功率因数曲线
</div>
<div class="graphContainer" style="overflow: hidden; width: 100%; border: 0; height:expression((document.documentElement.clientHeight||document.body.clientHeight)-25);">
  <div id="divChart01" style="float: left; width: 100%; height: 100%; display: block;">
    <c:out value='${initChart01}' escapeXml="false" />
  </div>
  <div id="divChart02" style="float: left; width: 100%; height: 100%; display: block;">
    <c:out value='${initChart02}' escapeXml="false" />
  </div>
  <div id="divChart03" style="float: left; width: 100%; height: 100%; display: block;">
    <c:out value='${initChart03}' escapeXml="false" />
  </div>
  <div id="divChart04" style="float: left; width: 100%; height: 100%; display: block;">
    <c:out value='${initChart04}' escapeXml="false" />
  </div>
  <div id="divChart05" style="float: left; width: 100%; height: 100%; display: block;">
    <c:out value='${initChart05}' escapeXml="false" />
  </div>
</div>
</body>
</html>