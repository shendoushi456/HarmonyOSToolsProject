import 'package:flutter_test/flutter_test.dart';
import 'package:harmonyos_flutter_empty/domain/validators/license_plate_validator.dart';
import 'package:harmonyos_flutter_empty/data/repositories/license_plate_options_repository.dart';

/// 车牌校验器 + 选项数据测试
void main() {
  group('LicensePlateValidator.isValid', () {
    test('普通车牌 6 位应合法', () {
      expect(LicensePlateValidator.isValid('A12345'), isTrue);
      expect(LicensePlateValidator.isValid('ABC123'), isTrue);
    });

    test('新能源车牌 7 位应合法', () {
      expect(LicensePlateValidator.isValid('AD12345'), isTrue);
      expect(LicensePlateValidator.isValid('D123456'), isTrue);
    });

    test('空字符串不合法', () {
      expect(LicensePlateValidator.isValid(''), isFalse);
    });

    test('长度不足不合法', () {
      expect(LicensePlateValidator.isValid('A1234'), isFalse);
    });

    test('长度过长不合法', () {
      expect(LicensePlateValidator.isValid('A1234567'), isFalse);
    });

    test('含小写字母不合法', () {
      expect(LicensePlateValidator.isValid('a12345'), isFalse);
    });

    test('含特殊字符不合法', () {
      expect(LicensePlateValidator.isValid('A1234!'), isFalse);
    });
  });

  group('LicensePlateValidator.errorMessage', () {
    test('空 → 请输入车牌号码', () {
      expect(LicensePlateValidator.errorMessage(''), '请输入车牌号码');
    });

    test('长度 < 6 → 长度不够', () {
      expect(LicensePlateValidator.errorMessage('A123'), '车牌号码长度不够');
    });

    test('长度 > 7 → 长度过长', () {
      expect(LicensePlateValidator.errorMessage('A12345678'), '车牌号码长度过长');
    });

    test('格式不对 → 格式不正确', () {
      expect(LicensePlateValidator.errorMessage('a12345'), '车牌号码格式不正确');
    });

    test('合法车牌 → null', () {
      expect(LicensePlateValidator.errorMessage('A12345'), isNull);
      expect(LicensePlateValidator.errorMessage('AD12345'), isNull);
    });
  });

  group('LicensePlateOptionsRepository', () {
    final repo = LicensePlateOptionsRepository();

    test('能源类型应有 3 项', () {
      expect(repo.getEnergyTypes().length, 3);
      expect(repo.getEnergyTypes(), ['默认', '新能源', '非新能源']);
    });

    test('车牌前缀应有 32 项（默认 + 31 省份）', () {
      expect(repo.getPlatePrefixes().length, 32);
      expect(repo.getPlatePrefixes().first, '默认');
      expect(repo.getPlatePrefixes().contains('京'), isTrue);
      expect(repo.getPlatePrefixes().contains('粤'), isTrue);
      expect(repo.getPlatePrefixes().contains('新'), isTrue);
    });

    test('车牌类型应有 5 项', () {
      expect(repo.getPlateTypes().length, 5);
      expect(repo.getPlateTypes(), ['默认', '小型汽车', '大型汽车', '新能源汽车', '挂车']);
    });
  });
}
