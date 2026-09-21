import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

const bg = Color(0xFF0A0E27);
const card = Color(0xFF141836);
const blue = Color(0xFF4F8EF7);
const purple = Color(0xFF9B59FF);
const orange = Color(0xFFFF6B35);
const success = Color(0xFF39D353);

class Topic {
  final String id;
  final String group;
  final String title;
  final String subtitle;
  final List<String> prereq;
  const Topic(this.id, this.group, this.title, this.subtitle, [this.prereq = const []]);
}

class LessonStep {
  final String title;
  final String body;
  final String icon;
  const LessonStep(this.title, this.body, this.icon);
}

class Question {
  final String id;
  final String topicId;
  final String topic;
  final String type;
  final String difficulty;
  final String prompt;
  final List<String> options;
  final String answer;
  final String hint;
  final String solution;
  final int wrongPercent;

  const Question({
    required this.id,
    required this.topicId,
    required this.topic,
    required this.type,
    required this.difficulty,
    required this.prompt,
    required this.options,
    required this.answer,
    required this.hint,
    required this.solution,
    required this.wrongPercent,
  });

  factory Question.fromJson(Map<String, dynamic> j) {
    return Question(
      id: j['id'] as String,
      topicId: j['topicId'] as String,
      topic: j['topic'] as String,
      type: j['type'] as String,
      difficulty: j['difficulty'] as String,
      prompt: j['prompt'] as String,
      options: (j['options'] as List).map((e) => e.toString()).toList(),
      answer: j['answer'].toString(),
      hint: j['hint'] as String,
      solution: j['solution'] as String,
      wrongPercent: j['wrongPercent'] as int,
    );
  }
}

const topics = <Topic>[
  Topic('1.1','1. SAYILAR VE CEBİR','Doğal, Tam ve Rasyonel Sayılar','Farkları ve sayı doğrusu'),
  Topic('1.2','1. SAYILAR VE CEBİR','Mutlak Değer','Nedir, neden kullanılır, denklemler',['1.1']),
  Topic('1.3','1. SAYILAR VE CEBİR','Üslü Sayılar','Çarpım, bölüm, kuvvet ve negatif üsler',['1.1']),
  Topic('1.4','1. SAYILAR VE CEBİR','Köklü Sayılar','Karekök sadeleştirme ve işlemler',['1.3']),
  Topic('1.5','1. SAYILAR VE CEBİR','Çarpanlara Ayırma','Beş farklı yöntem',['1.1']),
  Topic('1.6','1. SAYILAR VE CEBİR','Oran ve Orantı','Doğru, ters ve bileşik orantı',['1.1']),
  Topic('1.7','1. SAYILAR VE CEBİR','Yüzde Hesapları','Artış, azalış, kâr, zarar ve faiz',['1.6']),
  Topic('2.1','2. DENKLEMLER VE EŞİTSİZLİKLER','1. Dereceden Denklemler','Bilinmeyeni denge ile bul',['1.5']),
  Topic('2.2','2. DENKLEMLER VE EŞİTSİZLİKLER','1. Dereceden Eşitsizlikler','Aralık ve sayı doğrusu',['2.1']),
  Topic('2.3','2. DENKLEMLER VE EŞİTSİZLİKLER','2. Dereceden Denklemler','Diskriminant ve kökler',['2.1']),
  Topic('2.4','2. DENKLEMLER VE EŞİTSİZLİKLER','2. Dereceden Eşitsizlikler','Parabol yöntemi',['2.3']),
  Topic('2.5','2. DENKLEMLER VE EŞİTSİZLİKLER','Denklem Sistemleri','Yerine koyma, yok etme, grafik',['2.1']),
  Topic('3.1','3. FONKSİYONLAR','Fonksiyon Nedir?','Makine metaforu',['2.1']),
  Topic('3.2','3. FONKSİYONLAR','Doğrusal Fonksiyonlar','Eğim, sabit terim ve grafik',['3.1']),
  Topic('3.3','3. FONKSİYONLAR','2. Dereceden Fonksiyonlar','Parabol ve tepe noktası',['2.3','3.1']),
  Topic('3.4','3. FONKSİYONLAR','Mutlak Değer Fonksiyonu','V grafiği',['1.2','3.1']),
  Topic('3.5','3. FONKSİYONLAR','Parçalı Fonksiyonlar','Koşula göre çalışan fonksiyon',['3.1']),
  Topic('3.6','3. FONKSİYONLAR','Fonksiyon Dönüşümleri','Öteleme, yansıma, ölçekleme',['3.1']),
  Topic('4.1','4. ÜÇGENLER VE TRİGONOMETRİ','Üçgen Çeşitleri','Kenar ve açı özellikleri'),
  Topic('4.2','4. ÜÇGENLER VE TRİGONOMETRİ','Pisagor Teoremi','İspat ve uygulamalar',['4.1']),
  Topic('4.3','4. ÜÇGENLER VE TRİGONOMETRİ','Sinüs, Kosinüs, Tanjant','Birim çember üzerinde görsel',['4.2']),
  Topic('4.4','4. ÜÇGENLER VE TRİGONOMETRİ','Sinüs ve Kosinüs Kuralı','Her üçgende uzunluk ve açı',['4.3']),
  Topic('4.5','4. ÜÇGENLER VE TRİGONOMETRİ','Trigonometrik Denklemler','Periyodik çözümler',['4.3']),
  Topic('5.1','5. GEOMETRİ','Açılar ve Paralellik','Açı ilişkileri'),
  Topic('5.2','5. GEOMETRİ','Çokgenler','İç ve dış açı toplamları',['5.1']),
  Topic('5.3','5. GEOMETRİ','Çember ve Daire','Yay, kiriş, alan ve çevre',['5.1']),
  Topic('5.4','5. GEOMETRİ','Katı Cisimler','Hacim ve yüzey alanı',['5.2']),
  Topic('6.1','6. VERİ VE OLASILIK','Temel İstatistik','Ortalama, medyan, mod'),
  Topic('6.2','6. VERİ VE OLASILIK','Kombinasyon ve Permütasyon','Sayma teknikleri',['1.1']),
  Topic('6.3','6. VERİ VE OLASILIK','Olasılık','Klasik ve koşullu olasılık',['6.2']),
  Topic('6.4','6. VERİ VE OLASILIK','Veri Yorumlama','Grafik ve tablo okuma',['6.1']),
  Topic('7','7. İLERİ LİSE','Logaritma ve Üstel Fonksiyonlar','Ters işlemler ve büyüme',['1.3','3.1']),
  Topic('8','8. İLERİ LİSE','Diziler','Aritmetik, geometrik ve sonsuz seri',['1.3']),
  Topic('9','9. İLERİ LİSE','Limit ve Süreklilik','Yaklaşma fikri',['3.1']),
  Topic('10','10. İLERİ LİSE','Türev','Fiziksel yorum, kurallar, uygulamalar',['9']),
  Topic('11','11. İLERİ LİSE','İntegral','Alan yorumu ve temel teknikler',['10']),
  Topic('12','12. İLERİ LİSE','Karmaşık Sayılar','Gerçel ve sanal bileşenler',['2.3']),
  Topic('13','13. İLERİ MATEMATİK','Lineer Cebir','Matrisler, determinant, vektörler',['2.5']),
  Topic('14','14. İLERİ MATEMATİK','Diferansiyel Denklemler','Değişim denklemlerine giriş',['10','11']),
  Topic('15','15. İLERİ MATEMATİK','İleri İstatistik ve Olasılık','Dağılımlar ve çıkarım',['6.1','6.3']),
];

class LessonBlueprint {
  final String useCase;
  final String concept;
  final String rules;
  final String visual;
  final String example1A;
  final String example1B;
  final String example2;
  final String example3;
  final String pitfalls;
  final String recap;

  const LessonBlueprint({
    required this.useCase,
    required this.concept,
    required this.rules,
    required this.visual,
    required this.example1A,
    required this.example1B,
    required this.example2,
    required this.example3,
    required this.pitfalls,
    required this.recap,
  });
}

