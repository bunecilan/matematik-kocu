package com.matematikkocu.app

import androidx.compose.animation.AnimatedVisibility
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay
import kotlin.math.max

@Composable
fun PracticeSetupScreen(
    title: String,
    subtitle: String,
    initialTrack: StudyTrack,
    fixedTopicTitle: String? = null,
    allowTrackChoice: Boolean = true,
    onBack: () -> Unit,
    onStart: (StudyTrack, Difficulty?, Int) -> Unit
) {
    var track by remember { mutableStateOf(initialTrack) }
    var difficultyLabel by remember { mutableStateOf("Adaptif") }
    var count by remember { mutableIntStateOf(10) }

    Column(Modifier.fillMaxSize().padding(18.dp)) {
        AppHeader(title, subtitle, onBack)
        Spacer(Modifier.height(6.dp))
        if (fixedTopicTitle != null) {
            InfoBlock("📚 Seçili konu", fixedTopicTitle, Color(0xFF2B2053))
            Spacer(Modifier.height(12.dp))
        }
        if (allowTrackChoice) {
            Text("Çalışma türü", fontWeight=FontWeight.Bold, fontSize=17.sp)
            Spacer(Modifier.height(6.dp))
            LazyRow(horizontalArrangement=Arrangement.spacedBy(8.dp)) {
                items(StudyTrack.entries) { item ->
                    FilterChip(selected=track==item,onClick={track=item},label={Text(item.label)})
                }
            }
            Spacer(Modifier.height(15.dp))
        }
        Text("Zorluk", fontWeight=FontWeight.Bold, fontSize=17.sp)
        Text("Adaptif seçersen başarı durumuna göre kolay → orta → zor geçer.", color=AppTextSoft, fontSize=13.sp)
        Spacer(Modifier.height(6.dp))
        LazyRow(horizontalArrangement=Arrangement.spacedBy(8.dp)) {
            items(listOf("Adaptif","Kolay","Orta","Zor")) { item ->
                FilterChip(selected=difficultyLabel==item,onClick={difficultyLabel=item},label={Text(item)})
            }
        }
        Spacer(Modifier.height(15.dp))
        Text("Soru sayısı", fontWeight=FontWeight.Bold, fontSize=17.sp)
        Spacer(Modifier.height(6.dp))
        LazyRow(horizontalArrangement=Arrangement.spacedBy(8.dp)) {
            items(listOf(5,10,20,30)) { item ->
                FilterChip(selected=count==item,onClick={count=item},label={Text("$item soru")})
            }
        }
        Spacer(Modifier.height(18.dp))
        Card(colors=CardDefaults.cardColors(containerColor=AppCard),shape=RoundedCornerShape(18.dp)) {
            Column(Modifier.padding(16.dp)) {
                Text("🎯 Bu modda ne olacak?",fontWeight=FontWeight.Bold)
                Text("Her cevap anında açıklanır. Yanlış yaptığın soru Yanlışlar Defteri'ne eklenir. Doğru/yanlış oranına göre konu seviyesi otomatik ayarlanır.",color=AppTextSoft,lineHeight=21.sp)
            }
        }
        Spacer(Modifier.weight(1f))
        Button(onClick={
            val d = when(difficultyLabel){"Kolay"->Difficulty.EASY;"Orta"->Difficulty.MEDIUM;"Zor"->Difficulty.HARD;else->null}
            onStart(track,d,count)
        },modifier=Modifier.fillMaxWidth().height(56.dp),shape=RoundedCornerShape(16.dp)) {
            Icon(Icons.Default.PlayArrow,null);Spacer(Modifier.width(8.dp));Text("Çalışmayı başlat",fontWeight=FontWeight.Bold)
        }
    }
}

