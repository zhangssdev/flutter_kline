import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dash_path.dart' as dashPath;



class OHLCVGraph extends StatefulWidget{
  OHLCVGraph({
    Key key,
    @required this.data,
    this.currentValue,
    this.lineWidth = 1.0,
    this.fallbackHeight = 100.0,
    this.fallbackWidth = 300.0,
    this.gridLineColor = Colors.grey,
    this.gridLineAmount = 5,
    this.gridLineWidth = 0.5,
    this.gridLineLabelColor = Colors.grey,
    this.labelPrefix = "\$",
    @required this.enableGridLines,
    @required this.volumeProp,
    this.increaseColor = Colors.green,
    this.decreaseColor = Colors.red,
    @required this.preData,
    @required this.maxPreDay,
    this.gridHorizontal = 5,
    this.enableHorizontalGridLines = true,
    this.dayLineWidth = 1.0,
    @required this.timeType,
    this.isShowVolume,
    this.minDayColor,
    this.mediumDayColor,
    this.maxDayColor,
    this.minDayLine,
    this.mediumDayLine,
    this.maxDayLine,
  })  : assert(data != null),
        super(key: key);

  /// OHLCV data to graph  /// List of Maps containing open, high, low, close and volumeto
  /// Example: [["open" : 40.0, "high" : 75.0, "low" : 25.0, "close" : 50.0, "volumeto" : 5000.0}, {...}]
  final List data;

  int gridHorizontal;
  bool enableHorizontalGridLines;
  TimeType timeType;
  double dayLineWidth;
  int maxPreDay;
  List preData;
  bool isShowVolume;
  Color minDayColor;
  Color mediumDayColor;
  Color maxDayColor;
  int minDayLine;
  int mediumDayLine;
  int maxDayLine;
  double currentValue;

  /// All lines in chart are drawn with this width
  final double lineWidth;

  /// Enable or disable grid lines
  final bool enableGridLines;

  /// Color of grid lines and label text
  final Color gridLineColor;
  final Color gridLineLabelColor;

  /// Number of grid lines
  final int gridLineAmount;

  /// Width of grid lines
  final double gridLineWidth;

  /// Proportion of paint to be given to volume bar graph
  final double volumeProp;

  /// If graph is given unbounded space,
  /// it will default to given fallback height and width
  final double fallbackHeight;
  final double fallbackWidth;

  /// Symbol prefix for grid line labels
  final String labelPrefix;

  /// Increase color
  final Color increaseColor;

  /// Decrease color
  final Color decreaseColor;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return OHLCVGraphState();
  }

}


class OHLCVGraphState extends State<OHLCVGraph> {

  bool isShowLongPressLine = false;
  double longPressX;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressEnd: _onLongPressEnd,
      onLongPressStart: _onLongPressStart,
      onLongPressMoveUpdate: _onLongPressMove,
      child: LimitedBox(
        maxHeight: widget.fallbackHeight,
        maxWidth: widget.fallbackWidth,
        child: CustomPaint(
          size: Size.infinite,
          painter: _OHLCVPainter(
            widget.data,
            currentValue: widget.currentValue,
            lineWidth: widget.lineWidth,
            gridLineColor: widget.gridLineColor,
            gridLineAmount: widget.gridLineAmount,
            gridLineWidth: widget.gridLineWidth,
            gridLineLabelColor: widget.gridLineLabelColor,
            enableGridLines: widget.enableGridLines,
            volumeProp: widget.volumeProp,
            labelPrefix: widget.labelPrefix,
            increaseColor: widget.increaseColor,
            decreaseColor: widget.decreaseColor,
            maxPreDay: widget.maxPreDay,
            preData: widget.preData,
            gridHorizontal: widget.gridHorizontal,
            enableHorizontalGridLines: widget.enableHorizontalGridLines,
            dayLineWidth: widget.dayLineWidth,
            timeType: TimeType.day,
            isShowVolume: widget.isShowVolume,
            minDayColor: widget.minDayColor,
            maxDayColor: widget.maxDayColor,
            mediumDayColor: widget.mediumDayColor,
            minDayLine: widget.minDayLine,
            mediumDayLine: widget.mediumDayLine,
            maxDayLine: widget.maxDayLine,
            isShowLongPressLine: isShowLongPressLine,
            longPressX: longPressX,
          ),
        ),
      ),
    );
  }

  _onLongPressEnd(LongPressEndDetails details) {
    print('end${details.localPosition.dx}');
    isShowLongPressLine = false;
    setState(() {});
  }

  _onLongPressMove(LongPressMoveUpdateDetails details) {
    print('move${details.localPosition.dx}');
    longPressX = details.localPosition.dx;
    setState(() {});
  }

  _onLongPressStart(LongPressStartDetails details) {
    print('start${details.localPosition.dx}');
    isShowLongPressLine = true;
    setState(() {});
  }
}