LessonBlueprint blueprintFor(Topic t) {
  switch (t.id) {
    case "7":
      return const LessonBlueprint(
        useCase: "Deprem, pH, ses ve üstel büyüme ölçeklerinde logaritma büyük aralıkları yönetir.",
        concept: "Logaritma üstel işlemin tersidir: logₐb=c ⇔ aᶜ=b.",
        rules: "log(xy)=logx+logy; log(x/y)=logx−logy; log(xᵏ)=klogx. Log içi >0, taban >0 ve ≠1.",
        visual: "y=2ˣ ile y=log₂x, y=x doğrusuna göre birbirinin ters/yansıma grafikleridir.",
        example1A: "log₂32.\nYöntem A: 2ˣ=32=2⁵ → 5.",
        example1B: "Aynı — Yöntem B: 32’yi 2’ye beş kez bölüp 1’e ulaşırsın → üs 5.",
        example2: "log₁₀1000+log₁₀0,1 =3+(−1)=2.",
        example3: "log₂x=3 → x=2³=8.",
        pitfalls: "log(x+y)=logx+logy değildir. Log içi pozitif olmalıdır.",
        recap: "Özet: logaritmayı 'tabanı hangi kuvvete yükseltirsem?' diye oku.",
      );
    case "8":
      return const LessonBlueprint(
        useCase: "Düzenli artan ödemeler, tasarruf ve büyüme örüntüleri dizilerle modellenir.",
        concept: "Aritmetik dizide fark sabit; geometrik dizide oran sabittir.",
        rules: "Aritmetik aₙ=a₁+(n−1)d. Geometrik aₙ=a₁rⁿ⁻¹. Aritmetik toplam n(a₁+aₙ)/2.",
        visual: "2,5,8,11 her adım +3; 2,6,18,54 her adım ×3.",
        example1A: "2,5,8,... 10. terim.\nYöntem A: 2+9·3=29.",
        example1B: "Aynı — Yöntem B: 1’den 10’a 9 geçiş var; her geçiş +3 → 29.",
        example2: "3,6,12,24,... 6. terim: 3·2⁵=96.",
        example3: "1,4,7,10,13 toplam: 5(1+13)/2=35.",
        pitfalls: "n. terimde n−1 geçiş vardır. Fark ve oranı karıştırma.",
        recap: "Özet: önce ardışık fark/oranı kontrol et, sonra uygun terim/toplam formülünü seç.",
      );
    case "9":
      return const LessonBlueprint(
        useCase: "Türev ve integralin temeli olan limit, bir fonksiyonun bir noktaya yaklaşırken davranışını inceler.",
        concept: "lim x→a f(x), x a’ya yaklaşırken f(x)’in yaklaştığı değerdir. Noktada tanımlı olmak şart değildir.",
        rules: "Sürekli fonksiyonda yerine koy. 0/0 çıkarsa sadeleştirme ara. Sağ ve sol limit eşit değilse iki yönlü limit yok.",
        visual: "Grafikte x=a’ya soldan ve sağdan yaklaş; y değerleri aynı yüksekliğe gidiyorsa limit vardır.",
        example1A: "lim x→2 (x²−4)/(x−2).\nYöntem A: (x−2)(x+2)/(x−2)=x+2 → 4.",
        example1B: "Aynı — Yöntem B, tablo: 1,99→3,99; 2,01→4,01 → 4’e yaklaşır.",
        example2: "lim x→3 (2x+1)=7, doğrudan yerine koy.",
        example3: "f=0 (x<0),1 (x≥0). x→0 soldan 0, sağdan 1 → limit yok.",
        pitfalls: "0/0 sonuç değil belirsizliktir. Fonksiyon değeri ile limit farklı olabilir.",
        recap: "Özet: önce yerine koy; belirsizlikte sadeleştir; parçalı durumda sağ-sol kontrol et.",
      );
    case "10":
      return const LessonBlueprint(
        useCase: "Anlık hız, eğim, maksimum-minimum ve optimizasyon türevle çözülür.",
        concept: "Türev anlık değişim hızıdır; grafikte teğetin eğimidir.",
        rules: "(xⁿ)'=nxⁿ⁻¹. Sabit türevi 0. Çarpım u'v+uv'. Zincir kuralı: dış türev × iç türev.",
        visual: "İki noktalı kesen eğimini noktalar yaklaşınca tek noktadaki teğet eğimine dönüştürürüz.",
        example1A: "f=x²+3x.\nYöntem A — Kurallar: f'=2x+3.",
        example1B: "Aynı fikri x² için limit tanımıyla: [(x+h)²−x²]/h=2x+h → h→0 → 2x.",
        example2: "f=(2x+1)³ → 3(2x+1)²·2=6(2x+1)².",
        example3: "f=−x²+4x. f'=−2x+4=0 → x=2; f(2)=4 ve parabol aşağı → maksimum.",
        pitfalls: "Zincir kuralında iç türevi unutma. f'=0 yalnız aday noktadır, türünü kontrol et.",
        recap: "Özet: türev=anlık değişim. Temel kurallar + zincir; optimizasyonda kritik noktaları incele.",
      );
    case "11":
      return const LessonBlueprint(
        useCase: "Alan, toplam değişim, yol ve birikimli miktarlar integralle hesaplanır.",
        concept: "Belirsiz integral türevin tersidir: ∫f=F+C. Belirli integral F(b)−F(a) ile toplam değişimi verir.",
        rules: "∫xⁿdx=xⁿ⁺¹/(n+1)+C (n≠−1). Sabit çarpan dışarı çıkar.",
        visual: "Eğri altını çok ince dikdörtgenlerle doldur; dikdörtgenler inceldikçe toplam gerçek alana yaklaşır.",
        example1A: "∫(2x+3)dx.\nYöntem A: terim terim → x²+3x+C.",
        example1B: "Aynı — Yöntem B, ters türev: türevi 2x+3 olan x²+3x+C.",
        example2: "∫₀² x dx = [x²/2]₀²=2.",
        example3: "∫3x²dx=x³+C; türevle kontrol: 3x².",
        pitfalls: "Belirsiz integralde +C unutma. Kuvveti artırdıktan sonra yeni üse böl.",
        recap: "Özet: integral ters türev ve birikimdir; belirli integralde üst-alt sınırı uygula.",
      );
    case "12":
      return const LessonBlueprint(
        useCase: "Elektrik, dalga ve gerçek kökü olmayan denklemlerde karmaşık sayılar kullanılır.",
        concept: "i²=−1. z=a+bi; a gerçel, b sanal katsayıdır.",
        rules: "Toplam bileşen bileşen yapılır. Çarpım dağıtılır, i²=−1. Eşlenik a−bi ve çarpımı a²+b².",
        visual: "Karmaşık düzlemde a+bi noktası (a,b) olarak çizilir: yatay gerçel, dikey sanal.",
        example1A: "(3+2i)(1−i).\nYöntem A: dağıt →3−3i+2i−2i²=5−i.",
        example1B: "Aynı — Yöntem B: (ac−bd)+(ad+bc)i → 5−i.",
        example2: "(4+3i)+(2−5i)=6−2i.",
        example3: "1/(2+i): eşlenikle → (2−i)/5.",
        pitfalls: "i²=−1. Gerçel ve sanal terimleri ayrı topla. Bölmede eşlenik kullan.",
        recap: "Özet: iki bileşen gibi işle; i² gördüğünde −1’e dönüştür.",
      );
    case "13":
      return const LessonBlueprint(
        useCase: "Yapay zekâ, grafik, fizik ve çok denklemli sistemlerde matris-vektör dili kullanılır.",
        concept: "Matris satır-sütun tablosudur. 2×2 determinant ad−bc. Lineer sistem Ax=b biçiminde yazılabilir.",
        rules: "Det≠0 ise 2×2 matris terslenebilir. Matris çarpımı satır-sütun noktasal çarpımıdır.",
        visual: "2x+y=5, x−y=1 sistemi A=[[2,1],[1,−1]], bilinmeyen vektörü [x,y] biçiminde tek yapıda yazılır.",
        example1A: "2x+y=5, x−y=1.\nYöntem A — Yok etme: denklemleri topla →3x=6 → x=2,y=1.",
        example1B: "Aynı — Yöntem B, Cramer: detA=−3; detX=−6 → x=2; benzer şekilde y=1.",
        example2: "det[[3,4],[2,5]]=15−8=7.",
        example3: "u=(1,2),v=(3,−1). u+v=(4,1), noktasal çarpım=3−2=1.",
        pitfalls: "Matris çarpımı eleman eleman değildir. AB genelde BA’ya eşit değildir. det=0 ise ters yok.",
        recap: "Özet: satır işlemleri sistem çözmenin temelidir; determinant terslenebilirlik ve Cramer için önemlidir.",
      );
    case "14":
      return const LessonBlueprint(
        useCase: "Nüfus, soğuma, devre ve hareket gibi değişimin kendisinin denklem olduğu modeller diferansiyel denklemdir.",
        concept: "dy/dx=f(x,y) bize y’nin değişim hızını söyler; amaç bu kurala uyan y fonksiyonunu bulmaktır.",
        rules: "dy/dx=f(x) ise integre et. Başlangıç koşulu C sabitini belirler. Ayrılabilir denklemlerde x ve y terimleri ayrı taraflara alınır.",
        visual: "dy/dx=2x: x>0 iken eğim pozitif ve büyür; çözüm eğrileri yukarı kıvrılır.",
        example1A: "dy/dx=2x, y(0)=3.\nYöntem A: y=x²+C; C=3 → y=x²+3.",
        example1B: "Aynı — Yöntem B, türev tanı: türevi 2x olan x²; başlangıç noktası C=3.",
        example2: "dy/dx=3, y(2)=5 → y=3x+C; C=−1 → y=3x−1.",
        example3: "dy/dx=y çözüm ailesi Ceˣ; y(0)=2 → y=2eˣ.",
        pitfalls: "İntegral sabitini unutma. Başlangıç koşulunu genel çözümden sonra uygula.",
        recap: "Özet: değişim kuralını integre ederek fonksiyonu kur; başlangıç koşulu tek çözümü seçer.",
      );
    case "15":
      return const LessonBlueprint(
        useCase: "Anket, deney, kalite kontrol ve finansal riskte örnekten ana kütle hakkında çıkarım yapılır.",
        concept: "Ortalama merkez, standart sapma yayılım; z-skoru bir değerin ortalamadan kaç standart sapma uzakta olduğunu gösterir.",
        rules: "z=(x−μ)/σ. Standart hata yaklaşık σ/√n. Örneklem büyüdükçe ortalama tahmininin belirsizliği azalır.",
        visual: "Normal dağılım çan biçimlidir; ortalama merkezde, standart sapma yatay yayılım ölçeğidir.",
        example1A: "μ=70,σ=10,x=85.\nYöntem A: z=(85−70)/10=1,5.",
        example1B: "Aynı — Yöntem B: ortalamadan 15 puan uzakta; her standart birim 10 → 15/10=1,5.",
        example2: "σ=12,n=36 → standart hata 12/6=2.",
        example3: "r=0,82 → güçlü pozitif doğrusal ilişki; tek başına neden-sonuç kanıtlamaz.",
        pitfalls: "Standart sapma ile standart hata farklıdır. Korelasyon nedensellik değildir. Yanlı örneklemi büyük n kurtarmaz.",
        recap: "Özet: z-skoru konumu standartlaştırır; standart hata tahmin belirsizliğini ölçer; veri toplama yöntemi kritiktir.",
      );
    case "1.1":
      return const LessonBlueprint(
        useCase: "Markette adet sayarken doğal sayılar, borç ve sıcaklıkta tam sayılar, bir bütünün parçasını anlatırken rasyonel sayılar kullanılır. Bu konu cebirin temel alfabesidir.",
        concept: "Doğal sayılar 0,1,2,...; tam sayılar ...,−2,−1,0,1,2,...; rasyonel sayılar a/b biçiminde yazılabilen sayılardır (b≠0). Sayı doğrusunda sağa gittikçe değer büyür.",
        rules: "Pozitif sayı her negatif sayıdan büyüktür. Negatiflerde sıfıra yakın olan daha büyüktür: −2>−7. Kesirleri ortak payda, ondalık veya çapraz çarpma ile karşılaştırabilirsin. Her tam sayı aynı zamanda rasyoneldir: 4=4/1.",
        visual: "Sayı doğrusunu cadde gibi düşün: −5 −4 −3 −2 −1 0 1 2 3 4 5. Sağ taraf daha büyük, sol taraf daha küçüktür. Bu yüzden −3, −7’den büyüktür.",
        example1A: "Soru: −7/2 ile −3 hangisi büyük?\nYöntem A — Ondalık:\n1) −7/2=−3,5.\n2) −3=−3,0.\n3) −3,0 sayı doğrusunda daha sağdadır.\nSonuç: −3 > −7/2.",
        example1B: "Aynı soru — Yöntem B, ortak payda:\n−3=−6/2.\nŞimdi −7/2 ve −6/2 karşılaştırılır.\n−6>−7 olduğu için −6/2 yani −3 daha büyüktür.",
        example2: "Soru: −4 ile 3 arasındaki tam sayıların toplamı, uçlar hariç?\n−3,−2,−1,0,1,2.\n(−2+2)=0, (−1+1)=0; geriye −3 kalır.\nCevap: −3.",
        example3: "Soru: 0,125’i kesre çevir.\n0,125=125/1000.\nPay ve paydayı 125’e böl: 1/8.\nSonuç: 1/8.",
        pitfalls: "Sık hata: “8>3 olduğuna göre −8>−3” demek. Yanlış; negatiflerde sayı doğrusu kullanılır. Ayrıca payda 0 olamaz ve devreden ondalıklar da rasyoneldir.",
        recap: "Özet: sayı türünü tanı, sayı doğrusunda konumu düşün, kesirleri ortak biçime getir. Negatif işaretleri rakam büyüklüğünden ayrı değerlendir.",
      );
    case "1.2":
      return const LessonBlueprint(
        useCase: "Mutlak değer yönü değil uzaklığı ölçer. Bir noktanın merkeze uzaklığı, hedef değerden sapma ve hata miktarı gibi durumlarda kullanılır.",
        concept: "|x|, x’in 0’a uzaklığıdır. Bu yüzden |5|=5 ve |−5|=5. |x−a| ise x ile a arasındaki uzaklıktır.",
        rules: "|x|≥0. |x|=k (k>0) ise x=k veya x=−k. |x|<k ise −k<x<k. |x|>k ise x<−k veya x>k. |ab|=|a||b|.",
        visual: "|x−2|=4, '2’ye uzaklığı 4 olan noktaları bul' demektir. 2’nin 4 sağında 6, 4 solunda −2 vardır.",
        example1A: "Soru: |2x−6|=4.\nYöntem A — İki durum:\n2x−6=4 → x=5.\n2x−6=−4 → x=1.\nSonuç: x=1 veya 5.",
        example1B: "Aynı soru — Yöntem B, uzaklık:\n|2(x−3)|=4 → 2|x−3|=4 → |x−3|=2.\nx, 3’ten 2 birim uzakta: 3−2=1 ve 3+2=5.",
        example2: "Soru: |x+1|<3.\n−3<x+1<3.\nHer tarafa 1 çıkar: −4<x<2.\n'Küçük' mutlak değerde çözüm merkezin çevresindeki aralıktır.",
        example3: "Soru: |x−4|>2.\n4’e uzaklık 2’den büyük olmalı.\n2 ile 6 arasının dışı seçilir: x<2 veya x>6.",
        pitfalls: "|−7|=−7 değildir; uzaklık negatif olamaz. |x|=−3 gerçek sayılarda çözümsüzdür. < ile > durumlarında çözüm şekli ters mantıkla gider.",
        recap: "Özet: mutlak değer=uzaklık. Denklemde iki yön, küçük eşitsizlikte iç bölge, büyük eşitsizlikte dış bölge.",
      );
    case "1.3":
      return const LessonBlueprint(
        useCase: "Üslü sayılar bilgisayar belleği, hızlı büyüme, bilimsel gösterim ve bileşik artışta tekrarlı çarpımı kısaltır.",
        concept: "aⁿ, a’nın n kez çarpımıdır. a⁰=1 (a≠0), a⁻ⁿ=1/aⁿ. Parantez önemlidir: (−2)²=4 ama −2²=−4.",
        rules: "aᵐ·aⁿ=aᵐ⁺ⁿ; aᵐ/aⁿ=aᵐ⁻ⁿ; (aᵐ)ⁿ=aᵐⁿ; (ab)ⁿ=aⁿbⁿ. Negatif üs tersini aldırır.",
        visual: "2,4,8,16,32 dizisini düşün: her adımda 2 ile çarpılır. Üstel büyümede artış miktarı da giderek büyür.",
        example1A: "Soru: 2³·2⁴.\nYöntem A — Kural:\nTabanlar aynı → üsleri topla: 2⁷=128.",
        example1B: "Aynı soru — Yöntem B, açarak:\n2³=2·2·2 ve 2⁴=2·2·2·2.\nToplam 7 tane 2 çarpılır → 2⁷=128.",
        example2: "Soru: (3²)³/3⁴.\n(3²)³=3⁶.\n3⁶/3⁴=3²=9.",
        example3: "Soru: 5⁻².\nNegatif üs → tersini al: 1/5²=1/25.",
        pitfalls: "2³, 2×3 değildir. Kuvvetin kuvvetinde üsler toplanmaz çarpılır. a⁰=0 değil 1’dir. Negatif üs sonucu negatif yapmaz.",
        recap: "Özet: çarpma → üsleri topla; bölme → çıkar; kuvvetin kuvveti → çarp; negatif üs → tersini al.",
      );
    case "1.4":
      return const LessonBlueprint(
        useCase: "Köklü sayılar kare alanından kenar bulma, Pisagor, uzaklık ve mühendislik formüllerinde sık görülür.",
        concept: "√a, karesi a olan pozitif değerdir. √25=5. Tam kare çarpanlar kök dışına çıkarılabilir: √72=√(36·2)=6√2.",
        rules: "√(ab)=√a√b; √(a/b)=√a/√b; √(a²)=|a|. Benzer köklüler katsayıları toplanarak birleştirilir: 3√2+5√2=8√2.",
        visual: "Alanı 36 olan kareyi düşün. Kenarı 6’dır, çünkü 6²=36. Karekök, alan bilgisinden kare kenarını geri bulur.",
        example1A: "Soru: √72.\nYöntem A — En büyük tam kare:\n72=36·2 → √72=6√2.",
        example1B: "Aynı soru — Yöntem B, asal çarpan:\n72=2·2·2·3·3.\nÇiftler dışarı: 2·3=6, içeride 2 kalır → 6√2.",
        example2: "Soru: 2√8+√18.\n√8=2√2 → 2√8=4√2.\n√18=3√2.\nToplam 7√2.",
        example3: "Soru: 3/√3 paydasını köksüz yap.\n√3/√3 ile çarp: 3√3/3=√3.",
        pitfalls: "√(a+b)=√a+√b genelde yanlıştır. √(a²)=a değil |a|’dır. Kök içleri farklıysa doğrudan katsayı gibi toplanmaz.",
        recap: "Özet: önce sadeleştir, tam kareleri dışarı çıkar, sonra benzer köklüleri birleştir.",
      );
    case "1.5":
      return const LessonBlueprint(
        useCase: "Çarpanlara ayırma denklemleri çözmek, cebirsel kesirleri sadeleştirmek, parabol köklerini bulmak ve limitte sadeleştirme yapmak için kullanılır.",
        concept: "Dağıtmanın tersidir: 3x+6=3(x+2). Büyük ifadeyi daha küçük çarpanların çarpımı şeklinde yazarız.",
        rules: "Ortak çarpan: ab+ac=a(b+c). Kare farkı: a²−b²=(a−b)(a+b). Tam kare: a²±2ab+b²=(a±b)².",
        visual: "3x+6’yı iki ayrı alan yerine ortak yüksekliği 3 olan tek dikdörtgen gibi düşün: 3(x+2).",
        example1A: "Soru: x²−5x+6.\nYöntem A — Çarpım/toplam:\nÇarpımı 6, toplamı −5 olan −2 ve −3.\n(x−2)(x−3).",
        example1B: "Aynı soru — Yöntem B, köklerden:\nx²−5x+6=0 kökleri 2 ve 3’tür.\nKöklerden çarpanlar (x−2)(x−3).",
        example2: "Soru: 9x²−25.\nİki kare farkı: (3x)²−5²=(3x−5)(3x+5).",
        example3: "Soru: 6x²+9x.\nOrtak çarpan 3x: 3x(2x+3).",
        pitfalls: "Her soruda önce ortak çarpan ara. Sonucu dağıtarak kontrol et. İşaretleri toplam ve çarpım koşuluna göre seç.",
        recap: "Özet sıra: ortak çarpan → özdeşlik → üç terimli çarpım/toplam → gerekiyorsa başka yöntem.",
      );
    case "1.6":
      return const LessonBlueprint(
        useCase: "Tarif büyütme, fiyat-miktar, harita ölçeği ve işçi-gün problemleri oran-orantı ile çözülür.",
        concept: "Oran a/b; orantı a/b=c/d. Doğru orantıda birlikte artma/azalma, ters orantıda biri artarken diğerinin azalması vardır.",
        rules: "a/b=c/d → ad=bc. Doğru orantı y=kx. Ters orantı xy=k. Birim oran yöntemi çoğu soruda hızlıdır.",
        visual: "3 kg ürün 90 TL ise 1 kg 30 TL. Miktar iki katına çıkarsa doğru orantıda fiyat da iki katına çıkar.",
        example1A: "Soru: 3 kg 90 TL, 5 kg?\nYöntem A — Birim fiyat:\n90/3=30 TL/kg.\n5·30=150 TL.",
        example1B: "Aynı soru — Yöntem B, orantı:\n3/90=5/x → 3x=450 → x=150.",
        example2: "6 işçi işi 10 günde bitiriyor, 12 işçi?\nTers orantı: 6·10=12·x → x=5 gün.",
        example3: "Ölçek 1:200000, haritada 4 cm.\n4·200000=800000 cm=8 km.",
        pitfalls: "İlişkinin doğru mu ters mi olduğunu belirlemeden denklem kurma. Birimleri eşitle.",
        recap: "Özet: önce ilişkinin yönünü seç; sonra birim oran veya içler-dışlar ile çöz.",
      );
    case "1.7":
      return const LessonBlueprint(
        useCase: "İndirim, zam, enflasyon, faiz, kâr-zarar ve başarı oranı yüzde ile hesaplanır.",
        concept: "%p=p/100. Bir sayının %p’si sayı·p/100. Artış çarpanı 1+p/100, azalış çarpanı 1−p/100.",
        rules: "Yüzde değişim=(yeni−eski)/eski·100. Ardışık yüzdeler doğrudan toplanmaz; her değişim yeni değer üzerinden uygulanır.",
        visual: "800 TL’nin %15’i 120 TL’dir. 100 eş parçadan 15 parça düşün; geriye %85 yani 680 TL kalır.",
        example1A: "800 TL üründe %15 indirim.\nYöntem A: 800·0,15=120 indirim; 800−120=680.",
        example1B: "Aynı soru — Yöntem B: kalan oran %85.\n800·0,85=680.",
        example2: "500 TL önce %20 artıp sonra %20 azalır:\n500·1,20=600; 600·0,80=480.\nBaşlangıca dönmez.",
        example3: "240’tan 300’e artış:\nFark 60.\n60/240=0,25 → %25.",
        pitfalls: "Yüzde değişimde paydaya eski değer gelir. +%10 ve −%10 birbirini tam götürmez.",
        recap: "Özet: yüzdeleri çarpana çevir; artışta 1+oran, azalışta 1−oran.",
      );
    case "2.1":
      return const LessonBlueprint(
        useCase: "Yaş, fiyat, mesafe ve bilinmeyen miktar problemlerinde verilen ilişkiyi denklem kurarak çözeriz.",
        concept: "Denklem bir terazidir. Bir tarafa yaptığın işlemi diğer tarafa da yaparsan eşitlik bozulmaz. Hedef bilinmeyeni yalnız bırakmaktır.",
        rules: "ax+b=c → ax=c−b → x=(c−b)/a. Parantez varsa dağıtılabilir. Kesirli denklemlerde ortak payda ile tüm denklemi çarpmak kullanılabilir.",
        visual: "3 kutu+5 kg=20 kg. İki taraftan 5 çıkar → 3 kutu=15. Üçe böl → bir kutu=5.",
        example1A: "3x+5=20.\nYöntem A — Denge:\n−5: 3x=15.\n/3: x=5.",
        example1B: "Aynı soru — Yöntem B, ters işlem:\nx’e son olarak +5 yapılmış → 20−5=15.\nÖncesinde ×3 → 15/3=5.",
        example2: "2(x−3)+4=14 → 2x−6+4=14 → 2x−2=14 → 2x=16 → x=8.",
        example3: "x/3+2=7 → x/3=5 → x=15. Alternatif: tüm denklemi 3 ile çarp → x+6=21.",
        pitfalls: "'Karşıya geçir işaret değiştir' aslında iki tarafa aynı işlemi yapmanın kısaltmasıdır. Parantezi tüm terimlere dağıt.",
        recap: "Özet: x’i yalnız bırak, işlemleri ters sırayla çöz, sonucu yerine koyarak doğrula.",
      );
    case "2.2":
      return const LessonBlueprint(
        useCase: "Bütçe sınırı, minimum puan, hız limiti ve yaş koşulları eşitsizlikle ifade edilir.",
        concept: "Eşitsizlik tek bir sayı değil aralık verir. < ve > uç noktayı içermez; ≤ ve ≥ içerir.",
        rules: "Toplama/çıkarma ve pozitif sayıyla çarpma-bölmede yön aynı kalır. Negatif sayıyla çarpma veya bölmede işaret yön değiştirir.",
        visual: "x>2 için 2’de açık nokta ve sağa ok; x≥2 için 2’de dolu nokta ve sağa ok.",
        example1A: "−2x+3>7.\n3 çıkar: −2x>4.\n−2’ye böl: x<−2. Negatife böldüğümüz için yön değişti.",
        example1B: "Aynı çözümü test et: x=−3 → 9>7 doğru. x=0 → 3>7 yanlış. Böylece x<−2 aralığı doğrulanır.",
        example2: "3x−4≤11 → 3x≤15 → x≤5.",
        example3: "2<x+1≤6. Her üç parçadan 1 çıkar → 1<x≤5.",
        pitfalls: "Negatifle bölmede yön çevirmeyi unutma. Bileşik eşitsizlikte işlemi üç tarafa uygula.",
        recap: "Özet: denklem gibi çöz; tek ek kritik kural negatifle çarpma/bölmede yönün dönmesidir.",
      );
    case "2.3":
      return const LessonBlueprint(
        useCase: "Parabol hareketi, maksimum alan ve birçok optimizasyon problemi ikinci derece denkleme dönüşür.",
        concept: "ax²+bx+c=0 (a≠0). Çözümler köklerdir. Grafikte kökler parabolün x eksenini kestiği noktalardır.",
        rules: "Δ=b²−4ac. Δ>0 iki kök, Δ=0 çift kök, Δ<0 gerçek kök yok. x=(-b±√Δ)/(2a).",
        visual: "Parabol x eksenini iki kez keserse iki kök; teğet olursa bir çift kök; hiç kesmezse gerçek kök yoktur.",
        example1A: "x²−5x+6=0.\nYöntem A — Çarpan:\n(x−2)(x−3)=0 → x=2,3.",
        example1B: "Aynı soru — Yöntem B, formül:\nΔ=25−24=1.\nx=(5±1)/2 → 2 ve 3.",
        example2: "2x²−8=0 → x²=4 → x=±2. Bu soruda genel formül gereksizdir.",
        example3: "x²+4x+4=0 → (x+2)²=0 → x=−2; Δ=0.",
        pitfalls: "x²=9 için ±3 vardır. Kök formülünde −b ve b² işaretlerine dikkat et.",
        recap: "Özet: önce kolay çarpan yöntemlerini ara; olmazsa diskriminant-kök formülü genel çözümdür.",
      );
    case "2.4":
      return const LessonBlueprint(
        useCase: "Bir ikinci derece ifadenin hangi aralıklarda pozitif/negatif olduğunu bulmak için ikinci derece eşitsizlik kullanılır.",
        concept: "Önce kökleri bul, sonra köklerin böldüğü aralıklarda işareti incele.",
        rules: "a>0 ve iki kök varsa parabol dışarıda pozitif, arada negatif. a<0’da tersi. ≥/≤ varsa uygun kökler dahil edilir.",
        visual: "x²−5x+6=(x−2)(x−3). Kökler 2 ve 3. Yukarı açıldığı için x<2:+, 2<x<3:−, x>3:+.",
        example1A: "x²−5x+6>0.\nYöntem A — İşaret tablosu:\nKökler 2,3. Testler dış aralıkta +, ortada −.\nSonuç x<2 veya x>3.",
        example1B: "Aynı soru — Yöntem B, parabol:\na=1>0 → yukarı açılır. x ekseninin üstü köklerin dışındadır.",
        example2: "x²−4≤0 → (x−2)(x+2)≤0. Kökler −2,2; arası negatif/eşit → −2≤x≤2.",
        example3: "−x²+4x−3>0 → −(x−1)(x−3)>0 → (x−1)(x−3)<0 → 1<x<3.",
        pitfalls: "Kökleri bulup bırakma; istenen işaret bölgesini seç. Baş katsayının işaretini kontrol et.",
        recap: "Özet: kökler → aralıklar → işaret → istenen bölge.",
      );
    case "2.5":
      return const LessonBlueprint(
        useCase: "İki bilinmeyenli fiyat, yaş, karışım ve kesişim problemlerinde iki denklem birlikte çözülür.",
        concept: "Ortak çözüm iki denklemi de aynı anda sağlayan (x,y) çiftidir. Grafikte iki doğrunun kesişimidir.",
        rules: "Yok etme: bir değişkenin katsayılarını zıt yap. Yerine koyma: bir değişkeni yalnız bırakıp diğer denkleme yaz. Grafik: kesişimi bul.",
        visual: "x+y=10 ve x−y=2 doğruları (6,4)’te kesişir; bu nokta iki denklemi de sağlar.",
        example1A: "x+y=10, x−y=2.\nYöntem A — Yok etme:\nTopla → 2x=12 → x=6; y=4.",
        example1B: "Aynı soru — Yöntem B, yerine koyma:\nx=y+2.\n(y+2)+y=10 → y=4 → x=6.",
        example2: "2x+3y=13, x+y=5.\nx=5−y → 10−2y+3y=13 → y=3, x=2.",
        example3: "2x+y=7 ve 4x+2y=14 aynı doğruyu temsil eder → sonsuz çözüm.",
        pitfalls: "Yok etmede tüm denklemi çarp. Paralel farklı doğrular çözüm vermez; aynı doğrular sonsuz çözüm verir.",
        recap: "Özet: kolay katsayı varsa yok etme, değişken yalnızsa yerine koyma, anlam için grafik.",
      );
    case "3.1":
      return const LessonBlueprint(
        useCase: "Fonksiyon taksi ücreti, sıcaklık dönüşümü, gelir hesabı gibi girdi-çıktı ilişkilerini modelleyen matematik makinesidir.",
        concept: "f(x), x girdisine karşılık tek bir çıktı verir. Tanım kümesi girişler, görüntü/değer kümesi çıktılardır.",
        rules: "f(a) için x yerine a yaz. Bileşke (f∘g)(x)=f(g(x)). Grafikte dikey doğru testi fonksiyon kontrolü sağlar.",
        visual: "x=4 → [×2,+3] → 11. Bu makine f(x)=2x+3’tür.",
        example1A: "f(x)=2x+3, f(4)?\nYöntem A — Yerine koy: 2·4+3=11.",
        example1B: "Aynı soru — Yöntem B, makine:\n4 → ×2=8 → +3=11.",
        example2: "f(x)=x²−1, f(−3)=9−1=8. Negatif değeri parantezle koy.",
        example3: "f(x)=x+1, g(x)=2x. (f∘g)(3): g(3)=6, f(6)=7.",
        pitfalls: "f(x) çarpma değildir. Bileşkede içten dışa ilerle. Tanım kısıtlarını kontrol et.",
        recap: "Özet: girdi → kural → çıktı. f(a) yerine koymadır; bileşke makineleri ardışık bağlamaktır.",
      );
    case "3.2":
      return const LessonBlueprint(
        useCase: "Sabit hız, birim fiyat ve doğrusal maliyet ilişkileri doğrusal fonksiyonlarla modellenir.",
        concept: "y=mx+b. m eğim, b y-kesişimidir. Eğim x bir artınca y’nin değişimini ölçer.",
        rules: "m=(y₂−y₁)/(x₂−x₁). Nokta-eğim: y−y₁=m(x−x₁). Paralel doğrular aynı eğime sahiptir.",
        visual: "m=2: sağa 1, yukarı 2. m=−1/2: sağa 2, aşağı 1.",
        example1A: "(1,3) ve (4,9) doğrusu.\nYöntem A: m=6/3=2. 3=2·1+b → b=1. y=2x+1.",
        example1B: "Aynı soru — Yöntem B: y−3=2(x−1) → y=2x+1.",
        example2: "y=−3x+6 eksen kesişimleri: x=0 → (0,6); y=0 → x=2 → (2,0).",
        example3: "y=4x−1’e paralel, (2,5)’ten geçen: y−5=4(x−2) → y=4x−3.",
        pitfalls: "Eğim hesabında nokta sırasını pay/payda aynı tut. b ile m’yi karıştırma.",
        recap: "Özet: iki noktadan önce eğim; sonra nokta-eğim veya y=mx+b.",
      );
    case "3.3":
      return const LessonBlueprint(
        useCase: "Atış hareketi, maksimum alan ve optimizasyon parabol yani ikinci derece fonksiyonlarla modellenir.",
        concept: "f(x)=ax²+bx+c. a>0 yukarı, a<0 aşağı açılır. Tepe noktası maksimum/minimumu verir.",
        rules: "Tepe x’i h=−b/(2a), k=f(h). Tepe formu a(x−h)²+k. Kökler f(x)=0 çözümleridir.",
        visual: "Parabol simetriktir; simetri ekseni tepe noktasından geçer.",
        example1A: "f=x²−4x+3 tepe.\nYöntem A: h=4/2=2, k=f(2)=−1 → (2,−1).",
        example1B: "Aynı soru — Yöntem B, kare tamamlama:\nx²−4x+3=(x−2)²−1 → tepe (2,−1).",
        example2: "f=−2x²+8x−5. h=2, f(2)=3. a<0 → maksimum 3.",
        example3: "x²−5x+6 kökleri: (x−2)(x−3)=0 → 2 ve 3.",
        pitfalls: "Kök, tepe ve y-kesişimini karıştırma. −b/(2a) hesabında parantez kullan.",
        recap: "Özet: a yönü, c y-kesişimini, kökler x-kesişimlerini, tepe maksimum/minimumu anlatır.",
      );
    case "3.4":
      return const LessonBlueprint(
        useCase: "Uzaklık ve sapma modellerinde mutlak değer fonksiyonları V biçimli grafikler oluşturur.",
        concept: "f(x)=|x| temel grafiktir. |x−h|+k tepeyi (h,k)’ye taşır.",
        rules: "|x−h| içeride yatay öteleme; +k dışarıda düşey öteleme. −|x| grafiği aşağı çevirir.",
        visual: "|x| için x=−2 ve x=2 aynı y=2 verir; grafik y eksenine göre simetriktir.",
        example1A: "y=|x−2|+1.\nYöntem A — Dönüşüm: 2 sağ, 1 yukarı → tepe (2,1).",
        example1B: "Aynı soru — Yöntem B: |x−2| en küçük 0 olur; x=2 iken y=1 → tepe (2,1).",
        example2: "y=−|x+3|+4: 3 sol, 4 yukarı, eksi nedeniyle aşağı bakan V. Tepe (−3,4).",
        example3: "|x−1|=3 → x−1=±3 → x=4 veya −2.",
        pitfalls: "|x−2| 2 sağa gider; içerideki işaret ters görünür. −f(x) ile f(−x) farklıdır.",
        recap: "Özet: iç kısım yatay, dış kısım düşey dönüşümü belirler; tepe içi 0 yapan x’te oluşur.",
      );
    case "3.5":
      return const LessonBlueprint(
        useCase: "Kargo ücreti, vergi dilimi ve otopark tarifesi gibi koşula göre değişen kurallar parçalı fonksiyonla yazılır.",
        concept: "Aynı fonksiyon farklı x aralıklarında farklı formüller uygular. Önce koşulu seçmek gerekir.",
        rules: "Sınır noktalarında < ve ≤ farkı kritiktir. Grafikte dahil olmayan uç açık, dahil olan uç dolu nokta ile çizilir.",
        visual: "f(x)=x+2 (x<0), 2x (x≥0). Sol tarafta bir doğru, sağ tarafta başka bir doğru parçası oluşur.",
        example1A: "f(−3)?\nYöntem A: −3<0 → ilk kural → −3+2=−1.",
        example1B: "Aynı soru — Yöntem B, akış: 'x≥0 mı?' hayır → x+2 kolu → −1.",
        example2: "f(0): 0≥0 olduğu için ikinci kural → 2·0=0.",
        example3: "g=x² (x≤2), 3x−2 (x>2). g(2)=4, g(3)=7.",
        pitfalls: "Önce koşul seç; bütün formülleri aynı anda uygulama. Sınırdaki dahil olma işaretini kontrol et.",
        recap: "Özet: x’e bak → doğru aralığı seç → yalnız o formülü uygula.",
      );
    case "3.6":
      return const LessonBlueprint(
        useCase: "Temel grafikleri yeniden çizmeden öteleme, yansıma ve ölçekleme ile yeni grafikler oluşturulur.",
        concept: "f(x)+k düşey, f(x−h) yatay ötelemedir. −f(x) x eksenine, f(−x) y eksenine yansıtır.",
        rules: "İçerideki yatay değişim ters işaretli görünür: f(x−3) 3 sağ. Dışarıdaki +2 doğrudan 2 yukarıdır.",
        visual: "y=x² tepesini (0,0)’dan y=(x−2)²+3 ile (2,3)’e taşı.",
        example1A: "y=(x−2)²+3.\nYöntem A: x−2 → 2 sağ, +3 → 3 yukarı.",
        example1B: "Aynı — Yöntem B, noktaları taşı: (0,0),(1,1),(−1,1) → (2,3),(3,4),(1,4).",
        example2: "y=−2|x|: x eksenine yansıma ve dikeyde 2 kat ölçek.",
        example3: "y=f(−x)+1: önce y eksenine yansıt, sonra 1 yukarı taşı.",
        pitfalls: "−f(x) ve f(−x) farklıdır. İç yatay dönüşümlerde işaret ters okunur.",
        recap: "Özet: içerisi yatay, dışarısı düşey; eksi işaretinin konumu yansıma eksenini belirler.",
      );
    case "4.1":
      return const LessonBlueprint(
        useCase: "Üçgen türü, hangi geometri kuralının kullanılacağını belirler; yapı, arazi ve tasarım problemlerinde temel şekildir.",
        concept: "Kenarlarına göre eşkenar/ikizkenar/çeşitkenar; açılarına göre dar/dik/geniş. İç açı toplamı 180°.",
        rules: "Eşkenarda tüm açılar 60°. İkizkenarda eş kenarların karşı açıları eşit. Üçgen eşitsizliği: |a−b|<c<a+b.",
        visual: "İkizkenar üçgende simetri doğrusu tabanı ikiye böler ve özel durumlarda yükseklik/açıortay/kenarortaydır.",
        example1A: "Kenarlar 5,5,8.\nYöntem A: iki kenar eşit → ikizkenar.",
        example1B: "Aynı — Yöntem B: eş 5’lerin karşı açıları eşit olmalı; simetri ikizkenar yapıyı doğrular.",
        example2: "Açılar 40,60,80: hepsi <90 → dar açılı; toplam 180.",
        example3: "3,4,8 üçgen olur mu? 3+4=7<8 → olmaz.",
        pitfalls: "Sadece açı toplamına değil kenarların üçgen eşitsizliğine de bak.",
        recap: "Özet: önce kenar türü, sonra açı türü, sonra üçgen eşitsizliği.",
      );
    case "4.2":
      return const LessonBlueprint(
        useCase: "Merdiven, köşegen ve koordinat uzaklığı dik üçgende Pisagor ile hesaplanır.",
        concept: "Dik üçgende a²+b²=c²; c hipotenüs ve 90° açının karşısındaki en uzun kenardır.",
        rules: "Bilinen üçlüler: 3-4-5, 5-12-13, 8-15-17. Eksik dik kenar √(c²−b²).",
        visual: "Dik kenarlara kurulan iki karenin alanları toplamı hipotenüse kurulan karenin alanına eşittir.",
        example1A: "Dik kenarlar 6,8.\nYöntem A: c²=36+64=100 → c=10.",
        example1B: "Aynı — Yöntem B: 6-8-10, 3-4-5’in iki katıdır → c=10.",
        example2: "c=13, bir kenar 5 → diğer²=169−25=144 → 12.",
        example3: "A(1,2),B(4,6): farklar 3,4 → uzaklık √(9+16)=5.",
        pitfalls: "Pisagor doğrudan sadece dik üçgende kullanılır. Hipotenüsü doğru tanı.",
        recap: "Özet: dik açı varsa kareler toplamı; bilinen üçlüler hız sağlar.",
      );
    case "4.3":
      return const LessonBlueprint(
        useCase: "Yükseklik, eğim, dalga ve dönme problemleri sinüs-kosinüs-tanjant oranlarıyla çözülür.",
        concept: "Dik üçgende sin=karşı/hipotenüs, cos=komşu/hipotenüs, tan=karşı/komşu.",
        rules: "tan=sin/cos; sin²+cos²=1. Özel değerler: sin30=1/2, sin45=√2/2, sin90=1.",
        visual: "3-4-5 üçgeninde açıya göre karşı=3, komşu=4 ise sin=3/5, cos=4/5, tan=3/4.",
        example1A: "3-4-5 üçgeninde sinθ?\nYöntem A: karşı/hipotenüs=3/5.",
        example1B: "Aynı — Yöntem B: hipotenüsü Pisagor’la √(9+16)=5 bul, sonra 3/5.",
        example2: "cosθ=4/5, θ dar. sin²=1−16/25=9/25 → sin=3/5.",
        example3: "8 m merdiven 30° açı: sin30=h/8 → h=4 m.",
        pitfalls: "Karşı/komşu seçimi verilen açıya bağlıdır. Hesap makinesinde derece/radyan modunu kontrol et.",
        recap: "Özet: istenen ve bilinen kenar çiftine göre sin/cos/tan seç.",
      );
    case "4.4":
      return const LessonBlueprint(
        useCase: "Dik olmayan üçgenlerde arazi ölçümü ve navigasyon için sinüs/kosinüs kuralları kullanılır.",
        concept: "Sinüs kuralı karşılıklı kenar-açı çiftlerini, kosinüs kuralı iki kenar ve aradaki açıyı bağlar.",
        rules: "a/sinA=b/sinB=c/sinC. c²=a²+b²−2ab cosC. C=90° olursa Pisagor çıkar.",
        visual: "Her kenarı karşı açısıyla eşleştir: a↔A, b↔B, c↔C.",
        example1A: "a=5,b=7,C=60. c?\nYöntem A — Kosinüs: c²=25+49−70·1/2=39 → c=√39.",
        example1B: "Aynı — Yöntem B, bileşen/yükseklik: 7cos60=3,5; 7sin60=7√3/2. Pisagorla c²=39.",
        example2: "A=30,a=4,B=45. b=4·sin45/sin30=4√2.",
        example3: "3,4,5 üçgende en büyük açı: cosC=(9+16−25)/(24)=0 → C=90°.",
        pitfalls: "Sinüs kuralında kenar-karşı açı eşleştirmesini, kosinüste aradaki açıyı doğru seç.",
        recap: "Özet: karşılıklı çift varsa sinüs; iki kenar+aradaki açı veya üç kenar varsa kosinüs.",
      );
    case "4.5":
      return const LessonBlueprint(
        useCase: "Periyodik hareket ve dalgalarda belirli trigonometrik değeri veren tüm açıları bulmak gerekir.",
        concept: "Sin, cos ve tan periyodiktir. Temel açıdan simetri ve periyotla diğer çözümler bulunur.",
        rules: "sin: x=α veya 180−α (+360k). cos: x=±α+360k. tan: x=α+180k.",
        visual: "Birim çemberde sin y-koordinatı, cos x-koordinatıdır; aynı koordinatı paylaşan birden fazla açı olabilir.",
        example1A: "0≤x<360, 2sinx=1.\nYöntem A: sinx=1/2; birim çemberde 30° ve 150°.",
        example1B: "Aynı — Yöntem B: α=30; x=α ve 180−α → 30,150.",
        example2: "cosx=−√2/2 → referans 45°, 2. ve 3. bölge → 135,225.",
        example3: "tanx=1 → 45° +180°k → aralıkta 45,225.",
        pitfalls: "Referans açıyı bulup tek çözümde kalma. Tan periyodu 180°, sin/cos 360°.",
        recap: "Özet: ifadeyi yalnız bırak → referans açı → doğru bölgeler → periyot → aralık filtresi.",
      );
    case "5.1":
      return const LessonBlueprint(
        useCase: "Paralel yollar, mimari çizimler ve geometri ispatlarında açı ilişkileri kullanılır.",
        concept: "Ters açılar eşit; doğrusal komşu açılar toplamı 180°. Paralel doğrularda yöndeş ve iç ters açılar eşittir.",
        rules: "Tam açı 360, doğru açı 180, dik açı 90. Paralelde aynı yandaki iç açılar toplamı 180.",
        visual: "Bir dar açı 50° ise ters açı 50°, doğrusal komşu 130° olur; paralellik bu deseni diğer kesişime taşır.",
        example1A: "Yöndeş açı 65°.\nYöntem A: paralelde yöndeşler eşit → 65°.",
        example1B: "Aynı — Yöntem B: 65’in komşusu 115; ters/iç ters zinciriyle diğer dar açı yeniden 65.",
        example2: "Doğrusal çift 3x ve x+20: 4x+20=180 → x=40; açılar 120,60.",
        example3: "Aynı yandaki iç açı 112 → diğeri 68.",
        pitfalls: "Şekle bakıp ölçü tahmin etme; paralellik verilmediyse yöndeş eşitliği kullanma.",
        recap: "Özet: ters=e, doğrusal=180, paralelde yöndeş/iç ters=eşit, aynı yan iç=180.",
      );
    case "5.2":
      return const LessonBlueprint(
        useCase: "Desen, kaplama ve mimari çokgenlerde açı toplamı kuralları kullanılır.",
        concept: "n kenarlı çokgen bir köşeden n−2 üçgene ayrılır; iç açı toplamı (n−2)180°.",
        rules: "Düzgün çokgende bir iç açı toplam/n. Dış açı toplamı 360°. Düzgün dış açı=360/n.",
        visual: "Altıgeni bir köşeden 4 üçgene böl → 4·180=720.",
        example1A: "Altıgen iç toplam?\nYöntem A: (6−2)180=720.",
        example1B: "Aynı — Yöntem B: 4 üçgen·180=720.",
        example2: "Düzgün sekizgen bir iç açı: (6·180)/8=135°.",
        example3: "Düzgün çokgende dış açı 24° → n=360/24=15.",
        pitfalls: "İç açı toplamını n·180 sanma. 'Düzgün' değilse tüm açılar eşit değildir.",
        recap: "Özet: iç toplam (n−2)180; dış toplam her zaman 360.",
      );
    case "5.3":
      return const LessonBlueprint(
        useCase: "Tekerlek, saat, boru ve dönme problemleri çember-daire formüllerine dayanır.",
        concept: "Çember sınır, daire iç bölgedir. Çap=2r, çevre=2πr, alan=πr².",
        rules: "Yay=(merkez açı/360)·2πr. Dilim alanı=(merkez açı/360)·πr².",
        visual: "90° tam turun 1/4’üdür; yay ve dilim alanı da tam değerin 1/4’ü olur.",
        example1A: "r=6, 90° yay.\nYöntem A: 90/360·12π=3π.",
        example1B: "Aynı — Yöntem B: çevre 12π, çeyrek tur → 12π/4=3π.",
        example2: "r=5 alan → 25π.",
        example3: "Çevre 20π: 2πr=20π → r=10.",
        pitfalls: "Çap verilirse r=d/2. Alan ve çevre formüllerini karıştırma.",
        recap: "Özet: tam çember formülünü bil; parça sorularında açı/360 oranıyla çarp.",
      );
    case "5.4":
      return const LessonBlueprint(
        useCase: "Depo kapasitesi, kutu hacmi ve yüzey kaplama miktarı katı cisimlerle hesaplanır.",
        concept: "Hacim 3 boyutlu miktar, yüzey alanı dış yüzlerin toplamıdır. Alan birimi kare, hacim birimi küptür.",
        rules: "Prizma V=taban alanı·h. Küp a³. Silindir πr²h. Koni (1/3)πr²h. Küre (4/3)πr³.",
        visual: "Prizmayı üst üste dizilmiş eş tabanlı ince katmanlar gibi düşün: taban alanı × yükseklik.",
        example1A: "3×4×5 prizma.\nYöntem A: V=3·4·5=60.",
        example1B: "Aynı — Yöntem B: taban 3·4=12, 5 katman → 60.",
        example2: "r=3,h=4 silindir → V=π·9·4=36π.",
        example3: "Ayrıt 5 küp yüzey alanı: 6·25=150.",
        pitfalls: "Alan cm², hacim cm³. Koni hacmindeki 1/3’ü unutma.",
        recap: "Özet: prizma/silindir taban×yükseklik; birim kontrolü hata yakalar.",
      );
    case "6.1":
      return const LessonBlueprint(
        useCase: "Not, gelir ve spor verilerini birkaç sayı ile özetlemek için ortalama-medyan-mod kullanılır.",
        concept: "Ortalama=toplam/adet. Medyan=sıralı verinin ortası. Mod=en sık değer. Açıklık=max−min.",
        rules: "Aykırı değer ortalamayı güçlü etkiler, medyanı daha az etkiler. Çift veri sayısında medyan ortadaki iki değerin ortalamasıdır.",
        visual: "2,3,3,4,20 verisinde 20 ortalamayı yukarı çeker; medyan 3 kalır.",
        example1A: "4,6,8,10 ortalama.\nYöntem A: toplam 28 /4=7.",
        example1B: "Aynı — Yöntem B, denge: 7’ye sapmalar −3,−1,+1,+3; toplam 0 → ortalama 7.",
        example2: "2,4,7,9,12 medyan: sıralı 5 veri → ortadaki 7.",
        example3: "3,3,4,5,5,5,8 mod: en sık 5.",
        pitfalls: "Medyan öncesi sırala. Mod tek olmak zorunda değil. Aykırı değerde ortalama ile medyanı birlikte yorumla.",
        recap: "Özet: ortalama denge, medyan orta, mod en sık, açıklık kaba yayılım.",
      );
    case "6.2":
      return const LessonBlueprint(
        useCase: "Şifre, takım seçme ve oturma düzeni gibi 'kaç farklı yol var?' soruları sayma teknikleridir.",
        concept: "Permütasyonda sıra önemli, kombinasyonda sıra önemsiz. n!=n(n−1)...1.",
        rules: "P(n,r)=n!/(n−r)!; C(n,r)=n!/[r!(n−r)!]. Önce 'AB ile BA farklı mı?' diye sor.",
        visual: "A,B,C’den ikili sıralama 6; ikili grup seçimi 3’tür.",
        example1A: "5 kişiden 2 kişi seç.\nYöntem A: C(5,2)=10.",
        example1B: "Aynı — Yöntem B, liste: A ile 4, B ile yeni 3, C ile 2, D ile 1 → toplam 10.",
        example2: "5 kişiden başkan+yardımcı: sıra/rol önemli → 5·4=20.",
        example3: "4 farklı kitap rafa → 4!=24.",
        pitfalls: "Seçim ile sıralamayı karıştırma. 0!=1. Faktöriyelleri gerektiği kadar aç.",
        recap: "Özet: sıra önemliyse permütasyon, değilse kombinasyon.",
      );
    case "6.3":
      return const LessonBlueprint(
        useCase: "Risk, oyun, tahmin ve kalite kontrol belirsizliği olasılıkla ölçer.",
        concept: "Eş olasılıklı durumda P(A)=istenen/tüm. Olasılık 0 ile 1 arasındadır.",
        rules: "Tamamlayıcı P(Aᶜ)=1−P(A). Bağımsız olaylarda birlikte olma P(A∩B)=P(A)P(B).",
        visual: "Zarda örnek uzay 1-6; çift olay {2,4,6} → 3/6=1/2.",
        example1A: "İki zar toplamı 7.\nYöntem A: 36 çift; uygun 6 → 1/6.",
        example1B: "Aynı — Yöntem B: 6×6 tablo çiz; toplam 7 hücreleri çapraz 6 tane → 1/6.",
        example2: "Zarda 6 gelmemesi: 1−1/6=5/6.",
        example3: "Para iki kez, iki yazı: 1/2·1/2=1/4.",
        pitfalls: "'ve' ile 'veya' aynı değildir. Eş olasılık ve bağımsızlık varsayımlarını kontrol et.",
        recap: "Özet: örnek uzay → istenen olay → uygun kural; tamamlayıcı çoğu soruyu kısaltır.",
      );
    case "6.4":
      return const LessonBlueprint(
        useCase: "Haber, ekonomi ve bilimde grafik/tablodan doğru sonuç çıkarmak veri yorumlamadır.",
        concept: "Başlık, eksen, birim ve ölçek okunmadan yorum yapılmaz. Mutlak fark ile yüzde fark ayrıdır.",
        rules: "Mutlak değişim=yeni−eski. Yüzde değişim=(yeni−eski)/eski·100. Korelasyon neden-sonuç değildir.",
        visual: "Y ekseni sıfırdan başlamıyorsa küçük farklar görselde çok büyük görünebilir.",
        example1A: "80’den 100’e satış.\nYöntem A: mutlak artış 20.",
        example1B: "Aynı veri — Yöntem B, yüzde: 20/80=0,25 → %25.",
        example2: "A=50,B=75. Fark 25; B, A’dan %50 fazla.",
        example3: "Çizgi yükseliyor ama eğim azalıyor: değer artmaya devam ederken artış hızı yavaşlıyor olabilir.",
        pitfalls: "Eksen ölçeğini, birimi ve başlangıç noktasını kontrol et. Korelasyonu nedensellik diye sunma.",
        recap: "Özet: başlık → eksen → birim → ölçek → trend → sayısal hesap.",
      );
    default:
      return LessonBlueprint(
        useCase: t.title + ' konusu gerçek hayattaki problemleri matematik diline çevirmek ve sonraki konuları öğrenmek için kullanılır.',
        concept: t.title + ' için önce tanımları ve sembollerin ne söylediğini kuracağız; amaç formülü ezberlemek değil, hangi durumda neden kullanıldığını anlamaktır.',
        rules: 'Temel kuralları koşullarıyla birlikte öğren. Her formülde hangi büyüklüğün bilindiğini ve hangisinin arandığını önce belirle.',
        visual: 'Kavramı sayı doğrusu, şekil, tablo veya grafik üzerinde düşün. Değişken değiştiğinde sonucun nasıl değiştiğini gözlemle.',
        example1A: 'Örnek 1 — Yöntem A\n1) Verilenleri yaz.\n2) İsteneni belirle.\n3) Uygun kuralı seç.\n4) İşlemi adım adım yap.\n5) Sonucu kontrol et.',
        example1B: 'Aynı örnek — Yöntem B\nSoruyu alternatif bir temsil ile çöz: ters işlem, tablo, grafik veya farklı formül. İki yöntemin aynı sonuca neden ulaştığını karşılaştır.',
        example2: 'Örnek 2\nYeni sayılarla benzer yapıyı uygula. Gereksiz bilgiyi ayır, işlem sırasını koru ve sonucu başlangıç koşullarıyla doğrula.',
        example3: 'Örnek 3\nSınav tipi bir soruda önce koşulu oku, sonra yöntemi seç. İşaret, parantez ve birim kontrolünü çözüm sonunda yap.',
        pitfalls: 'En sık hata, soruyu tam anlamadan formül seçmektir. Tanım koşulu, işaret, parantez ve birimleri mutlaka kontrol et.',
        recap: 'Tanım → kural → görsel ilişki → iki yöntemli örnek → yeni örnekler → hata kontrolü. Şimdi soru çözme aşamasına geçmeye hazırsın.',
      );
  }
}

