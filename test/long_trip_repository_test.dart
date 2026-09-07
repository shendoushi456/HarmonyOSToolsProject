import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qingman_weather/core/storage/prefs_storage.dart';
import 'package:qingman_weather/features/long_trip/models/long_trip_models.dart';
import 'package:qingman_weather/features/long_trip/repositories/long_trip_repository.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      PrefsStorage.keyCity: '[{"cityName":"首页城市"}]',
    });
    await PrefsStorage.init();
  });

  test('完整长途规划可本地保存并读回城市定位字段', () async {
    final repository = LongTripRepository();
    final plan = LongTripPlan(
      id: 'plan-1',
      start: LongTripPoint(
        cityName: '北京',
        sourceId: '1',
        locationId: '101010100',
        provinceName: '北京',
        adminCityName: '北京',
        latitude: '39.90',
        longitude: '116.40',
        date: DateTime(2026, 9, 8),
        sequence: 0,
      ),
      waypoints: [
        LongTripPoint(
          cityName: '郑州',
          sourceId: '2',
          locationId: '101180101',
          provinceName: '河南',
          adminCityName: '郑州',
          latitude: '34.75',
          longitude: '113.62',
          date: DateTime(2026, 9, 9),
          sequence: 1,
        ),
      ],
      end: LongTripPoint(
        cityName: '武汉',
        sourceId: '3',
        locationId: '101200101',
        provinceName: '湖北',
        adminCityName: '武汉',
        latitude: '30.58',
        longitude: '114.27',
        date: DateTime(2026, 9, 10),
        sequence: 2,
      ),
      createdAt: DateTime(2026, 9, 7),
    );

    expect(await repository.saveAll([plan]), isTrue);
    expect(await repository.containsPersistedPlan(plan.id), isTrue);

    final loaded = repository.loadAll().single;
    expect(loaded.points.map((point) => point.locationId), [
      '101010100',
      '101180101',
      '101200101',
    ]);
    expect(loaded.points.map((point) => point.sequence), [0, 1, 2]);
  });

  test('常用沿途城市独立保存，按天气 locationId 去重', () async {
    final repository = LongTripRepository();
    final points = [
      LongTripPoint(
        cityName: '北京',
        locationId: '101010100',
        date: DateTime(2026, 9, 8),
      ),
      LongTripPoint(
        cityName: '北京城区',
        locationId: '101010100',
        date: DateTime(2026, 9, 9),
      ),
      LongTripPoint(
        cityName: '武汉',
        locationId: '101200101',
        date: DateTime(2026, 9, 10),
      ),
    ];

    expect(await repository.addCommonCities(points), isTrue);
    expect(repository.loadCommonCities().map((city) => city.locationId), [
      '101010100',
      '101200101',
    ]);
    expect(
        PrefsStorage.getString(PrefsStorage.keyCity), '[{"cityName":"首页城市"}]');
  });

  test('相同城市顺序和日期的路线拥有相同指纹', () {
    LongTripPlan createPlan(String id, String startWeatherId) => LongTripPlan(
          id: id,
          start: LongTripPoint(
            cityName: '北京',
            sourceId: '1',
            locationId: startWeatherId,
            date: DateTime(2026, 9, 8),
            sequence: 0,
          ),
          waypoints: const [],
          end: LongTripPoint(
            cityName: '武汉',
            sourceId: '3',
            locationId: '101200101',
            date: DateTime(2026, 9, 10),
            sequence: 1,
          ),
          createdAt: DateTime(2026, 9, 7),
        );

    expect(createPlan('old', '101010100').routeFingerprint,
        createPlan('new', '').routeFingerprint);
  });

  // 回归：saveDraft 会对 loadAll 结果直接 add。空存储时若返回
  // const []（不可变列表），首次保存会抛
  // "Unsupported operation: Cannot add to an unmodifiable list"。
  test('无已存数据时 loadAll 返回可增长列表', () async {
    SharedPreferences.setMockInitialValues({});
    await PrefsStorage.init();

    final plans = LongTripRepository().loadAll();
    expect(
        () => plans.add(LongTripPlan(
              id: 'plan-empty',
              start: LongTripPoint(
                  cityName: '北京', date: DateTime(2026, 9, 8)),
              waypoints: const [],
              end: LongTripPoint(
                  cityName: '上海', date: DateTime(2026, 9, 9)),
              createdAt: DateTime(2026, 9, 7),
            )),
        returnsNormally);
  });
}