//zl__________________start
enum TimeType {
  month,
  week,
  day,
  hour,
  fiveMinute,
  minute,
}
//zl__________________end

class _OHLCVPainter extends CustomPainter {
  _OHLCVPainter(
    this.data, {
    @required this.lineWidth,
    @required this.enableGridLines,
    @required this.gridLineColor,
    @required this.gridLineAmount,
    @required this.gridLineWidth,
    @required this.gridLineLabelColor,
    @required this.volumeProp,
    @required this.labelPrefix,
    @required this.increaseColor,
    @required this.decreaseColor,
    @required this.timeType,
    @required this.maxPreDay,
    @required this.preData,
    this.currentValue,
    this.gridHorizontal,
    this.enableHorizontalGridLines,
    this.dayLineWidth,
    this.isShowVolume,
    this.minDayColor,
    this.mediumDayColor,
    this.maxDayColor,
    this.minDayLine,
    this.mediumDayLine,
    this.maxDayLine,
    this.isShowLongPressLine,
    this.longPressX,
  });

  final List data;
  final double lineWidth;
  final bool enableGridLines;

  final Color gridLineColor;
  final int gridLineAmount;

  final double gridLineWidth;
  final Color gridLineLabelColor;
  final String labelPrefix;
  final double volumeProp;
  final Color increaseColor;
  final Color decreaseColor;

  double _min;
  double _max;
  double _maxVolume;

  List<TextPainter> gridLineTextPainters = [];
  TextPainter maxVolumePainter;

  //zl________________________start
  int gridHorizontal;
  bool enableHorizontalGridLines;
  TimeType timeType;
  double dayLineWidth;
  int maxPreDay;
  List preData;
  bool isShowVolume;
  Color minDayColor;
  Color mediumDayColor;
  Color maxDayColor;
  int minDayLine;
  int mediumDayLine;
  int maxDayLine;
  bool isShowLongPressLine;
  double longPressX;

  List<TextPainter> gridLineHorizontalTextPainters = [];
  int date_min;
  int date_max;
  List _minDayLineList = [];
  List _mediumDayLineList = [];
  List _maxDayLineList = [];
  Offset lastMinOffset;
  Offset lastMediumOffset;
  Offset lastMaxOffset;
  List _minCache = []; //minLineCache
  List _mediumCache = []; //mediumCache
  List _maxCache = []; //maxLineCache
  double currentValue;

//zl__________________________end