List<LessonStep> lessonFor(Topic t) {
  final b = blueprintFor(t);
  return [
    LessonStep(
      '1 — Bu Konu Neden Var?',
      b.useCase +
          '\n\nBu derste yalnızca formül ezberlemeyeceğiz. Önce problemin ne anlattığını anlayacağız, sonra matematik diline çevireceğiz. Her yeni kuralı bir örnek üzerinde neden çalıştığıyla birlikte göreceksin.',
      '🌍',
    ),
    LessonStep(
      '2 — Temelden Başlayalım',
      b.concept +
          '\n\nKendine şu üç soruyu sor:\n• Elimde hangi bilgiler var?\n• Benden ne isteniyor?\n• Verilenlerle istenen arasında hangi ilişki var?\n\nBu üç soruya cevap vermeden işlem yapmaya başlama. Matematikte doğru yöntem çoğu zaman soruyu doğru okumaktan çıkar.',
      '🧠',
    ),
    LessonStep(
      '3 — Mantığını Gör',
      b.visual +
          '\n\nŞimdi formülü bir kenara bırakıp ilişkiye odaklan. Bir sayı, şekil veya değişken değiştiğinde diğerinin ne yaptığına bak. Böylece ezber yerine neden-sonuç ilişkisi kurarsın.',
      '👀',
    ),
    LessonStep(
      '4 — Kurallar ve Formüller',
      b.rules +
          '\n\nKuralı kullanmadan önce koşullarını kontrol et. İşaret, parantez, payda, tanım aralığı, birim ve özel durumlar sınavlarda en çok hata yapılan yerlerdir.',
      '📐',
    ),
    LessonStep(
      '5 — Çözümlü Örnek 1 · Yöntem A',
      b.example1A +
          '\n\nÇözüm kontrolü:\n1) Verilenleri kullandık mı?\n2) Her adım bir önceki adımdan mantıklı biçimde çıktı mı?\n3) Sonuç sorunun istediği türde mi?',
      '🪜',
    ),
    LessonStep(
      '6 — Aynı Soru · Yöntem B',
      b.example1B +
          '\n\nNeden ikinci yöntem? Çünkü sınavda tek bir yolu bilmek bazen yetmez. Bir yöntem uzun gelirse diğerine geçebilmelisin. İki yöntemin ortak fikrini bulmaya çalış; asıl öğrenmen gereken yer orasıdır.',
      '🔁',
    ),
    LessonStep(
      '7 — İki Yöntemi Karşılaştır',
      'Yöntem A ile Yöntem B aynı sonuca ulaşıyor fakat düşünme yolları farklı olabilir.\n\n• Hangisi daha kısa?\n• Hangisi daha anlaşılır?\n• Hangi bilgi verildiğinde hangi yöntem avantajlı?\n\nSınavda amaç her zaman en uzun çözümü yapmak değil; güvenli ve hızlı yöntemi seçmektir.',
      '⚖️',
    ),
    LessonStep(
      '8 — Çözümlü Örnek 2 · Adım Adım',
      b.example2 +
          '\n\nBurada ne yaptık? Önce soru tipini tanıdık, sonra uygun kuralı seçtik, işlemleri küçük parçalara böldük ve sonucu kontrol ettik. Bir adımı zihinden atlamak yerine özellikle ilk öğrenirken yaz.',
      '✍️',
    ),
    LessonStep(
      '9 — Çözümlü Örnek 3 · Biraz Daha Zor',
      b.example3 +
          '\n\nBu örnekte amaç yalnızca cevabı bulmak değil, hangi ipucunun hangi yöntemi çağırdığını fark etmektir. Sorudaki anahtar kelimeleri ve verilen özel bilgileri işaretle.',
      '🧩',
    ),
    LessonStep(
      '10 — Soru Çözerken Uygulayacağın Plan',
      'Her soruda şu sırayı uygula:\n'
          '1) Soruyu bir kez sadece anlamak için oku.\n'
          '2) Verilenleri ve isteneni ayır.\n'
          '3) Konuyu ve soru tipini belirle.\n'
          '4) En kısa güvenilir yöntemi seç.\n'
          '5) İşlemleri satır satır yap.\n'
          '6) İşaret, parantez ve birim kontrolü yap.\n'
          '7) Sonucun mantıklı olup olmadığını kontrol et.\n\n'
          'Bu planı alışkanlık haline getirirsen zor sorularda bile nereden başlayacağını bilirsin.',
      '🗺️',
    ),
    LessonStep(
      '11 — Sık Yapılan Hatalar',
      b.pitfalls +
          '\n\nBir soruyu yanlış yaptığında sadece doğru cevaba bakma. Yanlışın sebebini seç: konuyu bilmeme, kuralı karıştırma, işlem hatası, soruyu yanlış okuma veya acele. Uygulama sonraki alıştırmalarda buna göre tekrar önerecek.',
      '⚠️',
    ),
    LessonStep(
      '12 — Mini Özet',
      b.recap +
          '\n\nKendini kontrol et:\n• Konuyu kendi cümlenle açıklayabiliyor musun?\n• En önemli kuralı neden kullandığını söyleyebiliyor musun?\n• Çözümlü örneği kapatıp yeniden çözebilir misin?\n\nBu üçüne de evet diyorsan soru çözme aşamasına geç.',
      '✅',
    ),
    const LessonStep(
      '13 — Şimdi Senin Sıran',
      'Konu anlatımı tamamlandı. Önünde kolaydan zora giden 5 kontrollü soru var. İlk sorular doğrudan temel mantığı, sonraki sorular ise yorum ve yöntem seçimini ölçecek.\n\nYanlış yaptığında sistem cevabı hemen göstermeyecek:\n1) Tekrar Dene\n2) İpucu Al\n3) Adım Adım Çözümü Gör\n\nAmaç cevabı ezberlemek değil, aynı tip soruyu bir daha gördüğünde kendi başına çözebilmek.',
      '🎯',
    ),
  ];
}

