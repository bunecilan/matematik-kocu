package com.matematikkocu.app

import java.util.Locale
import kotlin.math.abs
import kotlin.math.pow
import kotlin.math.sqrt
import kotlin.random.Random

object QuestionFactory {
    val tytTopics = listOf(
        "numbers", "operations", "fractions", "decimal", "percent", "negative",
        "powers", "roots", "algebra", "equations", "inequality", "ratio",
        "geometry", "functions", "probability", "statistics"
    )

    val aytTopics = listOf(
        "powers", "roots", "algebra", "equations", "inequality", "functions",
        "trigonometry", "probability", "statistics", "logarithm", "limit",
        "derivative", "integral", "matrix", "complex"
    )

    val allTopics: List<String> get() = Curriculum.lessons.map { it.id }

    fun topicsForTrack(track: StudyTrack): List<String> = when (track) {
        StudyTrack.GENERAL -> allTopics
        StudyTrack.TYT -> tytTopics
        StudyTrack.AYT -> aytTopics
    }

    fun generateSet(
        topics: List<String>,
        difficulty: Difficulty,
        count: Int,
        seed: Int = (System.currentTimeMillis() % Int.MAX_VALUE).toInt(),
        track: StudyTrack = StudyTrack.GENERAL
    ): List<PracticeQuestion> {
        if (topics.isEmpty() || count <= 0) return emptyList()
        val rng = Random(seed)
        return List(count) { index ->
            val topic = topics[rng.nextInt(topics.size)]
            generate(topic, difficulty, seed + (index + 1) * 7919, track)
        }
    }

    fun fromId(id: String): PracticeQuestion? {
        val parts = id.split('|')
        if (parts.size != 4) return null
        return runCatching {
            val track = StudyTrack.valueOf(parts[0])
            val topic = parts[1]
            val difficulty = Difficulty.valueOf(parts[2])
            val seed = parts[3].toInt()
            generate(topic, difficulty, seed, track)
        }.getOrNull()
    }

    fun generate(
        topicId: String,
        difficulty: Difficulty,
        seed: Int,
        track: StudyTrack = StudyTrack.GENERAL
    ): PracticeQuestion {
        val rng = Random(seed)
        val id = "${track.name}|$topicId|${difficulty.name}|$seed"
        return when (topicId) {
            "numbers" -> numbers(id, difficulty, rng, track)
            "operations" -> operations(id, difficulty, rng, track)
            "fractions" -> fractions(id, difficulty, rng, track)
            "decimal" -> decimals(id, difficulty, rng, track)
            "percent" -> percent(id, difficulty, rng, track)
            "negative" -> negatives(id, difficulty, rng, track)
            "powers" -> powers(id, difficulty, rng, track)
            "roots" -> roots(id, difficulty, rng, track)
            "algebra" -> algebra(id, difficulty, rng, track)
            "equations" -> equations(id, difficulty, rng, track)
            "inequality" -> inequalities(id, difficulty, rng, track)
            "ratio" -> ratios(id, difficulty, rng, track)
            "geometry" -> geometry(id, difficulty, rng, track)
            "functions" -> functions(id, difficulty, rng, track)
            "trigonometry" -> trigonometry(id, difficulty, rng, track)
            "probability" -> probability(id, difficulty, rng, track)
            "statistics" -> statistics(id, difficulty, rng, track)
            "logarithm" -> logarithm(id, difficulty, rng, track)
            "limit" -> limit(id, difficulty, rng, track)
            "derivative" -> derivative(id, difficulty, rng, track)
            "integral" -> integral(id, difficulty, rng, track)
            "matrix" -> matrix(id, difficulty, rng, track)
            "complex" -> complex(id, difficulty, rng, track)
            else -> fallback(id, topicId, difficulty, rng, track)
        }
    }

    private fun range(diff: Difficulty) = when (diff) {
        Difficulty.EASY -> 10
        Difficulty.MEDIUM -> 25
        Difficulty.HARD -> 70
    }

