// 资源路径常量 - 统一管理所有图片资源路径
class AppAssets {
  AppAssets._();

  static const String _base = 'assets/images';

  /// 顶部天空背景
  static const String skyBackground = '$_base/qmtq_sky_background.png';

  /// 天气卡片背景
  static const String homeWeatherCard = '$_base/qmtq_home_weather_card.png';

  /// 小时预报卡背景
  static const String homeHourlyCard = '$_base/qmtq_home_hourly_card.png';

  /// 趋势卡背景
  static const String homeTrendCard = '$_base/qmtq_home_trend_card.png';

  /// 列表卡背景
  static const String homeListCard = '$_base/qmtq_home_list_card.png';

  /// 城市切换图标
  static const String weatherCitySwitch = '$_base/qmtq_weather_city_switch.png';

  /// 风速指标图标
  static const String weatherWind = '$_base/qmtq_weather_wind.png';

  /// 气压指标图标
  static const String weatherPressure = '$_base/qmtq_weather_pressure.png';

  /// 湿度指标图标
  static const String weatherHumidity = '$_base/qmtq_weather_humidity.png';

  /// 大天气图标(雨/雪/默认)
  static const String weatherLarge = '$_base/qmtq_weather_large.png';

  /// 晴图标
  static const String weatherSunny = '$_base/qmtq_weather_sunny.png';

  /// 多云图标
  static const String weatherCloudy = '$_base/qmtq_weather_cloudy.png';

  /// 雨图标
  static const String weatherRain = '$_base/qmtq_weather_rain.png';

  /// 雷图标
  static const String weatherThunder = '$_base/qmtq_weather_thunder.png';

  /// 15日天气标题图标
  static const String weatherForecastTitle =
      '$_base/qmtq_weather_forecast_title.png';

  /// 底部导航 - 首页
  static const String tabHomeNormal = '$_base/qmtq_tab_home_normal.png';
  static const String tabHomeSelected = '$_base/qmtq_tab_home_selected.png';

  /// 底部导航 - 日历
  static const String tabCalendarNormal = '$_base/qmtq_tab_calendar_normal.png';
  static const String tabCalendarSelected =
      '$_base/qmtq_tab_calendar_selected.png';

  /// 底部导航 - 空气
  static const String tabAirNormal = '$_base/qmtq_tab_air_normal.png';
  static const String tabAirSelected = '$_base/qmtq_tab_air_selected.png';

  // ====== 糖压管家底部导航（从 Android navtools_menu 迁移） ======
  static const String toolboxTabTodoNormal =
      '$_base/toolbox_tab_todo_normal.png';
  static const String toolboxTabTodoSelected =
      '$_base/toolbox_tab_todo_selected.png';
  static const String toolboxTabMedicationNormal =
      '$_base/toolbox_tab_medication_normal.png';
  static const String toolboxTabMedicationSelected =
      '$_base/toolbox_tab_medication_selected.png';
  static const String toolboxTabExpiryNormal =
      '$_base/toolbox_tab_expiry_normal.png';
  static const String toolboxTabExpirySelected =
      '$_base/toolbox_tab_expiry_selected.png';
  static const String toolboxTabMoreNormal =
      '$_base/toolbox_tab_more_normal.png';
  static const String toolboxTabMoreSelected =
      '$_base/toolbox_tab_more_selected.png';

  /// 日历卡片背景(335x328)
  static const String calendarCard = '$_base/qmtq_calendar_card.png';

  /// 日历上一月箭头(28dp)
  static const String calendarLeft = '$_base/qmtq_calendar_left.png';

  /// 日历下一月箭头(28dp)
  static const String calendarRight = '$_base/qmtq_calendar_right.png';

  /// 日历选中周背景
  static const String calendarWeekHighlight =
      '$_base/qmtq_calendar_week_highlight.png';

  /// 城市搜索图标(16dp)
  static const String icSearch = '$_base/ic_search.webp';