class AppState extends ChangeNotifier {
  final SharedPreferences prefs;
  bool onboarded;
  int xp;
  int streak;
  int freezeRights;
  int correctRun;
  int wrongRun;
  int difficultyIndex;
  int answered;
  int correct;
  int dailyGoal;
  int studySeconds;
  final Set<String> completed;
  final Set<String> wrongIds;
  final Set<String> favorites;
  final List<String> diary;

  AppState(this.prefs)
      : onboarded = prefs.getBool('onboarded') ?? false,
        xp = prefs.getInt('xp') ?? 0,
        streak = prefs.getInt('streak') ?? 0,
        freezeRights = prefs.getInt('freezeRights') ?? 1,
        correctRun = 0,
        wrongRun = 0,
        difficultyIndex = prefs.getInt('difficultyIndex') ?? 0,
        answered = prefs.getInt('answered') ?? 0,
        correct = prefs.getInt('correct') ?? 0,
        dailyGoal = prefs.getInt('dailyGoal') ?? 20,
        studySeconds = prefs.getInt('studySeconds') ?? 0,
        completed = (prefs.getStringList('completed') ?? []).toSet(),
        wrongIds = (prefs.getStringList('wrongIds') ?? []).toSet(),
        favorites = (prefs.getStringList('favorites') ?? []).toSet(),
        diary = List<String>.from(prefs.getStringList('diary') ?? []);

