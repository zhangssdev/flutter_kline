import 'dart:core' ;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'ohlcv_graph.dart';

class KLine extends StatefulWidget {

  final int minNum;
  final double scaleDamp;
  final double dragDamp;
  final int maxPreDay;
  final List dataList;
  Color minDayColor;
  Color mediumDayColor;
  Color maxDayColor;
  int minDayLine;
  int mediumDayLine;
  int maxDayLine;

  @override
  State<StatefulWidget> createState() {
    return KLineState();
  }

  KLine({
    @required this.dataList,
    this.minNum = 20,
    this.scaleDamp = 0.8,
    this.dragDamp = 0.5,
    this.maxPreDay = 30,
    this.minDayColor = Colors.white,
    this.mediumDayColor = Colors.yellow,
    this.maxDayColor = Colors.greenAccent,
    this.minDayLine = 5,
    this.mediumDayLine = 10,
    this.maxDayLine = 30,
  });
}



class KLineState extends State<KLine> {

  bool isFirst = true;

  int end;
  int start; //因为最终数据最重要，所以初始值为end-num
  int currentNum;
  int lastNum;
  int currentStart;
  int currentEnd;
  bool isFirstScaleFrame = false;
  List _data;
  double marginHeight;

  bool allowDrag = true;

  int currentCount;


  double _open;
  double _close;
  double _high;
  double _low;

  _longPressChange(double open, double close,double high,double low){
    _open = open;
    _close = close;
    _high = high;
    _low = low;
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            content: Container(
              child: Column(
                children: <Widget>[
                  Text('最高：$_high'),
                  Text('最低：$_low'),
                  Text('开盘：$_open'),
                  Text('收盘：$_close'),
                ],
              ),
            ),
          );
        }
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    lastNum = widget.minNum;
    currentCount = widget.dataList.length;
    initSplit();
    _data = _subList(start);

    //计算文字高度,解决高度溢出
    TextPainter _textPainter = TextPainter(
        text: new TextSpan(
            text: '1,1558',
            style: new TextStyle(
                fontSize: 10.0,
                fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr)
    ..layout();

     marginHeight = _textPainter.height/2;
  }

  //计算初始end和start
  initSplit() {
    end =  widget.dataList.length;
    start = end - lastNum;

    print('end$end');
  }

  @override
  void didUpdateWidget(KLine oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(widget.dataList.length > currentCount){//即add了一条数据
      if(_data.last['id'] == widget.dataList[widget.dataList.length -2]['id']){//即当前显示最后一条数据
        initSplit();
        _data = _subList(start);
        currentCount = widget.dataList.length;

      }
    }else{//即最后一条数据在波动

      if(_data[_data.length -2]['id'] == widget.dataList[ widget.dataList.length -2]['id']){//即当前显示最后一条数据
        initSplit();
        _data = _subList(start);

      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
        onHorizontalDragUpdate: allowDrag ? _dragUpdate : null,
        onHorizontalDragStart: _dragStart,
        onHorizontalDragEnd: _dragEnd,
        child: RawGestureDetector(
          gestures: {
            ScaleEveryGestureRecognizer:GestureRecognizerFactoryWithHandlers<ScaleEveryGestureRecognizer>(
                    () =>ScaleEveryGestureRecognizer(),
                    (ScaleEveryGestureRecognizer instance){
                  instance.onUpdate = (ScaleUpdateDetails de){
                    if(de.horizontalScale != 1.0){
                      _scaleUpload(de);
                    };
                  };
                  instance.onStart = handleScaleStart;
                  instance.onEnd = _scaleEnd;
                }
            ),
          },
         /* onScaleUpdate: _scaleUpload,
          onScaleStart: handleScaleStart,
          onScaleEnd: _scaleEnd,*/
          child: Container(
            margin: EdgeInsets.only(top: marginHeight),
            child: OHLCVGraph(
              preData: _subList(start -  widget.maxPreDay, end: start),
              //   key: ValueKey(valueKey),
              currentValue: widget.dataList.last['close'],
              data: _data,
              enableGridLines: true,
              //右侧网格线
              volumeProp: 0.2,
              gridLineAmount: 5,
              gridLineColor: Colors.grey[300],
              timeType: TimeType.hour,
              gridLineLabelColor: Colors.grey,
              maxPreDay:widget.maxPreDay,
              isShowVolume:false,
              minDayColor: widget.minDayColor,
              maxDayColor: widget.maxDayColor,
              mediumDayColor:widget.mediumDayColor,
              minDayLine:widget.minDayLine,
              mediumDayLine:widget.mediumDayLine,
              maxDayLine:widget.maxDayLine,
            ),
          ),
        ),
    );
  }

  _dragStart(DragStartDetails details) {
    print('dragStart');
  }

  _dragUpdate(DragUpdateDetails details) {
    int offsetNum = (details.delta.dx *  1).toInt();
    if(offsetNum <0 && offsetNum> -1){
      offsetNum = -1;
    }else if(offsetNum >0 && offsetNum< 1){
      offsetNum = 1;
    }

    start = start - offsetNum;
    end = end - offsetNum;

    if (end >=  widget.dataList.length) {
      end =  widget.dataList.length;
      start = end -  lastNum;
    }
    if (start <=  widget.maxPreDay) {
      start =  widget.maxPreDay;
      end = start +  lastNum;
    }
    print('start$start end$end');
    _data = _subList(start, end: end);
    setState(() {});
  }

  _dragEnd(DragEndDetails details) {

  }

  //获取段落
  List _subList(int start, {int end}) {
    List result;
    if (end != null) {
      result =  widget.dataList.sublist(start, end);
    } else {
      result =  widget.dataList.sublist(start);
    }
    return result;
  }

  handleScaleStart(ScaleStartDetails details) {
    isFirstScaleFrame = true;
  }

  _scaleEnd(ScaleEndDetails details) {
    if (currentNum != null) {
      lastNum = currentNum;
    }
    allowDrag = true;
    setState(() {});
  }

  _scaleUpload(ScaleUpdateDetails details) {
    allowDrag = false;
    //if(details.horizontalScale != 1.0){
      double ho = (details.horizontalScale - 1).abs();
      double ve = (details.verticalScale - 1).abs();
     // if (ho > ve) {
        if (isFirstScaleFrame) {
          isFirstScaleFrame = false;
          return;
       }
        double scale = details.horizontalScale;

        currentNum = ((1 / scale) * lastNum).floor();
        currentNum = (currentNum *  widget.scaleDamp).toInt();
        currentNum = clamp(widget.minNum, widget.dataList.length -  widget.maxPreDay, currentNum);
        //改变起始值和结束值
        double center = (end + start)/2;
        //加0.5保证均衡性
        end =  (center + currentNum/2 +0.5).toInt();
        start = (center - currentNum/2).toInt();
        if (end >=  widget.dataList.length) {
          end =  widget.dataList.length;
          start = end -  currentNum;
        }
        if (start <=  widget.maxPreDay) {
          start =  widget.maxPreDay;
          end = start +  currentNum;
        }
        print('start=$start end=$end');
        _data = _subList(start, end: end);
        setState(() {});
     // }
    }
//  }
}

num clamp(num min, num max, num currentValue) {
  if (currentValue <= min) {
    return min;
  } else if (currentValue >= max) {
    return max;
  }
  return currentValue;
}

class ScaleEveryGestureRecognizer extends ScaleGestureRecognizer {
  @override
  void handleEvent(PointerEvent event) {
    super.handleEvent(event);
  }

  @override
  void rejectGesture(int pointer) {//当battle失败后执行的语句
    acceptGesture(pointer);
  }
}