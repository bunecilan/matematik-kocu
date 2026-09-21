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

List<LessonStep> lessonFor(Topic t) {
  if (t.id == '1.1') {
    return const [
      LessonStep('1 — Bu Ne İşe Yarar?','🛒 Markette 3 ürün sayarken doğal sayıları kullanırsın.\n🌡️ Hava eksi 4 derece olduğunda tam sayılar devreye girer.\n🍕 Bir pizzanın yarısını anlatırken rasyonel sayılar gerekir.\n\nKısa hikâye: Deniz’in cebinde 5 lira vardı, 8 lira borç aldı ve pizzanın yarısını yedi. Tek bir günde üç sayı ailesiyle karşılaştı.','💡'),
      LessonStep('2 — En Basit Hali','Doğal sayılar saymak için kullandığın sıfırdan başlayan sayılardır. Tam sayılar bunlara eksi değerleri de ekler. Rasyonel sayılar ise bir bütünün parçalarını anlatabilen sayılardır.','🧠'),
      LessonStep('3 — Görselle Anlayalım','Sayı doğrusunu bir cadde gibi düşün. Sağ tarafa gittikçe sayı büyür, sola gittikçe küçülür. Sıfır ortadaki buluşma noktasıdır. Aşağıdaki görselde noktayı sürükleyerek sayıların yerini zihninde canlandır.','🎨'),
      LessonStep('4 — Adım Adım Çözüm','Örnek: Eksi üç ile iki arasındaki tam sayıları bulalım.\n\n1. Sayı doğrusunda eksi üçü bul.\nBurada ne yaptık? Başlangıç sınırını belirledik.\n\n2. İkiye doğru sağa ilerle.\nBurada ne yaptık? Sayıları küçükten büyüğe sıraladık.\n\n3. Arada eksi iki, eksi bir, sıfır ve bir vardır.\nBurada ne yaptık? Uçları almadan aradaki tam sayıları yazdık.','🪜'),
      LessonStep('5 — Peki Ya Şimdi?','Soru: Eksi iki mi, eksi beş mi daha büyüktür?\n\n⚠️ Çoğu kişi burada hata yapar: “Beş daha büyük, o hâlde eksi beş büyüktür.”\n\nYanlış yol: Eksi işaretini görmezden gelmek.\nDoğru yol: Sayı doğrusunda sağda olan daha büyüktür. Eksi iki, eksi beşin sağındadır.','⚠️'),
      LessonStep('6 — Senin Sıran','Üç soru çözeceksin: kolay, orta ve zor. Yanlışta önce tekrar dene, sonra ipucu al, en son adım adım çözümü aç.','🎯'),
      LessonStep('7 — Bunu Biliyor muydun?','Sıfırın bir sayı olarak sistemli biçimde kullanılması matematik tarihinde büyük bir dönüm noktasıdır. Hint matematik geleneğinde gelişen sıfır fikri, daha sonra İslam dünyası üzerinden Avrupa’ya yayılmıştır.','🏛️'),
    ];
  }
  if (t.id == '1.2') {
    return const [
      LessonStep('1 — Bu Ne İşe Yarar?','📍 Bir yere ne kadar uzakta olduğunu söylerken yön değil mesafe önemlidir.\n💳 Borcun büyüklüğünü konuşurken eksi işareti değil miktar önemlidir.\n🌡️ Sıfır dereceden kaç derece uzakta olduğunu hesaplarken kullanılır.','💡'),
      LessonStep('2 — En Basit Hali','Mutlak değer, bir sayının sıfıra olan uzaklığıdır. Uzaklık negatif olamayacağı için sonuç da negatif olmaz.','🧠'),
      LessonStep('3 — Görselle Anlayalım','Sıfırdan sağa üç adım ile sıfırdan sola üç adım aynı mesafedir. Bu yüzden üç ile eksi üçün mutlak değeri aynıdır.','🎨'),
      LessonStep('4 — Adım Adım Çözüm','Örnek: Mutlak değeri beş olan sayıları bulalım.\n\n1. Sıfırı merkeze al.\nBurada ne yaptık? Mesafenin başlangıcını seçtik.\n\n2. Sağda beş adım git: beş.\n3. Solda beş adım git: eksi beş.\n\nSonuç: İki sayı vardır.','🪜'),
      LessonStep('5 — Peki Ya Şimdi?','⚠️ Hata: “Mutlak değer içindeki eksi her zaman artıya döner.”\nBu cümle tek başına yeterli değildir. İçeride işlem varsa önce içeriyi hesaplamak gerekir.\n\nÖrneğin bir sayıdan beş çıkarınca sonuç pozitif de negatif de olabilir; mutlak değer sonucun sıfıra uzaklığını alır.','⚠️'),
      LessonStep('6 — Senin Sıran','Kolay, orta ve zor üç mutlak değer sorusuna geç. Yanlış yaptığında uygulama ipucu ve çözüm yolunu gösterecek.','🎯'),
      LessonStep('7 — Bunu Biliyor muydun?','Mutlak değer yalnızca okul matematiğinde değil, veri biliminde hata miktarını ve uzaklık ölçülerini tanımlarken de kullanılır.','🏛️'),
    ];
  }
  if (t.id == '1.3') {
    return const [
      LessonStep('1 — Bu Ne İşe Yarar?','🦠 Çok hızlı çoğalan canlıları anlatırken,\n💾 bilgisayardaki ikinin kuvvetlerinde,\n📈 bileşik büyüme hesaplarında üsler hayat kurtarır.','💡'),
      LessonStep('2 — En Basit Hali','Üslü sayı, aynı sayıyı tekrar tekrar çarpmanın kısa yoludur. Örneğin iki sayısını üç kez kendisiyle çarpmak yerine “ikinin üçüncü kuvveti” dersin.','🧠'),
      LessonStep('3 — Görselle Anlayalım','Bir kareyi iki kat, sonra tekrar iki kat, sonra tekrar iki kat büyüttüğünü düşün. Her adımda tekrar eden çarpma vardır. Üs, kaç tekrar olduğunu söyler.','🎨'),
      LessonStep('4 — Adım Adım Çözüm','Örnek: İkinin dördüncü kuvveti.\n1. Taban iki.\n2. Üs dört, yani dört tane iki çarpılacak.\n3. İki çarpı iki dört, dört çarpı iki sekiz, sekiz çarpı iki on altı.\nBurada ne yaptık? Üs ifadesini tekrarlı çarpıma çevirdik.','🪜'),
      LessonStep('5 — Peki Ya Şimdi?','⚠️ Çok yapılan hata: İkinin üçüncü kuvvetini iki çarpı üç sanmak.\nYanlış sonuç altıdır.\nDoğru düşünce: iki çarpı iki çarpı iki; sonuç sekizdir.\nNegatif üs ise sayının tersini almaya götürür.','⚠️'),
      LessonStep('6 — Senin Sıran','Üç soru: temel kuvvet, aynı tabanlı çarpım ve negatif üs. İstersen ipucuyla ilerle.','🎯'),
      LessonStep('7 — Bunu Biliyor muydun?','Üstel gösterim astronomide çok büyük, mikroskobik bilimlerde ise çok küçük sayıları okunabilir biçimde yazmak için bilimsel gösterimin temelidir.','🏛️'),
    ];
  }

  return [
    LessonStep('1 — Bu Ne İşe Yarar?','🎯 ' + t.title + ' konusu gerçek hayattaki problem çözme, sınav sorularını yorumlama ve sonraki matematik konularını öğrenme için bir araçtır. Önce “neden”ini anlayacağız.','💡'),
    LessonStep('2 — En Basit Hali',t.title + ' konusunu önce sembolsüz bir fikir olarak düşün. Amaç ezberlemek değil, hangi durumda hangi düşünceyi kullanacağını fark etmektir.','🧠'),
    LessonStep('3 — Görselle Anlayalım','Şekilleri, sayı doğrusunu veya grafiği hareket ettirerek değişimin sonucunu gözlemle. Görsel hafıza, kuralı daha kalıcı hâle getirir.','🎨'),
    LessonStep('4 — Adım Adım Çözüm','İlk örnekte problemi küçük parçalara ayır: verilenleri belirle, isteneni söyle, uygun kuralı seç, işlemi uygula ve sonucu kontrol et. Her adımın nedenini kendine söyle.','🪜'),
    LessonStep('5 — Peki Ya Şimdi?','⚠️ En sık hata, kuralı soruyu anlamadan uygulamaktır. Önce koşulları oku, sonra işlemi seç. Yanlış çözüm ile doğru çözümü karşılaştır.','⚠️'),
    LessonStep('6 — Senin Sıran','Kolay → Orta → Zor üç soru ile konuyu sınayacaksın. Yanlışta Tekrar Dene → İpucu → Adım Adım Çöz sırası kullanılacak.','🎯'),
    LessonStep('7 — Bunu Biliyor muydun?',t.title + ' fikri matematiğin farklı dönemlerinde farklı ihtiyaçlardan doğmuş ve bugün bilim, mühendislik, ekonomi veya veri analizinde kullanılmaya devam etmektedir.','🏛️'),
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
            for (int i = 0; i < 7; i++)
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
              if (step == 2) ...[
                const SizedBox(height: 12),
                VisualLesson(topicId: topic.id),
              ],
              if (step == 3 && topic.id == '1.3') ...[
                const SizedBox(height: 14),
                Center(child: Math.tex(r'2^4 = 2 \times 2 \times 2 \times 2 = 16', textStyle: const TextStyle(fontSize: 20))),
              ],
              if (step == 5) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PracticeScreen(topicId: topic.id, limit: 3))),
                  icon: const Icon(Icons.play_arrow),
                  label: const Padding(padding: EdgeInsets.all(14), child: Text('3 Soruluk Pratiği Başlat')),
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
                    if (step < 6) {
                      setState(() => step++);
                    } else {
                      await ref.read(appStateProvider).completeTopic(topic.id);
                      if (context.mounted) {
                        showDialog(context: context, builder: (_) => AlertDialog(
                          title: const Text('🎉 Konu tamamlandı!'),
                          content: const Text('+50 XP kazandın. Bir sonraki konuya geçebilir veya pratik yapabilirsin.'),
                          actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('Harika'))],
                        ));
                      }
                    }
                  },
                  child: Padding(padding: const EdgeInsets.all(14), child: Text(step < 6 ? 'Devam' : 'Konuyu Tamamla', style: const TextStyle(fontWeight: FontWeight.w900))),
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
        title: const Text('Pratik Modu', style: TextStyle(fontWeight: FontWeight.w900)),
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
                            Navigator.pop(context);
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