@Composable
fun ExamSetupScreen(onBack:()->Unit,onStart:(StudyTrack,Int,Int)->Unit) {
    var track by remember { mutableStateOf(StudyTrack.TYT) }
    var count by remember { mutableIntStateOf(10) }
    val minutes = when(count){10->15;20->30;else->60}
    Column(Modifier.fillMaxSize().padding(18.dp)) {
        AppHeader("TYT / AYT Sınav Modu","Süre işler, cevap açıklamaları sınav sonunda açılır.",onBack)
        Text("Sınav türü",fontWeight=FontWeight.Bold,fontSize=17.sp)
        LazyRow(horizontalArrangement=Arrangement.spacedBy(8.dp)) {
            items(listOf(StudyTrack.TYT,StudyTrack.AYT)){item->FilterChip(selected=track==item,onClick={track=item},label={Text(item.label)})}
        }
        Spacer(Modifier.height(16.dp))
        Text("Soru sayısı",fontWeight=FontWeight.Bold,fontSize=17.sp)
        LazyRow(horizontalArrangement=Arrangement.spacedBy(8.dp)) {
            items(listOf(10,20,40)){item->FilterChip(selected=count==item,onClick={count=item},label={Text("$item soru")})}
        }
        Spacer(Modifier.height(16.dp))
        InfoBlock("⏱️ Süre","Bu deneme için $minutes dakika verilecek. Süre dolarsa sınav otomatik biter.",Color(0xFF3B2039))
        Spacer(Modifier.height(12.dp))
        InfoBlock("🧭 Not","Bu bölüm TYT/AYT tarzında pratik yapmak içindir; resmi ÖSYM sorularının kopyası değildir. Sorular uygulamanın kendi üreticisinden gelir.",Color(0xFF2B2053))
        Spacer(Modifier.weight(1f))
        Button(onClick={onStart(track,count,minutes*60)},modifier=Modifier.fillMaxWidth().height(56.dp),shape=RoundedCornerShape(16.dp)) {
            Icon(Icons.Default.Timer,null);Spacer(Modifier.width(8.dp));Text("Sınavı başlat",fontWeight=FontWeight.Bold)
        }
    }
}

@Composable
fun SmartReviewScreen(
    weakTopics: List<WeakTopicInfo>,
    onBack:()->Unit,
    onStart:()->Unit
) {
    Column(Modifier.fillMaxSize().padding(18.dp)) {
        AppHeader("Akıllı Tekrar","Yanlış yaptığın konular otomatik öne çıkar.",onBack)
        if(weakTopics.isEmpty()) {
            InfoBlock("🌱 Henüz veri yok","Önce birkaç test çöz. Uygulama hangi konularda zorlandığını gördükçe bu ekran kişiselleşecek.",Color(0xFF173C39))
        } else {
            Text("Öncelikli konular",fontWeight=FontWeight.ExtraBold,fontSize=20.sp)
            Spacer(Modifier.height(8.dp))
            LazyColumn(modifier=Modifier.weight(1f),verticalArrangement=Arrangement.spacedBy(9.dp)) {
                items(weakTopics) { info ->
                    Card(colors=CardDefaults.cardColors(containerColor=AppCard),shape=RoundedCornerShape(18.dp)) {
                        Row(Modifier.padding(15.dp),verticalAlignment=Alignment.CenterVertically) {
                            Text("🧠",fontSize=25.sp);Spacer(Modifier.width(11.dp))
                            Column(Modifier.weight(1f)) {
                                Text(info.title,fontWeight=FontWeight.Bold)
                                Text("${info.attempts} deneme • ${info.wrong} yanlış • önerilen ${info.difficulty.label}",color=AppTextSoft,fontSize=12.sp)
                            }
                        }
                    }
                }
            }
            Button(onClick=onStart,modifier=Modifier.fillMaxWidth().height(56.dp),shape=RoundedCornerShape(16.dp)) {
                Icon(Icons.Default.Replay,null);Spacer(Modifier.width(8.dp));Text("10 soruluk akıllı tekrar başlat",fontWeight=FontWeight.Bold)
            }
        }
    }
}