    private fun intQuestion(
        id: String,
        topic: String,
        prompt: String,
        answer: Int,
        explanation: String,
        difficulty: Difficulty,
        rng: Random,
        track: StudyTrack,
        hint: String = ""
    ): PracticeQuestion {
        val values = linkedSetOf(answer)
        var guard = 0
        while (values.size < 4 && guard++ < 100) {
            val delta = rng.nextInt(1, maxOf(3, abs(answer) / 3 + 4)) * if (rng.nextBoolean()) 1 else -1
            values += answer + delta
        }
        while (values.size < 4) values += answer + values.size + 1
        val options = values.map { it.toString() }.shuffled(rng)
        return PracticeQuestion(id, topic, prompt, options, options.indexOf(answer.toString()), explanation, difficulty, track, hint)
    }

    private fun textQuestion(
        id: String,
        topic: String,
        prompt: String,
        correct: String,
        distractors: List<String>,
        explanation: String,
        difficulty: Difficulty,
        rng: Random,
        track: StudyTrack,
        hint: String = ""
    ): PracticeQuestion {
        val values = linkedSetOf(correct)
        distractors.forEach { if (it != correct) values += it }
        var n = 1
        while (values.size < 4) values += "$correct ($n)".also { n++ }
        val options = values.take(4).shuffled(rng)
        return PracticeQuestion(id, topic, prompt, options, options.indexOf(correct), explanation, difficulty, track, hint)
    }

    private fun numbers(id: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        val m = range(d)
        val nums = List(4) { r.nextInt(-m, m + 1) }.distinct().toMutableList()
        while (nums.size < 4) nums += r.nextInt(-m, m + 1)
        val unique = nums.distinct().take(4)
        val answer = unique.max()
        return textQuestion(id, "numbers", "Aşağıdaki sayılardan hangisi en büyüktür?", answer.toString(), unique.filter { it != answer }.map { it.toString() },
            "Sayı doğrusunda en sağda olan sayı en büyüktür. Bu nedenle cevap $answer.", d, r, t,
            "Negatif sayılarda sıfıra daha yakın olan sayı daha büyüktür.")
    }

    private fun operations(id: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        val m = range(d)
        return if (d == Difficulty.EASY || r.nextBoolean()) {
            val a = r.nextInt(2, m + 3)
            val b = r.nextInt(2, m + 3)
            val op = r.nextInt(3)
            when (op) {
                0 -> intQuestion(id, "operations", "$a + $b = ?", a + b, "$a ile $b'yi toplarsak ${a+b} olur.", d, r, t)
                1 -> intQuestion(id, "operations", "$a × $b = ?", a * b, "$a sayısını $b kez toplamak $a × $b = ${a*b} sonucunu verir.", d, r, t)
                else -> {
                    val big = a * b
                    intQuestion(id, "operations", "$big ÷ $a = ?", b, "$big sayısını $a eşit gruba bölersek her grupta $b olur.", d, r, t)
                }
            }
        } else {
            val a = r.nextInt(1, 15)
            val b = r.nextInt(2, 10)
            val c = r.nextInt(2, 10)
            intQuestion(id, "operations", "$a + $b × $c = ?", a + b * c,
                "İşlem önceliği nedeniyle önce $b × $c = ${b*c}; sonra $a + ${b*c} = ${a+b*c}.", d, r, t,
                "Önce çarpma-bölme, sonra toplama-çıkarma.")
        }
    }

    private fun fractions(id: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        val den = when (d) { Difficulty.EASY -> r.nextInt(2, 7); Difficulty.MEDIUM -> r.nextInt(3, 10); Difficulty.HARD -> r.nextInt(5, 13) }
        val a = r.nextInt(1, den)
        val b = r.nextInt(1, den)
        val num = a + b
        val g = gcd(num, den)
        val correct = if (g > 1) "${num/g}/${den/g}" else "$num/$den"
        val raw = "$num/$den"
        val distractors = listOf("${a+b}/${den+den}", "${a*b}/$den", "${abs(a-b)}/$den", raw).distinct().filter { it != correct }
        return textQuestion(id, "fractions", "$a/$den + $b/$den = ?", correct, distractors,
            "Paydalar aynı olduğu için payları toplarız: $a + $b = $num. Sonuç $raw${if (raw != correct) ", sadeleşince $correct" else ""}.", d, r, t,
            "Paydalar aynıysa alt tarafı değiştirme; sadece üstleri topla.")
    }

