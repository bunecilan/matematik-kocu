# Matematik Akademi — Flutter Android

Matematik Akademi; matematiği sevmeyen veya temelden başlamak isteyen kişilere Türkçe, görsel ve oyunlaştırılmış biçimde matematik öğretmek için hazırlanmış Flutter uygulamasıdır.

## Neler var?

- 9. sınıf seviyesinden ileri matematiğe kadar konu ağacı
- Her ders için 7 adımlı öğretim düzeni
- İlk 3 temel konuda ayrıntılı tam ders
- JSON içinde 4.000 soruluk soru bankası
- Kolay / Orta / Zor / Çok Zor dağılımı
- Pratik, TYT, AYT, konu sınavı ve tekrar modları
- XP, seviye, günlük seri ve rozetler
- Yanlışlar defteri ve favori sorular
- İstatistik grafikleri
- Grafik çizici
- Parmakla karalama alanı
- Geometri laboratuvarı
- Türkçe TTS sesli anlatım

## GitHub'a yükleme — sıfır bilgi düzeyi

Bu depo zaten GitHub'daysa sadece dosyaları değiştirip Commit changes demen yeterlidir.

Yeni bir depoda kullanacaksan:
1. GitHub'da New repository ile boş bir depo oluştur.
2. Bu projenin bütün dosyalarını depoya yükle.
3. Commit changes düğmesine bas.
4. Üst menüden Actions bölümüne gir.
5. Flutter APK Oluştur iş akışını aç.
6. Yeşil tik oluşunca iş akışını aç ve Artifacts bölümündeki MatematikAkademi-APK dosyasını indir.

## APK'yı telefona kurma

En kolay APK:
- MatematikAkademi-universal.apk

Dosyayı Android telefona gönder, aç ve gerekirse kullandığın dosya yöneticisi için “Bilinmeyen uygulama yükleme” izni ver.

## Otomatik build

.github/workflows/build-flutter-apk.yml:
- Flutter stable kurar
- flutter pub get çalıştırır
- flutter analyze çalıştırır
- universal release APK üretir
- ABI bazlı APK'ları üretir
- Artifacts alanına yükler
- Her başarılı build için GitHub Releases alanına APK'ları otomatik ekler