  numCommaParse(number) {
    return number.round().toString().replaceAllMapped(
        new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
  }

  addCache(List cacheList, int length) {
    for (int i = length - 1; i > 0; i--) {
      cacheList.add(preData[maxPreDay - i]["close"]);
    }
  }

  double getAvg(List cacheList, int length) {
    double result = 0.0;
    for (int i = 0; i < length; i++) {
      result += cacheList[i];
    }
    return result / length;
  }

  update() {
    _min = double.infinity;
    _max = -double.infinity;
    _maxVolume = -double.infinity;
    addCache(_minCache, minDayLine);
    addCache(_mediumCache, mediumDayLine);
    addCache(_maxCache, maxDayLine);

    for (int i = 0; i < data.length; i++) {
      if (timeType == TimeType.day) {
        //zl____________-start

        _minCache.add(data[i]["close"]);
        _mediumCache.add(data[i]["close"]);
        _maxCache.add(data[i]["close"]);
        //5天图

        double minValue = getAvg(_minCache, minDayLine);
        _minDayLineList.add(minValue);
        _minCache.removeAt(0);
        //10天图

        double mediumValue = getAvg(_mediumCache, mediumDayLine);
        _mediumDayLineList.add(mediumValue);
        _mediumCache.removeAt(0);
        //30天图
        double value30 = getAvg(_maxCache, maxDayLine);
        _maxDayLineList.add(value30);
        _maxCache.removeAt(0);
        //zl____________-end
      }

      if (data[i]["high"] > _max) {
        _max = data[i]["high"].toDouble();
      }
      if (data[i]["low"] < _min) {
        _min = data[i]["low"].toDouble();
      }
      if (data[i]["volumeto"] > _maxVolume) {
        _maxVolume = data[i]["volumeto"].toDouble();
      }
    }

    for (int i = 0; i < preData.length; i++) {
      if (preData[i]["high"] > _max) {
        _max = preData[i]["high"].toDouble();
      }
      if (preData[i]["low"] < _min) {
        _min = preData[i]["low"].toDouble();
      }
      if (preData[i]["volumeto"] > _maxVolume) {
        _maxVolume = preData[i]["volumeto"].toDouble();
      }
    }

    //zl__________________________start
    date_max = data[0]['id'];
    date_min = data[data.length - 1]['id'];
    //zl__________________________end

    if (enableGridLines) {
      double gridLineValue;
      for (int i = 0; i < gridLineAmount; i++) {
        // Label grid lines
        gridLineValue = _max - (((_max - _min) / (gridLineAmount - 1)) * i);

        String gridLineText;
        if (gridLineValue < 1) {
          // 保留变量的位数(小数点前后的总位数), 不足补0, 多余的四舍五入
          // print(d0.toStringAsPrecision(10));  // 13.09870000
          gridLineText = gridLineValue.toStringAsPrecision(4);
        } else if (gridLineValue < 999) {
          // 保留指定的小数位数(四舍五入), 不足补0, 字符串返回
          //print(d0.toStringAsFixed(2)); // 13.10
          gridLineText = gridLineValue.toStringAsFixed(2);
        } else {
          gridLineText = gridLineValue.round().toString().replaceAllMapped(
              new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => "${m[1]},");
        }

        gridLineTextPainters.add(new TextPainter(
            text: new TextSpan(
                text: labelPrefix + gridLineText,
                style: new TextStyle(
                    color: gridLineLabelColor,
                    fontSize: 6.0,
                    fontWeight: FontWeight.bold)),
            textDirection: TextDirection.ltr));
        gridLineTextPainters[i].layout();
      }

      // Label volume line
      maxVolumePainter = new TextPainter(
          text: new TextSpan(
              text: labelPrefix + numCommaParse(_maxVolume),
              style: new TextStyle(
                  color: gridLineLabelColor,
                  fontSize: 6.0,
                  fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr);
      maxVolumePainter.layout();
    }
    //zl______________________start
    //时间轴
    if (enableHorizontalGridLines) {
      int gridLineHorizontalValue;
      for (int i = 0; i < gridHorizontal; i++) {
        // Label grid lines
        gridLineHorizontalValue = date_max -
            (((date_max - date_min) / (gridHorizontal - 1)) * i).toInt();
        String gridLinegridLineHorizontalValueText;
        if (timeType == TimeType.month ||
            timeType == TimeType.day ||
            timeType == TimeType.week) {
          //月日周全部显示日期
          DateTime date = DateTime.fromMillisecondsSinceEpoch(
              gridLineHorizontalValue * 1000);
          gridLinegridLineHorizontalValueText = '${date.month}月${date.day}日';
        } else {
          //其余显示时分
          DateTime date = DateTime.fromMillisecondsSinceEpoch(
              gridLineHorizontalValue * 1000);
          gridLinegridLineHorizontalValueText = '${date.hour}时${date.minute}分';
        }

        gridLineHorizontalTextPainters.add(new TextPainter(
            text: new TextSpan(
                text: gridLinegridLineHorizontalValueText,
                style: new TextStyle(
                    color: gridLineLabelColor,
                    fontSize: 6.0,
                    fontWeight: FontWeight.bold)),
            textDirection: TextDirection.ltr));
        gridLineHorizontalTextPainters[i].layout();
      }
    }
    //zl______________________end
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_min == null ||
        _max == null ||
        _maxVolume == null ||
        currentValue < _min ||
        currentValue > _max) {
      update();
    }
    //绘制黑色背景
    canvas.drawColor(Colors.black87, BlendMode.src);
//zl_________________---start
    Paint minDayPaint = Paint()
      ..color = minDayColor
      ..strokeWidth = dayLineWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Paint mediumDayPaint = Paint()
      ..color = mediumDayColor
      ..strokeWidth = dayLineWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Paint maxDayPaint = Paint()
      ..color = maxDayColor
      ..strokeWidth = dayLineWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    //zl_________________---end

    final double volumeHeight = size.height * volumeProp;
    final double volumeNormalizer = volumeHeight / _maxVolume;

    double width = size.width;
    final double height = size.height * (1 - volumeProp);

    if (enableGridLines) {
      width = size.width - gridLineTextPainters[0].text.text.length * 6;
      Paint gridPaint = new Paint()
        ..color = gridLineColor
        ..strokeWidth = gridLineWidth;

      double gridLineDist = height / (gridLineAmount - 1);
      double gridLineY;

      // Draw grid lines
      for (int i = 0; i < gridLineAmount; i++) {
        gridLineY = (gridLineDist * i).round().toDouble();
        canvas.drawLine(new Offset(0.0, gridLineY),
            new Offset(width, gridLineY), gridPaint);

        // Label grid lines
        gridLineTextPainters[i]
            .paint(canvas, new Offset(width + 2.0, gridLineY - 6.0));
      }

      if (isShowVolume) {
        // Label volume line
        maxVolumePainter.paint(canvas, new Offset(0.0, gridLineY + 2.0));
      }

      //zl______________________start
      double thisHeight = size
          .height /*- gridLineHorizontalTextPainters[0].text.text.length * 6*/;
      Paint gridHorizontalPaint = new Paint()
        ..color = gridLineColor
        ..strokeWidth = gridLineWidth;

      double gridHorizontalLineDist = width / (gridLineAmount - 1);
      double gridLineX;

      // Draw grid lines
      for (int i = 0; i < gridHorizontal; i++) {
        gridLineX = (gridHorizontalLineDist * i).round().toDouble();
        canvas.drawLine(new Offset(gridLineX, 0.0),
            new Offset(gridLineX, thisHeight), gridHorizontalPaint);

        // Label grid lines
        gridLineHorizontalTextPainters[i]
            .paint(canvas, new Offset(gridLineX + 6.0, gridLineY + 2.0));
      }
      //zl______________________end
    }

    final double heightNormalizer = height / (_max - _min);
    final double rectWidth = width / data.length;

    double rectLeft;
    double rectTop;
    double rectRight;
    double rectBottom;

    Paint rectPaint;
    List<double> herizontalLocalValues = [];
    // Loop through all data
    for (int i = 0; i < data.length; i++) {
      herizontalLocalValues.add(i * rectWidth + rectWidth/2);
      rectLeft = (i * rectWidth) + lineWidth / 2;
      rectRight = ((i + 1) * rectWidth) - lineWidth / 2;

      double volumeBarTop = (height + volumeHeight) -
          (data[i]["volumeto"] * volumeNormalizer - lineWidth / 2);
      double volumeBarBottom = height + volumeHeight + lineWidth / 2;

      if (data[i]["open"] > data[i]["close"]) {
        // Draw candlestick if decrease
        rectTop = height - (data[i]["open"] - _min) * heightNormalizer;
        rectBottom = height - (data[i]["close"] - _min) * heightNormalizer;
        rectPaint = new Paint()
          ..color = decreaseColor
          ..strokeWidth = lineWidth;

        Rect ocRect =
            new Rect.fromLTRB(rectLeft, rectTop, rectRight, rectBottom);
        canvas.drawRect(ocRect, rectPaint);

        // Draw volume bars
        Rect volumeRect = new Rect.fromLTRB(
            rectLeft, volumeBarTop, rectRight, volumeBarBottom);
        canvas.drawRect(volumeRect, rectPaint);
      } else {
        // Draw candlestick if increase
        rectTop = (height - (data[i]["close"] - _min) * heightNormalizer) +
            lineWidth / 2;
        rectBottom = (height - (data[i]["open"] - _min) * heightNormalizer) -
            lineWidth / 2;
        rectPaint = new Paint()
          ..color = increaseColor
          ..strokeWidth = lineWidth;
        //zl_________________start
        Rect ocRect =
            new Rect.fromLTRB(rectLeft, rectTop, rectRight, rectBottom);
        canvas.drawRect(ocRect, rectPaint);
        //zl_________________end
        /*  canvas.drawLine(new Offset(rectLeft, rectBottom - lineWidth / 2),
            new Offset(rectRight, rectBottom - lineWidth / 2), rectPaint);
        canvas.drawLine(new Offset(rectLeft, rectTop + lineWidth / 2),
            new Offset(rectRight, rectTop + lineWidth / 2), rectPaint);
        canvas.drawLine(new Offset(rectLeft + lineWidth / 2, rectBottom),
            new Offset(rectLeft + lineWidth / 2, rectTop), rectPaint);
        canvas.drawLine(new Offset(rectRight - lineWidth / 2, rectBottom),
            new Offset(rectRight - lineWidth / 2, rectTop), rectPaint);
*/

        //zl_________________start
        Rect bolumnRect = new Rect.fromLTRB(
            rectLeft, volumeBarTop, rectRight, volumeBarBottom);
        canvas.drawRect(bolumnRect, rectPaint);
        //zl_________________end
        // Draw volume bars
        /*  canvas.drawLine(new Offset(rectLeft, volumeBarBottom - lineWidth / 2),
            new Offset(rectRight, volumeBarBottom - lineWidth / 2), rectPaint);
        canvas.drawLine(new Offset(rectLeft, volumeBarTop + lineWidth / 2),
            new Offset(rectRight, volumeBarTop + lineWidth / 2), rectPaint);
        canvas.drawLine(new Offset(rectLeft + lineWidth / 2, volumeBarBottom),
            new Offset(rectLeft + lineWidth / 2, volumeBarTop), rectPaint);
        canvas.drawLine(new Offset(rectRight - lineWidth / 2, volumeBarBottom),
            new Offset(rectRight - lineWidth / 2, volumeBarTop), rectPaint);*/
      }
      //zl______________5日图start
      if ((timeType == TimeType.day ||
          timeType == TimeType.month ||
          timeType == TimeType.week)) {
        double x = rectLeft + rectWidth / 2 - lineWidth / 2;
        double y = height - (_minDayLineList[i] - _min) * heightNormalizer;

        Offset currentOffset = Offset(x, y);
        if (lastMinOffset != null) {
          canvas.drawLine(lastMinOffset, currentOffset, minDayPaint);
        }
        lastMinOffset = currentOffset;
      }
      //zl______________5日图end
      //zl______________10日图start
      if ((timeType == TimeType.day ||
          timeType == TimeType.month ||
          timeType == TimeType.week)) {
        double x = rectLeft + rectWidth / 2 - lineWidth / 2;
        double y = height - (_mediumDayLineList[i] - _min) * heightNormalizer;

        Offset currentOffset = Offset(x, y);
        if (lastMediumOffset != null) {
          canvas.drawLine(lastMediumOffset, currentOffset, mediumDayPaint);
        }
        lastMediumOffset = currentOffset;
      }
      //zl______________10日图end
      //zl______________30日图start
      if ((timeType == TimeType.day ||
          timeType == TimeType.month ||
          timeType == TimeType.week)) {
        double x = rectLeft + rectWidth / 2 - lineWidth / 2;
        double y = height - (_maxDayLineList[i] - _min) * heightNormalizer;
        Offset currentOffset = Offset(x, y);
        if (lastMaxOffset != null) {
          canvas.drawLine(lastMaxOffset, currentOffset, maxDayPaint);
        }
        lastMaxOffset = currentOffset;
      }
      //zl______________30日图end

      // Draw low/high candlestick wicks
      double low = height - (data[i]["low"] - _min) * heightNormalizer;
      double high = height - (data[i]["high"] - _min) * heightNormalizer;
      canvas.drawLine(
          new Offset(rectLeft + rectWidth / 2 - lineWidth / 2, rectBottom),
          new Offset(rectLeft + rectWidth / 2 - lineWidth / 2, low),
          rectPaint);
      canvas.drawLine(
          new Offset(rectLeft + rectWidth / 2 - lineWidth / 2, rectTop),
          new Offset(rectLeft + rectWidth / 2 - lineWidth / 2, high),
          rectPaint);
    }

    //显示准线------------------------------
    if (currentValue != null) {
      Paint currentPaint = Paint()
        ..color = Colors.purple
        ..strokeWidth = 2
        ..isAntiAlias = true;

      TextPainter currentLineTextPaint = TextPainter(
          text: new TextSpan(
              text: currentValue.toString(),
              style: new TextStyle(
                  color: Colors.purple,
                  fontSize: 6.0,
                  fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr);
      currentLineTextPaint.layout();

      double currentLine = height - (currentValue - _min) * heightNormalizer;
      //画实线
      /*   canvas.drawLine(new Offset(0.0, currentLine),
          new Offset(width, currentLine), currentPaint);*/
      //画虚线
      Path path = Path();
      path.moveTo(0.0, currentLine);
      path.lineTo(width, currentLine);
      path = dashPath.dashPath(path,
          dashArray: dashPath.CircularIntervalList<double>([
            3,
            3,
          ]));
      canvas.drawPath(
          path, BorderSide(color: Colors.purple, width: 2.0).toPaint());
      canvas.drawRRect(
          RRect.fromLTRBR(
              width,
              currentLine - 8.0,
              width + currentLineTextPaint.width + 4,
              currentLine + currentLineTextPaint.height / 2,
              new Radius.circular(3.0)),
          Paint()
            ..color = Colors.white
            ..isAntiAlias = true
            ..style = PaintingStyle.fill);
      currentLineTextPaint.paint(
          canvas, new Offset(width + 2.0, currentLine - 6.0));
    }
    //-----------------显示长按线
    if (isShowLongPressLine && longPressX != null) {
      Paint pressPoint = Paint()..color=Colors.white..isAntiAlias=true;
     int positionX =  middle2(herizontalLocalValues, 0, herizontalLocalValues.length-1, longPressX, rectWidth / 2);
      double width = size.width - gridLineTextPainters[0].text.text.length * 6;
      double thisHeight = size.height;
      double x = herizontalLocalValues[positionX];
     double yValue = data[positionX]['close'];
      double y = height - (yValue - _min) * heightNormalizer;
     canvas.drawLine(Offset(x, 0), Offset(x, thisHeight), pressPoint);
     canvas.drawLine(Offset(0, y), Offset(width, y), pressPoint);
     //在左上角显示按住时刻开盘，收盘
      String leftShow = '开${ data[positionX]['open'].toStringAsFixed(2)} 高${ data[positionX]['high'].toStringAsFixed(2)} 低${ data[positionX]['low'].toStringAsFixed(2)} 关${ data[positionX]['close'].toStringAsFixed(2)}';
      TextPainter currentPressTextPaint = TextPainter(
          text: new TextSpan(
              text: leftShow,
              style: new TextStyle(
                  color: Colors.purple,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr);
      currentPressTextPaint.layout();
      currentPressTextPaint.paint(canvas, Offset(3.0,3.0));
      //线的值
      String leftBottomShow = 'MA$minDayLine ${_minDayLineList[positionX].toStringAsFixed(2)} MA$mediumDayLine ${_mediumDayLineList[positionX].toStringAsFixed(2)} MA$maxDayLine ${_maxDayLineList[positionX].toStringAsFixed(2)}';
      TextPainter currentBottomPressTextPaint = TextPainter(
          text: new TextSpan(
              text: leftBottomShow,
              style: new TextStyle(
                  color: Colors.purple,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr);
      currentBottomPressTextPaint.layout();
      currentBottomPressTextPaint.paint(canvas, Offset(3.0,3.0 + currentPressTextPaint.height));
    }
  }


  /**
   * 二分法返回应该被选中的对应的x值
   */
  int middle2(List<double> list, int start, int end,
      double currentValue, allowScope) {
    int index = 0;
    int middle = ((start + end) / 2).toInt();
    double errorScope = (list[middle] - currentValue).abs();
    if (errorScope < allowScope) {
      return middle;
    } else if((index++) < 10){
      if (currentValue <= list[middle]) {
        print('middle=$middle errorScope=$errorScope allowScope=$allowScope');
        return middle2(
            list, start, middle, currentValue, allowScope);
      } else {
        return middle2(
            list, middle, end, currentValue, allowScope);
      }
    }
  }

  @override
  bool shouldRepaint(_OHLCVPainter old) {
    /*  return data != old.data ||
        lineWidth != old.lineWidth ||
        enableGridLines != old.enableGridLines ||
        gridLineColor != old.gridLineColor ||
        gridLineAmount != old.gridLineAmount ||
        gridLineWidth != old.gridLineWidth ||
        volumeProp != old.volumeProp ||
        gridLineLabelColor != old.gridLineLabelColor;*/
    return true;
  }
}