    private fun decimals(id: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        val scale = if (d == Difficulty.EASY) 10 else 100
        val a = r.nextInt(1, scale * 2)
        val b = r.nextInt(1, scale)
        val ans = a + b
        fun f(v: Int) = String.format(Locale.US, if (scale == 10) "%.1f" else "%.2f", v.toDouble()/scale).replace('.', ',')
        val correct = f(ans)
        val distractors = listOf(f(abs(a-b)), f(ans+1), f(ans+10), f(a*b/scale)).distinct()
        return textQuestion(id, "decimal", "${f(a)} + ${f(b)} = ?", correct, distractors,
            "Virgülleri alt alta düşün. ${f(a)} + ${f(b)} = $correct.", d, r, t,
            "Virgülleri aynı hizaya getir.")
    }

    private fun percent(id: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        val percents = when (d) {
            Difficulty.EASY -> listOf(10, 25, 50)
            Difficulty.MEDIUM -> listOf(5, 10, 20, 25, 40, 50)
            Difficulty.HARD -> listOf(12, 15, 18, 24, 35)
        }
        val p = percents.random(r)
        val baseUnit = if (100 % p == 0) 100 / gcd(100, p) else 100
        val k = r.nextInt(1, 10)
        val n = baseUnit * k
        val answer = n * p / 100
        return intQuestion(id, "percent", "$n sayısının %$p'i kaçtır?", answer,
            "%$p = $p/100. $n × $p ÷ 100 = $answer.", d, r, t,
            "Yüzde demek 100'de demektir: sayı × yüzde ÷ 100.")
    }

    private fun negatives(id: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        val m = range(d)
        val a = r.nextInt(-m, m + 1)
        val b = r.nextInt(-m, m + 1)
        val minus = d != Difficulty.EASY && r.nextBoolean()
        val answer = if (minus) a - b else a + b
        val sign = if (minus) "−" else "+"
        val exp = if (minus) "$a − ($b) = $answer. Negatif bir sayıyı çıkarmanın işareti dikkat ister." else "$a + ($b) = $answer. Sayı doğrusunda hareket ederek de kontrol edebilirsin."
        return intQuestion(id, "negative", "$a $sign ($b) = ?", answer, exp, d, r, t,
            "Borç-alacak mantığıyla düşün veya sayı doğrusunu kullan.")
    }

    private fun powers(id: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        val base = when(d) { Difficulty.EASY -> r.nextInt(2,6); Difficulty.MEDIUM -> r.nextInt(2,7); Difficulty.HARD -> r.nextInt(2,6) }
        return if (d == Difficulty.HARD && r.nextBoolean()) {
            val p1 = r.nextInt(2,5); val p2 = r.nextInt(2,5); val resultP = p1 + p2
            val correct = "$base^$resultP"
            textQuestion(id, "powers", "$base^$p1 × $base^$p2 = ?", correct,
                listOf("$base^${p1*p2}", "${base*2}^$resultP", "$base^${abs(p1-p2)}"),
                "Tabanlar aynıysa çarpmada üsler toplanır: $p1 + $p2 = $resultP.", d, r, t,
                "Aynı taban × aynı taban → üsleri topla.")
        } else {
            val exp = when(d) { Difficulty.EASY -> r.nextInt(2,4); Difficulty.MEDIUM -> r.nextInt(2,5); Difficulty.HARD -> r.nextInt(3,6) }
            val answer = base.toDouble().pow(exp).toInt()
            intQuestion(id, "powers", "$base^$exp = ?", answer,
                "$base^$exp, $base sayısını $exp kez çarpmaktır. Sonuç $answer.", d, r, t,
                "Üs, tabanı kaç kez kendisiyle çarpacağını söyler.")
        }
    }

