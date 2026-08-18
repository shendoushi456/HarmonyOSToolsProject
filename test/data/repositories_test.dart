import 'package:flutter_test/flutter_test.dart';
import 'package:harmonyos_flutter_empty/data/repositories/car_detail_repository.dart';
import 'package:harmonyos_flutter_empty/data/repositories/car_maintenance_repository.dart';
import 'package:harmonyos_flutter_empty/data/repositories/driving_license_repository.dart';
import 'package:harmonyos_flutter_empty/data/repositories/indicator_light_repository.dart';
import 'package:harmonyos_flutter_empty/data/repositories/violation_code_repository.dart';
import 'package:harmonyos_flutter_empty/data/repositories/violation_processing_repository.dart';
import 'package:harmonyos_flutter_empty/domain/models/car_detail_type.dart';

/// 数据完整性测试
///
/// 验证从 Android 搬运的静态数据条数与内容完整。
void main() {
  group('ViolationCodeRepository', () {
    final repo = ViolationCodeRepository();
    test('应有 332 条违章代码', () {
      expect(repo.all.length, 332);
    });

    test('查询 1001A 应返回正确结果', () {
      final result = repo.findByCode('1001A');
      expect(result, isNotNull);
      expect(result!.code, '1001A');
      expect(result.content, contains('拼装的非汽车类'));
    });

    test('查询应大小写不敏感', () {
      expect(repo.findByCode('1001a')?.code, '1001A');
      expect(repo.findByCode('1001A')?.code, '1001A');
    });

    test('查询不存在的代码应返回 null', () {
      expect(repo.findByCode('NOT_EXIST'), isNull);
    });
  });

  group('IndicatorLightRepository', () {
    final repo = IndicatorLightRepository();
    test('应有 21 个指示灯', () {
      expect(repo.getAll().length, 21);
    });

    test('首个指示灯为 ABS', () {
      expect(repo.getAll().first.name, 'ABS');
    });

    test('textIcon 字段保留（ABS/O/D/TCS）', () {
      final textIcons = repo.getAll().where((e) => e.textIcon.isNotEmpty).map((e) => e.textIcon).toSet();
      expect(textIcons, {'ABS', 'O/D', 'TCS'});
    });
  });

  group('CarMaintenanceRepository', () {
    final repo = CarMaintenanceRepository();
    test('应有 6 项养护', () {
      expect(repo.getAll().length, 6);
    });

    test('首项为座椅', () {
      expect(repo.getAll().first.title, '座椅');
    });

    test('每项含图片资源与 Markdown 内容', () {
      for (final item in repo.getAll()) {
        expect(item.imageAsset, startsWith('assets/images/car/ic_car_maintenance_'));
        expect(item.markdownContent, isNotEmpty);
      }
    });
  });

  group('ViolationProcessingRepository', () {
    final repo = ViolationProcessingRepository();
    test('应有 5 项违章处理', () {
      expect(repo.getAll().length, 5);
    });

    test('首项为汽车交通事故处理全流程指南', () {
      expect(repo.getAll().first.title, '汽车交通事故处理全流程指南');
    });
  });

  group('DrivingLicenseRepository', () {
    final repo = DrivingLicenseRepository();
    test('应有 5 档扣分', () {
      expect(repo.tabList.length, 5);
    });

    test('Tab 标签正确', () {
      expect(repo.tabList, ['记12分', '记9分', '记6分', '记3分', '记1分']);
    });

    test('每档内容非空', () {
      for (var i = 0; i < 5; i++) {
        expect(repo.getContent(i), isNotEmpty);
      }
    });
  });

  group('CarDetailRepository', () {
    final repo = CarDetailRepository();
    test('应有 6 个详情类型', () {
      expect(CarDetailType.values.length, 6);
    });

    test('按标签查找"交通标志"应返回正确类型', () {
      final type = repo.findByLabel('交通标志');
      expect(type, CarDetailType.trafficSign);
      expect(type?.assetPath, 'assets/images/car/ic_car_detail_1.png');
      expect(type?.enableZoom, isTrue);
    });

    test('按标签查找"车牌类型"应返回 enableZoom=false', () {
      final type = repo.findByLabel('车牌类型');
      expect(type, CarDetailType.licensePlateType);
      expect(type?.enableZoom, isFalse);
    });
  });
}
