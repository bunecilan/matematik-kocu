package com.matematikkocu.app

data class Example(val question: String, val steps: List<String>, val answer: String)
data class QuizQuestion(val question: String, val options: List<String>, val correct: Int, val explanation: String)
data class Lesson(
    val id: String,
    val level: String,
    val title: String,
    val subtitle: String,
    val icon: String,
    val simpleExplanation: String,
    val rule: String,
    val examples: List<Example>,
    val quiz: List<QuizQuestion>
)

object Curriculum {
    val lessons = listOf(
        Lesson(
            "numbers", "Başlangıç", "Sayılar ve sayı doğrusu", "Matematiğin alfabesi", "🔢",
            "Sayıyı, kaç tane şey olduğunu gösteren bir etiket gibi düşün. 5 elma demek, elimizde beş tane elma var demektir. Sayı doğrusu ise yerde uzayan bir yol gibidir: sağa gittikçe sayı büyür, sola gittikçe küçülür.",
            "Sağdaki sayı daha büyük, soldaki sayı daha küçüktür. 0 ne artı ne eksidir.",
            listOf(
                Example("3 mü büyük, 7 mi?", listOf("Sayı doğrusunda 7, 3'ün sağındadır.", "Sağdaki sayı daha büyüktür."), "7 daha büyüktür."),
                Example("-2 mi büyük, 1 mi?", listOf("-2 sıfırın solunda, 1 sıfırın sağındadır.", "Sağdaki sayı büyük olduğu için 1 daha büyüktür."), "1 > -2")
            ),
            listOf(
                QuizQuestion("Hangisi en büyüktür?", listOf("-3", "0", "2", "-1"), 2, "2 sayı doğrusunda diğerlerinin hepsinden daha sağdadır."),
                QuizQuestion("Hangisi doğrudur?", listOf("-5 > 1", "0 < -2", "4 > -1", "-1 > 9"), 2, "4 pozitif, -1 negatiftir; bu yüzden 4 daha büyüktür.")
            )
        ),
        Lesson(
            "operations", "Başlangıç", "Dört işlem", "Topla, çıkar, çarp, böl", "➕",
            "Toplama bir araya getirmektir. Çıkarma elindekinden azaltmaktır. Çarpma aynı sayıyı tekrar tekrar toplamaktır. Bölme ise bir şeyi eşit paylaştırmaktır.",
            "İşlem önceliği: önce parantez, sonra çarpma-bölme, en son toplama-çıkarma.",
            listOf(
                Example("8 + 5 kaç?", listOf("8'in üstüne 5 ekle.", "9, 10, 11, 12, 13 diye ilerle."), "13"),
                Example("3 × 4 kaç?", listOf("3'ü dört kez topla: 3 + 3 + 3 + 3", "Toplam 12 eder."), "12"),
                Example("2 + 3 × 4", listOf("Önce çarpma: 3 × 4 = 12", "Sonra toplama: 2 + 12 = 14"), "14")
            ),
            listOf(
                QuizQuestion("7 + 6 = ?", listOf("11", "12", "13", "14"), 2, "7'nin üzerine 6 ekleyince 13 olur."),
                QuizQuestion("18 ÷ 3 = ?", listOf("5", "6", "7", "9"), 1, "18'i 3 eşit gruba bölersen her grupta 6 olur."),
                QuizQuestion("5 + 2 × 3 = ?", listOf("21", "11", "15", "9"), 1, "Önce 2×3=6, sonra 5+6=11.")
            )
        ),
        Lesson(
            "fractions", "Başlangıç", "Kesirler", "Pastayı paylaşır gibi", "🍕",
            "Kesri pasta gibi düşün. Alt sayı pastanın kaç eşit parçaya bölündüğünü, üst sayı bu parçalardan kaç tanesini aldığını söyler. 3/4 demek, dört eşit parçanın üçünü almak demektir.",
            "Pay üstte, payda alttadır. Paydalar eşitse payları toplarsın. Paydalar farklıysa önce eşitlersin.",
            listOf(
                Example("1/4 + 2/4", listOf("Paydalar zaten aynı: 4.", "Üstteki sayıları topla: 1 + 2 = 3."), "3/4"),
                Example("1/2 + 1/4", listOf("1/2'yi dörtte birlik dilime çevir: 1/2 = 2/4.", "2/4 + 1/4 = 3/4."), "3/4")
            ),
            listOf(
                QuizQuestion("2/5 ne demektir?", listOf("5 parçanın 2'si", "2 parçanın 5'i", "2+5", "5-2"), 0, "Payda 5: toplam beş eşit parça. Pay 2: bunların ikisi."),
                QuizQuestion("1/3 + 1/3 = ?", listOf("1/6", "2/3", "2/6", "1"), 1, "Paydalar aynıysa sadece payları toplarsın: 1+1=2, sonuç 2/3.")
            )
        ),
        Lesson(
            "decimal", "Başlangıç", "Ondalık sayılar", "Virgülün solunu ve sağını anla", "🔸",
            "1,5 sayısını 1 tam ve yarım gibi düşün. Virgülün solu tam kısmı, sağı ise bütünün küçük parçalarını gösterir.",
            "Toplama ve çıkarmada virgülleri alt alta getir. 0,5 = 1/2 ve 0,25 = 1/4 gibi düşünmek işleri kolaylaştırır.",
            listOf(
                Example("1,2 + 0,7", listOf("Virgülleri hizala.", "12 onda + 7 onda = 19 onda."), "1,9"),
                Example("0,5 × 10", listOf("10 ile çarpınca virgül bir basamak sağa kayar."), "5")
            ),
            listOf(
                QuizQuestion("0,5 hangisine eşittir?", listOf("1/5", "1/2", "5/100", "2"), 1, "0,5 = 5/10 = 1/2."),
                QuizQuestion("2,4 + 1,1 = ?", listOf("3,5", "3,4", "2,5", "4,1"), 0, "Virgülleri hizala: 2,4 + 1,1 = 3,5.")
            )
        ),
        Lesson(
            "percent", "Temel", "Yüzdeler", "100 parçadan kaçı?", "%",
            "% işaretini '100 parçadan' diye oku. %20 demek 100 parçanın 20'si demektir. %50 yarısı, %25 dörtte biri, %10 onda biridir.",
            "Bir sayının yüzde x'i = sayı × x / 100.",
            listOf(
                Example("200 TL'nin %10'u", listOf("%10 onda birdir.", "200 ÷ 10 = 20."), "20 TL"),
                Example("80'in %25'i", listOf("%25 = 1/4.", "80 ÷ 4 = 20."), "20")
            ),
            listOf(
                QuizQuestion("300'ün %10'u kaç?", listOf("3", "30", "300", "10"), 1, "%10 onda birdir; 300÷10=30."),
                QuizQuestion("%50 ne demektir?", listOf("İki katı", "Yarısı", "Dörtte biri", "On katı"), 1, "%50 = 50/100 = 1/2.")
            )
        ),
        Lesson(
            "negative", "Temel", "Negatif sayılar", "Borç gibi düşün", "➖",
            "Negatif sayıları borç gibi düşün. +10 TL paran varsa artıdasın. 10 TL borcun varsa -10 gibi düşünebilirsin. Daha büyük borç, sayı doğrusunda daha soldadır.",
            "Eksi ile eksiyi toplarken borç büyür. Negatif sayıyı çıkarmak, artı eklemek gibi davranır: 5 - (-2) = 7.",
            listOf(
                Example("-3 + -4", listOf("3 borca 4 borç daha ekle.", "Toplam 7 borç olur."), "-7"),
                Example("5 - (-2)", listOf("Eksi bir negatifi çıkarmak artıya dönüşür.", "5 + 2 = 7."), "7")
            ),
            listOf(
                QuizQuestion("-2 + -5 = ?", listOf("7", "-7", "3", "-3"), 1, "İki borç birleşir: 2+5=7 borç, yani -7."),
                QuizQuestion("4 - (-3) = ?", listOf("1", "-1", "7", "-7"), 2, "Negatifi çıkarmak artı eklemektir: 4+3=7.")
            )
        ),
        Lesson(
            "powers", "Orta", "Üslü sayılar", "Aynı sayıyı tekrar çarp", "²",
            "2³ yazınca korkma. Bu sadece '2'yi üç kere çarp' demektir: 2×2×2. Küçük üstteki sayı kaç kez çarpacağını söyler.",
            "aᵐ × aⁿ = aᵐ⁺ⁿ. Aynı taban bölünürse üsler çıkarılır.",
            listOf(
                Example("2⁴", listOf("2'yi dört kez çarp: 2×2×2×2", "4×4=16"), "16"),
                Example("3² × 3³", listOf("Taban aynı: 3.", "Üsleri topla: 2+3=5."), "3⁵ = 243")
            ),
            listOf(
                QuizQuestion("5² = ?", listOf("10", "25", "15", "52"), 1, "5² = 5×5 = 25."),
                QuizQuestion("2³ × 2² = ?", listOf("2⁵", "4⁵", "2⁶", "4²"), 0, "Taban aynıysa üsler toplanır: 3+2=5.")
            )
        ),
        Lesson(
            "roots", "Orta", "Karekök", "Hangi sayı kendisiyle çarpılınca?", "√",
            "√9 demek 'hangi sayı kendisiyle çarpılınca 9 eder?' sorusudur. 3×3=9 olduğu için √9=3.",
            "√(a²)=|a|. Tam kareleri bilmek hız kazandırır: 1,4,9,16,25,36,49,64,81,100.",
            listOf(
                Example("√49", listOf("7×7=49.", "O halde karekök 7'dir."), "7"),
                Example("√81", listOf("9×9=81."), "9")
            ),
            listOf(
                QuizQuestion("√64 = ?", listOf("6", "7", "8", "9"), 2, "8×8=64."),
                QuizQuestion("√25 = ?", listOf("5", "10", "12,5", "625"), 0, "5×5=25.")
            )
        ),
        Lesson(
            "algebra", "Orta", "Cebir ve bilinmeyen", "x aslında gizli sayı", "x",
            "x'i gizli kutu gibi düşün. x+3=8 denince 'kutunun içine hangi sayı gelirse 3 ekleyince 8 olur?' diye soruyoruz.",
            "Eşitliğin bir tarafında ne yaparsan diğer tarafında da aynısını yap. Amaç x'i yalnız bırakmak.",
            listOf(
                Example("x + 5 = 12", listOf("x'in yanındaki +5'i kaldırmak için iki taraftan 5 çıkar.", "x = 12-5"), "x = 7"),
                Example("3x = 18", listOf("3x, 3 tane x demektir.", "İki tarafı 3'e böl."), "x = 6")
            ),
            listOf(
                QuizQuestion("x + 4 = 10 ise x?", listOf("4", "5", "6", "14"), 2, "10-4=6."),
                QuizQuestion("2x = 14 ise x?", listOf("5", "6", "7", "28"), 2, "İki tarafı 2'ye böl: x=7.")
            )
        ),
        Lesson(
            "equations", "Orta", "Denklemler", "Terazi dengede kalmalı", "⚖️",
            "Denklemi terazi gibi düşün. Sol taraf ile sağ taraf eşit ağırlıktadır. Bir taraftan 4 çıkarırsan diğer taraftan da 4 çıkarmalısın ki denge bozulmasın.",
            "Parantezleri aç, benzer terimleri birleştir, x'leri bir tarafa, sayıları diğer tarafa topla.",
            listOf(
                Example("2x + 3 = 11", listOf("İki taraftan 3 çıkar: 2x=8.", "İki tarafı 2'ye böl."), "x=4"),
                Example("3(x+2)=15", listOf("İki tarafı 3'e böl: x+2=5.", "2 çıkar: x=3."), "x=3")
            ),
            listOf(
                QuizQuestion("4x - 8 = 12 ise x?", listOf("4", "5", "6", "8"), 1, "8 ekle: 4x=20. 4'e böl: x=5."),
                QuizQuestion("5(x-1)=20 ise x?", listOf("3", "4", "5", "6"), 2, "5'e böl: x-1=4. 1 ekle: x=5.")
            )
        ),
        Lesson(
            "inequality", "Orta", "Eşitsizlikler", "Büyük mü, küçük mü?", "<",
            "Eşitsizlik denklem gibidir ama iki tarafın eşit olması gerekmez. > büyük, < küçük demektir. İşaretin açık ağzı büyük sayıya bakar.",
            "Negatif bir sayıyla çarpar veya bölersen eşitsizlik işareti yön değiştirir.",
            listOf(
                Example("x + 2 > 5", listOf("İki taraftan 2 çıkar.", "x > 3 olur."), "x>3"),
                Example("-2x > 6", listOf("İki tarafı -2'ye böl.", "Negatife böldüğümüz için işaret ters döner."), "x < -3")
            ),
            listOf(
                QuizQuestion("x-4<2 ise?", listOf("x<6", "x>6", "x<2", "x>2"), 0, "İki tarafa 4 ekle: x<6."),
                QuizQuestion("-x < 3 ise?", listOf("x<3", "x>-3", "x< -3", "x>3"), 1, "-1'e bölünce işaret yön değiştirir: x>-3.")
            )
        ),
        Lesson(
            "ratio", "Orta", "Oran ve orantı", "Karışım reçetesi gibi", "↔",
            "Oran iki miktarı karşılaştırır. 2 bardak suya 1 kaşık şurup koyuyorsan oran 2:1'dir. Aynı tadı korumak için miktarları aynı katsayıyla artırırsın.",
            "a/b = c/d ise içler-dışlar çarpımı yapılabilir: a×d = b×c.",
            listOf(
                Example("2/3 = x/12", listOf("3'ten 12'ye 4 kat var.", "2'yi de 4 ile çarp."), "x=8"),
                Example("5 kalem 20 TL ise 1 kalem?", listOf("20'yi 5'e böl."), "4 TL")
            ),
            listOf(
                QuizQuestion("3/4 = x/20 ise x?", listOf("10", "12", "15", "16"), 2, "4'ten 20'ye 5 kat; 3×5=15."),
                QuizQuestion("2 ürün 30 TL ise aynı fiyattan 6 ürün?", listOf("60", "75", "90", "120"), 2, "6 ürün, 2 ürünün 3 katıdır: 30×3=90.")
            )
        ),
        Lesson(
            "geometry", "Orta", "Geometri temelleri", "Şekilleri ölç", "📐",
            "Geometri şekillerin matematiğidir. Çevre, şeklin kenarlarının etrafında yürüme mesafesidir. Alan ise şeklin kapladığı zemindir.",
            "Dikdörtgen alanı = kısa kenar × uzun kenar. Üçgen alanı = taban × yükseklik / 2. Dairenin alanı = πr².",
            listOf(
                Example("Kenarları 3 ve 5 olan dikdörtgenin alanı", listOf("Alan = 3×5"), "15"),
                Example("Tabanı 6, yüksekliği 4 olan üçgen", listOf("6×4=24", "Üçgen olduğu için ikiye böl: 12"), "12")
            ),
            listOf(
                QuizQuestion("4×7 dikdörtgenin alanı?", listOf("11", "22", "28", "44"), 2, "4×7=28."),
                QuizQuestion("Kenarları 5,5,5 olan üçgenin çevresi?", listOf("10", "15", "20", "25"), 1, "Çevre tüm kenarları toplamaktır: 5+5+5=15.")
            )
        ),
        Lesson(
            "functions", "İleri", "Fonksiyonlar", "Makineye sayı koy, sonuç çıksın", "ƒ",
            "Fonksiyonu makine gibi düşün. İçine bir sayı atarsın, makine belirli bir kurala göre başka sayı çıkarır. f(x)=2x+1 ise makine 'ikiyle çarp, bir ekle' der.",
            "f(a) bulmak için formüldeki x yerine a yaz.",
            listOf(
                Example("f(x)=2x+1, f(3)?", listOf("x yerine 3 yaz: 2×3+1", "6+1=7"), "7"),
                Example("g(x)=x², g(-4)?", listOf("(-4)² = (-4)×(-4)"), "16")
            ),
            listOf(
                QuizQuestion("f(x)=3x-2, f(4)?", listOf("8", "10", "12", "14"), 1, "3×4-2=12-2=10."),
                QuizQuestion("f(x)=x+5, f(0)?", listOf("0", "1", "5", "10"), 2, "0+5=5.")
            )
        ),
        Lesson(
            "trigonometry", "İleri", "Trigonometri", "Üçgende açı ve kenar ilişkisi", "△",
            "Sinüs, kosinüs ve tanjantı üçgenin kenarları arasındaki oranlar gibi düşün. Dik üçgende bir açı seçersin; karşı, komşu ve hipotenüs kenarlarını buna göre isimlendirirsin.",
            "sin = karşı/hipotenüs, cos = komşu/hipotenüs, tan = karşı/komşu.",
            listOf(
                Example("Karşı=3, hipotenüs=5 ise sinθ", listOf("sin = karşı/hipotenüs", "3/5 yaz."), "3/5"),
                Example("Karşı=4, komşu=3 ise tanθ", listOf("tan = karşı/komşu"), "4/3")
            ),
            listOf(
                QuizQuestion("cos hangi orandır?", listOf("karşı/hipotenüs", "komşu/hipotenüs", "karşı/komşu", "hipotenüs/karşı"), 1, "Kosinus = komşu / hipotenüs."),
                QuizQuestion("tan 45° kaçtır?", listOf("0", "1", "√2", "2"), 1, "45-45-90 üçgeninde karşı ve komşu eşittir; oran 1 olur.")
            )
        ),
        Lesson(
            "probability", "İleri", "Olasılık", "Olma ihtimali", "🎲",
            "Olasılık, bir şeyin olma şansını sayıyla anlatır. Adil bir zarın 6 yüzü vardır ve sadece bir yüzünde 6 yazdığı için 6 gelme ihtimali 1/6'dır.",
            "Olasılık = istediğin durum sayısı / tüm mümkün durum sayısı. Sonuç 0 ile 1 arasındadır.",
            listOf(
                Example("Parada yazı gelme olasılığı", listOf("İki sonuç var: yazı veya tura.", "İstenen sonuç 1 tanedir."), "1/2"),
                Example("Zarda çift sayı gelmesi", listOf("Çiftler: 2,4,6 yani 3 sonuç.", "Toplam 6 sonuç var: 3/6=1/2."), "1/2")
            ),
            listOf(
                QuizQuestion("Zarda 1 gelme olasılığı?", listOf("1/2", "1/3", "1/6", "1"), 2, "Altı eşit olası yüzden sadece biri 1'dir."),
                QuizQuestion("İmkânsız olayın olasılığı?", listOf("0", "1/2", "1", "2"), 0, "İmkânsız olayın olasılığı 0'dır.")
            )
        ),
        Lesson(
            "statistics", "İleri", "İstatistik", "Veriyi anlamlandır", "📊",
            "İstatistik çok sayıdaki bilgiyi özetlemeye yardım eder. Ortalama, bütün sayıları toplayıp kaç sayı varsa ona bölmektir. Medyan ortadaki değerdir.",
            "Aritmetik ortalama = toplam / adet. Medyan için sayıları önce küçükten büyüğe sırala.",
            listOf(
                Example("2, 4, 6 ortalaması", listOf("Topla: 2+4+6=12", "3 sayı var: 12÷3=4"), "4"),
                Example("1,9,3 medyanı", listOf("Sırala: 1,3,9", "Ortadaki sayı 3."), "3")
            ),
            listOf(
                QuizQuestion("4,6,8 ortalaması?", listOf("5", "6", "7", "8"), 1, "4+6+8=18; 18÷3=6."),
                QuizQuestion("2,10,5 medyanı?", listOf("2", "5", "10", "17"), 1, "Sıra 2,5,10; ortadaki 5.")
            )
        ),
        Lesson(
            "logarithm", "İleri", "Logaritma", "Üssü tersinden sor", "log",
            "Logaritma aslında üs sorusudur. log₂8 = 3 demek '2'yi kaçıncı kuvvete çıkarırsam 8 olur?' demektir. Cevap 3 çünkü 2³=8.",
            "logₐb = c ise aᶜ = b.",
            listOf(
                Example("log₂16", listOf("2'nin hangi kuvveti 16?", "2⁴=16."), "4"),
                Example("log₁₀1000", listOf("10³=1000."), "3")
            ),
            listOf(
                QuizQuestion("log₂8 = ?", listOf("2", "3", "4", "8"), 1, "2³=8."),
                QuizQuestion("log₁₀100 = ?", listOf("1", "2", "10", "100"), 1, "10²=100.")
            )
        ),
        Lesson(
            "limit", "Üniversite", "Limit", "Bir değere yaklaşmak", "→",
            "Limiti, hedefe yaklaşan araba gibi düşün. Araba hedefe varmak zorunda değil; önemli olan yaklaşırken hangi değere yaklaştığıdır.",
            "Basit sürekli fonksiyonlarda x yerine yaklaşan değeri yazmak çoğu zaman yeterlidir.",
            listOf(
                Example("lim x→2 (x+3)", listOf("Fonksiyon sürekli.", "x yerine 2 yaz: 2+3."), "5"),
                Example("lim x→3 x²", listOf("x yerine 3 yaz.", "3²=9."), "9")
            ),
            listOf(
                QuizQuestion("lim x→4 (2x) = ?", listOf("2", "4", "6", "8"), 3, "x yerine 4 yaz: 2×4=8."),
                QuizQuestion("lim x→1 (x²+1)=?", listOf("1", "2", "3", "4"), 1, "1²+1=2.")
            )
        ),
        Lesson(
            "derivative", "Üniversite", "Türev", "Değişim hızını ölç", "dy/dx",
            "Türevi hız göstergesi gibi düşün. Yolun kendisini değil, o anda ne kadar hızlı değiştiğini söyler. Grafikte ise o noktadaki eğimi verir.",
            "Temel kural: d/dx(xⁿ)=n·xⁿ⁻¹. Sabitin türevi 0'dır.",
            listOf(
                Example("f(x)=x² türevi", listOf("Üstteki 2'yi öne indir.", "Üssü bir azalt: x¹."), "f'(x)=2x"),
                Example("f(x)=3x³", listOf("3 sabit katsayı kalır.", "x³ türevi 3x².", "3×3x²=9x²."), "9x²")
            ),
            listOf(
                QuizQuestion("x⁴ türevi?", listOf("x³", "4x³", "4x⁴", "3x⁴"), 1, "Üs öne iner: 4x³."),
                QuizQuestion("7 sayısının türevi?", listOf("0", "1", "7", "x"), 0, "Sabit sayı değişmediği için türevi 0'dır.")
            )
        ),
        Lesson(
            "integral", "Üniversite", "İntegral", "Küçük parçaları biriktir", "∫",
            "İntegrali çok küçük parçaları toplayıp toplam alanı bulmak gibi düşün. Türevin ters yönlü akrabasıdır.",
            "∫xⁿ dx = xⁿ⁺¹/(n+1) + C, n≠-1. Belirsiz integralde +C unutulmaz.",
            listOf(
                Example("∫x dx", listOf("x = x¹.", "Üssü bir artır: x².", "Yeni üse böl: x²/2.", "+C ekle."), "x²/2 + C"),
                Example("∫3x² dx", listOf("x² → x³/3.", "Baştaki 3 ile sadeleşir."), "x³ + C")
            ),
            listOf(
                QuizQuestion("∫1 dx = ?", listOf("0", "1", "x+C", "x²"), 2, "x'in türevi 1 olduğu için ∫1 dx = x+C."),
                QuizQuestion("∫2x dx = ?", listOf("x²+C", "2x²+C", "x+C", "2+C"), 0, "x²'nin türevi 2x'tir.")
            )
        ),
        Lesson(
            "matrix", "Üniversite", "Matrisler", "Sayı tablosuyla işlem", "▦",
            "Matris, sayıları satır ve sütun halinde düzenlediğimiz bir kutudur. Fotoğraftaki piksel tablosu ya da Excel hücreleri gibi düşünebilirsin.",
            "Toplama için aynı konumdaki elemanları topla. Çarpma için satır ile sütunu eşleştir.",
            listOf(
                Example("[1 2] + [3 4]", listOf("Aynı konumdakileri topla: 1+3 ve 2+4."), "[4 6]"),
                Example("2×[1 3]", listOf("Her elemanı 2 ile çarp."), "[2 6]")
            ),
            listOf(
                QuizQuestion("[2 5]+[1 4] = ?", listOf("[3 9]", "[2 20]", "[1 1]", "[7 5]"), 0, "2+1=3 ve 5+4=9."),
                QuizQuestion("3×[2 1] = ?", listOf("[5 4]", "[6 3]", "[6 1]", "[2 3]"), 1, "Her eleman 3 ile çarpılır.")
            )
        ),
        Lesson(
            "complex", "Üniversite", "Karmaşık sayılar", "i ile yeni sayı dünyası", "i",
            "Normal sayılarda karesi -1 olan gerçek bir sayı yoktur. Matematikçiler bunun için i adında bir sayı tanımlar: i²=-1. Karmaşık sayılar a+bi şeklindedir.",
            "i²=-1, i³=-i, i⁴=1 ve döngü tekrar eder.",
            listOf(
                Example("i²", listOf("Bu i'nin tanımıdır."), "-1"),
                Example("(2+3i)+(1-2i)", listOf("Gerçek kısımları topla: 2+1=3.", "i'li kısımları topla: 3i-2i=i."), "3+i")
            ),
            listOf(
                QuizQuestion("i⁴ = ?", listOf("-1", "i", "-i", "1"), 3, "i²=-1 olduğundan i⁴=(-1)²=1."),
                QuizQuestion("(1+i)+(2+3i)=?", listOf("3+4i", "3+3i", "2+4i", "4i"), 0, "Gerçekler 1+2=3, i'ler i+3i=4i.")
            )
        )
    )
}