    private fun roots(id: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        val root = when(d) { Difficulty.EASY -> r.nextInt(2,11); Difficulty.MEDIUM -> r.nextInt(4,16); Difficulty.HARD -> r.nextInt(8,26) }
        val square = root * root
        return intQuestion(id, "roots", "√$square = ?", root,
            "$root × $root = $square olduğu için √$square = $root.", d, r, t,
            "Kendisiyle çarpılınca kökün içindeki sayıyı veren sayıyı ara.")
    }

    private fun algebra(id: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        val x = r.nextInt(1, range(d)/2 + 5)
        val add = r.nextInt(1, 12)
        val total = x + add
        return intQuestion(id, "algebra", "x + $add = $total ise x kaçtır?", x,
            "x'i yalnız bırakmak için iki taraftan $add çıkar: x = $total − $add = $x.", d, r, t,
            "x'i gizli kutu gibi düşün.")
    }

    private fun equations(id: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        val x = r.nextInt(1, 14)
        val a = when(d) { Difficulty.EASY -> r.nextInt(2,5); Difficulty.MEDIUM -> r.nextInt(2,8); Difficulty.HARD -> r.nextInt(3,10) }
        val b = r.nextInt(1, 15)
        val c = a*x + b
        return intQuestion(id, "equations", "$a x + $b = $c ise x kaçtır?", x,
            "Önce $b çıkar: ${a}x = ${c-b}. Sonra $a'ya böl: x = $x.", d, r, t,
            "Önce x'in yanındaki ekleme/çıkarma işlemini kaldır, sonra katsayıya böl.")
    }

    private fun inequalities(id: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        val bound = r.nextInt(1, 15)
        val add = r.nextInt(1, 9)
        val rhs = bound + add
        val correct = "x > $bound"
        return textQuestion(id, "inequality", "x + $add > $rhs ise aşağıdakilerden hangisi doğrudur?", correct,
            listOf("x < $bound", "x ≥ $rhs", "x < ${rhs+add}"),
            "İki taraftan da $add çıkar: x > ${rhs-add}, yani $correct.", d, r, t,
            "Denklem gibi çöz; ama eşitsizlik işaretini koru.")
    }

    private fun ratios(id: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        val a = r.nextInt(2, 8)
        val b = r.nextInt(2, 8)
        val k = r.nextInt(2, if (d == Difficulty.HARD) 14 else 8)
        val c = a*k
        val answer = b*k
        return intQuestion(id, "ratio", "$a / $b = $c / x ise x kaçtır?", answer,
            "İlk oran $k kat büyümüş: $a × $k = $c. O halde $b × $k = $answer, yani x=$answer.", d, r, t,
            "İki oranda da aynı büyütme/küçültme katsayısını ara.")
    }

    private fun geometry(id: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        return if (r.nextBoolean()) {
            val a = r.nextInt(2, 15); val b = r.nextInt(2, 15)
            intQuestion(id, "geometry", "Kenarları $a cm ve $b cm olan dikdörtgenin alanı kaç cm²?", a*b,
                "Dikdörtgen alanı = kısa kenar × uzun kenar = $a × $b = ${a*b} cm².", d, r, t,
                "Alan için iki kenarı çarp.")
        } else {
            val a = r.nextInt(3, 15); val b = r.nextInt(3, 15)
            intQuestion(id, "geometry", "Kenarları $a cm ve $b cm olan dikdörtgenin çevresi kaç cm?", 2*(a+b),
                "Çevre bütün kenarların toplamıdır: 2×($a+$b) = ${2*(a+b)} cm.", d, r, t,
                "Çevre şeklin etrafında yürüdüğün toplam yol gibidir.")
        }
    }

