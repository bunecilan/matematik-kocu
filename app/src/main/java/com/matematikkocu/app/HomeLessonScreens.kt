package com.matematikkocu.app

import android.speech.tts.TextToSpeech
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import java.util.Locale

@Composable
fun HomeScreenV2(
    state: UserUiState,
    onContinue: () -> Unit,
    onTopics: () -> Unit,
    onSmartReview: () -> Unit,
    onQuestionBank: () -> Unit,
    onExam: () -> Unit,
    onWrong: () -> Unit,
    onFavorites: () -> Unit,
    onTools: () -> Unit,
    onProgress: () -> Unit
) {
    val total = Curriculum.lessons.size
    LazyColumn(
        modifier = Modifier.fillMaxSize()
            .background(Brush.verticalGradient(listOf(Color(0xFF17122F), Color(0xFF0B0918))))
            .padding(horizontal = 18.dp),
        verticalArrangement = Arrangement.spacedBy(13.dp)
    ) {
        item {
            Spacer(Modifier.height(18.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Column(Modifier.weight(1f)) {
                    Text("Matematik Koçu", fontSize = 31.sp, fontWeight = FontWeight.ExtraBold)
                    Text("Anlamadan ezber yok.", color = AppTextSoft, fontSize = 16.sp)
                }
                Surface(color = Color(0xFF33245D), shape = RoundedCornerShape(18.dp)) {
                    Column(Modifier.padding(horizontal=14.dp, vertical=9.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                        Text("🔥 ${state.streak}", fontSize = 20.sp, fontWeight = FontWeight.ExtraBold)
                        Text("gün seri", color = AppTextSoft, fontSize = 11.sp)
                    }
                }
            }
        }
        item {
            Card(colors = CardDefaults.cardColors(containerColor = AppCard2), shape = RoundedCornerShape(25.dp)) {
                Column(Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(11.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Surface(shape = RoundedCornerShape(14.dp), color = AppMint.copy(alpha=.15f)) {
                            Icon(Icons.Default.School, null, tint=AppMint, modifier=Modifier.padding(11.dp))
                        }
                        Spacer(Modifier.width(12.dp))
                        Column {
                            Text("Bugünkü görev", fontWeight = FontWeight.ExtraBold, fontSize = 20.sp)
                            Text("1 konu öğren • 10 soru çöz • yanlışını tekrar et", color = AppTextSoft, fontSize = 13.sp)
                        }
                    }
                    LinearProgressIndicator(
                        progress = { if(total == 0) 0f else state.completed.size.toFloat()/total },
                        modifier = Modifier.fillMaxWidth().height(10.dp).clip(RoundedCornerShape(99.dp)),
                        color = AppMint, trackColor = Color.White.copy(alpha=.08f)
                    )
                    Text("${state.completed.size}/$total konu  •  ${state.xp} XP  •  %${state.accuracy} doğruluk", color=Color(0xFFD8D1F2), fontSize=13.sp)
                    Button(onClick=onContinue, modifier=Modifier.fillMaxWidth().height(52.dp), shape=RoundedCornerShape(16.dp)) {
                        Icon(Icons.Default.PlayArrow, null); Spacer(Modifier.width(7.dp)); Text("Derse devam et", fontWeight=FontWeight.Bold)
                    }
                }
            }
        }
        item {
            if (state.weakTopics.isNotEmpty()) {
                val weakNames = state.weakTopics.take(2).mapNotNull { id -> Curriculum.lessons.firstOrNull { it.id == id }?.title }
                Card(colors=CardDefaults.cardColors(containerColor=Color(0xFF3B2039)), shape=RoundedCornerShape(20.dp), modifier=Modifier.fillMaxWidth().clickable{onSmartReview()}) {
                    Row(Modifier.padding(16.dp), verticalAlignment=Alignment.CenterVertically) {
                        Text("🧠", fontSize=28.sp); Spacer(Modifier.width(12.dp))
                        Column(Modifier.weight(1f)) {
                            Text("Akıllı tekrar hazır", fontWeight=FontWeight.Bold, fontSize=17.sp)
                            Text("Zayıf görünen: ${weakNames.joinToString(", ")}", color=Color(0xFFEACCDD), fontSize=13.sp)
                        }
                        Icon(Icons.Default.ChevronRight, null)
                    }
                }
            }
        }
        item { Text("Çalışma alanın", fontWeight=FontWeight.ExtraBold, fontSize=21.sp) }
        item {
            Row(horizontalArrangement=Arrangement.spacedBy(10.dp)) {
                FeatureCard("Konular", "Konu seç", "📚", Modifier.weight(1f), onTopics)
                FeatureCard("Soru Bankası", "1000+ varyasyon", "🎯", Modifier.weight(1f), onQuestionBank)
            }
        }
        item {
            Row(horizontalArrangement=Arrangement.spacedBy(10.dp)) {
                FeatureCard("TYT / AYT", "Süreli sınav", "⏱️", Modifier.weight(1f), onExam)
                FeatureCard("Akıllı Tekrar", "Zayıf konular", "🧠", Modifier.weight(1f), onSmartReview)
            }
        }
        item {
            Row(horizontalArrangement=Arrangement.spacedBy(10.dp)) {
                FeatureCard("Yanlışlar", "${state.wrongIds.size} soru", "📕", Modifier.weight(1f), onWrong)
                FeatureCard("Favoriler", "${state.favorites.size} soru", "⭐", Modifier.weight(1f), onFavorites)
            }
        }
        item { WideFeatureCard("Görsel Matematik Araçları", "Grafik laboratuvarı • hareketli geometri • karalama ve hesap", Icons.Default.AutoGraph, onTools) }
        item { WideFeatureCard("İlerleme & Rozetler", "Seri, XP, doğruluk, başarı rozetleri", Icons.Default.EmojiEvents, onProgress) }
        item {
            Card(colors=CardDefaults.cardColors(containerColor=Color(0xFF19152E)), shape=RoundedCornerShape(20.dp)) {
                Column(Modifier.padding(16.dp)) {
                    Text("💡 Nasıl öğretiyorum?", fontWeight=FontWeight.Bold)
                    Spacer(Modifier.height(6.dp))
                    Text("Günlük hayattan benzetme → tek kural → adım adım örnek → test → yanlışın nedenini açıklama → zayıf konuyu otomatik tekrar.", color=AppTextSoft, lineHeight=21.sp)
                }
            }
        }
        item { Spacer(Modifier.height(22.dp)) }
    }
}

@Composable
private fun FeatureCard(title:String, subtitle:String, emoji:String, modifier:Modifier, onClick:()->Unit) {
    Card(modifier=modifier.height(118.dp).clickable{onClick()}, colors=CardDefaults.cardColors(containerColor=AppCard), shape=RoundedCornerShape(20.dp)) {
        Column(Modifier.fillMaxSize().padding(15.dp), verticalArrangement=Arrangement.SpaceBetween) {
            Text(emoji, fontSize=26.sp)
            Column { Text(title, fontWeight=FontWeight.Bold, fontSize=16.sp); Text(subtitle, color=AppTextSoft, fontSize=12.sp) }
        }
    }
}

@Composable
private fun WideFeatureCard(title:String, subtitle:String, icon:ImageVector, onClick:()->Unit) {
    Card(modifier=Modifier.fillMaxWidth().clickable{onClick()}, colors=CardDefaults.cardColors(containerColor=AppCard), shape=RoundedCornerShape(20.dp)) {
        Row(Modifier.padding(17.dp), verticalAlignment=Alignment.CenterVertically) {
            Surface(color=AppPurple.copy(alpha=.18f), shape=RoundedCornerShape(15.dp)) { Icon(icon,null,tint=Color(0xFFBCA9FF),modifier=Modifier.padding(12.dp)) }
            Spacer(Modifier.width(13.dp)); Column(Modifier.weight(1f)) { Text(title,fontWeight=FontWeight.Bold,fontSize=17.sp); Text(subtitle,color=AppTextSoft,fontSize=13.sp) }
            Icon(Icons.Default.ChevronRight,null,tint=Color(0xFF8D85A8))
        }
    }
}

@Composable
fun TopicsScreenV2(completed:Set<String>, onBack:()->Unit, onLesson:(Lesson)->Unit) {
    var query by remember { mutableStateOf("") }
    var level by remember { mutableStateOf("Tümü") }
    val levels = listOf("Tümü","Başlangıç","Temel","Orta","İleri","Üniversite")
    val shown = Curriculum.lessons.filter { (level=="Tümü" || it.level==level) && (query.isBlank() || it.title.contains(query,true) || it.subtitle.contains(query,true)) }
    Column(Modifier.fillMaxSize().padding(18.dp)) {
        AppHeader("Konular", "Sıfırdan ileri seviyeye konu konu ilerle.", onBack)
        OutlinedTextField(query,{query=it},modifier=Modifier.fillMaxWidth(),singleLine=true,label={Text("Konu ara")},leadingIcon={Icon(Icons.Default.Search,null)},shape=RoundedCornerShape(16.dp))
        Spacer(Modifier.height(8.dp))
        LazyRow(horizontalArrangement=Arrangement.spacedBy(8.dp)) { items(levels){ item -> FilterChip(selected=level==item,onClick={level=item},label={Text(item)}) } }
        Spacer(Modifier.height(8.dp))
        LazyColumn(verticalArrangement=Arrangement.spacedBy(9.dp)) {
            items(shown) { lesson ->
                Card(modifier=Modifier.fillMaxWidth().clickable{onLesson(lesson)},colors=CardDefaults.cardColors(containerColor=AppCard),shape=RoundedCornerShape(18.dp)) {
                    Row(Modifier.padding(15.dp),verticalAlignment=Alignment.CenterVertically) {
                        Text(lesson.icon,fontSize=29.sp); Spacer(Modifier.width(12.dp))
                        Column(Modifier.weight(1f)){ Text(lesson.title,fontWeight=FontWeight.Bold,fontSize=16.sp); Text("${lesson.level} • ${lesson.subtitle}",color=AppTextSoft,fontSize=12.sp) }
                        if(lesson.id in completed) Icon(Icons.Default.CheckCircle,"Tamamlandı",tint=AppMint) else Icon(Icons.Default.ChevronRight,null)
                    }
                }
            }
            item{Spacer(Modifier.height(22.dp))}
        }
    }
}

@Composable
fun LessonScreenV2(lesson:Lesson, onBack:()->Unit, onStartQuiz:()->Unit) {
    val context = LocalContext.current
    val ttsState = remember { mutableStateOf<TextToSpeech?>(null) }
    var extraSimple by remember { mutableStateOf(false) }
    DisposableEffect(context) {
        var engine: TextToSpeech? = null
        engine = TextToSpeech(context) { status ->
            if (status == TextToSpeech.SUCCESS) engine?.language = Locale("tr", "TR")
        }
        ttsState.value = engine
        onDispose { engine?.stop(); engine?.shutdown(); ttsState.value=null }
    }

    LazyColumn(Modifier.fillMaxSize().padding(18.dp),verticalArrangement=Arrangement.spacedBy(13.dp)) {
        item { AppHeader(lesson.title, "${lesson.level} • ${lesson.subtitle}", onBack) }
        item {
            Row(horizontalArrangement=Arrangement.spacedBy(8.dp)) {
                OutlinedButton(onClick={ttsState.value?.speak("${lesson.title}. ${lesson.simpleExplanation}. ${lesson.rule}",TextToSpeech.QUEUE_FLUSH,null,"lesson")},modifier=Modifier.weight(1f)) {
                    Icon(Icons.Default.VolumeUp,null);Spacer(Modifier.width(6.dp));Text("Sesli anlat")
                }
                OutlinedButton(onClick={extraSimple=!extraSimple},modifier=Modifier.weight(1f)) {
                    Icon(Icons.Default.ChildCare,null);Spacer(Modifier.width(6.dp));Text("Daha basit")
                }
            }
        }
        item { InfoBlock("👶 En basit anlatımı",lesson.simpleExplanation,Color(0xFF2B2053)) }
        item {
            AnimatedVisibility(extraSimple) { InfoBlock("🍼 Daha da basit anlat",ultraSimple(lesson.id),Color(0xFF442B55)) }
        }
        item { InfoBlock("📌 Tek kural",lesson.rule,Color(0xFF173C39)) }
        item { Text("Adım adım çözümlü örnekler",fontWeight=FontWeight.ExtraBold,fontSize=20.sp) }
        items(lesson.examples) { ex -> ExampleBlock(ex) }
        item {
            Button(onClick=onStartQuiz,modifier=Modifier.fillMaxWidth().height(56.dp),shape=RoundedCornerShape(16.dp)) {
                Icon(Icons.Default.Quiz,null);Spacer(Modifier.width(8.dp));Text("Bu konudan adaptif test çöz",fontWeight=FontWeight.Bold)
            }
        }
        item { Spacer(Modifier.height(25.dp)) }
    }
}

@Composable
internal fun InfoBlock(title:String,text:String,color:Color) {
    Card(colors=CardDefaults.cardColors(containerColor=color),shape=RoundedCornerShape(20.dp)) {
        Column(Modifier.padding(17.dp)){Text(title,fontWeight=FontWeight.Bold,fontSize=18.sp);Spacer(Modifier.height(7.dp));Text(text,color=Color(0xFFE7E2F4),lineHeight=22.sp)}
    }
}

@Composable
private fun ExampleBlock(ex:Example) {
    var open by remember { mutableStateOf(false) }
    Card(colors=CardDefaults.cardColors(containerColor=AppCard),shape=RoundedCornerShape(18.dp)) {
        Column(Modifier.padding(16.dp)) {
            Text(ex.question,fontWeight=FontWeight.Bold,fontSize=17.sp);Spacer(Modifier.height(8.dp))
            OutlinedButton(onClick={open=!open}) { Text(if(open)"Çözümü gizle" else "Adım adım çöz") }
            AnimatedVisibility(open) {
                Column(Modifier.padding(top=10.dp),verticalArrangement=Arrangement.spacedBy(6.dp)) {
                    ex.steps.forEachIndexed { i,s -> Text("${i+1}. $s",color=Color(0xFFD4CCE9)) }
                    Text("Cevap: ${ex.answer}",color=AppMint,fontWeight=FontWeight.Bold)
                }
            }
        }
    }
}

@Composable
fun ToolHubScreen(onBack:()->Unit,onGraph:()->Unit,onGeometry:()->Unit,onScratch:()->Unit) {
    Column(Modifier.fillMaxSize().padding(18.dp)) {
        AppHeader("Matematik Laboratuvarı", "Görerek ve çizerek öğren.", onBack)
        Spacer(Modifier.height(8.dp))
        WideFeatureCard("Fonksiyon Grafik Laboratuvarı","y=ax+b ve parabolü canlı değiştir",Icons.Default.AutoGraph,onGraph)
        Spacer(Modifier.height(10.dp))
        WideFeatureCard("Hareketli Geometri","Üçgen, dikdörtgen ve daireyi formülle bağla",Icons.Default.ChangeHistory,onGeometry)
        Spacer(Modifier.height(10.dp))
        WideFeatureCard("Karalama & Hesap","Parmakla işlem yap, hızlı hesap makinesini kullan",Icons.Default.Draw,onScratch)
    }
}

@Composable
fun ProgressScreenV2(state:UserUiState,onBack:()->Unit) {
    LazyColumn(Modifier.fillMaxSize().padding(18.dp),verticalArrangement=Arrangement.spacedBy(12.dp)) {
        item{AppHeader("İlerleme & Rozetler","Çalıştıkça burada büyüdüğünü gör.",onBack)}
        item {
            Card(colors=CardDefaults.cardColors(containerColor=AppCard2),shape=RoundedCornerShape(22.dp)) {
                Column(Modifier.padding(18.dp),verticalArrangement=Arrangement.spacedBy(8.dp)) {
                    Text("${state.xp} XP",fontSize=31.sp,fontWeight=FontWeight.ExtraBold,color=AppMint)
                    Text("🔥 ${state.streak} günlük seri  •  Rekor ${state.longestStreak} gün",color=AppTextSoft)
                    Text("${state.attempts} soru  •  %${state.accuracy} doğruluk  •  ${state.completed.size}/${Curriculum.lessons.size} konu",color=Color(0xFFDCD5F2))
                    LinearProgressIndicator(progress={state.completed.size.toFloat()/Curriculum.lessons.size.coerceAtLeast(1)},modifier=Modifier.fillMaxWidth().height(9.dp).clip(RoundedCornerShape(99.dp)),color=AppMint)
                }
            }
        }
        item{Text("Başarı rozetleri",fontWeight=FontWeight.ExtraBold,fontSize=21.sp)}
        items(state.badges) { badge ->
            Card(colors=CardDefaults.cardColors(containerColor=if(badge.unlocked) Color(0xFF263B37) else AppCard),shape=RoundedCornerShape(17.dp)) {
                Row(Modifier.padding(15.dp),verticalAlignment=Alignment.CenterVertically) {
                    Text(if(badge.unlocked) badge.icon else "🔒",fontSize=28.sp);Spacer(Modifier.width(12.dp))
                    Column{Text(badge.title,fontWeight=FontWeight.Bold);Text(badge.description,color=AppTextSoft,fontSize=13.sp)}
                }
            }
        }
        item{Spacer(Modifier.height(20.dp))}
    }
}

private fun ultraSimple(id:String):String = when(id) {
    "numbers" -> "Sayıları bir yolun üzerindeki evler gibi düşün. Sağdaki ev daha büyük numaralıdır. -3 solda, +2 sağda olduğu için +2 daha büyüktür."
    "operations" -> "Toplama: cebine eklemek. Çıkarma: cebinden vermek. Çarpma: aynı şeyi birkaç kez toplamak. Bölme: eşit paylaşmak."
    "fractions" -> "Bir pizzayı 4 eşit dilime böldün ve 3 dilim aldın: 3/4. Alttaki 4 bütün pizzanın kaç dilim olduğunu, üstteki 3 senin kaç dilim aldığını söyler."
    "decimal" -> "1,5 demek 1 tane tam şey ve bir tamın yarısı demek. Virgülün solu tamlar, sağı küçük parçalar."
    "percent" -> "%20 demek 100 tane şey varsa 20 tanesi demek. %50 yarım, %25 çeyrek gibi düşün."
    "negative" -> "Artı paran, eksi borcun gibi. +5 cebinde 5 TL; -5 ise 5 TL borç gibi."
    "powers" -> "2³ sadece 2×2×2 demek. Küçük üst sayı sana kaç tane 2 çarpacağını söylüyor."
    "roots" -> "√25 görünce 'hangi sayı kendisiyle çarpılınca 25 oluyor?' de. 5×5=25; cevap 5."
    "algebra","equations" -> "x kapalı bir kutu. Kutunun içindeki sayıyı bulmaya çalışıyoruz. Terazinin iki tarafına aynı şeyi yaparsan denge bozulmaz."
    "inequality" -> "İki sayı eşit olmak zorunda değil. Timsahın ağzı gibi düşün: açık taraf büyük sayıya bakar."
    "ratio" -> "2 kişiye 4 ekmek düşüyorsa 4 kişiye aynı düzende 8 ekmek düşer. Oran aynı büyütme tarifidir."
    "geometry" -> "Alan şeklin içini boyamak için gereken yer; çevre ise şeklin etrafında yürüdüğün yol."
    "functions" -> "Fonksiyon meyve sıkacağı gibi. İçine x koyuyorsun, makine kuralını uygulayıp sana y çıkarıyor."
    "trigonometry" -> "Dik üçgende açı değişince kenarların birbirine göre boyu değişir. sin, cos ve tan bu oranlara verilen kısa isimlerdir."
    "probability" -> "Torbadaki 10 bilyenin 2'si kırmızıysa gözün kapalı kırmızı çekme şansın 2/10."
    "statistics" -> "Ortalama için herkeste ne varsa bir havuza koyup eşit paylaştırdığını düşün. Topla, kişi sayısına böl."
    "logarithm" -> "Logaritma, üs işlemini tersinden sorar: '2'yi kaç kere kendisiyle çarparsam 8 olur?' Cevap 3."
    "limit" -> "Bir kapıya doğru yürüyorsun ama kapıya değmeden sürekli yaklaşıyorsun. Limit, yaklaştığın değeri sorar."
    "derivative" -> "Arabanın o anda kaç km/s hızla gittiğini düşün. Türev, bir şeyin o anda ne kadar hızlı değiştiğini ölçer."
    "integral" -> "Bir sürü küçücük parçayı biriktirip toplam alanı bulmak gibi. İntegral küçük parçaları toplar."
    "matrix" -> "Matris sadece sayıların kutular içinde düzenli bir tabloya konmuş halidir. Aynı kutuları eşleştirerek işlem yaparsın."
    "complex" -> "Normal sayılarla karesi -1 olan sayı bulamıyoruz. Bu yeni sayıya i adını veriyoruz; i²=-1."
    else -> "Konuyu küçük parçalara ayır: önce ne verildiğini bul, sonra senden ne istendiğini tek cümleyle söyle, en son sadece bir adım işlem yap."
}
