# Matematik Koçu V2

Sıfırdan ileri seviyeye matematik öğretmek için hazırlanmış, Türkçe, modern ve internetsiz çalışabilen Android uygulaması.

## V2'de neler var?

- 23 ana konu: sayılar ve dört işlemden türev, integral, matris ve karmaşık sayılara kadar.
- "Mala anlatır gibi" katmanlı anlatım: günlük hayat benzetmesi, tek kural, adım adım örnek, **Daha da basit anlat** kartı.
- Android Text-to-Speech ile **sesli konu anlatımı**.
- Parametreli soru üretici: konu, zorluk ve rastgele sayılara göre **1000'den çok farklı soru varyasyonu** üretme kapasitesi.
- Kolay / Orta / Zor / Adaptif zorluk.
- Kullanıcının konu bazında doğru-yanlış geçmişine göre adaptif seviye.
- Akıllı tekrar: en fazla hata yapılan konular otomatik öne çıkar.
- Yanlışlar Defteri ve "Öğrendim" ile tekrar havuzundan çıkarma.
- Favori sorular.
- Günlük seri (streak), XP, doğruluk oranı ve başarı rozetleri.
- TYT / AYT tarzı süreli deneme modu. (Resmî ÖSYM sorularının kopyası değildir.)
- Fonksiyon Grafik Laboratuvarı: doğrusal fonksiyon ve parabol katsayılarını canlı değiştir.
- Hareketli Geometri: üçgen, dikdörtgen ve daireyi görsel/formül bağlantısıyla öğren.
- Parmakla çizilebilen karalama alanı + hızlı hesap makinesi.
- Konu arama ve seviye filtresi.
- Öğrenme ilerlemesi cihazda yerel olarak saklanır.
- Üyelik ve sunucu gerektirmez.

## Bilgisayara program kurmadan APK oluşturma

1. Bu projenin **içindeki tüm dosya ve klasörleri** GitHub'da yeni bir repository'ye yükle. `.github` klasörünün de yüklendiğinden emin ol.
2. GitHub repository sayfasında **Actions** sekmesine gir.
3. `Android APK Oluştur` iş akışını aç. Push sonrasında otomatik başlayabilir; istersen `Run workflow` ile elle de başlatabilirsin.
4. İşlem yeşil tik olduğunda çalışmayı aç.
5. Sayfanın altındaki **Artifacts** bölümünden `MatematikKocu-V2-APK` paketini indir.
6. ZIP'i aç. İçindeki `app-debug.apk` dosyasını Android telefona gönderip kur.

> Telefonda Google Play dışından APK kurarken Android, kullandığın tarayıcı/dosya yöneticisi için "Bilinmeyen uygulama yükleme" izni isteyebilir.

## Teknik yapı

- Kotlin
- Jetpack Compose + Material 3
- Android minSdk 24 / targetSdk 35
- Harici sunucu yok
- İlerleme: SharedPreferences
- APK derleme: GitHub Actions + Gradle 8.9 + Java 17

## Önemli

Uygulama eğitim/pratik amaçlıdır. TYT/AYT modu sınav tarzı çalışma sağlar; ÖSYM ile bağlantılı değildir ve resmî soru bankası değildir.