    private fun functions(id: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        val a = when(d) { Difficulty.EASY -> r.nextInt(1,5); Difficulty.MEDIUM -> r.nextInt(-5,7).let { if(it==0) 2 else it }; Difficulty.HARD -> r.nextInt(-9,10).let { if(it==0) 3 else it } }
        val b = r.nextInt(-8, 9)
        val x = r.nextInt(-5, 7)
        val answer = a*x+b
        return intQuestion(id, "functions", "f(x) = ${a}x ${if(b>=0) "+ $b" else "− ${abs(b)}"}. f($x) kaçtır?", answer,
            "Fonksiyonda x gördüğün yere $x yaz: $a×($x) ${if(b>=0) "+ $b" else "− ${abs(b)}"} = $answer.", d, r, t,
            "Fonksiyon bir makine gibi: x'i içeri koy, formülü uygula.")
    }

    private fun trigonometry(id: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        val bank = listOf(
            Triple("sin 30°", "1/2", listOf("√3/2", "1", "0")),
            Triple("cos 60°", "1/2", listOf("√3/2", "1", "0")),
            Triple("sin 90°", "1", listOf("0", "1/2", "√3/2")),
            Triple("cos 0°", "1", listOf("0", "1/2", "√2/2")),
            Triple("tan 45°", "1", listOf("0", "1/2", "√3"))
        )
        val q = bank.random(r)
        return textQuestion(id, "trigonometry", "${q.first} = ?", q.second, q.third,
            "Özel açı değerlerinden ${q.first} = ${q.second}.", d, r, t,
            "30°-45°-60° özel açı değerlerini küçük bir tablo halinde ezberlemek işini hızlandırır.")
    }

    private fun probability(id: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        val red = r.nextInt(1, 7); val blue = r.nextInt(1, 7); val total = red+blue
        val g = gcd(red,total)
        val correct = "${red/g}/${total/g}"
        return textQuestion(id, "probability", "Bir torbada $red kırmızı ve $blue mavi bilye var. Rastgele bir bilyenin kırmızı olma olasılığı?", correct,
            listOf("$blue/$total", "$red/$blue", "1/$total", "$total/$red"),
            "İstenen durum sayısı $red, toplam durum sayısı $total. Olasılık = $red/$total${if(g>1) " = $correct" else ""}.", d, r, t,
            "Olasılık = istediğin durum sayısı ÷ bütün mümkün durumlar.")
    }

    private fun statistics(id: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        val count = if (d == Difficulty.HARD) 5 else 4
        val avg = r.nextInt(3, 16)
        val offsets = if (count == 4) listOf(-2,-1,1,2) else listOf(-4,-2,0,2,4)
        val nums = offsets.map { avg + it }
        return intQuestion(id, "statistics", "${nums.joinToString(", ")} sayılarının aritmetik ortalaması kaçtır?", avg,
            "Sayıları topla ve adetlerine böl. Bu sayıların toplamı ${avg*count}; ${avg*count} ÷ $count = $avg.", d, r, t,
            "Ortalama = toplam ÷ kaç tane sayı olduğu.")
    }

    private fun logarithm(id: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        val base = listOf(2,3,5,10).random(r)
        val exp = when(d) { Difficulty.EASY -> r.nextInt(1,4); Difficulty.MEDIUM -> r.nextInt(2,5); Difficulty.HARD -> r.nextInt(2,6) }
        val value = base.toDouble().pow(exp).toInt()
        return intQuestion(id, "logarithm", "log_$base($value) = ?", exp,
            "Logaritma 'kaçıncı kuvvet?' diye sorar. $base^$exp = $value olduğu için cevap $exp.", d, r, t,
            "logₐ(b)=c demek a^c=b demektir.")
    }

    private fun limit(id: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        val a = r.nextInt(1,6); val b = r.nextInt(-6,7); val x = r.nextInt(-4,6)
        val answer = a*x+b
        return intQuestion(id, "limit", "lim x→$x  (${a}x ${if(b>=0) "+ $b" else "− ${abs(b)}"}) = ?", answer,
            "Bu fonksiyon x=$x noktasında süreklidir; doğrudan yerine yazabiliriz: $a×$x ${if(b>=0) "+ $b" else "− ${abs(b)}"} = $answer.", d, r, t,
            "Basit polinomlarda önce x yerine yaklaşım değerini yazmayı dene.")
    }