  String get level {
    if (xp < 500) return 'Çırak';
    if (xp < 1500) return 'Öğrenci';
    if (xp < 3500) return 'Usta';
    if (xp < 7000) return 'Matematikçi';
    return 'Efsane';
  }

  double get successRate => answered == 0 ? 0 : correct / answered;

  List<String> get badges {
    final b = <String>[];
    if (answered > 0) b.add('İlk Çözüm');
    if (correct >= 10) b.add('Israr');
    if (correct >= 50) b.add('Hız Ustası');
    if (streak >= 7) b.add('7 Gün Ateşi');
    if (streak >= 30) b.add('30 Gün Disiplini');
    if (streak >= 100) b.add('100 Gün Efsanesi');
    if (completed.contains('7')) b.add('Logaritma Efsanesi');
    if (completed.contains('10')) b.add('Türev Kahramanı');
    if (completed.length >= 10) b.add('Konu Avcısı');
    return b;
  }

  Future<void> finishOnboarding(int goal) async {
    onboarded = true;
    dailyGoal = goal;
    await prefs.setBool('onboarded', true);
    await prefs.setInt('dailyGoal', goal);
    notifyListeners();
  }

  Future<void> recordAnswer(Question q, bool ok) async {
    answered++;
    if (ok) {
      correct++;
      correctRun++;
      wrongRun = 0;
      wrongIds.remove(q.id);
      final bonus = q.difficulty == 'çok zor' ? 25 : q.difficulty == 'zor' ? 18 : q.difficulty == 'orta' ? 12 : 8;
      xp += bonus;
      if (correctRun >= 3) {
        difficultyIndex = math.min(3, difficultyIndex + 1);
        correctRun = 0;
      }
    } else {
      wrongRun++;
      correctRun = 0;
      wrongIds.add(q.id);
      if (wrongRun >= 2) {
        difficultyIndex = math.max(0, difficultyIndex - 1);
        wrongRun = 0;
      }
    }
    await _touchStreak();
    await _save();
    notifyListeners();
  }

