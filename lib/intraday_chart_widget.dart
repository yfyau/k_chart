import 'dart:async';

import 'package:flutter/material.dart';
import 'package:k_chart/chart_translations.dart';
import 'package:k_chart/extension/map_ext.dart';
import 'package:k_chart/flutter_k_chart.dart';

class IntradayChartWidget extends StatefulWidget {
  final List<KLineEntity>? datas;

  final MainState mainState;
  final bool volHidden;
  final SecondaryState secondaryState;
  final Function()? onSecondaryTap;

  final bool hideGrid;
  final bool showNowPrice;
  final bool showInfoDialog;
  final Map<String, ChartTranslations> translations;
  final List<String> timeFormat;

  //当屏幕滚动到尽头会调用，真为拉到屏幕右侧尽头，假为拉到屏幕左侧尽头
  final Function(bool)? onLoadMore;

  final int fixedLength;
  final List<int> maDayList;

  final ChartColors chartColors;
  final ResponsiveChartStyle chartStyle;

  //Minimum and Maximum number of data for Intraday display
  final int minLength;
  final int maxLength;

  //Points to draw vertical line and text display
  final List<IntradayPoint> dayPoints;

  IntradayChartWidget(
    this.datas,
    this.chartStyle,
    this.chartColors, {
    this.mainState = MainState.MA,
    this.secondaryState = SecondaryState.MACD,
    this.onSecondaryTap,
    this.volHidden = false,
    this.hideGrid = false,
    this.showNowPrice = true,
    this.showInfoDialog = true,
    this.translations = kChartTranslations,
    this.timeFormat = TimeFormat.YEAR_MONTH_DAY,
    this.onLoadMore,
    this.fixedLength = 2,
    this.maDayList = const [5, 10, 20],
    this.minLength = 0,
    this.maxLength = 10000000,
    this.dayPoints = const [],
  });

  @override
  _IntradayChartWidgetState createState() => _IntradayChartWidgetState();
}