    private fun derivative(id: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        val n = when(d) { Difficulty.EASY -> r.nextInt(2,5); Difficulty.MEDIUM -> r.nextInt(2,7); Difficulty.HARD -> r.nextInt(3,9) }
        val k = r.nextInt(1,7)
        val coef = k*n
        val correct = if (n-1 == 1) "${coef}x" else "$coef x^${n-1}"
        return textQuestion(id, "derivative", "f(x) = $k x^$n ise f'(x) nedir?", correct,
            listOf("$k x^${n-1}", "${k+n}x^${n-1}", "${coef}x^$n"),
            "Kuvveti öne çarpan olarak indir ve kuvveti 1 azalt: $k×$n x^${n-1} = $correct.", d, r, t,
            "x^n türevi n·x^(n−1). Önündeki katsayı da kalır.")
    }

    private fun integral(id: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        val n = when(d) { Difficulty.EASY -> 1; Difficulty.MEDIUM -> r.nextInt(1,4); Difficulty.HARD -> r.nextInt(2,5) }
        val mult = r.nextInt(1,6)
        val k = mult*(n+1)
        val correct = if (n+1 == 2) "${mult}x² + C" else "${mult}x^${n+1} + C"
        return textQuestion(id, "integral", "∫ $k x^$n dx = ?", correct,
            listOf("${k*n}x^${maxOf(1,n-1)} + C", "$k x^${n+1} + C", "${mult}x^$n + C"),
            "Kuvveti 1 artır: ${n+1}. Sonra yeni kuvvete böl: $k ÷ ${n+1} = $mult. Sonuç $correct.", d, r, t,
            "İntegralde kuvveti 1 artır, sonra yeni kuvvete böl; +C'yi unutma.")
    }

    private fun matrix(id: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        val a = r.nextInt(-8,9); val b = r.nextInt(-8,9)
        return intQuestion(id, "matrix", "A matrisinin (1,1) elemanı $a, B matrisinin (1,1) elemanı $b ise (A+B)'nin (1,1) elemanı kaçtır?", a+b,
            "Matris toplamada aynı konumdaki elemanlar toplanır: $a + ($b) = ${a+b}.", d, r, t,
            "Aynı satır ve sütundaki kutuları birbiriyle topla.")
    }

    private fun complex(id: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        val n = r.nextInt(2, if(d == Difficulty.HARD) 30 else 14)
        val cycle = when(n % 4) { 0 -> "1"; 1 -> "i"; 2 -> "−1"; else -> "−i" }
        return textQuestion(id, "complex", "i^$n = ?", cycle,
            listOf("1", "−1", "i", "−i").filter { it != cycle },
            "i'nin kuvvetleri 4'lü döngü yapar: i, −1, −i, 1. $n mod 4 = ${n%4}; sonuç $cycle.", d, r, t,
            "Kuvveti 4'e böl; kalana göre i, −1, −i, 1 döngüsünü kullan.")
    }

    private fun fallback(id: String, topic: String, d: Difficulty, r: Random, t: StudyTrack): PracticeQuestion {
        val lesson = Curriculum.lessons.firstOrNull { it.id == topic }
        val q = lesson?.quiz?.random(r)
        return if (q != null) {
            PracticeQuestion(id, topic, q.question, q.options, q.correct, q.explanation, d, t, lesson.rule)
        } else {
            textQuestion(id, topic, "2 + 2 = ?", "4", listOf("2","3","5"), "2 ile 2'nin toplamı 4'tür.", d, r, t)
        }
    }

    private fun gcd(a0: Int, b0: Int): Int {
        var a = abs(a0); var b = abs(b0)
        while (b != 0) { val t = a % b; a = b; b = t }
        return if (a == 0) 1 else a
    }
}
