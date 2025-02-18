<%@page contentType="text/html; charset=UTF-8"%>
<%@include file="../../commons/taglibs.jsp"%>
<%@include file="../../commons/meta.jsp"%>
<%@ taglib tagdir="/WEB-INF/tags/simpletable" prefix="simpletable"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>漏保监测</title>
<link type="text/css" rel="stylesheet" href="<pss:path type="bgcolor"/>/css/content.css" />
<link type="text/css" rel="stylesheet" href="<pss:path type="webapp"/>/widgets/simpletable/simpletable.css" />
<script type="text/javascript" src="<pss:path type="webapp"/>/widgets/simpletable/simpletable.js"></script>
<script type="text/javascript" src="<pss:path type="webapp"/>/scripts/jquery.js"></script>
<script type="text/javascript" src="<pss:path type="webapp"/>/scripts/effects.js"></script>
<script type="text/javascript" src="<pss:path type="webapp"/>/scripts/jquery.query.js"></script>
<script type="text/javascript" src="<pss:path type="webapp"/>/scripts/jquery.corner.js"></script>
<script type="text/javascript">
var setupFlag = false;

function mySwitchTab(prefix, order, cnts) {
    if(cntMonitorB66F > 0 || cntMonitorC04F >0) {
        alert("正在监测中...");
        return false;
    }
    
    if(order == 1) {
        setupFlag = true;
    }
    else {
        setupFlag = false;
    }

    if(order == 2) {
        queryEvent();
    }

    if(order == 3) {
        queryEcCurv();
    }
    
    SwitchTab(prefix, order, cnts);
    return true;
}

function queryEvent() {
    var url = '<pss:path type="webapp"/>' + '/psmanage/psmon/eventQuery?psId=' + $("#psId").val() + '&sdate=' + $("#sdate").val() + '&edate=' + $("#edate").val() + '&r=' + Math.random();
    //alert(url);
    document.getElementById("fdata").src = url;
}

function queryEcCurv() {
    if(showMode3 == "grids") {
        var url = '<pss:path type="webapp"/>' + '/psmanage/psmon/ecCurvQuery?psId=' + $("#psId1").val() + '&sdate=' + $("#sdate1").val() + '&edate=' + $("#edate1").val() + '&r=' + Math.random();
        //alert(url);
        document.getElementById("fdata1").src = url;
    }
    else if(showMode3 == "chart") {
        var url = '<pss:path type="webapp"/>' + '/psmanage/psmon/ecCurvQuery_Chart?caption=漏保数据曲线&chartType=1&chartCategory=3&width=0&height=0&psId=' + $("#psId1").val() + '&sdate=' + $("#sdate1").val() + '&edate=' + $("#edate1").val() + '&r=' + Math.random();
        //alert(url);
        document.getElementById("fdata1").src = url;
    }
}

var cntMonitorB66F = 0;
var cntMonitorC04F = 0;
// 开始监测
function startMonitoring() {
    cntMonitorB66F = 10;
    cntMonitorC04F = 10;
    $("#startMonitoringBtn").attr("disabled", true);
    $("#endMonitoringBtn").attr("disabled", false);
    $("#monitoring").css("display", "block");
    readB66F();
    readC04F();
}
// 结束监测
function endMonitoring() {
    cntMonitorB66F = 0;
    cntMonitorC04F = 0;
    $("#startMonitoringBtn").attr("disabled", false);
    $("#endMonitoringBtn").attr("disabled", true);
    $("#monitoring").css("display", "none");
}

$(document).ready(function() {
    $("#psInfo").corner();
    $("#rmtTrip").corner();
    $("#rtVoltage").corner();
    $("#rtEc").corner();
    $("#rtPsParam").corner();
    $("#timeSetup").corner();
    $("#statusSetup").corner();
    $("#paramsSetup").corner();

    $("#startMonitoringBtn").attr("disabled", false);
    $("#endMonitoringBtn").attr("disabled", true);
    $("#monitoring").css("display", "none");
    //readB66F();
    //readC04F();

    readComputerTime();

    $("#eventInquiryBtn").click( function() {
        queryEvent();
    });

    $("#ecCurvInquiryBtn").click( function() {
        queryEcCurv();
    });

    chg8000C04F08($("select[rci='8000C04F'][rdi='8000C04F08']"));
});