@Composable
fun PracticeSessionScreen(
    title:String,
    questions:List<PracticeQuestion>,
    favorites:Set<String>,
    examMode:Boolean,
    durationSeconds:Int,
    onBack:()->Unit,
    onAnswer:(PracticeQuestion,Boolean)->Unit,
    onToggleFavorite:(String)->Unit,
    onFinish:()->Unit
) {
    if(questions.isEmpty()) {
        Column(Modifier.fillMaxSize().padding(18.dp)) { AppHeader(title,null,onBack); Text("Soru oluşturulamadı.") }
        return
    }
    var index by remember(questions) { mutableIntStateOf(0) }
    var selected by remember(questions,index) { mutableIntStateOf(-1) }
    var score by remember(questions) { mutableIntStateOf(0) }
    var finished by remember(questions) { mutableStateOf(false) }
    var timeLeft by remember(questions,durationSeconds) { mutableIntStateOf(durationSeconds) }
    val answers = remember(questions) { mutableStateMapOf<Int,Int>() }
    val recorded = remember(questions) { mutableStateMapOf<Int,Boolean>() }

    if(examMode && !finished) {
        LaunchedEffect(timeLeft,finished) {
            if(timeLeft>0) { delay(1000); timeLeft-- }
            else if(!finished) finished=true
        }
    }

    if(finished) {
        LaunchedEffect(Unit) {
            questions.forEachIndexed { i,q ->
                if(recorded[i] != true) { onAnswer(q,false); recorded[i]=true }
            }
            onFinish()
        }
        ExamOrPracticeResult(
            title=title,
            questions=questions,
            answers=answers,
            score=score,
            examMode=examMode,
            onDone=onBack
        )
        return
    }

    val q = questions[index]
    val answered = selected>=0
    Column(Modifier.fillMaxSize().padding(18.dp),verticalArrangement=Arrangement.spacedBy(12.dp)) {
        Row(verticalAlignment=Alignment.CenterVertically) {
            IconButton(onClick=onBack){Icon(Icons.Default.Close,"Çık")}
            Column(Modifier.weight(1f)) { Text(title,fontWeight=FontWeight.Bold,fontSize=19.sp); Text("Soru ${index+1}/${questions.size} • ${q.difficulty.label}",color=AppTextSoft,fontSize=12.sp) }
            IconButton(onClick={onToggleFavorite(q.id)}) { Icon(if(q.id in favorites) Icons.Default.Star else Icons.Default.StarBorder,"Favori",tint=if(q.id in favorites) Color(0xFFFFD166) else Color.White) }
        }
        LinearProgressIndicator(progress={ (index+1f)/questions.size },modifier=Modifier.fillMaxWidth().height(8.dp).clip(RoundedCornerShape(99.dp)),color=if(examMode)AppPink else AppMint)
        if(examMode) {
            val min=timeLeft/60; val sec=timeLeft%60
            Text("⏱️ %02d:%02d".format(min,sec),fontSize=20.sp,fontWeight=FontWeight.ExtraBold,color=if(timeLeft<60)AppPink else AppMint)
        } else {
            Text("💡 ${q.hint}",color=Color(0xFFCFC5ED),fontSize=13.sp)
        }
        Spacer(Modifier.height(4.dp))
        Text(q.prompt,fontSize=23.sp,fontWeight=FontWeight.ExtraBold,lineHeight=29.sp)
        q.options.forEachIndexed { i,option ->
            val isCorrect=i==q.correctIndex
            val bg=when {
                !answered || examMode -> if(i==selected) Color(0xFF37305C) else AppCard
                i==selected && isCorrect -> Color(0xFF17483F)
                i==selected -> Color(0xFF52243A)
                answered && isCorrect -> Color(0xFF17483F)
                else -> AppCard
            }
            Card(modifier=Modifier.fillMaxWidth().clickable(enabled=!answered){
                selected=i; answers[index]=i
                val correct=i==q.correctIndex
                if(correct)score++
                onAnswer(q,correct); recorded[index]=true
            },colors=CardDefaults.cardColors(containerColor=bg),shape=RoundedCornerShape(16.dp)) {
                Row(Modifier.padding(16.dp),verticalAlignment=Alignment.CenterVertically) {
                    Surface(color=Color.White.copy(alpha=.08f),shape=RoundedCornerShape(10.dp)){Text(('A'.code+i).toChar().toString(),modifier=Modifier.padding(horizontal=10.dp,vertical=6.dp),fontWeight=FontWeight.Bold)}
                    Spacer(Modifier.width(11.dp));Text(option,fontSize=16.sp)
                }
            }
        }
        if(!examMode) {
            AnimatedVisibility(answered) {
                InfoBlock(if(selected==q.correctIndex)"✅ Doğru" else "❌ Neden yanlış?",q.explanation,if(selected==q.correctIndex)Color(0xFF173C39) else Color(0xFF482238))
            }
        } else if(answered) {
            Text("Cevabın kaydedildi. Açıklama sınav sonunda gösterilecek.",color=AppTextSoft,fontSize=13.sp)
        }
        Spacer(Modifier.weight(1f))
        Button(onClick={
            if(index==questions.lastIndex) finished=true else { index++; selected=-1 }
        },enabled=answered,modifier=Modifier.fillMaxWidth().height(54.dp),shape=RoundedCornerShape(16.dp)) {
            Text(if(index==questions.lastIndex)"Bitir" else "Sonraki soru")
        }
    }
}

