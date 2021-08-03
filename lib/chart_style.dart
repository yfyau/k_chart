import 'dart:math';

import 'package:flutter/material.dart' show Color;
import 'package:k_chart/flutter_k_chart.dart';

class ChartColors {
  List<Color> bgColor = [Color(0xff18191d), Color(0xff18191d)];

  Color kLineColor = Color(0xff4C86CD);
  Color lineFillColor = Color(0x554C86CD);
  Color ma5Color = Color(0xffC9B885);
  Color ma10Color = Color(0xff6CB0A6);
  Color ma30Color = Color(0xff9979C6);
  Color upColor = Color(0xff4DAA90);
  Color dnColor = Color(0xffC15466);
  Color volColor = Color(0xff4729AE);

  Color macdColor = Color(0xff4729AE);
  Color difColor = Color(0xffC9B885);
  Color deaColor = Color(0xff6CB0A6);

  Color kColor = Color(0xffC9B885);
  Color dColor = Color(0xff6CB0A6);
  Color jColor = Color(0xff9979C6);
  Color rsiColor = Color(0xffC9B885);

  Color defaultTextColor = Color(0xff60738E);

  Color nowPriceUpColor = Color(0xff4DAA90);
  Color nowPriceDnColor = Color(0xffC15466);
  Color nowPriceTextColor = Color(0xffffffff);

  //深度颜色
  Color depthBuyColor = Color(0xff60A893);
  Color depthSellColor = Color(0xffC15866);

  //选中后显示值边框颜色
  Color selectBorderColor = Color(0xff6C7A86);

  //选中后显示值背景的填充颜色
  Color selectFillColor = Color(0xff0D1722);

  //分割线颜色
  Color gridColor = Color(0xff4c5c74);

  Color infoWindowNormalColor = Color(0xffffffff);
  Color infoWindowTitleColor = Color(0xffffffff);
  Color infoWindowUpColor = Color(0xff00ff00);
  Color infoWindowDnColor = Color(0xffff0000);

  Color hCrossColor = Color(0xffffffff);
  Color vCrossColor = Color(0x1Effffff);
  Color crossTextColor = Color(0xffffffff);

  //当前显示内最大和最小值的颜色
  Color maxColor = Color(0xffffffff);
  Color minColor = Color(0xffffffff);

  Color getMAColor(int index) {
    switch (index % 3) {
      case 1:
        return ma10Color;
      case 2:
        return ma30Color;
      default:
        return ma5Color;
    }
  }
}

class ChartStyle {
  double topPadding;

  double bottomPadding;

  double childPadding;

  //点与点的距离
  double pointWidth;

  //蜡烛宽度
  double candleWidth;

  //蜡烛中间线的宽度
  double candleLineWidth;

  //vol柱子宽度
  double volWidth;

  //macd柱子宽度
  double macdWidth;

  //垂直交叉线宽度
  double vCrossWidth;

  //水平交叉线宽度
  double hCrossWidth;

  //现在价格的线条长度
  double nowPriceLineLength;

  //现在价格的线条间隔
  double nowPriceLineSpan;

  //现在价格的线条粗细
  double nowPriceLineWidth;

  int gridRows;

  int gridColumns;

  //下方時間客製化
  List<String>? dateTimeFormat;

  ChartStyle({
    this.topPadding = 30.0,
    this.bottomPadding = 20.0,
    this.childPadding = 12.0,
    this.pointWidth = 11.0,
    this.candleWidth = 8.5,
    this.candleLineWidth = 1.5,
    this.volWidth = 8.5,
    this.macdWidth = 3.0,
    this.vCrossWidth = 8.5,
    this.hCrossWidth = 0.5,
    this.nowPriceLineLength = 1,
    this.nowPriceLineSpan = 1,
    this.nowPriceLineWidth = 1,
    this.gridRows = 4,
    this.gridColumns = 4,
    this.dateTimeFormat,
  });
}

/// Responsive Chart Style will using [pointWidth] to calculate for other widths
/// In the actual use case, [pointWidth] = screen width / datas.length in [IntradayChartWidget]
/// Other params would be inherited
class ResponsiveChartStyle extends ChartStyle {
  /// Will be controlled inside the [IntradayChartWidget]
  double pointWidth;

  double topPadding;

  double bottomPadding;

  double childPadding;

  //水平交叉线宽度
  double hCrossWidth;

  //现在价格的线条长度
  double nowPriceLineLength;

  //现在价格的线条间隔
  double nowPriceLineSpan;

  //现在价格的线条粗细
  double nowPriceLineWidth;

  int gridRows;

  //Number of columns for Grid
  //In IntradayChartWidget will force reset to 1
  int gridColumns;

  //下方時間客製化
  List<String>? dateTimeFormat;

  ResponsiveChartStyle({
    this.pointWidth = 11.0,
    this.topPadding = 30.0,
    this.bottomPadding = 20.0,
    this.childPadding = 12.0,
    this.hCrossWidth = 0.5,
    this.nowPriceLineLength = 1,
    this.nowPriceLineSpan = 1,
    this.nowPriceLineWidth = 1,
    this.gridRows = 4,
    this.gridColumns = 4,
    this.dateTimeFormat,
  }) : super(
          topPadding: topPadding,
          bottomPadding: bottomPadding,
          childPadding: childPadding,
          pointWidth: pointWidth,
          candleWidth: pointWidth * 0.8,
          candleLineWidth: pointWidth * 0.15,
          volWidth: pointWidth * 0.8,
          macdWidth: pointWidth * 0.8,
          vCrossWidth: pointWidth * 0.8,
          hCrossWidth: hCrossWidth,
          nowPriceLineLength: nowPriceLineLength,
          nowPriceLineSpan: nowPriceLineSpan,
          nowPriceLineWidth: nowPriceLineWidth,
          gridRows: gridRows,
          gridColumns: gridColumns,
          dateTimeFormat: dateTimeFormat,
        );
}