function readComputerTime() {
    if(setupFlag) {
        var url = '<pss:path type="webapp"/>/psmanage/psmon/time.json';
        $.ajax({
            type: 'POST',
            url: url,
            dataType: 'json',
            success: function(data) {
                //alert(data.computerTime);
                $("#computerTime").val(data.computerTime);
                setTimeout("readComputerTime()", 1000);
            },
            error: function(XmlHttpRequest, textStatus, errorThrown){
                //alert(errorThrown);
                setTimeout("readComputerTime()", 1000);
            }
        });
    }
    else {
        setTimeout("readComputerTime()", 1000);
    }
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

function fillTopsMeterAddr(meterAddr) {
    var result = $.trim(meterAddr);
    var lens = result.length;
    if(lens < 12) {
        for(var i = 0; i < (12 - lens); i++) {
            result = '0' + result;
        }
    }
    else {
        result = result.substring(0, 12);
    }

    return result;
}

function readB66F() {
    if(cntMonitorB66F > 0) {
        //alert(cntMonitorB66F);
        cntMonitorB66F--;
        var sb_dto = new StringBuffer();
        sb_dto.append('{');
        sb_dto.append('"collectObjects_Transmit":').append('[{');
        sb_dto.append('"terminalAddr":"' + $("#logicalAddr").val() + '"').append(',');
        sb_dto.append('"equipProtocol":"' + $("#protocolNo").val() + '"').append(',');
        sb_dto.append('"meterAddr":"' + $("#meterAddr").val() + '"').append(',');
        sb_dto.append('"meterType":"' + $("#meterType").val() + '"').append(',');
        sb_dto.append('"funcode":"1"').append(',');
        sb_dto.append('"port":"' + $("#port").val() + '"').append(',');
        sb_dto.append('"serialPortPara":').append('{');
        sb_dto.append('"baudrate":"' + $("#baudrate").val() + '"').append(',');
        sb_dto.append('"stopbit":"' + $("#stopbit").val() + '"').append(',');
        sb_dto.append('"checkbit":"' + $("#checkbit").val() + '"').append(',');
        sb_dto.append('"odd_even_bit":"' + $("#odd_even_bit").val() + '"').append(',');
        sb_dto.append('"databit":"' + $("#databit").val() + '"');
        sb_dto.append('}').append(',');
        sb_dto.append('"waitforPacket":"' + $("#waitforPacket").val() + '"').append(',');
        sb_dto.append('"waitforByte":"' + $("#waitforByte").val() + '"').append(',');
        sb_dto.append('"commandItems":').append('[').append('{');
        sb_dto.append('"identifier":').append('"8000B66F"');
        sb_dto.append('}').append(']');
        sb_dto.append('}]');
        sb_dto.append('}');
        var url = '<pss:path type="webapp"/>/psmanage/psmon/down.json';
        var params = {
                "dto": sb_dto.toString(),
                "mtoType": $("#protocolNo").val()
        };
        $.ajax({
            type: 'POST',
            url: url,
            data: jQuery.param(params),
            dataType: 'json',
            success: function(data) {
                //alert(data.collectId);
                //alert(data.fetchCount);
                setTimeout("fetchResultReadB66F(" + data.collectId + ", " + data.fetchCount + ")", 3000);
            },
            error: function(XmlHttpRequest, textStatus, errorThrown) {
                //alert(errorThrown);
                setTimeout("readB66F()", 3000);
            }
        });
    }
    else {
        if(cntMonitorC04F == 0) {
            endMonitoring();
        }
    }
}

function fetchResultReadB66F(collectId, fetchCount) {
    //alert(collectId + "," + fetchCount);
    //alert($("#opcilist").val());
    var url = '<pss:path type="webapp"/>/psmanage/psmon/up.json';
    var params = {
            "collectId": collectId,
            "type": "ReadB66F"
    };
    $.ajax({
        type: 'POST',
        url: url,
        data: jQuery.param(params),
        dataType: 'json',
        success: function(data) {
            var b = showResultReadB66F(data.resultMap);
            if(!b && fetchCount > 0) {
                setTimeout("fetchResultReadB66F(" + collectId + ", " + (fetchCount - 1) + ")", 3000);
            }
            else {
                setTimeout("readB66F()", 5000);
            }
        },
        error: function() {
            setTimeout("readB66F()", 5000);
        }
    });
}

function showResultReadB66F(resultMap) {
    var logicalAddr = $("#logicalAddr").val();
    var meterAddr = $("#meterAddr").val();
    var result = resultMap[logicalAddr + '#' + fillTopsMeterAddr(meterAddr) + "#" + "8000B66F"];
    //alert(result);
    if(typeof result != "undefined") {
        for(var i = 0; i < $("input[ci='8000B66F']").length; i++) {
            $($("input[ci='8000B66F']")[i]).val(result[$($("input[ci='8000B66F']")[i]).attr("di")]);
        }
        return true;
    }
    else {
        return false;
    }
}

function readC04F() {
    if(cntMonitorC04F > 0) {
        //alert(cntMonitorC04F);
        cntMonitorC04F--;
        var sb_dto = new StringBuffer();
        sb_dto.append('{');
        sb_dto.append('"collectObjects_Transmit":').append('[{');
        sb_dto.append('"terminalAddr":"' + $("#logicalAddr").val() + '"').append(',');
        sb_dto.append('"equipProtocol":"' + $("#protocolNo").val() + '"').append(',');
        sb_dto.append('"meterAddr":"' + $("#meterAddr").val() + '"').append(',');
        sb_dto.append('"meterType":"' + $("#meterType").val() + '"').append(',');
        sb_dto.append('"funcode":"1"').append(',');
        sb_dto.append('"port":"' + $("#port").val() + '"').append(',');
        sb_dto.append('"serialPortPara":').append('{');
        sb_dto.append('"baudrate":"' + $("#baudrate").val() + '"').append(',');
        sb_dto.append('"stopbit":"' + $("#stopbit").val() + '"').append(',');
        sb_dto.append('"checkbit":"' + $("#checkbit").val() + '"').append(',');
        sb_dto.append('"odd_even_bit":"' + $("#odd_even_bit").val() + '"').append(',');
        sb_dto.append('"databit":"' + $("#databit").val() + '"');
        sb_dto.append('}').append(',');
        sb_dto.append('"waitforPacket":"' + $("#waitforPacket").val() + '"').append(',');
        sb_dto.append('"waitforByte":"' + $("#waitforByte").val() + '"').append(',');
        sb_dto.append('"commandItems":').append('[').append('{');
        sb_dto.append('"identifier":').append('"8000C04F"');
        sb_dto.append('}').append(']');
        sb_dto.append('}]');
        sb_dto.append('}');
        var url = '<pss:path type="webapp"/>/psmanage/psmon/down.json';
        var params = {
                "dto": sb_dto.toString(),
                "mtoType": $("#protocolNo").val()
        };
        $.ajax({
            type: 'POST',
            url: url,
            data: jQuery.param(params),
            dataType: 'json',
            success: function(data) {
                //alert(data.collectId);
                //alert(data.fetchCount);
                setTimeout("fetchResultReadC04F(" + data.collectId + ", " + data.fetchCount + ")", 3000);
            },
            error: function(XmlHttpRequest, textStatus, errorThrown) {
                setTimeout("readC04F()", 3000);
            }
        });
    }
    else {
        if(cntMonitorB66F == 0) {
            endMonitoring();
        }
    }
}

function fetchResultReadC04F(collectId, fetchCount) {
    //alert(collectId + "," + fetchCount);
    //alert($("#opcilist").val());
    var url = '<pss:path type="webapp"/>/psmanage/psmon/up.json';
    var params = {
            "collectId": collectId,
            "type": "ReadC04F"
    };
    $.ajax({
        type: 'POST',
        url: url,
        data: jQuery.param(params),
        dataType: 'json',
        success: function(data) {
            var b = showResultReadC04F(data.resultMap);
            if(!b && fetchCount > 0) {
                setTimeout("fetchResultReadC04F(" + collectId + ", " + (fetchCount - 1) + ")", 3000);
            }
            else {
                setTimeout("readC04F()", 5000);
            }
        },
        error: function() {
            setTimeout("readC04F()", 5000);
        }
    });
}

function showResultReadC04F(resultMap) {
    var logicalAddr = $("#logicalAddr").val();
    var meterAddr = $("#meterAddr").val();
    var result = resultMap[logicalAddr + '#' + fillTopsMeterAddr(meterAddr) + "#" + "8000C04F"];
    if(typeof result != "undefined") {
        for(var i = 0; i < $("input[ci='8000C04F']").length; i++) {
            $($("input[ci='8000C04F']")[i]).val(result[$($("input[ci='8000C04F']")[i]).attr("di")]);
        }
        
        var msgStatus = "";
        if(result['8000C04F01'] == '0') {
            $("#rmtTripImg").attr('src', '<pss:path type="bgcolor"/>/img/pss-on.png');
            msgStatus += "合闸；\r";
        }
        else if(result['8000C04F01'] == '1') {
            $("#rmtTripImg").attr('src', '<pss:path type="bgcolor"/>/img/pss-off.png');
            msgStatus += "分闸；\r";
            if(result['8000C04F02'] == '0') {
                msgStatus += "未闭锁；\r";
            }
            else if(result['8000C04F02'] == '1') {
                msgStatus += "闭锁；\r";
            }

            if(result['8000C04F03'] == '00') {
                msgStatus += "相位：无效；\r";
            }
            else if(result['8000C04F03'] == '01') {
                msgStatus += "相位：A相；\r";
            }
            else if(result['8000C04F03'] == '10') {
                msgStatus += "相位：B相；\r";
            }
            else if(result['8000C04F03'] == '11') {
                msgStatus += "相位：C相；\r";
            }

            if(result['8000C04F04'] == '0000') {
                msgStatus += "漏电跳闸";
            }
            else if(result['8000C04F04'] == '0001') {
                msgStatus += "突变跳闸";
            }
            else if(result['8000C04F04'] == '0010') {
                msgStatus += "特波跳闸";
            }
            else if(result['8000C04F04'] == '0011') {
                msgStatus += "过载跳闸";
            }
            else if(result['8000C04F04'] == '0100') {
                msgStatus += "过压跳闸";
            }
            else if(result['8000C04F04'] == '0101') {
                msgStatus += "欠压跳闸";
            }
            else if(result['8000C04F04'] == '0110') {
                msgStatus += "短路跳闸";
            }
            else if(result['8000C04F04'] == '0111') {
                msgStatus += "手动跳闸";
            }
            else if(result['8000C04F04'] == '1000') {
                msgStatus += "停电跳闸";
            }
            else if(result['8000C04F04'] == '1001') {
                msgStatus += "互感器故障跳闸";
            }
            else if(result['8000C04F04'] == '1010') {
                msgStatus += "远程跳闸";
            }
            else if(result['8000C04F04'] == '1011') {
                msgStatus += "其它原因跳闸";
            }
            else if(result['8000C04F04'] == '1100') {
                msgStatus += "合闸过程中";
            }
            else if(result['8000C04F04'] == '1101') {
                msgStatus += "合闸失败";
            }
        }
        $("textarea[ci='8000C04F'][di='8000C04F0X']").val(msgStatus);
        
        return true;
    }
    else {
        return false;
    }
}

var bResultRemote = false;
function disableRemoteOperation() {
    bResultRemote = false;
    $("#rmtTripBtn").attr("disabled", true);
    $("#rmtSwitchBtn").attr("disabled", true);
    $("#rmtTestBtn").attr("disabled", true);
}

function enableRemoteOperation() {
    $("#rmtTripBtn").attr("disabled", false);
    $("#rmtSwitchBtn").attr("disabled", false);
    $("#rmtTestBtn").attr("disabled", false);
}

function initOpResultRemote(msg) {
    //alert(msg);
    $("#resultRemote").html(msg);
}

function showResultRemote(resultMap) {
    //alert(resultMap);
    var logicalAddr = $("#logicalAddr").val();
    var meterAddr = $("#meterAddr").val();
    var result = null;
    result = resultMap[logicalAddr + '#' + fillTopsMeterAddr(meterAddr) + "#" + "8000C037"];
    if(typeof result != "undefined") {
        if(result == "1") {
            result = "开关试验跳成功";
        }
        else if(result == "2") {
            result = "开关试验跳失败";
        }
        $("#resultRemote").html(result);
        bResultRemote = true;
        return true;
    }
    else {
        result = resultMap[logicalAddr + '#' + fillTopsMeterAddr(meterAddr) + "#" + "8000C036"];
        if(typeof result != "undefined") {
            if(result == "1") {
                result = "开关跳合闸成功";
            }
            else if(result == "2") {
                result = "开关跳合闸失败";
            }
            $("#resultRemote").html(result);
            bResultRemote = true;
            return true;
        }
        else {
            return false;
        }
    }
}

// 开关跳闸
function remoteTriping() {
    if(confirm("确定要对该漏保进行跳闸？")) {
        disableRemoteOperation();
        var sb_dto = new StringBuffer();
        sb_dto.append('{');
        sb_dto.append('"collectObjects_Transmit":').append('[{');
        sb_dto.append('"terminalAddr":"' + $("#logicalAddr").val() + '"').append(',');
        sb_dto.append('"equipProtocol":"' + $("#protocolNo").val() + '"').append(',');
        sb_dto.append('"meterAddr":"' + $("#meterAddr").val() + '"').append(',');
        sb_dto.append('"meterType":"' + $("#meterType").val() + '"').append(',');
        sb_dto.append('"funcode":"4"').append(',');
        sb_dto.append('"port":"' + $("#port").val() + '"').append(',');
        sb_dto.append('"serialPortPara":').append('{');
        sb_dto.append('"baudrate":"' + $("#baudrate").val() + '"').append(',');
        sb_dto.append('"stopbit":"' + $("#stopbit").val() + '"').append(',');
        sb_dto.append('"checkbit":"' + $("#checkbit").val() + '"').append(',');
        sb_dto.append('"odd_even_bit":"' + $("#odd_even_bit").val() + '"').append(',');
        sb_dto.append('"databit":"' + $("#databit").val() + '"');
        sb_dto.append('}').append(',');
        sb_dto.append('"waitforPacket":"' + $("#waitforPacket").val() + '"').append(',');
        sb_dto.append('"waitforByte":"' + $("#waitforByte").val() + '"').append(',');
        sb_dto.append('"commandItems":').append('[').append('{');
        sb_dto.append('"identifier":').append('"8000C036"').append(',');
        sb_dto.append('"datacellParam":').append('{');
        sb_dto.append('"8000C03601": "50"');
        sb_dto.append('}');
        sb_dto.append('}').append(']');
        sb_dto.append('}]');
        sb_dto.append('}');
        initOpResultRemote('正在开关跳闸...');
        var url = '<pss:path type="webapp"/>/psmanage/psmon/down.json';
        var params = {
                "dto": sb_dto.toString(),
                "mtoType": $("#protocolNo").val()
        };
        $.ajax({
            type: 'POST',
            url: url,
            data: jQuery.param(params),
            dataType: 'json',
            success: function(data) {
                //alert(data.collectId);
                //alert(data.fetchCount);
                setTimeout("fetchRemoteTripingResult(" + data.collectId + ", " + data.fetchCount + ")", 3000);
            },
            error: function(XmlHttpRequest, textStatus, errorThrown) {
                initOpResultRemote('下发开关跳闸命令失败...');
                enableRemoteOperation();
            }
        });
    }
}

function fetchRemoteTripingResult(collectId, fetchCount) {
    var url = '<pss:path type="webapp"/>/psmanage/psmon/up.json';
    var params = {
            "collectId": collectId,
            "type": "RemoteTriping"
    };
    $.ajax({
        type: 'POST',
        url: url,
        data: jQuery.param(params),
        dataType: 'json',
        success: function(data) {
            var b = showResultRemote(data.resultMap);
            if(!b && fetchCount > 0) {
                setTimeout("fetchRemoteTripingResult(" + collectId + ", " + (fetchCount - 1) + ")", 3000);
            }
            else if(b) {
                enableRemoteOperation();
            }
            else {
                initOpResultRemote('下发开关跳闸命令超时');
                enableRemoteOperation();
            }
        },
        error: function() {
        }
    });
}

// 开关合闸
function remoteSwitching() {
    if(confirm("确定要对该漏保进行合闸？")) {
        disableRemoteOperation();
        var sb_dto = new StringBuffer();
        sb_dto.append('{');
        sb_dto.append('"collectObjects_Transmit":').append('[{');
        sb_dto.append('"terminalAddr":"' + $("#logicalAddr").val() + '"').append(',');
        sb_dto.append('"equipProtocol":"' + $("#protocolNo").val() + '"').append(',');
        sb_dto.append('"meterAddr":"' + $("#meterAddr").val() + '"').append(',');
        sb_dto.append('"meterType":"' + $("#meterType").val() + '"').append(',');
        sb_dto.append('"funcode":"4"').append(',');
        sb_dto.append('"port":"' + $("#port").val() + '"').append(',');
        sb_dto.append('"serialPortPara":').append('{');
        sb_dto.append('"baudrate":"' + $("#baudrate").val() + '"').append(',');
        sb_dto.append('"stopbit":"' + $("#stopbit").val() + '"').append(',');
        sb_dto.append('"checkbit":"' + $("#checkbit").val() + '"').append(',');
        sb_dto.append('"odd_even_bit":"' + $("#odd_even_bit").val() + '"').append(',');
        sb_dto.append('"databit":"' + $("#databit").val() + '"');
        sb_dto.append('}').append(',');
        sb_dto.append('"waitforPacket":"' + $("#waitforPacket").val() + '"').append(',');
        sb_dto.append('"waitforByte":"' + $("#waitforByte").val() + '"').append(',');
        sb_dto.append('"commandItems":').append('[').append('{');
        sb_dto.append('"identifier":').append('"8000C036"').append(',');
        sb_dto.append('"datacellParam":').append('{');
        sb_dto.append('"8000C03601": "5F"');
        sb_dto.append('}');
        sb_dto.append('}').append(']');
        sb_dto.append('}]');
        sb_dto.append('}');
        initOpResultRemote('正在开关合闸...');
        var url = '<pss:path type="webapp"/>/psmanage/psmon/down.json';
        var params = {
                "dto": sb_dto.toString(),
                "mtoType": $("#protocolNo").val()
        };
        $.ajax({
            type: 'POST',
            url: url,
            data: jQuery.param(params),
            dataType: 'json',
            success: function(data) {
                //alert(data.collectId);
                //alert(data.fetchCount);
                setTimeout("fetchRemoteSwitchingResult(" + data.collectId + ", " + data.fetchCount + ")", 3000);
            },
            error: function(XmlHttpRequest, textStatus, errorThrown) {
                initOpResultRemote('下发开关合闸命令失败...');
                enableRemoteOperation();
            }
        });
    }
}

function fetchRemoteSwitchingResult(collectId, fetchCount) {
    var url = '<pss:path type="webapp"/>/psmanage/psmon/up.json';
    var params = {
            "collectId": collectId,
            "type": "RemoteSwitching"
    };
    $.ajax({
        type: 'POST',
        url: url,
        data: jQuery.param(params),
        dataType: 'json',
        success: function(data) {
            var b = showResultRemote(data.resultMap);
            if(!b && fetchCount > 0) {
                setTimeout("fetchRemoteSwitchingResult(" + collectId + ", " + (fetchCount - 1) + ")", 3000);
            }
            else if(b) {
                enableRemoteOperation();
            }
            else {
                initOpResultRemote('下发开关合闸命令超时');
                enableRemoteOperation();
            }
        },
        error: function() {
        }
    });
}

// 开关试跳
function remoteTest() {
    if(confirm("确定要对该漏保进行试跳？")) {
        disableRemoteOperation();
        var sb_dto = new StringBuffer();
        sb_dto.append('{');
        sb_dto.append('"collectObjects_Transmit":').append('[{');
        sb_dto.append('"terminalAddr":"' + $("#logicalAddr").val() + '"').append(',');
        sb_dto.append('"equipProtocol":"' + $("#protocolNo").val() + '"').append(',');
        sb_dto.append('"meterAddr":"' + $("#meterAddr").val() + '"').append(',');
        sb_dto.append('"meterType":"' + $("#meterType").val() + '"').append(',');
        sb_dto.append('"funcode":"4"').append(',');
        sb_dto.append('"port":"' + $("#port").val() + '"').append(',');
        sb_dto.append('"serialPortPara":').append('{');
        sb_dto.append('"baudrate":"' + $("#baudrate").val() + '"').append(',');
        sb_dto.append('"stopbit":"' + $("#stopbit").val() + '"').append(',');
        sb_dto.append('"checkbit":"' + $("#checkbit").val() + '"').append(',');
        sb_dto.append('"odd_even_bit":"' + $("#odd_even_bit").val() + '"').append(',');
        sb_dto.append('"databit":"' + $("#databit").val() + '"');
        sb_dto.append('}').append(',');
        sb_dto.append('"waitforPacket":"' + $("#waitforPacket").val() + '"').append(',');
        sb_dto.append('"waitforByte":"' + $("#waitforByte").val() + '"').append(',');
        sb_dto.append('"commandItems":').append('[').append('{');
        sb_dto.append('"identifier":').append('"8000C037"');
        sb_dto.append('}').append(']');
        sb_dto.append('}]');
        sb_dto.append('}');
        initOpResultRemote('正在试验跳...');
        var url = '<pss:path type="webapp"/>/psmanage/psmon/down.json';
        var params = {
                "dto": sb_dto.toString(),
                "mtoType": $("#protocolNo").val()
        };
        $.ajax({
            type: 'POST',
            url: url,
            data: jQuery.param(params),
            dataType: 'json',
            success: function(data) {
                //alert(data.collectId);
                //alert(data.fetchCount);
                setTimeout("fetchRemoteTestResult(" + data.collectId + ", " + data.fetchCount + ")", 3000);
            },
            error: function(XmlHttpRequest, textStatus, errorThrown) {
                initOpResultRemote('下发试验跳命令失败...');
                enableRemoteOperation();
            }
        });
    }
}

function fetchRemoteTestResult(collectId, fetchCount) {
    var url = '<pss:path type="webapp"/>/psmanage/psmon/up.json';
    var params = {
            "collectId": collectId,
            "type": "RemoteTest"
    };
    $.ajax({
        type: 'POST',
        url: url,
        data: jQuery.param(params),
        dataType: 'json',
        success: function(data) {
            var b = showResultRemote(data.resultMap);
            if(!b && fetchCount > 0) {
                setTimeout("fetchRemoteTestResult(" + collectId + ", " + (fetchCount - 1) + ")", 3000);
            }
            else if(b) {
                enableRemoteOperation();
            }
            else {
                initOpResultRemote('下发试验跳命令超时');
                enableRemoteOperation();
            }
        },
        error: function() {
        }
    });
}

var bResultTime = false;
function disableTimeOperation() {
    $("#timeReadBtn").attr("disabled", true);
    $("#timeSetupBtn").attr("disabled", true);
}

function enableTimeOperation() {
    $("#timeReadBtn").attr("disabled", false);
    $("#timeSetupBtn").attr("disabled", false);
}

function initOpResultTime(msg) {
    //alert(msg);
    $("#resultTime").html(msg);
}

function showResultTime(resultMap, type) {
    //alert(resultMap);
    var logicalAddr = $("#logicalAddr").val();
    var meterAddr = $("#meterAddr").val();
    if(type == 'setup') {  // 设置时钟
        var result = null;
        result = resultMap[logicalAddr + '#' + fillTopsMeterAddr(meterAddr) + "#" + "8000C012"];
        if(typeof result != "undefined") {
            if(result == "1") {
                result = "校时成功";
            }
            else if(result == "2") {
                result = "校时失败";
            }
            $("#resultTime").html(result);
            bResultTime = true;
            return true;
        }
        else {
            return false;
        }
    }
    else {                // 读取时钟
        var result = null;
        result = resultMap[logicalAddr + '#' + fillTopsMeterAddr(meterAddr) + "#" + "8000C012"];
        if(typeof result != "undefined") {
            $("input[ci='8000C012'][di='C012']").val(result['C012']);
            $("#resultTime").html("读取时钟成功");
            bResultTime = true;
            return true;
        }
        else {
            return false;
        }
    }
}

// 时钟读取
function timeRead() {
    if(confirm("确定要对该漏保的时钟进行读取？")) {
        disableTimeOperation();
        var sb_dto = new StringBuffer();
        sb_dto.append('{');
        sb_dto.append('"collectObjects_Transmit":').append('[{');
        sb_dto.append('"terminalAddr":"' + $("#logicalAddr").val() + '"').append(',');
        sb_dto.append('"equipProtocol":"' + $("#protocolNo").val() + '"').append(',');
        sb_dto.append('"meterAddr":"' + $("#meterAddr").val() + '"').append(',');
        sb_dto.append('"meterType":"' + $("#meterType").val() + '"').append(',');
        sb_dto.append('"funcode":"1"').append(',');
        sb_dto.append('"port":"' + $("#port").val() + '"').append(',');
        sb_dto.append('"serialPortPara":').append('{');
        sb_dto.append('"baudrate":"' + $("#baudrate").val() + '"').append(',');
        sb_dto.append('"stopbit":"' + $("#stopbit").val() + '"').append(',');
        sb_dto.append('"checkbit":"' + $("#checkbit").val() + '"').append(',');
        sb_dto.append('"odd_even_bit":"' + $("#odd_even_bit").val() + '"').append(',');
        sb_dto.append('"databit":"' + $("#databit").val() + '"');
        sb_dto.append('}').append(',');
        sb_dto.append('"waitforPacket":"' + $("#waitforPacket").val() + '"').append(',');
        sb_dto.append('"waitforByte":"' + $("#waitforByte").val() + '"').append(',');
        sb_dto.append('"commandItems":').append('[').append('{');
        sb_dto.append('"identifier":').append('"8000C012"');
        sb_dto.append('}').append(']');
        sb_dto.append('}]');
        sb_dto.append('}');
        initOpResultTime('正在读取时钟...');
        var url = '<pss:path type="webapp"/>/psmanage/psmon/down.json';
        var params = {
                "dto": sb_dto.toString(),
                "mtoType": $("#protocolNo").val()
        };
        $.ajax({
            type: 'POST',
            url: url,
            data: jQuery.param(params),
            dataType: 'json',
            success: function(data) {
                //alert(data.collectId);
                //alert(data.fetchCount);
                setTimeout("fetchTimeReadResult(" + data.collectId + ", " + data.fetchCount + ")", 3000);
            },
            error: function(XmlHttpRequest, textStatus, errorThrown) {
                initOpResultTime('下发读取时钟命令失败...');
                enableTimeOperation();
            }
        });
    }
}

function fetchTimeReadResult(collectId, fetchCount) {
    var url = '<pss:path type="webapp"/>/psmanage/psmon/up.json';
    var params = {
            "collectId": collectId,
            "type": "TimeRead"
    };
    $.ajax({
        type: 'POST',
        url: url,
        data: jQuery.param(params),
        dataType: 'json',
        success: function(data) {
            var b = showResultTime(data.resultMap, 'read');
            if(!b && fetchCount > 0) {
                setTimeout("fetchTimeReadResult(" + collectId + ", " + (fetchCount - 1) + ")", 3000);
            }
            else if(b) {
                enableTimeOperation();
            }
            else {
                initOpResultTime('读取时钟超时');
                enableTimeOperation();
            }
        },
        error: function() {
        }
    });
}

// 时钟设置
function timeSetup() {
    if(confirm("确定要对该漏保的时钟进行设置？")) {
        disableTimeOperation();
        var sb_dto = new StringBuffer();
        sb_dto.append('{');
        sb_dto.append('"collectObjects_Transmit":').append('[{');
        sb_dto.append('"terminalAddr":"' + $("#logicalAddr").val() + '"').append(',');
        sb_dto.append('"equipProtocol":"' + $("#protocolNo").val() + '"').append(',');
        sb_dto.append('"meterAddr":"' + $("#meterAddr").val() + '"').append(',');
        sb_dto.append('"meterType":"' + $("#meterType").val() + '"').append(',');
        sb_dto.append('"funcode":"4"').append(',');
        sb_dto.append('"port":"' + $("#port").val() + '"').append(',');
        sb_dto.append('"serialPortPara":').append('{');
        sb_dto.append('"baudrate":"' + $("#baudrate").val() + '"').append(',');
        sb_dto.append('"stopbit":"' + $("#stopbit").val() + '"').append(',');
        sb_dto.append('"checkbit":"' + $("#checkbit").val() + '"').append(',');
        sb_dto.append('"odd_even_bit":"' + $("#odd_even_bit").val() + '"').append(',');
        sb_dto.append('"databit":"' + $("#databit").val() + '"');
        sb_dto.append('}').append(',');
        sb_dto.append('"waitforPacket":"' + $("#waitforPacket").val() + '"').append(',');
        sb_dto.append('"waitforByte":"' + $("#waitforByte").val() + '"').append(',');
        sb_dto.append('"commandItems":').append('[').append('{');
        sb_dto.append('"identifier":').append('"8000C012"').append(',');
        sb_dto.append('"datacellParam":').append('{');
        sb_dto.append('"C012": "' + $("#computerTime").val() + '"');
        sb_dto.append('}');
        sb_dto.append('}').append(']');
        sb_dto.append('}]');
        sb_dto.append('}');
        initOpResultTime('正在校时...');
        var url = '<pss:path type="webapp"/>/psmanage/psmon/down.json';
        var params = {
                "dto": sb_dto.toString(),
                "mtoType": $("#protocolNo").val()
        };
        $.ajax({
            type: 'POST',
            url: url,
            data: jQuery.param(params),
            dataType: 'json',
            success: function(data) {
                //alert(data.collectId);
                //alert(data.fetchCount);
                setTimeout("fetchTimeSetupResult(" + data.collectId + ", " + data.fetchCount + ")", 3000);
            },
            error: function(XmlHttpRequest, textStatus, errorThrown) {
                initOpResultTime('下发校时命令失败...');
                enableTimeOperation();
            }
        });
    }
}

function fetchTimeSetupResult(collectId, fetchCount) {
    var url = '<pss:path type="webapp"/>/psmanage/psmon/up.json';
    var params = {
            "collectId": collectId,
            "type": "TimeSetup"
    };
    $.ajax({
        type: 'POST',
        url: url,
        data: jQuery.param(params),
        dataType: 'json',
        success: function(data) {
            var b = showResultTime(data.resultMap, 'setup');
            if(!b && fetchCount > 0) {
                setTimeout("fetchTimeSetupResult(" + collectId + ", " + (fetchCount - 1) + ")", 3000);
            }
            else if(b) {
                enableTimeOperation();
            }
            else {
                initOpResultTime('校时超时');
                enableTimeOperation();
            }
        },
        error: function() {
        }
    });
}

var bResultFuncSetupByte = false;
function disableFuncSetupByteOperation() {
    $("#funcSetupByteReadBtn").attr("disabled", true);
    $("#funcSetupByteSetupBtn").attr("disabled", true);
}

function enableFuncSetupByteOperation() {
    $("#funcSetupByteReadBtn").attr("disabled", false);
    $("#funcSetupByteSetupBtn").attr("disabled", false);
}

function initOpResultFuncSetupByte(msg) {
    //alert(msg);
    $("#resultFuncSetupByte").html(msg);
}

function showResultFuncSetupByte(resultMap, type) {
    //alert(resultMap + "," + type);
    var logicalAddr = $("#logicalAddr").val();
    var meterAddr = $("#meterAddr").val();
    if(type == 'setup') {  // 设置功能状态字
        var result = null;
        result = resultMap[logicalAddr + '#' + fillTopsMeterAddr(meterAddr) + "#" + "8001C04F"];
        if(typeof result != "undefined") {
            if(result == "1") {
                result = "设置功能状态字成功";
            }
            else if(result == "2") {
                result = "设置功能状态字失败";
            }
            $("#resultFuncSetupByte").html(result);
            bResultFuncSetupByte = true;
            return true;
        }
        else {
            return false;
        }
    }
    else {                // 读取功能状态字
        var result = null;
        result = resultMap[logicalAddr + '#' + fillTopsMeterAddr(meterAddr) + "#" + "8000C04F"];
        if(typeof result != "undefined") {
            //$("input[ci='8000C012'][di='C012']").val(result['C012']);
            var strFuncSetupByte = result['8000C04F10'];
            //alert(strFuncSetupByte);
            showFuncSetupBytes(strFuncSetupByte);
            $("#psModel").val(result['8000C04F11']);
            $("#resultFuncSetupByte").html("读取功能状态字成功");
            bResultFuncSetupByte = true;
            return true;
        }
        else {
            return false;
        }
    }
}

// 功能设定字读取
function funcSetupByteRead() {
    if(confirm("确定要对该漏保的功能设定字进行读取？")) {
        disableFuncSetupByteOperation();
        var sb_dto = new StringBuffer();
        sb_dto.append('{');
        sb_dto.append('"collectObjects_Transmit":').append('[{');
        sb_dto.append('"terminalAddr":"' + $("#logicalAddr").val() + '"').append(',');
        sb_dto.append('"equipProtocol":"' + $("#protocolNo").val() + '"').append(',');
        sb_dto.append('"meterAddr":"' + $("#meterAddr").val() + '"').append(',');
        sb_dto.append('"meterType":"' + $("#meterType").val() + '"').append(',');
        sb_dto.append('"funcode":"1"').append(',');
        sb_dto.append('"port":"' + $("#port").val() + '"').append(',');
        sb_dto.append('"serialPortPara":').append('{');
        sb_dto.append('"baudrate":"' + $("#baudrate").val() + '"').append(',');
        sb_dto.append('"stopbit":"' + $("#stopbit").val() + '"').append(',');
        sb_dto.append('"checkbit":"' + $("#checkbit").val() + '"').append(',');
        sb_dto.append('"odd_even_bit":"' + $("#odd_even_bit").val() + '"').append(',');
        sb_dto.append('"databit":"' + $("#databit").val() + '"');
        sb_dto.append('}').append(',');
        sb_dto.append('"waitforPacket":"' + $("#waitforPacket").val() + '"').append(',');
        sb_dto.append('"waitforByte":"' + $("#waitforByte").val() + '"').append(',');
        sb_dto.append('"commandItems":').append('[').append('{');
        sb_dto.append('"identifier":').append('"8000C04F"');
        sb_dto.append('}').append(']');
        sb_dto.append('}]');
        sb_dto.append('}');
        initOpResultFuncSetupByte('正在读取功能设定字...');
        var url = '<pss:path type="webapp"/>/psmanage/psmon/down.json';
        var params = {
                "dto": sb_dto.toString(),
                "mtoType": $("#protocolNo").val()
        };
        $.ajax({
            type: 'POST',
            url: url,
            data: jQuery.param(params),
            dataType: 'json',
            success: function(data) {
                //alert(data.collectId);
                //alert(data.fetchCount);
                setTimeout("fetchFuncSetupByteReadResult(" + data.collectId + ", " + data.fetchCount + ")", 3000);
            },
            error: function(XmlHttpRequest, textStatus, errorThrown){
                initOpResultFuncSetupByte('下发读取功能设定字命令失败...');
                enableFuncSetupByteOperation();
            }
        });
    }
}

function fetchFuncSetupByteReadResult(collectId, fetchCount) {
    var url = '<pss:path type="webapp"/>/psmanage/psmon/up.json';
    var params = {
            "collectId": collectId,
            "type": "FuncSetupByteRead"
    };
    $.ajax({
        type: 'POST',
        url: url,
        data: jQuery.param(params),
        dataType: 'json',
        success: function(data) {
            var b = showResultFuncSetupByte(data.resultMap, 'read');
            if(!b && fetchCount > 0) {
                setTimeout("fetchFuncSetupByteReadResult(" + collectId + ", " + (fetchCount - 1) + ")", 3000);
            }
            else if(b) {
                enableFuncSetupByteOperation();
            }
            else {
                initOpResultFuncSetupByte('读取功能设定字超时');
                enableFuncSetupByteOperation();
            }
        },
        error: function() {
        }
    });
}

// 功能设定字设置
function funcSetupByteSetup() {
    if(confirm("确定要对该漏保的功能设定字进行设置？")) {
        disableFuncSetupByteOperation();
        var sb_dto = new StringBuffer();
        sb_dto.append('{');
        sb_dto.append('"collectObjects_Transmit":').append('[{');
        sb_dto.append('"terminalAddr":"' + $("#logicalAddr").val() + '"').append(',');
        sb_dto.append('"equipProtocol":"' + $("#protocolNo").val() + '"').append(',');
        sb_dto.append('"meterAddr":"' + $("#meterAddr").val() + '"').append(',');
        sb_dto.append('"meterType":"' + $("#meterType").val() + '"').append(',');
        sb_dto.append('"funcode":"4"').append(',');
        sb_dto.append('"port":"' + $("#port").val() + '"').append(',');
        sb_dto.append('"serialPortPara":').append('{');
        sb_dto.append('"baudrate":"' + $("#baudrate").val() + '"').append(',');
        sb_dto.append('"stopbit":"' + $("#stopbit").val() + '"').append(',');
        sb_dto.append('"checkbit":"' + $("#checkbit").val() + '"').append(',');
        sb_dto.append('"odd_even_bit":"' + $("#odd_even_bit").val() + '"').append(',');
        sb_dto.append('"databit":"' + $("#databit").val() + '"');
        sb_dto.append('}').append(',');
        sb_dto.append('"waitforPacket":"' + $("#waitforPacket").val() + '"').append(',');
        sb_dto.append('"waitforByte":"' + $("#waitforByte").val() + '"').append(',');
        sb_dto.append('"commandItems":').append('[').append('{');
        sb_dto.append('"identifier":').append('"8001C04F"').append(',');
        sb_dto.append('"datacellParam":').append('{');
        sb_dto.append('"8001C04F01": "' + $("#psModel").val() + '"').append(',');   // 保护器型号ID
        sb_dto.append('"8001C04F02": "00000001"').append(',');                      // 有效定义
        sb_dto.append('"8001C04F03": "0"').append(',');                             //
        sb_dto.append('"8001C04F04": "0"').append(',');                             //
        sb_dto.append('"8001C04F05": "0"').append(',');                             //
        sb_dto.append('"8001C04F06": "' + getFuncSetupBytes() + '"');               // 开关功能设定字
        sb_dto.append('}');
        sb_dto.append('}').append(']');
        sb_dto.append('}]');
        sb_dto.append('}');
        initOpResultFuncSetupByte('正在设置功能设定字...');
        var url = '<pss:path type="webapp"/>/psmanage/psmon/down.json';
        var params = {
                "dto": sb_dto.toString(),
                "mtoType": $("#protocolNo").val()
        };
        $.ajax({
            type: 'POST',
            url: url,
            data: jQuery.param(params),
            dataType: 'json',
            success: function(data) {
                //alert(data.collectId);
                //alert(data.fetchCount);
                setTimeout("fetchFuncSetupByteSetupResult(" + data.collectId + ", " + data.fetchCount + ")", 3000);
            },
            error: function(XmlHttpRequest, textStatus, errorThrown){
                initOpResultFuncSetupByte('下发设置功能设定字命令失败...');
                enableFuncSetupByteOperation();
            }
        });
    }
}

function fetchFuncSetupByteSetupResult(collectId, fetchCount) {
    var url = '<pss:path type="webapp"/>/psmanage/psmon/up.json';
    var params = {
            "collectId": collectId,
            "type": "FuncSetupByteSetup"
    };
    $.ajax({
        type: 'POST',
        url: url,
        data: jQuery.param(params),
        dataType: 'json',
        success: function(data) {
            var b = showResultFuncSetupByte(data.resultMap, 'setup');
            if(!b && fetchCount > 0) {
                setTimeout("fetchFuncSetupByteSetupResult(" + collectId + ", " + (fetchCount - 1) + ")", 3000);
            }
            else if(b) {
                enableFuncSetupByteOperation();
            }
            else {
                initOpResultFuncSetupByte('设置功能设定字超时');
                enableFuncSetupByteOperation();
            }
        },
        error: function() {
        }
    });
}

function clkFuncSetupByte(bytes) {
    if(bytes == 8) {
        var bChk = $("#funcSetupByte" + bytes).attr("checked");
        if(bChk) {
            $("#funcSetupByte" + bytes + "_additional").html("30mA");
        }
        else {
            $("#funcSetupByte" + bytes + "_additional").html("50mA");
        }
    }
}

function getFuncSetupBytes() {
    var funcSetupBytes = "";
    for(var i = 1; i <= 8; i++) {
        //funcSetupByte
        if($("#funcSetupByte" + i).attr("checked")) {
            funcSetupBytes += "1";
        }
        else {
            funcSetupBytes += "0";
        }
    }
    return funcSetupBytes;
}

function showFuncSetupBytes(funcSetupBytes) {
    //alert("showFuncSetupBytes");
    funcSetupBytes = $.trim(funcSetupBytes);
    //alert(funcSetupBytes);
    for(var i = 1; i <= 8; i++) {
        //alert(funcSetupBytes.charAt(8 - i));
        if(funcSetupBytes.charAt(i - 1) == '1') {
            $("#funcSetupByte" + i).attr("checked", true);
        }
        else {
            $("#funcSetupByte" + i).attr("checked", false);
        }
        clkFuncSetupByte(8);
    }
}

var bResultPSTotalParams = false;
function disablePSTotalParamsOperation() {
    $("#psTotalParamsReadBtn").attr("disabled", true);
    $("#psTotalParamsSetupBtn").attr("disabled", true);
}

function enablePSTotalParamsOperation() {
    $("#psTotalParamsReadBtn").attr("disabled", false);
    $("#psTotalParamsSetupBtn").attr("disabled", false);
}

function initOpResultPSTotalParams(msg) {
    //alert(msg);
    $("#resultPSTotalParams").html(msg);
}

function showResultPSTotalParams(resultMap, type) {
    //alert(resultMap + "," + type);
    var logicalAddr = $("#logicalAddr").val();
    var meterAddr = $("#meterAddr").val();
    if(type == 'setup') {  // 设置开关全部参数
        var result = null;
        result = resultMap[logicalAddr + '#' + fillTopsMeterAddr(meterAddr) + "#" + "8001C04F"];
        if(typeof result != "undefined") {
            if(result == "1") {
                result = "设置开关全部参数成功";
            }
            else if(result == "2") {
                result = "设置开关全部参数失败";
            }
            $("#resultPSTotalParams").html(result);
            bResultPSTotalParams = true;
            return true;
        }
        else {
            return false;
        }
    }
    else {                // 读取开关全部参数
        var result = null;
        result = resultMap[logicalAddr + '#' + fillTopsMeterAddr(meterAddr) + "#" + "8000C04F"];
        if(typeof result != "undefined") {
            $("input[rci='8000C04F'][rdi='8000C04F05']").val(result['8000C04F05']);
            $("select[rci='8000C04F'][rdi='8000C04F06']").val(result['8000C04F06']);
            $("select[rci='8000C04F'][rdi='8000C04F07']").val(result['8000C04F06']);
            $("select[rci='8000C04F'][rdi='8000C04F08']").val(result['8000C04F08']);
            $("input[rci='8000C04F'][rdi='8000C04F09']").val(result['8000C04F09']);
            $("#psModel").val(result['8000C04F11']);
            $("#resultPSTotalParams").html("读取开关全部参数成功");
            bResultPSTotalParams = true;
            return true;
        }
        else {
            return false;
        }
    }
}

// 读开关全部参数
function psTotalParamsRead() {
    if(confirm("确定要对该漏保的参数进行读取？")) {
        disablePSTotalParamsOperation();
        var sb_dto = new StringBuffer();
        sb_dto.append('{');
        sb_dto.append('"collectObjects_Transmit":').append('[{');
        sb_dto.append('"terminalAddr":"' + $("#logicalAddr").val() + '"').append(',');
        sb_dto.append('"equipProtocol":"' + $("#protocolNo").val() + '"').append(',');
        sb_dto.append('"meterAddr":"' + $("#meterAddr").val() + '"').append(',');
        sb_dto.append('"meterType":"' + $("#meterType").val() + '"').append(',');
        sb_dto.append('"funcode":"1"').append(',');
        sb_dto.append('"port":"' + $("#port").val() + '"').append(',');
        sb_dto.append('"serialPortPara":').append('{');
        sb_dto.append('"baudrate":"' + $("#baudrate").val() + '"').append(',');
        sb_dto.append('"stopbit":"' + $("#stopbit").val() + '"').append(',');
        sb_dto.append('"checkbit":"' + $("#checkbit").val() + '"').append(',');
        sb_dto.append('"odd_even_bit":"' + $("#odd_even_bit").val() + '"').append(',');
        sb_dto.append('"databit":"' + $("#databit").val() + '"');
        sb_dto.append('}').append(',');
        sb_dto.append('"waitforPacket":"' + $("#waitforPacket").val() + '"').append(',');
        sb_dto.append('"waitforByte":"' + $("#waitforByte").val() + '"').append(',');
        sb_dto.append('"commandItems":').append('[').append('{');
        sb_dto.append('"identifier":').append('"8000C04F"');
        sb_dto.append('}').append(']');
        sb_dto.append('}]');
        sb_dto.append('}');
        initOpResultPSTotalParams('正在读开关全部参数...');
        var url = '<pss:path type="webapp"/>/psmanage/psmon/down.json';
        var params = {
                "dto": sb_dto.toString(),
                "mtoType": $("#protocolNo").val()
        };
        $.ajax({
            type: 'POST',
            url: url,
            data: jQuery.param(params),
            dataType: 'json',
            success: function(data) {
                //alert(data.collectId);
                //alert(data.fetchCount);
                setTimeout("fetchPSTotalParamsReadResult(" + data.collectId + ", " + data.fetchCount + ")", 3000);
            },
            error: function(XmlHttpRequest, textStatus, errorThrown){
                initOpResultPSTotalParams('下发读开关全部参数命令失败...');
                enablePSTotalParamsOperation();
            }
        });
    }
}

function fetchPSTotalParamsReadResult(collectId, fetchCount) {
    var url = '<pss:path type="webapp"/>/psmanage/psmon/up.json';
    var params = {
            "collectId": collectId,
            "type": "PSTotalParamsRead"
    };
    $.ajax({
        type: 'POST',
        url: url,
        data: jQuery.param(params),
        dataType: 'json',
        success: function(data) {
            var b = showResultPSTotalParams(data.resultMap, 'read');
            if(!b && fetchCount > 0) {
                setTimeout("fetchPSTotalParamsReadResult(" + collectId + ", " + (fetchCount - 1) + ")", 3000);
            }
            else if(b) {
                enablePSTotalParamsOperation();
            }
            else {
                initOpResultPSTotalParams('读开关全部参数超时');
                enablePSTotalParamsOperation();
            }
        },
        error: function() {
        }
    });
}

// 写开关全部参数
function psTotalParamsSetup() {
    if(confirm("确定要对该漏保的参数进行设置？")) {
        disablePSTotalParamsOperation();
        var sb_dto = new StringBuffer();
        sb_dto.append('{');
        sb_dto.append('"collectObjects_Transmit":').append('[{');
        sb_dto.append('"terminalAddr":"' + $("#logicalAddr").val() + '"').append(',');
        sb_dto.append('"equipProtocol":"' + $("#protocolNo").val() + '"').append(',');
        sb_dto.append('"meterAddr":"' + $("#meterAddr").val() + '"').append(',');
        sb_dto.append('"meterType":"' + $("#meterType").val() + '"').append(',');
        sb_dto.append('"funcode":"4"').append(',');
        sb_dto.append('"port":"' + $("#port").val() + '"').append(',');
        sb_dto.append('"serialPortPara":').append('{');
        sb_dto.append('"baudrate":"' + $("#baudrate").val() + '"').append(',');
        sb_dto.append('"stopbit":"' + $("#stopbit").val() + '"').append(',');
        sb_dto.append('"checkbit":"' + $("#checkbit").val() + '"').append(',');
        sb_dto.append('"odd_even_bit":"' + $("#odd_even_bit").val() + '"').append(',');
        sb_dto.append('"databit":"' + $("#databit").val() + '"');
        sb_dto.append('}').append(',');
        sb_dto.append('"waitforPacket":"' + $("#waitforPacket").val() + '"').append(',');
        sb_dto.append('"waitforByte":"' + $("#waitforByte").val() + '"').append(',');
        sb_dto.append('"commandItems":').append('[').append('{');
        sb_dto.append('"identifier":').append('"8001C04F"').append(',');//$("input[type=checkbox][name='itemId2']")
        sb_dto.append('"datacellParam":').append('{');
        sb_dto.append('"8001C04F01": "' + $("#psModel").val() + '"').append(',');                                   // 保护器型号ID
        sb_dto.append('"8001C04F02": "11100000"').append(',');                                                      // 有效定义
        sb_dto.append('"8001C04F03": "' + $("input[sci='8001C04F'][sdi='8001C04F03']").val() + '"').append(',');    // 额定负载电流档位值
        sb_dto.append('"8001C04F04": "' + $("select[sci='8001C04F'][sdi='8001C04F04']").val() + '"').append(',');   // 剩余电流档位
        sb_dto.append('"8001C04F05": "' + $("select[sci='8001C04F'][sdi='8001C04F05']").val() + '"').append(',');   // 漏电分断延迟档位
        sb_dto.append('"8001C04F06": "00000000"');                                                      // 
        sb_dto.append('}');
        sb_dto.append('}').append(']');
        sb_dto.append('}]');
        sb_dto.append('}');
        initOpResultPSTotalParams('正在写开关全部参数...');
        var url = '<pss:path type="webapp"/>/psmanage/psmon/down.json';
        var params = {
                "dto": sb_dto.toString(),
                "mtoType": $("#protocolNo").val()
        };
        $.ajax({
            type: 'POST',
            url: url,
            data: jQuery.param(params),
            dataType: 'json',
            success: function(data) {
                //alert(data.collectId);
                //alert(data.fetchCount);
                setTimeout("fetchPSTotalParamsSetupResult(" + data.collectId + ", " + data.fetchCount + ")", 3000);
            },
            error: function(XmlHttpRequest, textStatus, errorThrown){
                initOpResultPSTotalParams('下发写开关全部参数命令失败...');
                enablePSTotalParamsOperation();
            }
        });
    }
}

function fetchPSTotalParamsSetupResult(collectId, fetchCount) {
    var url = '<pss:path type="webapp"/>/psmanage/psmon/up.json';
    var params = {
            "collectId": collectId,
            "type": "PSTotalParamsSetup"
    };
    $.ajax({
        type: 'POST',
        url: url,
        data: jQuery.param(params),
        dataType: 'json',
        success: function(data) {
            var b = showResultPSTotalParams(data.resultMap, 'setup');
            if(!b && fetchCount > 0) {
                setTimeout("fetchPSTotalParamsSetupResult(" + collectId + ", " + (fetchCount - 1) + ")", 3000);
            }
            else if(b) {
                enablePSTotalParamsOperation();
            }
            else {
                initOpResultPSTotalParams('设置开关全部参数超时');
                enablePSTotalParamsOperation();
            }
        },
        error: function() {
        }
    });
}

function chg8000C04F06(obj) {
    $("select[rci='8000C04F'][rdi='8000C04F07']").val($(obj).val());
}

function chg8000C04F08(obj) {
    var iPsModel = parseInt($("#psModel").val());
    if(1 == iPsModel || 3 == iPsModel || 5 == iPsModel || 7 == iPsModel) {
        if("1" == $(obj).val()) {
            $("input[rci='8000C04F'][rdi='8000C04F09']").val("200");
        }
        else if("2" == $(obj).val()) {
            $("input[rci='8000C04F'][rdi='8000C04F09']").val("300");
        }
    }
    else if(2 == iPsModel || 4 == iPsModel || 6 == iPsModel || 8 == iPsModel) {
        if("1" == $(obj).val()) {
            $("input[rci='8000C04F'][rdi='8000C04F09']").val("300");
        }
        else if("2" == $(obj).val()) {
            $("input[rci='8000C04F'][rdi='8000C04F09']").val("500");
        }
    }
    else if(101 == iPsModel) {
        if("1" == $(obj).val()) {
            $("input[rci='8000C04F'][rdi='8000C04F09']").val("200");
        }
        else if("2" == $(obj).val()) {
            $("input[rci='8000C04F'][rdi='8000C04F09']").val("500");
        }
    }
}
</script>
</head>
<body style="overflow: auto;">
<div style="display: none;">
  <input type="hidden" id="protocolNo" name="protocolNo" value="${psInfo.terminalInfo.protocolNo}" />
  <input type="hidden" id="logicalAddr" name="logicalAddr" value="${psInfo.terminalInfo.logicalAddr}" />
  <input type="hidden" id="meterAddr" name="meterAddr" value="${psInfo.gpInfo.gpAddr}" />
  <input type="hidden" id="meterType" name="meterType" value="100" />
  <input type="hidden" id="port" name="port" value="1" />
  <input type="hidden" id="baudrate" name="baudrate" value="110" />
  <input type="hidden" id="stopbit" name="stopbit" value="1" />
  <input type="hidden" id="checkbit" name="checkbit" value="0" />
  <input type="hidden" id="odd_even_bit" name="odd_even_bit" value="1" />
  <input type="hidden" id="databit" name="databit" value="8" />
  <input type="hidden" id="waitforPacket" name="waitforPacket" value="10" />
  <input type="hidden" id="waitforByte" name="waitforByte" value="5" />
  <input type="hidden" id="psModel" name="psModel" value="${psModel.code}" />
</div>
<div>
  <div class="jc_tab">
    <ul id=jc_Option>
      <li class="curr" id=jc_Option_0 style="cursor: pointer;" onclick="return mySwitchTab('jc_',0,4)">基本信息</li>
      <li id=jc_Option_1 style="cursor: pointer;" onclick="return mySwitchTab('jc_',1,4)">参数设置</li>
      <li id=jc_Option_2 style="cursor: pointer;" onclick="return mySwitchTab('jc_',2,4)">跳闸信息查询</li>
      <li id=jc_Option_3 style="cursor: pointer;" onclick="return mySwitchTab('jc_',3,4)">漏保数据查询</li>
    </ul>
  </div>
  <div class="jc_con" id=jc_Con>
    <ul class=default id=jc_Con_0>
      <div style="width: 100%">
        <div id="monitoring" style="text-align:center; width: 90px; height: 100px; position: absolute; top: 63px; right: 32px; float: right;">
          <img src="<pss:path type="bgcolor"/>/img/monitoring.gif" alt="正在监测中..." width="85" height="81" />
          <span>正在监测中...</span>
        </div>
        <div class="info_top">
          <span>基本信息</span>
          <div id="bngMonitor" style="float: right;">
          <security:authorize ifAnyGranted="ROLE_AUTHORITY_7">
            <input type="button" id="startMonitoringBtn" value="开始监测" class="jc_sub mgl10" onclick="startMonitoring()" />
            <input type="button" id="endMonitoringBtn" value="结束监测" class="jc_sub mgl10" onclick="endMonitoring()" />
          </security:authorize>
          </div>
        </div>
        <div class="info_con">
          <table width="90%" border="0" cellspacing="0" cellpadding="0">
            <tr>
              <td width="30%" height="30">资产编号：<strong>${psInfo.assetNo}</strong></td>
              <td width="30%">漏保名称：<strong>${psInfo.psName}</strong></td>
              <td width="40%">漏保型号：<strong>${psModel.name}</strong></td>
            </tr>
            <tr>
              <td height="30">测量点序号：<strong>${psInfo.gpInfo.gpSn}</strong></td>
              <td>漏保地址：<strong>${psInfo.gpInfo.gpAddr}</strong></td>
              <td>漏保类型：<strong>${psType.name}</strong></td>
            </tr>
            <tr>
              <td height="30">通信方式：<strong>${commModeGm.name}</strong></td>
              <td colspan="2">安装地址：<strong>${tranInfo.instAddr}</strong></td>
            </tr>
          </table>
        </div>
        <div class="mgt10">
          <table width="100%" border="0" cellspacing="1" cellpadding="0" class="twidth">
            <tr>
              <td width="28%" class="td1" valign="top">
                <div class="green1"><strong>合闸/分闸操作</strong></div>
                <div class="mgt10" style="text-align: center; height: 80px;"><img id="rmtTripImg" src="<pss:path type="bgcolor"/>/img/ps-unkonwn.jpg" alt="" style="width: 101px; height: 70px;" /></div>
                <div class="mgt10 tc" style="height: 30px;">
                <security:authorize ifAnyGranted="ROLE_AUTHORITY_8">
                  <input type="button" id="rmtTripBtn" value=" 跳 闸 " style="width: 60px; height: 25px; cursor: pointer; font-size: 14px; font-weight: normal;" onclick="remoteTriping()" />
                  <input type="button" id="rmtSwitchBtn" value=" 合 闸 " style="width: 60px; height: 25px; cursor: pointer; font-size: 14px; font-weight: normal;" onclick="remoteSwitching()" />
                </security:authorize>
                </div>
                <div class="mgt5 tc" style="height: 30px;">
                <security:authorize ifAnyGranted="ROLE_AUTHORITY_8">
                  <input type="button" id="rmtTestBtn" value=" 试 跳 " style="width: 122px; height: 25px; cursor: pointer; font-size: 14px; font-weight: normal;" onclick="remoteTest()" />
                </security:authorize>
                </div>
                <div id="resultRemote" style="text-align: left;"></div>
              </td>
              <td width="35%" class="td1" valign="top">
                <div class="green1"><strong>实时电压</strong></div>
                <div class="mgt5">
                  <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                      <td width="35%" height="25" align="right">A相电压：</td>
                      <td width="65%"><input ci="8000B66F" di="B611" type="text" value="" style="width: 95px; height: 20px; text-align: right;" /> <span class="red"><strong>V</strong></span></td>
                    </tr>
                    <tr>
                      <td height="25" align="right">B相电压：</td>
                      <td><input ci="8000B66F" di="B612" type="text" value="" style="width: 95px; height: 20px; text-align: right;" /> <span class="red"><strong>V</strong></span></td>
                    </tr>
                    <tr>
                      <td height="25" align="right">C相电压：</td>
                      <td><input ci="8000B66F" di="B613" type="text" value="" style="width: 95px; height: 20px; text-align: right;" /> <span class="red"><strong>V</strong></span></td>
                    </tr>
                  </table>
                </div>
                <div class="green1 mgt10"><strong>负载电流</strong></div>
                <div class="mgt5">
                  <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                      <td width="35%" height="25" align="right">A相电流：</td>
                      <td width="65%"><input ci="8000B66F" di="B621" type="text" value="" style="width: 95px; height: 20px; text-align: right;" /> <span class="red"><strong>A</strong></span></td>
                    </tr>
                    <tr>
                      <td height="25" align="right">B相电流：</td>
                      <td><input ci="8000B66F" di="B622" type="text" value="" style="width: 95px; height: 20px; text-align: right;" /> <span class="red"><strong>A</strong></span></td>
                    </tr>
                    <tr>
                      <td height="25" align="right">C相电流：</td>
                      <td><input ci="8000B66F" di="B623" type="text" value="" style="width: 95px; height: 20px; text-align: right;" /> <span class="red"><strong>A</strong></span></td>
                    </tr>
                  </table>
                </div>
              </td>
              <td width="37%" class="td1" valign="top">
                <div class="green1"><strong>漏保信息</strong></div>
                <div class="mgt10">
                  <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                      <td width="48%" height="25" align="right">剩余电流：</td>
                      <td width="52%"><input ci="8000B66F" di="B660" type="text" value="" style="width: 75px; height: 20px; text-align: right;" /> <span class="red"><strong>mA</strong></span></td>
                    </tr>
                    <tr>
                      <td height="25" align="right">剩余电流动作值：</td>
                      <td><input ci="8000C04F" di="8000C04F07" type="text" value="" style="width: 75px; height: 20px; text-align: right;" /> <span class="red"><strong>mA</strong></span></td>
                    </tr>
                    <tr>
                      <td height="25" align="right">分断时间：</td>
                      <td><input ci="8000C04F" di="8000C04F09" type="text" value="" style="width: 75px; height: 20px; text-align: right;" /> <span class="red"><strong>ms</strong></span></td>
                    </tr>
                    <tr>
                      <td height="25" align="right">额定负载电流：</td>
                      <td><input ci="8000C04F" di="8000C04F05" type="text" value="" style="width: 75px; height: 20px; text-align: right;" /> <span class="red"><strong>A</strong></span></td>
                    </tr>
                    <tr>
                      <td height="25" align="right">设备状态：</td>
                      <td>
                        <textarea ci="8000C04F" di="8000C04F0X" rows="5" cols="10" style="overflow: auto;"></textarea>
                      </td>
                    </tr>
                  </table>
                </div>
              </td>
            </tr>
          </table>
        </div>
      </div>
    </ul>
    <ul class=disNone id=jc_Con_1>
      <div class="info_top"><span>时钟设定</span></div>
      <div class="info_con">
        <table width="90%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="80" height="30" align="right">当前时钟：</td>
            <td><input ci="8000C012" di="C012" type="text" value="" style="width: 240px; height: 22px;" /><input type="button" id="timeReadBtn" value=" 读 取 " class="jc_sub mgl10" onclick="timeRead()" /></td>
          </tr>
          <tr>
            <td height="30" align="right">计算机时钟：</td>
            <td><input id="computerTime" type="text" value="" style="width: 240px; height: 22px;" /><security:authorize ifAnyGranted="ROLE_AUTHORITY_9"><input type="button" id="timeSetupBtn" value=" 设 置 " class="jc_sub mgl10" onclick="timeSetup()" /></security:authorize></td>
          </tr>
        </table>
        <div id="resultTime" style="text-align: left;"></div>
      </div>
      <div class="info_top mgt10"><span>功能状态设置</span></div>
      <div class="info_con">
        <table width="90%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="20%" height="30"><input type="checkbox" id="funcSetupByte1" name="funcSetupByte" class="input_nostyle" /> 欠压保护功能 </td>
            <td width="20%"><input type="checkbox" id="funcSetupByte2" name="funcSetupByte" class="input_nostyle" /> 过压保护功能 </td>
            <td width="20%"><input type="checkbox" id="funcSetupByte3" name="funcSetupByte" class="input_nostyle" /> 突变保护功能 </td>
            <td width="25%"><input type="checkbox" id="funcSetupByte4" name="funcSetupByte" class="input_nostyle" /> 缓变保护功能 </td>
            <td width="15%"><input type="button" id="funcSetupByteReadBtn" value=" 读 取 " class="jc_sub" onclick="funcSetupByteRead()" /></td>
          </tr>
          <tr>
            <td height="30"><input type="checkbox" id="funcSetupByte5" name="funcSetupByte" class="input_nostyle" /> 特波保护功能 </td>
            <td><input type="checkbox" id="funcSetupByte6" name="funcSetupByte" class="input_nostyle" /> 自动跟踪功能 </td>
            <td><input type="checkbox" id="funcSetupByte7" name="funcSetupByte" class="input_nostyle" /> 告警功能 </td>
            <td><input type="checkbox" id="funcSetupByte8" name="funcSetupByte" class="input_nostyle" onclick="clkFuncSetupByte(8)" /> 特波动作值<span id="funcSetupByte8_additional">50mA</span> </td>
            <td><security:authorize ifAnyGranted="ROLE_AUTHORITY_9"><input type="button" id="funcSetupByteSetupBtn" value=" 设 置 " class="jc_sub" onclick="funcSetupByteSetup()" /></security:authorize></td>
          </tr>
        </table>
        <div id="resultFuncSetupByte" style="text-align: left;"></div>
      </div>
      <div class="info_top mgt10"><span>参数设定</span></div>
      <div class="info_con">
        <table width="90%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="22%" height="30" align="right">剩余电流档位：</td>
            <td width="28%">
              <select rci="8000C04F" rdi="8000C04F06" sci="8001C04F" sdi="8001C04F04" style="width: 120px; height: 24px;" onchange="chg8000C04F06(this)">
                <option value="1">1</option>
                <option value="2">2</option>
                <option value="3">3</option>
                <option value="4">4</option>
                <option value="5">自动挡</option>
              </select>
            </td>
            <td width="22%" align="right">漏电分断延迟档位：</td>
            <td width="28%">
              <select rci="8000C04F" rdi="8000C04F08" sci="8001C04F" sdi="8001C04F05" style="width: 120px; height: 24px;" onchange="chg8000C04F08(this)">
                <option value="1">1</option>
                <option value="2">2</option>
              </select>
            </td>
          </tr>
          <tr>
            <td height="30" align="right">剩余电流当前档位值：</td>
            <td>
              <select rci="8000C04F" rdi="8000C04F07" style="width: 120px; height: 24px;">
                <option value="1">100</option>
                <option value="2">300</option>
                <option value="3">500</option>
                <option value="4">800</option>
                <option value="5">自动档位值</option>
              </select>
            </td>
            <td align="right">漏电分断延迟时间值：</td>
            <td>
              <input rci="8000C04F" rdi="8000C04F09" type="text" value="" style="width: 100px; height: 20px;" /> mS
            </td>
          </tr>
          <tr>
            <td height="30" align="right">额定负载电流档位值：</td>
            <td>
              <input rci="8000C04F" rdi="8000C04F05" sci="8001C04F" sdi="8001C04F03" type="text" value="" style="width: 110px; height: 20px;" /> A
            </td>
            <td colspan="2" align="center">
              <input type="button" id="psTotalParamsReadBtn" value=" 读 取 " class="jc_sub" onclick="psTotalParamsRead()" />
              <security:authorize ifAnyGranted="ROLE_AUTHORITY_9"><input type="button" id="psTotalParamsSetupBtn" value=" 设 置 " class="jc_sub" onclick="psTotalParamsSetup()" /></security:authorize>
            </td>
          </tr>
        </table>
        <div id="resultPSTotalParams" style="text-align: left;"></div>
      </div>
    </ul>
    <ul class=disNone id=jc_Con_2>
      <div style="vertical-align:middle; height: 30px;">
        <table border="0" cellpadding="0" cellspacing="0">
          <tr>
            <td width="70" height="30" align="right" class="green">开始日期：</td>
            <td width="120" align="left">
              <input type="hidden" id="psId" name="psId" value="${psInfo.psId}" />
              <input type="text" class="input_time" id="sdate" name="sdate" value="${sdate}" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})" readonly="readonly" style="cursor: pointer; height: 22px; width: 152px;" />
            </td>
            <td width="70" align="right" class="green">结束日期：</td>
            <td width="120" align="left">
              <input type="text" class="input_time" id="edate" name="edate" value="${edate}" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})" readonly="readonly" style="cursor: pointer; height: 22px; width: 152px;" />
            </td>
            <td width="100" align="center">
              <img id="eventInquiryBtn" src="<pss:path type="bgcolor"/>/img/inquiry.gif" width="62" height="21" style="cursor: pointer;" />
            </td>
            <td>&nbsp;</td>
          </tr>
        </table>
      </div>
      <div class="content">
        <div id="cont_1" style="height: expression(((document.documentElement.clientHeight || document.body.clientHeight)-75));">
          <iframe id="fdata" name="fdata" scrolling="no" frameborder="0" style="display: block; overflow-y: hidden; overflow-x: hidden; width: 100%; height: 100%"></iframe>
        </div>
      </div>
    </ul>
    <ul class=disNone id=jc_Con_3>
      <div style="vertical-align:middle; height: 30px;">
        <table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr>
            <td width="70" height="30" align="right" class="green">开始日期：</td>
            <td width="120" align="left">
              <input type="hidden" id="psId1" name="psId1" value="${psInfo.psId}" />
              <input type="text" class="input_time" id="sdate1" name="sdate1" value="${sdate}" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})" readonly="readonly" style="cursor: pointer; height: 22px; width: 152px;" />
            </td>
            <td width="70" align="right" class="green">结束日期：</td>
            <td width="120" align="left">
              <input type="text" class="input_time" id="edate1" name="edate1" value="${edate}" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})" readonly="readonly" style="cursor: pointer; height: 22px; width: 152px;" />
            </td>
            <td width="100" align="center">
              <img id="ecCurvInquiryBtn" src="<pss:path type="bgcolor"/>/img/inquiry.gif" width="62" height="21" style="cursor: pointer;" />
            </td>
            <td align="right">
              <img src="<pss:path type="bgcolor"/>/img/grids.png" onclick="showGridMode(3)" width="16" height="16" alt="表格" style="cursor: pointer; border: 1px #DBDBDB solid;" />
              &nbsp;&nbsp;&nbsp; 
              <img src="<pss:path type="bgcolor"/>/img/chart.png" onclick="showPictMode(3)" width="16" height="16" alt="图形" style="cursor: pointer; border: 0px #DBDBDB solid;" />
            </td>
          </tr>
        </table>
      </div>
      <div class="content">
        <div id="cont_1" style="height: expression(((document.documentElement.clientHeight || document.body.clientHeight)-75));">
          <iframe id="fdata1" name="fdata1" scrolling="no" frameborder="0" style="display: block; overflow-y: hidden; overflow-x: hidden; width: 100%; height: 100%"></iframe>
        </div>
      </div>
    </ul>
  </div>
</div>
<script type="text/javascript">
var showMode3 = "grids";
function showGridMode(jcIndex) {
    if(jcIndex == 3) {
        showMode3 = "grids";
        queryEcCurv();
    }
}

function showPictMode(jcIndex) {
    if(jcIndex == 3) {
        showMode3 = "chart";
        queryEcCurv();
    }
}
</script>
</body>
</html>