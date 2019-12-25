import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'k_line.dart';


class MyWidgetKLine extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyWidgetKLineState();
  }
}

class MyWidgetKLineState extends State<MyWidgetKLine> {
  List dataList = [];
  int index =0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rootBundle.loadString('assets/k_data.json').then((value){
     // String data = value.toString();
      var dataMap = json.decode(value);
      for(int i =0 ; i< dataMap['t'].length; i++){
        int id =      dataMap['t'][i];
        double open =   dataMap['o'][i]+0.001;
        double high =   dataMap['h'][i]+0.001;
        double low =   dataMap['l'][i]+0.001;
        double close =   dataMap['c'][i]+0.001;
        double volumeto =   5000 + (Random().nextInt(5000)) +0.001;
        dataList.add({'id':id, 'open':open, 'high':high, 'low':low, 'close':close, 'volumeto':volumeto});
      }
      setState(() {});
      openTimer();
    });
        }

  openTimer (){
    Timer.periodic(Duration(seconds: 1), (Timer t){
      //动态变化
      rootBundle.loadString('assets/now_kline.json').then((value){
        var dataMap = json.decode(value);
        var glodMap = dataMap['data'][t.tick];
        if(t.tick >= 4){
          t.cancel();
        }
        int  id = glodMap['currentTime'];
        double  sellOutPrice = glodMap['sellOutPrice'];
        Map currentMap;
        if(t.tick == 0){
          currentMap = {
            'id': id,
            'open': dataList.last['close'],
            'high': dataList.last['close'] > sellOutPrice ? dataList.last['close'] : sellOutPrice,//当前值与收盘价比较
            'low': dataList.last['close'] > sellOutPrice ? sellOutPrice : dataList.last['close'],
            'close':sellOutPrice,
            'volumeto':  5000 + (Random().nextInt(5000)) +0.001
          };
        }else{
          currentMap = {
            'id': id,
            'open': dataList[dataList.length -2]['close'],
            'high': dataList[dataList.length -2]['close'] > sellOutPrice ? dataList[dataList.length -2]['close'] : sellOutPrice,
            'low': dataList[dataList.length -2]['close'] > sellOutPrice ? sellOutPrice: dataList[dataList.length -2]['close'] ,
            'close':sellOutPrice,
            'volumeto':  5000 + (Random().nextInt(5000)) +0.001
          };
        }
        //此处3600表示时间戳之差，现在表示一小时的k图
        if(id - dataList.last['id'] > 3600){ //如果和上次时间超过1小时，那么增加一个柱子
          dataList.add(currentMap);
          setState(() {

          });
        }else{//否则替换最后一个柱子
          //id不同才改变。如果用tcp或者websocket，此处不用加判断。
          if(id != dataList.last['id']){
            dataList.last = currentMap;
            setState(() {});
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('K线图'),
      ),
      body:  Container(
          height: 500,
          child: dataList.length > 0
              ? KLine(
                  dataList: dataList,
                  minNum: 30,
                  minDayColor: Colors.red[400],
                  maxDayColor: Colors.red[100],
                  mediumDayColor: Colors.red[300],
                )
              : CircularProgressIndicator(),
        ),
    );
  }
}