class _IntradayChartWidgetState extends State<IntradayChartWidget>
    with TickerProviderStateMixin {
  double mSelectX = 0.0;
  StreamController<InfoWindowEntity?>? mInfoWindowStream;
  double mHeight = 0, mWidth = 0;
  AnimationController? _controller;
  Animation<double>? aniX;

  bool isScale = false, isDrag = false, isLongPress = false;

  @override
  void initState() {
    super.initState();
    mInfoWindowStream = StreamController<InfoWindowEntity?>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    mInfoWindowStream?.close();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.datas != null && widget.datas!.isEmpty) {
      mSelectX = 0.0;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        mHeight = constraints.maxHeight;
        mWidth = constraints.maxWidth;

        ChartStyle chartStyle = widget.chartStyle;

        if (widget.datas != null) {
          int length =
              widget.datas!.length.clamp(widget.minLength, widget.maxLength);

          /// Re-construct to init the values
          chartStyle = ResponsiveChartStyle(
            pointWidth: mWidth / length,
            topPadding: chartStyle.topPadding,
            bottomPadding: chartStyle.bottomPadding,
            childPadding: chartStyle.childPadding,
            hCrossWidth: chartStyle.hCrossWidth,
            nowPriceLineLength: chartStyle.nowPriceLineLength,
            nowPriceLineSpan: chartStyle.nowPriceLineSpan,
            nowPriceLineWidth: chartStyle.nowPriceLineWidth,
            gridRows: chartStyle.gridRows,
            gridColumns: 0,
            dateTimeFormat: chartStyle.dateTimeFormat,
          );
        }

        final _painter = IntradayChartPainter(
          chartStyle,
          widget.chartColors,
          datas: widget.datas,
          selectX: mSelectX,
          isLongPass: isLongPress,
          mainState: widget.mainState,
          volHidden: widget.volHidden,
          secondaryState: widget.secondaryState,
          isLine: true,
          hideGrid: widget.hideGrid,
          showNowPrice: widget.showNowPrice,
          sink: mInfoWindowStream?.sink,
          fixedLength: widget.fixedLength,
          maDayList: widget.maDayList,
          dayPoints: widget.dayPoints,
        );

        return GestureDetector(
          onTapUp: (details) {
            if (widget.onSecondaryTap != null &&
                _painter.isInSecondaryRect(details.localPosition)) {
              widget.onSecondaryTap!();
            }
          },
          onLongPressStart: (details) {
            isLongPress = true;
            if (mSelectX != details.globalPosition.dx) {
              mSelectX = details.globalPosition.dx;
              notifyChanged();
            }
          },
          onLongPressMoveUpdate: (details) {
            if (mSelectX != details.globalPosition.dx) {
              mSelectX = details.globalPosition.dx;
              notifyChanged();
            }
          },
          onLongPressEnd: (details) {
            isLongPress = false;
            mInfoWindowStream?.sink.add(null);
            notifyChanged();
          },
          child: Stack(
            children: <Widget>[
              CustomPaint(
                size: Size(double.infinity, double.infinity),
                painter: _painter,
              ),
              if (widget.showInfoDialog) _buildInfoDialog()
            ],
          ),
        );
      },
    );
  }

  void notifyChanged() => setState(() {});

  late List<String> infos;

  Widget _buildInfoDialog() {
    return StreamBuilder<InfoWindowEntity?>(
        stream: mInfoWindowStream?.stream,
        builder: (context, snapshot) {
          if (!isLongPress ||
              !snapshot.hasData ||
              snapshot.data?.kLineEntity == null) return Container();
          KLineEntity entity = snapshot.data!.kLineEntity;
          double upDown = entity.change ?? entity.close - entity.open;
          double upDownPercent = entity.ratio ?? (upDown / entity.open) * 100;
          infos = [
            getDate(entity.time),
            entity.open.toStringAsFixed(widget.fixedLength),
            entity.high.toStringAsFixed(widget.fixedLength),
            entity.low.toStringAsFixed(widget.fixedLength),
            entity.close.toStringAsFixed(widget.fixedLength),
            "${upDown > 0 ? "+" : ""}${upDown.toStringAsFixed(widget.fixedLength)}",
            "${upDownPercent > 0 ? "+" : ''}${upDownPercent.toStringAsFixed(2)}%",
            entity.amount.toInt().toString()
          ];
          return Container(
            margin: EdgeInsets.only(
                left: snapshot.data!.isLeft ? 4 : mWidth - mWidth / 3 - 4,
                top: 25),
            width: mWidth / 3,
            decoration: BoxDecoration(
                color: widget.chartColors.selectFillColor,
                border: Border.all(
                    color: widget.chartColors.selectBorderColor, width: 0.5)),
            child: ListView.builder(
              padding: EdgeInsets.all(4),
              itemCount: infos.length,
              itemExtent: 14.0,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final translations = widget.translations.of(context);

                return _buildItem(
                  infos[index],
                  translations.byIndex(index),
                );
              },
            ),
          );
        });
  }

  Widget _buildItem(String info, String infoName) {
    Color color = widget.chartColors.infoWindowNormalColor;
    if (info.startsWith("+"))
      color = widget.chartColors.infoWindowUpColor;
    else if (info.startsWith("-")) color = widget.chartColors.infoWindowDnColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
            child: Text("$infoName",
                style: TextStyle(
                    color: widget.chartColors.infoWindowTitleColor,
                    fontSize: 10.0))),
        Text(info, style: TextStyle(color: color, fontSize: 10.0)),
      ],
    );
  }

  String getDate(int? date) => dateFormat(
      DateTime.fromMillisecondsSinceEpoch(
          date ?? DateTime.now().millisecondsSinceEpoch),
      widget.timeFormat);
}

class IntradayPoint {
  final String text;
  final int index;

  const IntradayPoint(this.text, this.index);

  static const List<IntradayPoint> HKEX = [
    const IntradayPoint('9:30', 0),
    const IntradayPoint('13:00', 150),
    const IntradayPoint('16:00', 329),
  ];
}