@Composable
private fun ExamOrPracticeResult(
    title:String,
    questions:List<PracticeQuestion>,
    answers:Map<Int,Int>,
    score:Int,
    examMode:Boolean,
    onDone:()->Unit
) {
    val wrongIndexes=questions.indices.filter { answers[it] != questions[it].correctIndex }
    LazyColumn(Modifier.fillMaxSize().padding(18.dp),verticalArrangement=Arrangement.spacedBy(11.dp)) {
        item {
            Text(if(examMode)"Sınav tamamlandı" else "Çalışma tamamlandı",fontSize=29.sp,fontWeight=FontWeight.ExtraBold)
            Text(title,color=AppTextSoft)
        }
        item {
            Card(colors=CardDefaults.cardColors(containerColor=AppCard2),shape=RoundedCornerShape(22.dp)) {
                Column(Modifier.padding(19.dp)) {
                    Text("$score / ${questions.size}",fontSize=36.sp,fontWeight=FontWeight.ExtraBold,color=AppMint)
                    Text("Doğru: $score  •  Yanlış/boş: ${questions.size-score}",color=AppTextSoft)
                }
            }
        }
        if(wrongIndexes.isNotEmpty()) {
            item{Text("Tekrar bakman gerekenler",fontWeight=FontWeight.ExtraBold,fontSize=20.sp)}
            items(wrongIndexes.take(20)) { i ->
                val q=questions[i]
                Card(colors=CardDefaults.cardColors(containerColor=Color(0xFF3B2039)),shape=RoundedCornerShape(18.dp)) {
                    Column(Modifier.padding(15.dp)) {
                        Text(q.prompt,fontWeight=FontWeight.Bold)
                        Spacer(Modifier.height(5.dp))
                        Text("Doğru cevap: ${q.options[q.correctIndex]}",color=AppMint,fontWeight=FontWeight.SemiBold)
                        Text(q.explanation,color=Color(0xFFE8D6E0),fontSize=13.sp,lineHeight=20.sp)
                    }
                }
            }
        } else item { InfoBlock("🏆 Kusursuz","Bütün soruları doğru yaptın.",Color(0xFF173C39)) }
        item {
            Button(onClick=onDone,modifier=Modifier.fillMaxWidth().height(54.dp),shape=RoundedCornerShape(16.dp)){Text("Ana ekrana dön")}
        }
        item{Spacer(Modifier.height(20.dp))}
    }
}

@Composable
fun SavedQuestionsScreen(
    title:String,
    subtitle:String,
    questions:List<PracticeQuestion>,
    favorites:Set<String>,
    wrongMode:Boolean,
    onBack:()->Unit,
    onToggleFavorite:(String)->Unit,
    onMastered:(String)->Unit,
    onPracticeTopic:(String)->Unit
) {
    LazyColumn(Modifier.fillMaxSize().padding(18.dp),verticalArrangement=Arrangement.spacedBy(10.dp)) {
        item{AppHeader(title,subtitle,onBack)}
        if(questions.isEmpty()) item { InfoBlock(if(wrongMode)"✅ Defter temiz" else "⭐ Henüz favori yok",if(wrongMode)"Yanlış yaptığın sorular burada birikir. Çözümü öğrendiğinde defterden çıkarabilirsin." else "Soru çözerken yıldız simgesine bas; soru burada saklansın.",Color(0xFF173C39)) }
        items(questions) { q ->
            var open by remember(q.id){ mutableStateOf(false) }
            Card(colors=CardDefaults.cardColors(containerColor=AppCard),shape=RoundedCornerShape(18.dp)) {
                Column(Modifier.padding(15.dp),verticalArrangement=Arrangement.spacedBy(7.dp)) {
                    Row(verticalAlignment=Alignment.Top) {
                        Text(q.prompt,modifier=Modifier.weight(1f),fontWeight=FontWeight.Bold)
                        IconButton(onClick={onToggleFavorite(q.id)}){Icon(if(q.id in favorites)Icons.Default.Star else Icons.Default.StarBorder,"Favori",tint=if(q.id in favorites)Color(0xFFFFD166) else Color.White)}
                    }
                    Text("${Curriculum.lessons.firstOrNull{it.id==q.topicId}?.title ?: q.topicId} • ${q.difficulty.label}",color=AppTextSoft,fontSize=12.sp)
                    OutlinedButton(onClick={open=!open}){Text(if(open)"Çözümü gizle" else "Çözümü göster")}
                    AnimatedVisibility(open) {
                        Column(verticalArrangement=Arrangement.spacedBy(4.dp)) {
                            Text("Doğru: ${q.options[q.correctIndex]}",color=AppMint,fontWeight=FontWeight.Bold)
                            Text(q.explanation,color=Color(0xFFDCD5F1),fontSize=13.sp,lineHeight=20.sp)
                        }
                    }
                    Row(horizontalArrangement=Arrangement.spacedBy(8.dp)) {
                        OutlinedButton(onClick={onPracticeTopic(q.topicId)},modifier=Modifier.weight(1f)){Text("Benzer soru çöz")}
                        if(wrongMode) Button(onClick={onMastered(q.id)},modifier=Modifier.weight(1f)){Text("Öğrendim ✓")}
                    }
                }
            }
        }
        item{Spacer(Modifier.height(20.dp))}
    }
}
