import '../../domain/models/indicator_light.dart';

/// 指示灯静态数据仓库
///
/// 对应 Android: toolCarLib/CarIndicatorLightActivity.kt:54-165 getData()
/// 共 21 个指示灯，全部硬编码。
class IndicatorLightRepository {
  static final List<IndicatorLight> _data = [
    IndicatorLight(
      name: 'ABS',
      description: '该指示灯用来显示ABS工作状况。当打开钥匙后，车辆自检时，ABS灯会点亮数秒，随后熄灭。如果未闪亮或者启动后仍不熄灭，表明ABS出现故障。',
      iconAsset: 'assets/images/car/ic_car_indicator_light_1.png',
      textIcon: 'ABS',
    ),
    IndicatorLight(
      name: 'EPC',
      description: '常用于大众品牌车型中。打开钥匙后，车辆开始自检时，EPC灯会点亮数秒，随后熄灭。如车辆启动后仍不熄灭，说明车辆机械与电子系统出现故障。',
      iconAsset: 'assets/images/car/ic_car_indicator_light_2.png',
    ),
    IndicatorLight(
      name: '安全带',
      description: '该指示灯用来显示安全带是否处于锁止状态。当该灯点亮时，说明安全带没有及时的扣紧，有些车型会有相应的提示音。当安全带被及时扣紧后，该指示灯自动熄灭。',
      iconAsset: 'assets/images/car/ic_car_indicator_light_3.png',
    ),
    IndicatorLight(
      name: '电瓶',
      description: '该指示灯用来显示电瓶使用状态。车辆开始自检时，该指示灯点亮，启动后自动熄灭。如果启动后电瓶指示灯常亮，说明该电瓶出现了使用问题，需要更换。',
      iconAsset: 'assets/images/car/ic_car_indicator_light_4.png',
    ),
    IndicatorLight(
      name: '机油',
      description: '该指示灯用来显示发动机内机油的压力状况。打开钥匙门，车辆开始自检时，指示灯点亮，启动后熄灭。该指示灯常亮，说明该车发动机机油压力低于规定标准，需要维修。',
      iconAsset: 'assets/images/car/ic_car_indicator_light_5.png',
    ),
    IndicatorLight(
      name: 'O/D档',
      description: '该指示灯用来显示自动挡的O/D档（Over-Drive）超速档的工作状态。当O/D档指示灯闪亮，说明O/D档已锁止。此时加速器能力获得提升，但会增加油耗。',
      iconAsset: 'assets/images/car/ic_car_indicator_light_6.png',
      textIcon: 'O/D',
    ),
    IndicatorLight(
      name: '油量',
      description: '该指示灯用来显示发动机内燃油的剩余情况。燃油箱内几乎无燃油，此报警灯亮起时，油箱内约剩余7-8L的燃油量。',
      iconAsset: 'assets/images/car/ic_car_indicator_light_7.png',
    ),
    IndicatorLight(
      name: '车门',
      description: '该指示灯用来显示车辆各车门状况。任意车门未关上，或者未关好，该指示灯都有点亮相应的车门指示灯，提示车主车门未关好，当车门关闭或关好时，相应车门指示灯熄灭。',
      iconAsset: 'assets/images/car/ic_car_indicator_light_8.png',
    ),
    IndicatorLight(
      name: '安全气囊',
      description: '该指示灯用来显示安全气囊的工作状态。当打开钥匙门，车辆开始自检时，该指示灯自动点亮数秒后熄灭，如果常亮，则安全气囊出现故障。',
      iconAsset: 'assets/images/car/ic_car_indicator_light_9.png',
    ),
    IndicatorLight(
      name: '刹车盘',
      description: '该指示灯是用来显示车辆刹车盘磨损的状况。一般，该指示灯为熄灭状态，当刹车盘出现故障或磨损过渡时，该灯点亮，修复后熄灭。',
      iconAsset: 'assets/images/car/ic_car_indicator_light_10.png',
    ),
    IndicatorLight(
      name: '手刹',
      description: '该指示灯用来显示车辆手刹的状态。平时为熄灭状态。当手刹被拉起后，该指示灯自动点亮。手刹被放下时，该指示灯自动熄灭。有的车型在行驶中未放下手刹会伴随有警告音。',
      iconAsset: 'assets/images/car/ic_car_indicator_light_11.png',
    ),
    IndicatorLight(
      name: '水温',
      description: '该指示灯用来显示发动机内冷却液的温度。钥匙门打开，车辆自检时会点亮数秒，后熄灭。水温指示灯常亮，说明冷却液温度超过规定值，需立刻暂停行驶。水温正常后熄灭。',
      iconAsset: 'assets/images/car/ic_car_indicator_light_12.png',
    ),
    IndicatorLight(
      name: '发动机',
      description: '该指示灯用来显示车辆发动机的工作状况。当打开钥匙门时，车辆自检时，该指示灯点亮后自动熄灭。如常亮，则说明车辆的发动机出现了机械故障，需要维修。',
      iconAsset: 'assets/images/car/ic_car_indicator_light_13.png',
    ),
    IndicatorLight(
      name: '转向灯',
      description: '该指示灯是用来显示车辆转向灯所在的位置。通常为熄灭状态，当车主点亮转向灯时，该指示灯会同时点亮相应方向的转向指示灯，转向灯熄灭后，该指示灯自动熄灭。',
      iconAsset: 'assets/images/car/ic_car_indicator_light_14.png',
    ),
    IndicatorLight(
      name: '远光灯',
      description: '该指示灯是用来显示车辆远光灯的状态。通常的情况下该指示灯为熄灭状态，当车主点亮远光灯时，该指示灯会同时点亮，以提示车主，车辆的远光灯处于开启状态。',
      iconAsset: 'assets/images/car/ic_car_indicator_light_15.png',
    ),
    IndicatorLight(
      name: '玻璃水',
      description: '该指示灯是用来显示车辆所装玻璃清洁液的多少，平时为熄灭状态。该指示灯点亮时，说明车辆所装载玻璃清洁液已不足，需添加玻璃清洁液。添加玻璃清洁液后，指示灯熄灭。',
      iconAsset: 'assets/images/car/ic_car_indicator_light_16.png',
    ),
    IndicatorLight(
      name: '雾灯',
      description: '该指示灯是用来显示前后雾灯的工作状况。当前后雾灯点亮时，该指示灯相应的标志就会点亮。关闭雾灯后，相应的指示灯熄灭。',
      iconAsset: 'assets/images/car/ic_car_indicator_light_17.png',
    ),
    IndicatorLight(
      name: '示宽灯',
      description: '该指示灯是用来显示车辆示宽灯的工作状态，平时为熄灭状态。当示宽灯打开时，该指示灯随即点亮。当示宽灯关闭或者关闭示宽灯打开大灯时，该指示灯自动熄灭。',
      iconAsset: 'assets/images/car/ic_car_indicator_light_18.png',
    ),
    IndicatorLight(
      name: '内循环',
      description: '该指示灯是用来显示车辆空调系统的工作状态，平时为熄灭状态。当点亮内循环按钮，车辆关闭外循环，空调系统进入内循环状态时，该指示灯自动点亮。内循环关闭时熄灭。',
      iconAsset: 'assets/images/car/ic_car_indicator_light_19.png',
    ),
    IndicatorLight(
      name: 'VSC',
      description: '该指示灯是用来显示车辆VSC（电子车身稳定系统）的工作状态，多出现在日系车上。当该指示灯点亮时，说明VSC系统已被关闭。',
      iconAsset: 'assets/images/car/ic_car_indicator_light_20.png',
    ),
    IndicatorLight(
      name: 'TCS',
      description: '该指示灯是用来显示车辆TCS（牵引力控制系统）的工作状态，多出现在日系车上。当该指示灯点亮时，说明TCS系统已被关闭。',
      iconAsset: 'assets/images/car/ic_car_indicator_light_21.png',
      textIcon: 'TCS',
    ),
  ];

  List<IndicatorLight> getAll() => _data;
}