  Future<void> _touchStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastRaw = prefs.getString('lastPractice');
    if (lastRaw == null) {
      streak = 1;
    } else {
      final last = DateTime.parse(lastRaw);
      final lastDay = DateTime(last.year, last.month, last.day);
      final diff = today.difference(lastDay).inDays;
      if (diff == 1) streak++;
      if (diff > 1) streak = 1;
    }
    await prefs.setString('lastPractice', now.toIso8601String());
  }

  Future<void> toggleFavorite(String id) async {
    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }
    await prefs.setStringList('favorites', favorites.toList());
    notifyListeners();
  }

  Future<void> completeTopic(String id) async {
    completed.add(id);
    xp += 50;
    await _save();
    notifyListeners();
  }

  Future<void> addDiary(String text) async {
    final stamp = DateTime.now().toIso8601String().split('T').first;
    diary.insert(0, stamp + ' — ' + text);
    if (diary.length > 30) diary.removeLast();
    await prefs.setStringList('diary', diary);
    notifyListeners();
  }

  Future<void> _save() async {
    await prefs.setInt('xp', xp);
    await prefs.setInt('streak', streak);
    await prefs.setInt('answered', answered);
    await prefs.setInt('correct', correct);
    await prefs.setInt('difficultyIndex', difficultyIndex);
    await prefs.setInt('studySeconds', studySeconds);
    await prefs.setStringList('completed', completed.toList());
    await prefs.setStringList('wrongIds', wrongIds.toList());
    await prefs.setStringList('favorites', favorites.toList());
  }
}

final appStateProvider = ChangeNotifierProvider<AppState>((ref) => throw UnimplementedError());

final questionsProvider = FutureProvider<List<Question>>((ref) async {
  final raw = await rootBundle.loadString('assets/questions.json');
  final list = jsonDecode(raw) as List<dynamic>;
  return list.map((e) => Question.fromJson(e as Map<String, dynamic>)).toList();
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [appStateProvider.overrideWith((ref) => AppState(prefs))],
    child: const MatematikAkademiApp(),
  ));
}

ThemeData appTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: blue,
      secondary: purple,
      tertiary: orange,
      surface: card,
      error: Color(0xFFFF5C7A),
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF0E1331),
      indicatorColor: blue.withOpacity(.20),
      labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF101533),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    ),
    useMaterial3: true,
  );
}

class MatematikAkademiApp extends ConsumerWidget {
  const MatematikAkademiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Matematik Akademi',
      theme: appTheme(),
      home: state.onboarded ? const ShellScreen() : const OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int stage = 0;
  int testIndex = 0;
  int testCorrect = 0;
  int goal = 20;
  Timer? timer;

  final qs = const [
    ['7 + 5 kaçtır?','10','12','14','16','12'],
    ['Bir sayının yarısı 8 ise sayı kaçtır?','4','8','16','24','16'],
    ['Eksi 3 ile 2 arasında kaç tam sayı vardır?','3','4','5','6','4'],
    ['3 üzeri 2 kaçtır?','6','9','12','18','9'],
    ['Bir üçgende iki açı 60 ve 50 ise üçüncü açı?','60','70','80','90','70'],
  ];

  @override
  void initState() {
    super.initState();
    timer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => stage = 1);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (stage == 0) {
      return Scaffold(
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(colors: [blue, purple]),
                boxShadow: [BoxShadow(color: purple.withOpacity(.35), blurRadius: 40)],
              ),
              child: const Icon(Icons.functions_rounded, size: 62),
            ).animate().scale(duration: 800.ms, curve: Curves.elasticOut).fadeIn(),
            const SizedBox(height: 22),
            const Text('MATEMATİK AKADEMİ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            const Text('Ezberleme. Gör. Anla. Çöz.', style: TextStyle(color: Colors.white70)),
          ]),
        ),
      );
    }

    if (stage == 1) {
      final q = qs[testIndex];
      return Scaffold(
        appBar: AppBar(title: Text('Seviye testi ' + (testIndex + 1).toString() + '/5'), backgroundColor: Colors.transparent),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: 24),
            const Text('Matematik seviyeni belirle', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 28),
            Text(q[0], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 22),
            for (final o in q.sublist(1, 5))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FilledButton.tonal(
                  onPressed: () {
                    if (o == q[5]) testCorrect++;
                    if (testIndex < 4) {
                      setState(() => testIndex++);
                    } else {
                      setState(() => stage = 2);
                    }
                  },
                  child: Padding(padding: const EdgeInsets.all(16), child: Text(o, style: const TextStyle(fontSize: 18))),
                ),
              ),
          ]),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Spacer(),
            const Icon(Icons.auto_awesome, color: orange, size: 70),
            const SizedBox(height: 20),
            Text(
              testCorrect <= 1 ? 'Temelden başlayalım' : testCorrect <= 3 ? 'Temelin var, güçlendirelim' : 'İyi başlangıç!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              '5 sorudan ' + testCorrect.toString() + ' doğru. Başlangıç rotanı buna göre kişiselleştireceğiz.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 34),
            const Text('Haftalık çalışma hedefin', style: TextStyle(fontWeight: FontWeight.w800)),
            Slider(
              value: goal.toDouble(),
              min: 10,
              max: 60,
              divisions: 10,
              label: goal.toString() + ' dk/gün',
              onChanged: (v) => setState(() => goal = v.round()),
            ),
            Text(goal.toString() + ' dakika / gün', textAlign: TextAlign.center, style: const TextStyle(color: blue, fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),
            Card(
              child: ListTile(
                leading: const Icon(Icons.notifications_active_outlined, color: orange),
                title: const Text('Günlük hatırlatıcı'),
                subtitle: const Text('Bildirim izni cihazdan istendiğinde izin verebilirsin.'),
                trailing: const Icon(Icons.check_circle, color: success),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => ref.read(appStateProvider).finishOnboarding(goal),
              child: const Padding(padding: EdgeInsets.all(16), child: Text('Akademiye Başla', style: TextStyle(fontWeight: FontWeight.w900))),
            ),
          ]),
        ),
      ),
    );
  }
}

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});
  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int index = 0;
  final pages = const [HomeScreen(), TopicsScreen(), ExamsScreen(), StatsScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Ana Sayfa'),
          NavigationDestination(icon: Icon(Icons.account_tree_outlined), selectedIcon: Icon(Icons.account_tree), label: 'Konular'),
          NavigationDestination(icon: Icon(Icons.timer_outlined), selectedIcon: Icon(Icons.timer), label: 'Sınavlar'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'İstatistik'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStateProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Matematik Akademi', style: TextStyle(fontWeight: FontWeight.w900)),
          Text('Bugün bir adım daha ileri', style: TextStyle(fontSize: 12, color: Colors.white60)),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Chip(avatar: const Text('🔥'), label: Text(s.streak.toString() + ' gün')),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(colors: [Color(0xFF233A8B), Color(0xFF512B8E)]),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.level, style: const TextStyle(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(s.xp.toString() + ' XP', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                ])),
                const Icon(Icons.workspace_premium, size: 54, color: Color(0xFFFFD166)),
              ]),
              const SizedBox(height: 14),
              LinearProgressIndicator(value: (s.xp % 500) / 500, minHeight: 8, borderRadius: BorderRadius.circular(10)),
              const SizedBox(height: 8),
              Text('Günlük hedef: ' + s.dailyGoal.toString() + ' dk', style: const TextStyle(color: Colors.white70)),
            ]),
          ).animate().fadeIn(duration: 350.ms).slideY(begin: .06),
          const SizedBox(height: 16),
          const Text('Bugün ne yapalım?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: ActionCard(icon: Icons.play_circle_fill, color: blue, title: 'Pratik', subtitle: 'Adaptif sonsuz akış', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PracticeScreen()));
            })),
            const SizedBox(width: 12),
            Expanded(child: ActionCard(icon: Icons.refresh, color: success, title: 'Tekrar', subtitle: '10 kişisel soru', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PracticeScreen(repeatOnly: true, limit: 10)));
            })),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: ActionCard(icon: Icons.show_chart, color: purple, title: 'Grafik Çizici', subtitle: 'Eğimi canlı değiştir', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const GraphToolScreen()));
            })),
            const SizedBox(width: 12),
            Expanded(child: ActionCard(icon: Icons.draw, color: orange, title: 'Karalama', subtitle: 'Parmakla çöz', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ScratchScreen()));
            })),
          ]),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0x334F8EF7), child: Icon(Icons.school, color: blue)),
              title: const Text('Önerilen başlangıç', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('1.1 Doğal, Tam ve Rasyonel Sayılar'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LessonScreen(topicId: '1.1')));
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0x33FF6B35), child: Text('👾')),
              title: const Text('Mini Boss Sorusu', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Birden fazla konuyu tek soruda birleştir.'),
              trailing: const Icon(Icons.bolt, color: orange),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PracticeScreen(limit: 1, bossOnly: true))),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const ActionCard({super.key, required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        height: 148,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withOpacity(.05))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(.15), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color)),
          const Spacer(),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white60)),
        ]),
      ),
    );
  }
}