  // ====== 空气质量页资源 ======
  /// AQI 卡片右侧"实时更新"图标
  static const String airRefresh = '$_base/qmtq_air_refresh.png';

  /// 紫外线指数图标
  static const String airUv = '$_base/qmtq_air_uv.png';

  /// 化妆指数图标
  static const String airMakeup = '$_base/qmtq_air_makeup.png';

  // ====== 设置页资源 ======
  /// 应用 logo
  static const String appLogo = '$_base/ic_logo.png';

  /// 右箭头(设置项)
  static const String arrowRight = '$_base/arrow_right.png';

  /// 白色返回箭头(设置页顶部栏)
  static const String iconWhiteBack = '$_base/icon_white_back.webp';

  /// 用户协议图标
  static const String settingUserIcon = '$_base/setting_4_user_icon.webp';

  /// 隐私协议图标
  static const String settingPrivateIcon = '$_base/setting_4_private_icon.webp';

  /// 关于我们图标
  static const String settingAboutIcon = '$_base/setting_4_about_icon.webp';

  /// 意见反馈图标
  static const String settingFeedbackIcon =
      '$_base/setting_4_feedback_icon.webp';

  // ====== 百宝箱更多页资源（对齐 Android MoreComposeFragment） ======
  static const String toolboxNotebookCard =
      '$_base/nxtx_toolbox_notebook_card.png';
  static const String toolboxNotebook = '$_base/nxtx_toolbox_notebook.png';
  static const String toolboxBankCard = '$_base/nxtx_toolbox_bank_card.png';
  static const String toolboxBank = '$_base/nxtx_toolbox_bank.png';
  static const String toolboxTextCard = '$_base/nxtx_toolbox_text_card.png';
  static const String toolboxText = '$_base/nxtx_toolbox_text.png';
  static const String toolboxPlantCard = '$_base/nxtx_toolbox_plant_card.png';
  static const String toolboxPlant = '$_base/nxtx_toolbox_plant.png';
  static const String toolboxAnimalCard = '$_base/nxtx_toolbox_animal_card.png';
  static const String toolboxAnimal = '$_base/nxtx_toolbox_animal.png';

  // ====== 待办打卡页资源（对齐 Android TodoClockinFragment Nxtx 风格） ======
  /// 待办打卡页每日一句背景
  static const String nxtxHomeQuoteBackground =
      '$_base/nxtx_home_quote_background.png';

  /// 待办 Tab 背景
  static const String nxtxHomeTodoTab = '$_base/nxtx_home_todo_tab.png';

  /// 打卡 Tab 背景
  static const String nxtxHomeClockTab = '$_base/nxtx_home_clock_tab.png';

  /// 待办未完成卡片背景
  static const String nxtxHomeTodoPendingCard =
      '$_base/nxtx_home_todo_pending_card.png';

  /// 待办已完成卡片背景
  static const String nxtxHomeTodoCompletedCard =
      '$_base/nxtx_home_todo_completed_card.png';

  /// 打卡习惯卡片背景
  static const String nxtxHomeClockCard = '$_base/nxtx_home_clock_card.png';

  /// 打卡已勾选图标
  static const String nxtxHomeClockChecked =
      '$_base/nxtx_home_clock_checked.png';

  /// 打卡未勾选图标
  static const String nxtxHomeClockUnchecked =
      '$_base/nxtx_home_clock_unchecked.png';

  /// 添加条背景
  static const String nxtxHomeAddBar = '$_base/nxtx_home_add_bar.png';

  /// 天气定位图标
  static const String nxtxWeatherLocation = '$_base/nxtx_weather_location.png';

  /// 天气小图标 - 晴
  static const String weatherSmallSunny = '$_base/wl_ic_six_7day_sun.png';

  /// 天气小图标 - 多云
  static const String weatherSmallCloudy = '$_base/wl_ic_six_7day_cloudy.png';

