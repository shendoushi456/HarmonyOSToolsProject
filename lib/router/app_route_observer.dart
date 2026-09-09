import 'package:flutter/material.dart';

/// 监听页面是否被其他路由覆盖，配合 TickerMode 停止不可见页面的动画。
final RouteObserver<ModalRoute<dynamic>> appRouteObserver =
    RouteObserver<ModalRoute<dynamic>>();