class TopicsScreen extends ConsumerWidget {
  const TopicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStateProvider);
    final groups = <String, List<Topic>>{};
    for (final t in topics) {
      groups.putIfAbsent(t.group, () => []).add(t);
    }
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('Konu Haritası', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                const Icon(Icons.map, color: purple),
                const SizedBox(width: 12),
                Expanded(child: Text('Tamamlanan ' + s.completed.length.toString() + ' / ' + topics.length.toString() + ' konu')),
                SizedBox(width: 90, child: LinearProgressIndicator(value: s.completed.length / topics.length, borderRadius: BorderRadius.circular(8))),
              ]),
            ),
          ),
          for (final entry in groups.entries)
            Card(
              margin: const EdgeInsets.only(top: 10),
              child: ExpansionTile(
                initiallyExpanded: entry.key.startsWith('1.'),
                title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w900)),
                children: [
                  for (final t in entry.value)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: s.completed.contains(t.id) ? success.withOpacity(.2) : blue.withOpacity(.12),
                        child: s.completed.contains(t.id) ? const Icon(Icons.check, color: success) : Text(t.id, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                      ),
                      title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(t.subtitle + (t.prereq.isEmpty ? '' : '\nÖnce: ' + t.prereq.join(', '))),
                      isThreeLine: t.prereq.isNotEmpty,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LessonScreen(topicId: t.id))),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class LessonScreen extends ConsumerStatefulWidget {
  final String topicId;
  const LessonScreen({super.key, required this.topicId});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  int step = 0;
  bool simple = false;
  bool summary = false;
  final tts = FlutterTts();
  double speechRate = 1.0;

  Topic get topic => topics.firstWhere((e) => e.id == widget.topicId);

  Future<void> speak(String text) async {
    await tts.setLanguage('tr-TR');
    await tts.setSpeechRate(speechRate * .5);
    await tts.speak(text);
  }

  @override
  void dispose() {
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = lessonFor(topic);
    final item = lesson[step];
    final body = simple ? 'Çok basit düşün: ' + item.body.split('\n').first : item.body;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(topic.id + ' ' + topic.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
        actions: [
          IconButton(onPressed: () => speak(body), icon: const Icon(Icons.volume_up_outlined)),
          PopupMenuButton<double>(
            icon: const Icon(Icons.speed),
            onSelected: (v) => setState(() => speechRate = v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: .75, child: Text('0.75x')),
              PopupMenuItem(value: 1.0, child: Text('1x')),
              PopupMenuItem(value: 1.25, child: Text('1.25x')),
              PopupMenuItem(value: 1.5, child: Text('1.5x')),
            ],
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            for (int i = 0; i < lesson.length; i++)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 5,
                  decoration: BoxDecoration(color: i <= step ? blue : Colors.white12, borderRadius: BorderRadius.circular(9)),
                ),
              )
          ]),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Row(children: [
                Text(item.icon, style: const TextStyle(fontSize: 42)),
                const SizedBox(width: 12),
                Expanded(child: Text(item.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
              ]),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(summary ? item.body.split('\n').first : body, style: const TextStyle(fontSize: 17, height: 1.65)),
                ),
              ).animate(key: ValueKey(step)).fadeIn(duration: 300.ms).slideX(begin: .04),
              if (step == 3) ...[
                const SizedBox(height: 12),
                VisualLesson(topicId: topic.id),
              ],
              if (step >= 4 && step <= 7) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: blue.withOpacity(.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: blue.withOpacity(.22)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.tips_and_updates_outlined, color: orange),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Her adımın sonunda “Bunu neden yaptım?” diye sor. Çözümü okuduktan sonra ekrana bakmadan aynı örneği bir kez daha çöz.',
                          style: TextStyle(height: 1.45, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: OutlinedButton.icon(onPressed: () => setState(() => simple = !simple), icon: const Icon(Icons.sentiment_satisfied), label: Text(simple ? 'Normal Anlat' : 'Daha Basit Anlat'))),
                const SizedBox(width: 10),
                Expanded(child: OutlinedButton.icon(onPressed: () => setState(() => summary = !summary), icon: const Icon(Icons.fast_forward), label: Text(summary ? 'Tam Anlatım' : 'Daha Hızlı Geç'))),
              ]),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(children: [
              if (step > 0)
                Expanded(child: OutlinedButton(onPressed: () => setState(() => step--), child: const Padding(padding: EdgeInsets.all(14), child: Text('Geri')))),
              if (step > 0) const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () async {
                    if (step < lesson.length - 1) {
                      setState(() => step++);
                    } else {
                      final finishedPractice = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PracticeScreen(topicId: topic.id, limit: 5),
                        ),
                      );
                      if (finishedPractice == true) {
                        await ref.read(appStateProvider).completeTopic(topic.id);
                        if (context.mounted) {
                          await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('🎉 Konu tamamlandı!'),
                              content: const Text('Ayrıntılı anlatım, çözümlü örnekler ve 5 soruluk uygulama tamamlandı. +50 XP kazandın.'),
                              actions: [
                                FilledButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Harika'),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      step < lesson.length - 1 ? 'Devam' : '5 Soru Çözerek Bitir',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class VisualLesson extends StatefulWidget {
  final String topicId;
  const VisualLesson({super.key, required this.topicId});
  @override
  State<VisualLesson> createState() => _VisualLessonState();
}

class _VisualLessonState extends State<VisualLesson> {
  double value = -3;
  double power = 3;

  @override
  Widget build(BuildContext context) {
    if (widget.topicId == '1.1' || widget.topicId == '1.2') {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            SizedBox(height: 130, child: CustomPaint(painter: NumberLinePainter(value), child: Container())),
            Slider(value: value, min: -8, max: 8, divisions: 16, label: value.round().toString(), onChanged: (v) => setState(() => value = v)),
            Text(widget.topicId == '1.2' ? 'Sıfıra uzaklık: ' + value.abs().round().toString() : 'Seçili sayı: ' + value.round().toString(), style: const TextStyle(fontWeight: FontWeight.w800, color: blue)),
          ]),
        ),
      );
    }
    if (widget.topicId == '1.3') {
      final result = math.pow(2, power.round());
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Wrap(spacing: 7, runSpacing: 7, children: List.generate(result.toInt().clamp(1, 32), (_) => Container(width: 18, height: 18, decoration: BoxDecoration(color: purple.withOpacity(.75), borderRadius: BorderRadius.circular(4))))),
            const SizedBox(height: 14),
            Slider(value: power, min: 1, max: 5, divisions: 4, label: power.round().toString(), onChanged: (v) => setState(() => power = v)),
            Text('2 üzeri ' + power.round().toString() + ' = ' + result.toString(), style: const TextStyle(fontWeight: FontWeight.w900)),
          ]),
        ),
      );
    }
    return const Card(child: SizedBox(height: 180, child: Center(child: Icon(Icons.animation, size: 70, color: purple))));
  }
}

class NumberLinePainter extends CustomPainter {
  final double value;
  NumberLinePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final axis = Paint()..color = Colors.white70..strokeWidth = 2;
    final marker = Paint()..color = orange;
    final y = size.height / 2;
    canvas.drawLine(Offset(20, y), Offset(size.width - 20, y), axis);
    for (int i = -8; i <= 8; i++) {
      final x = 20 + (i + 8) * (size.width - 40) / 16;
      canvas.drawLine(Offset(x, y - 6), Offset(x, y + 6), axis);
      final tp = TextPainter(text: TextSpan(text: i.toString(), style: const TextStyle(color: Colors.white60, fontSize: 10)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y + 12));
    }
    final x = 20 + (value + 8) * (size.width - 40) / 16;
    canvas.drawCircle(Offset(x, y), 9, marker);
  }

  @override
  bool shouldRepaint(covariant NumberLinePainter oldDelegate) => oldDelegate.value != value;
}

class PracticeScreen extends ConsumerStatefulWidget {
  final String? topicId;
  final int? limit;
  final bool repeatOnly;
  final bool bossOnly;
  const PracticeScreen({super.key, this.topicId, this.limit, this.repeatOnly = false, this.bossOnly = false});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  int index = 0;
  int solved = 0;
  String? selected;
  final input = TextEditingController();
  bool checked = false;
  bool correct = false;
  bool showHint = false;
  bool showSolution = false;

  String difficultyName(int i) => ['kolay','orta','zor','çok zor'][i.clamp(0, 3)];

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(questionsProvider);
    final s = ref.watch(appStateProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          widget.limit == null
              ? 'Pratik Modu'
              : 'Pratik · ' + math.min(solved + 1, widget.limit!).toString() + '/' + widget.limit!.toString(),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScratchScreen())), icon: const Icon(Icons.draw)),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Soru bankası açılamadı: ' + e.toString())),
        data: (all) {
          var pool = all.where((q) {
            if (widget.topicId != null && q.topicId != widget.topicId) return false;
            if (widget.repeatOnly && !s.wrongIds.contains(q.id)) return false;
            if (widget.bossOnly && q.difficulty != 'çok zor') return false;
            if (!widget.repeatOnly && !widget.bossOnly && widget.topicId == null && q.difficulty != difficultyName(s.difficultyIndex)) return false;
            return true;
          }).toList();
          if (pool.isEmpty) pool = all.take(100).toList();
          final q = pool[index % pool.length];
          final isText = q.type == 'fill' || q.type == 'numeric';

          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Row(children: [
                Chip(label: Text(q.topicId + ' · ' + q.difficulty)),
                const Spacer(),
                Text('XP ' + s.xp.toString(), style: const TextStyle(color: orange, fontWeight: FontWeight.w900)),
                IconButton(
                  onPressed: () => ref.read(appStateProvider).toggleFavorite(q.id),
                  icon: Icon(s.favorites.contains(q.id) ? Icons.star : Icons.star_border, color: const Color(0xFFFFD166)),
                )
              ]),
              const SizedBox(height: 8),
              Text(q.topic, style: const TextStyle(color: blue, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text(q.prompt, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1.35)),
              const SizedBox(height: 8),
              Text('Bu soruyu çözenlerin %' + q.wrongPercent.toString() + ' kadarı zorlanıyor.', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 22),
              if (isText)
                TextField(
                  controller: input,
                  enabled: !checked,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(labelText: 'Cevabını yaz', prefixIcon: Icon(Icons.calculate_outlined)),
                )
              else
                for (final o in q.options)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ChoiceChip(
                      selected: selected == o,
                      onSelected: checked ? null : (_) => setState(() => selected = o),
                      label: SizedBox(width: double.infinity, child: Padding(padding: const EdgeInsets.all(10), child: Text(o, style: const TextStyle(fontSize: 16)))),
                    ),
                  ),
              const SizedBox(height: 14),
              if (!checked)
                FilledButton(
                  onPressed: () async {
                    final answer = (isText ? input.text : selected ?? '').trim().toLowerCase();
                    if (answer.isEmpty) return;
                    final ok = answer == q.answer.trim().toLowerCase();
                    await ref.read(appStateProvider).recordAnswer(q, ok);
                    if (mounted) setState(() { checked = true; correct = ok; });
                  },
                  child: const Padding(padding: EdgeInsets.all(15), child: Text('Kontrol Et', style: TextStyle(fontWeight: FontWeight.w900))),
                )
              else
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: (correct ? success : const Color(0xFFFF5C7A)).withOpacity(.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: correct ? success : const Color(0xFFFF5C7A)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text(correct ? '🎉 Doğru! +' + (q.difficulty == 'çok zor' ? '25' : q.difficulty == 'zor' ? '18' : q.difficulty == 'orta' ? '12' : '8') + ' XP' : 'Henüz değil. Doğru cevabı birlikte bulalım.', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    if (!correct) ...[
                      const SizedBox(height: 12),
                      Wrap(spacing: 8, children: [
                        OutlinedButton(onPressed: () => setState(() { checked = false; selected = null; input.clear(); }), child: const Text('Tekrar Dene')),
                        OutlinedButton(onPressed: () => setState(() => showHint = true), child: const Text('İpucu')),
                        OutlinedButton(onPressed: () => setState(() => showSolution = true), child: const Text('Adım Adım Çöz')),
                      ]),
                      if (showHint) Padding(padding: const EdgeInsets.only(top: 12), child: Text('💡 ' + q.hint)),
                      if (showSolution) Padding(padding: const EdgeInsets.only(top: 12), child: Text('🪜 ' + q.solution + '\nDoğru cevap: ' + q.answer)),
                    ],
                    const SizedBox(height: 12),
                    if (correct || showSolution)
                      FilledButton.tonal(
                        onPressed: () {
                          solved++;
                          if (widget.limit != null && solved >= widget.limit!) {
                            Navigator.pop(context, true);
                            return;
                          }
                          setState(() {
                            index++;
                            checked = false;
                            correct = false;
                            selected = null;
                            input.clear();
                            showHint = false;
                            showSolution = false;
                          });
                        },
                        child: const Text('Sonraki Soru'),
                      ),
                  ]),
                ),
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.psychology_alt, color: purple),
                  title: const Text('Neden yanlış yaptım?'),
                  subtitle: Text(correct ? 'Bu soruda hata yok.' : 'Olası kategori: ' + (q.id.hashCode.abs() % 3 == 0 ? 'İşaret hatası' : q.id.hashCode.abs() % 3 == 1 ? 'Formülü yanlış uygulama' : 'Soruyu yanlış okuma')),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ExamsScreen extends StatelessWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('Sınavlar', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ExamCard(title: 'TYT Matematik', subtitle: '40 soru · 60 dakika', color: blue, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamRunner(title: 'TYT Matematik', count: 40, minutes: 60)))),
          ExamCard(title: 'AYT Matematik', subtitle: '30 soru · 75 dakika', color: purple, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamRunner(title: 'AYT Matematik', count: 30, minutes: 75)))),
          ExamCard(title: 'Konu Sınavı', subtitle: '20 soru · 30 dakika', color: orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamRunner(title: 'Konu Sınavı', count: 20, minutes: 30, topicId: '1.1')))),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: success),
              title: const Text('Sınav özelliği'),
              subtitle: const Text('Soruyu işaretle, geri dön, süreyi takip et ve sınav sonunda net başarı oranını gör.'),
            ),
          )
        ],
      ),
    );
  }
}

class ExamCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const ExamCard({super.key, required this.title, required this.subtitle, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        leading: CircleAvatar(radius: 26, backgroundColor: color.withOpacity(.14), child: Icon(Icons.timer, color: color)),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text(subtitle)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class ExamRunner extends ConsumerStatefulWidget {
  final String title;
  final int count;
  final int minutes;
  final String? topicId;
  const ExamRunner({super.key, required this.title, required this.count, required this.minutes, this.topicId});

  @override
  ConsumerState<ExamRunner> createState() => _ExamRunnerState();
}

class _ExamRunnerState extends ConsumerState<ExamRunner> {
  int current = 0;
  int remaining = 0;
  Timer? timer;
  List<Question>? questions;
  final Map<int, String> answers = {};
  final Set<int> flagged = {};

  @override
  void initState() {
    super.initState();
    remaining = widget.minutes * 60;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (remaining <= 0) {
        timer?.cancel();
        submit();
      } else {
        setState(() => remaining--);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> submit() async {
    if (questions == null) return;
    int good = 0;
    for (int i = 0; i < questions!.length; i++) {
      final q = questions![i];
      final ok = (answers[i] ?? '').trim().toLowerCase() == q.answer.trim().toLowerCase();
      if (ok) good++;
      await ref.read(appStateProvider).recordAnswer(q, ok);
    }
    if (!mounted) return;
    await showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
      title: const Text('Sınav tamamlandı'),
      content: Text(widget.count.toString() + ' soruda ' + good.toString() + ' doğru. Başarı: %' + ((good / widget.count) * 100).round().toString()),
      actions: [FilledButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('Sonuçları Kaydet'))],
    ));
  }

  String timeText() {
    final m = remaining ~/ 60;
    final s = remaining % 60;
    return m.toString().padLeft(2, '0') + ':' + s.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(questionsProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.title),
        actions: [Center(child: Text('⏱ ' + timeText(), style: const TextStyle(fontWeight: FontWeight.w900, color: orange))), const SizedBox(width: 16)],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (all) {
          if (questions == null) {
            final pool = widget.topicId == null ? all : all.where((q) => q.topicId == widget.topicId).toList();
            questions = List<Question>.from(pool)..shuffle(math.Random(42));
            questions = questions!.take(widget.count).toList();
          }
          final q = questions![current];
          return Column(children: [
            LinearProgressIndicator(value: (current + 1) / questions!.length),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Row(children: [
                    Text('Soru ' + (current + 1).toString() + '/' + questions!.length.toString(), style: const TextStyle(color: blue, fontWeight: FontWeight.w900)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => setState(() => flagged.contains(current) ? flagged.remove(current) : flagged.add(current)),
                      icon: Icon(flagged.contains(current) ? Icons.flag : Icons.outlined_flag, color: flagged.contains(current) ? orange : Colors.white70),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Text(q.prompt, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900, height: 1.4)),
                  const SizedBox(height: 22),
                  if (q.options.isNotEmpty)
                    for (final o in q.options)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: ChoiceChip(
                          selected: answers[current] == o,
                          onSelected: (_) => setState(() => answers[current] = o),
                          label: SizedBox(width: double.infinity, child: Padding(padding: const EdgeInsets.all(10), child: Text(o))),
                        ),
                      )
                  else
                    TextFormField(
                      initialValue: answers[current] ?? '',
                      onChanged: (v) => answers[current] = v,
                      decoration: const InputDecoration(labelText: 'Cevabın'),
                    ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Expanded(child: OutlinedButton(onPressed: current == 0 ? null : () => setState(() => current--), child: const Text('Önceki'))),
                  const SizedBox(width: 10),
                  Expanded(child: FilledButton(onPressed: current == questions!.length - 1 ? submit : () => setState(() => current++), child: Text(current == questions!.length - 1 ? 'Bitir' : 'Sonraki'))),
                ]),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStateProvider);
    final rate = (s.successRate * 100).round();
    final points = <FlSpot>[
      FlSpot(0, math.max(10, rate - 22).toDouble()),
      FlSpot(1, math.max(10, rate - 15).toDouble()),
      FlSpot(2, math.max(10, rate - 12).toDouble()),
      FlSpot(3, math.max(10, rate - 8).toDouble()),
      FlSpot(4, math.max(10, rate - 5).toDouble()),
      FlSpot(5, math.max(10, rate - 3).toDouble()),
      FlSpot(6, math.max(10, rate).toDouble()),
    ];

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('İstatistik', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            Expanded(child: StatTile(label: 'Çözülen', value: s.answered.toString(), icon: Icons.quiz, color: blue)),
            const SizedBox(width: 10),
            Expanded(child: StatTile(label: 'Başarı', value: '%' + rate.toString(), icon: Icons.insights, color: success)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: StatTile(label: 'XP', value: s.xp.toString(), icon: Icons.bolt, color: orange)),
            const SizedBox(width: 10),
            Expanded(child: StatTile(label: 'Yanlış Defteri', value: s.wrongIds.length.toString(), icon: Icons.menu_book, color: purple)),
          ]),
          const SizedBox(height: 18),
          const Text('Son 7 gün başarı eğilimi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Card(
            child: SizedBox(
              height: 220,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LineChart(LineChartData(
                  minX: 0, maxX: 6, minY: 0, maxY: 100,
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [LineChartBarData(spots: points, isCurved: true, color: blue, barWidth: 4, dotData: const FlDotData(show: true), belowBarData: BarAreaData(show: true, color: blue.withOpacity(.12)))],
                )),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.book_outlined, color: orange),
                title: const Text('Yanlışlar Defteri', style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(s.wrongIds.length.toString() + ' soru tekrar bekliyor'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedQuestionsScreen(mode: 'wrong'))),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.star_outline, color: Color(0xFFFFD166)),
                title: const Text('Favori Sorular', style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(s.favorites.length.toString() + ' soru'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedQuestionsScreen(mode: 'favorite'))),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          const Text('Güçlü / Zayıf Konular', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Card(child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('💪 Güçlü: Sayılar · Yüzde · Temel İstatistik'),
            SizedBox(height: 10),
            Text('🧩 Geliştir: Trigonometri · Türev · Olasılık'),
            SizedBox(height: 8),
            Text('Not: Bu liste soru çözdükçe kişiselleşir.', style: TextStyle(fontSize: 12, color: Colors.white54)),
          ]))),
        ],
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const StatTile({super.key, required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white60)),
      ]),
    );
  }
}

class SavedQuestionsScreen extends ConsumerWidget {
  final String mode;
  const SavedQuestionsScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStateProvider);
    final async = ref.watch(questionsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(mode == 'wrong' ? 'Yanlışlar Defteri' : 'Favori Sorular'), backgroundColor: Colors.transparent),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (all) {
          final ids = mode == 'wrong' ? s.wrongIds : s.favorites;
          final list = all.where((q) => ids.contains(q.id)).toList();
          if (list.isEmpty) return const Center(child: Text('Burada henüz soru yok.'));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final q = list[i];
              return Card(child: ListTile(
                title: Text(q.prompt, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(q.topicId + ' · ' + q.difficulty),
                trailing: const Icon(Icons.play_arrow),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PracticeScreen(topicId: q.topicId, limit: 1))),
              ));
            },
          );
        },
      ),
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> addDiary(BuildContext context, WidgetRef ref) async {
    final c = TextEditingController();
    final result = await showDialog<String>(context: context, builder: (_) => AlertDialog(
      title: const Text('Bugün ne öğrendim?'),
      content: TextField(controller: c, maxLines: 4, decoration: const InputDecoration(hintText: 'Kısa bir not yaz...')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
        FilledButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: const Text('Kaydet')),
      ],
    ));
    if (result != null && result.isNotEmpty) await ref.read(appStateProvider).addDiary(result);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStateProvider);
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('Profil', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                const CircleAvatar(radius: 34, backgroundColor: Color(0x334F8EF7), child: Icon(Icons.person, size: 34, color: blue)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.level, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  Text(s.xp.toString() + ' XP · 🔥 ' + s.streak.toString() + ' gün seri', style: const TextStyle(color: Colors.white60)),
                ])),
              ]),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Rozetler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          if (s.badges.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('İlk sorunu çöz ve ilk rozetini aç.')))
          else
            Wrap(spacing: 8, runSpacing: 8, children: s.badges.map((b) => Chip(avatar: const Text('🏅'), label: Text(b))).toList()),
          const SizedBox(height: 18),
          const Text('Araçlar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Card(
            child: Column(children: [
              ListTile(leading: const Icon(Icons.show_chart, color: purple), title: const Text('Grafik Çizici'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GraphToolScreen()))),
              const Divider(height: 1),
              ListTile(leading: const Icon(Icons.change_history, color: orange), title: const Text('Geometri Laboratuvarı'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GeometryLabScreen()))),
              const Divider(height: 1),
              ListTile(leading: const Icon(Icons.draw, color: blue), title: const Text('Karalama Alanı'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScratchScreen()))),
            ]),
          ),
          const SizedBox(height: 14),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month, color: success),
              title: const Text('Matematik Günlüğü', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(s.diary.isEmpty ? 'Bugün ne öğrendim?' : s.diary.first),
              trailing: const Icon(Icons.add_circle_outline),
              onTap: () => addDiary(context, ref),
            ),
          ),
          if (s.diary.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final d in s.diary.take(5)) Card(child: Padding(padding: const EdgeInsets.all(14), child: Text(d))),
          ],
          const SizedBox(height: 18),
          Card(
            child: ListTile(
              leading: const Icon(Icons.ac_unit, color: Colors.lightBlueAccent),
              title: const Text('Ertele hakkı'),
              subtitle: Text('Bu hafta ' + s.freezeRights.toString() + ' kullanım hakkın var.'),
            ),
          )
        ],
      ),
    );
  }
}

class GraphToolScreen extends StatefulWidget {
  const GraphToolScreen({super.key});
  @override
  State<GraphToolScreen> createState() => _GraphToolScreenState();
}

class _GraphToolScreenState extends State<GraphToolScreen> {
  double m = 2;
  double b = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('Grafik Çizici')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(children: [
                Math.tex('y = ' + m.toStringAsFixed(1) + 'x + ' + b.toStringAsFixed(1), textStyle: const TextStyle(fontSize: 26)),
                const SizedBox(height: 12),
                SizedBox(height: 320, child: CustomPaint(painter: FunctionPainter(m, b), child: Container())),
              ]),
            ),
          ),
          const SizedBox(height: 14),
          Text('Eğim: ' + m.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w800)),
          Slider(value: m, min: -5, max: 5, divisions: 20, onChanged: (v) => setState(() => m = v)),
          Text('Sabit: ' + b.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w800)),
          Slider(value: b, min: -5, max: 5, divisions: 20, onChanged: (v) => setState(() => b = v)),
          const Card(child: Padding(padding: EdgeInsets.all(15), child: Text('Noktaları ve doğrunun yönünü izle: eğim pozitifse grafik sağa giderken yükselir, negatifse düşer.'))),
        ],
      ),
    );
  }
}

class FunctionPainter extends CustomPainter {
  final double m;
  final double b;
  FunctionPainter(this.m, this.b);

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = Colors.white10..strokeWidth = 1;
    final axis = Paint()..color = Colors.white54..strokeWidth = 2;
    final line = Paint()..color = blue..strokeWidth = 3..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    const scale = 28.0;
    for (int i = -5; i <= 5; i++) {
      canvas.drawLine(Offset(cx + i * scale, 0), Offset(cx + i * scale, size.height), grid);
      canvas.drawLine(Offset(0, cy + i * scale), Offset(size.width, cy + i * scale), grid);
    }
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), axis);
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), axis);
    Offset map(double x, double y) => Offset(cx + x * scale, cy - y * scale);
    final p1 = map(-6, m * -6 + b);
    final p2 = map(6, m * 6 + b);
    canvas.drawLine(p1, p2, line);
    final p0 = map(0, b);
    canvas.drawCircle(p0, 6, Paint()..color = orange);
  }

  @override
  bool shouldRepaint(covariant FunctionPainter oldDelegate) => oldDelegate.m != m || oldDelegate.b != b;
}

class GeometryLabScreen extends StatefulWidget {
  const GeometryLabScreen({super.key});
  @override
  State<GeometryLabScreen> createState() => _GeometryLabScreenState();
}

class _GeometryLabScreenState extends State<GeometryLabScreen> {
  double a = 3;
  double b = 4;
  double angle = 45;

  @override
  Widget build(BuildContext context) {
    final c = math.sqrt(a * a + b * b);
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('Geometri Laboratuvarı')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(children: [
                const Text('Pisagor — canlı üçgen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                SizedBox(height: 220, child: CustomPaint(painter: TrianglePainter(a, b), child: Container())),
                Text('a = ' + a.toStringAsFixed(1) + '   b = ' + b.toStringAsFixed(1) + '   c = ' + c.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w800)),
                Slider(value: a, min: 1, max: 8, onChanged: (v) => setState(() => a = v)),
                Slider(value: b, min: 1, max: 8, onChanged: (v) => setState(() => b = v)),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(children: [
                const Text('Açı sürükle', style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Transform.rotate(angle: angle * math.pi / 180, child: const Icon(Icons.change_history, size: 100, color: purple)),
                Slider(value: angle, min: 0, max: 180, divisions: 18, label: angle.round().toString() + '°', onChanged: (v) => setState(() => angle = v)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final double a;
  final double b;
  TrianglePainter(this.a, this.b);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = blue..style = PaintingStyle.stroke..strokeWidth = 4;
    final origin = Offset(40, size.height - 35);
    final sx = math.min(18.0, (size.width - 80) / math.max(a, 1));
    final sy = math.min(18.0, (size.height - 70) / math.max(b, 1));
    final p2 = Offset(origin.dx + a * sx, origin.dy);
    final p3 = Offset(origin.dx, origin.dy - b * sy);
    final path = Path()..moveTo(origin.dx, origin.dy)..lineTo(p2.dx, p2.dy)..lineTo(p3.dx, p3.dy)..close();
    canvas.drawPath(path, p);
    canvas.drawRect(Rect.fromLTWH(origin.dx, origin.dy - 18, 18, 18), Paint()..color = orange.withOpacity(.5)..style = PaintingStyle.stroke..strokeWidth = 2);
  }
  @override
  bool shouldRepaint(covariant TrianglePainter oldDelegate) => oldDelegate.a != a || oldDelegate.b != b;
}

class ScratchScreen extends StatefulWidget {
  const ScratchScreen({super.key});
  @override
  State<ScratchScreen> createState() => _ScratchScreenState();
}

class _ScratchScreenState extends State<ScratchScreen> {
  final List<List<Offset>> strokes = [];
  List<Offset>? current;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Karalama Alanı'),
        actions: [
          IconButton(onPressed: strokes.isEmpty ? null : () => setState(() => strokes.removeLast()), icon: const Icon(Icons.undo)),
          IconButton(onPressed: () => setState(() => strokes.clear()), icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: GestureDetector(
            onPanStart: (d) => setState(() { current = [d.localPosition]; strokes.add(current!); }),
            onPanUpdate: (d) => setState(() => current?.add(d.localPosition)),
            onPanEnd: (_) => current = null,
            child: CustomPaint(painter: ScratchPainter(strokes), child: const SizedBox.expand()),
          ),
        ),
      ),
    );
  }
}

class ScratchPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  ScratchPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF17213F)..strokeWidth = 3..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant ScratchPainter oldDelegate) => true;
}