  /// 天气小图标 - 雨
  static const String weatherSmallRain = '$_base/wl_ic_six_7day_rain.png';

  /// 天气小图标 - 雷暴
  static const String weatherSmallThunderstorm =
      '$_base/wl_ic_six_7day_thunderstorm.png';

  // ====== 倒数日页资源（对齐 Android CountdownFragment / AddCountdownActivity） ======
  /// 倒数日列表卡片背景 - 蓝(颜色0)
  static const String countdownCardBlue = '$_base/nxtx_countdown_card_blue.png';

  /// 倒数日列表卡片背景 - 绿(颜色1)
  static const String countdownCardGreen =
      '$_base/nxtx_countdown_card_green.png';

  /// 倒数日列表卡片背景 - 橙(颜色2)
  static const String countdownCardOrange =
      '$_base/nxtx_countdown_card_orange.png';

  /// 置顶倒数日圆形背景
  static const String countdownPinCircle =
      '$_base/nxtx_countdown_pin_circle.png';

  /// 添加倒数日悬浮按钮
  static const String countdownAdd = '$_base/nxtx_countdown_add.png';

  /// 新增页 - 目标日日历图标
  static const String countdownDatePicker = '$_base/dsbwl_date_picker.png';

  /// 新增页 - 置顶图标
  static const String countdownPin = '$_base/dsbwl_pin.png';

  /// 新增页 - 重复图标
  static const String countdownRepeat = '$_base/dsbwl_repeat.png';

  /// 新增页 - 颜色图标
  static const String countdownColor = '$_base/dsbwl_color.png';

  /// 底部导航 - 倒数日
  static const String toolboxTabCountdownNormal =
      '$_base/nxtx_tab_countdown_normal.png';
  static const String toolboxTabCountdownSelected =
      '$_base/nxtx_tab_countdown_selected.png';

  // ====== 花费记账页资源（对齐 Android ExpenseFragment / AddExpenseActivity） ======
  /// 记录数卡左侧图标
  static const String expenseRecords = '$_base/nxtx_expense_records.png';

  /// 记录数卡右侧添加按钮
  static const String expenseAdd = '$_base/nxtx_expense_add.png';

  /// 分类图标 - 餐饮
  static const String expenseMeal = '$_base/nxtx_expense_meal.png';

  /// 分类图标 - 购物/其他支出
  static const String expenseShopping = '$_base/nxtx_expense_shopping.png';

  /// 分类图标 - 话费
  static const String expensePhone = '$_base/nxtx_expense_phone.png';

  /// 分类图标 - 工资/其他收入
  static const String expenseIncome = '$_base/nxtx_expense_income.png';

  /// 底部导航 - 花费记账
  static const String toolboxTabExpenseNormal =
      '$_base/nxtx_tab_expense_normal.png';
  static const String toolboxTabExpenseSelected =
      '$_base/nxtx_tab_expense_selected.png';

  // ====== 分类页资源（对齐 Android OtherSaoMiaoFrgment） ======
  /// 底部导航 - 分类(图标用安卓"精洗"Tab 的 ic_quan_tab_1，标题仍为"分类")
  static const String toolboxTabCategoryNormal =
      '$_base/toolbox_tab_category_normal.webp';
  static const String toolboxTabCategorySelected =
      '$_base/toolbox_tab_category_selected.webp';

  /// 分类页顶栏设置图标(源分支 ic_black_shezhi)
  static const String categorySettings = '$_base/ic_black_shezhi.webp';

  /// 部分工具图标为 png 格式(源分支 mipmap 中 2/11/14 为 png，其余为 webp)
  static const _quanToolsPngIndexes = {2, 11, 14};

  /// 分类页工具图标(源分支 ic_quan_tools_1..35)
  static String quanTool(int index) =>
      '$_base/ic_quan_tools_$index.${_quanToolsPngIndexes.contains(index) ? 'png' : 'webp'}';
}
