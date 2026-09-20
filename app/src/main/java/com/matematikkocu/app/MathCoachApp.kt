package com.matematikkocu.app

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import kotlin.random.Random

private sealed class ScreenV2 {
    data object Home: ScreenV2()
    data object Topics: ScreenV2()
    data class LessonView(val lesson: Lesson): ScreenV2()
    data class PracticeSetup(val topicId:String?=null, val title:String="Soru Bankası", val subtitle:String="Konu ve seviyene göre sınırsız pratik."): ScreenV2()
    data class Practice(val title:String, val questions:List<PracticeQuestion>, val exam:Boolean=false, val durationSeconds:Int=0, val completionTopicId:String?=null): ScreenV2()
    data object ExamSetup: ScreenV2()
    data object SmartReview: ScreenV2()
    data object WrongBook: ScreenV2()
    data object Favorites: ScreenV2()
    data object Tools: ScreenV2()
    data object FunctionLab: ScreenV2()
    data object GeometryLab: ScreenV2()
    data object Scratchpad: ScreenV2()
    data object Progress: ScreenV2()
}

@Composable
fun MathCoachApp() {
    val context=LocalContext.current
    val store=remember { LearningStore(context) }
    var user by remember { mutableStateOf(store.snapshot()) }
    var screen by remember { mutableStateOf<ScreenV2>(ScreenV2.Home) }

    fun refresh(){ user=store.snapshot() }

    LaunchedEffect(Unit) { store.touchStudyDay(); refresh() }

    fun buildPractice(topicId:String?,track:StudyTrack,difficulty:Difficulty?,count:Int,topicsOverride:List<String>?=null):List<PracticeQuestion> {
        val available = when {
            topicId!=null -> listOf(topicId)
            !topicsOverride.isNullOrEmpty() -> topicsOverride
            else -> QuestionFactory.topicsForTrack(track)
        }
        if(available.isEmpty()) return emptyList()
        val baseSeed=(System.currentTimeMillis()%1_000_000_000L).toInt()
        val rng=Random(baseSeed)
        return List(count) { i ->
            val topic=available[rng.nextInt(available.size)]
            val diff=difficulty ?: store.adaptiveDifficulty(topic)
            QuestionFactory.generate(topic,diff,baseSeed+(i+1)*104729,track)
        }
    }

    fun buildExam(track:StudyTrack,count:Int):List<PracticeQuestion> {
        val topics=QuestionFactory.topicsForTrack(track)
        val baseSeed=(System.currentTimeMillis()%1_000_000_000L).toInt()
        val rng=Random(baseSeed)
        return List(count){i->
            val topic=topics[rng.nextInt(topics.size)]
            val diff = if(track==StudyTrack.AYT) {
                if(i%3==0) Difficulty.MEDIUM else Difficulty.HARD
            } else {
                when(i%4){0->Difficulty.EASY;1,2->Difficulty.MEDIUM;else->Difficulty.HARD}
            }
            QuestionFactory.generate(topic,diff,baseSeed+(i+1)*65537,track)
        }
    }

    MaterialTheme(
        colorScheme= darkColorScheme(
            primary=AppPurple,secondary=AppPink,tertiary=AppMint,
            background=AppDark,surface=AppCard,onBackground=Color.White,onSurface=Color.White
        )
    ) {
        Surface(Modifier.fillMaxSize(),color=AppDark) {
            when(val s=screen) {
                ScreenV2.Home -> HomeScreenV2(
                    state=user,
                    onContinue={
                        val weak=user.weakTopics.firstOrNull()
                        val next=weak?.let{id->Curriculum.lessons.firstOrNull{it.id==id}}
                            ?: Curriculum.lessons.firstOrNull{it.id !in user.completed}
                            ?: Curriculum.lessons.first()
                        screen=ScreenV2.LessonView(next)
                    },
                    onTopics={screen=ScreenV2.Topics},
                    onSmartReview={screen=ScreenV2.SmartReview},
                    onQuestionBank={screen=ScreenV2.PracticeSetup()},
                    onExam={screen=ScreenV2.ExamSetup},
                    onWrong={screen=ScreenV2.WrongBook},
                    onFavorites={screen=ScreenV2.Favorites},
                    onTools={screen=ScreenV2.Tools},
                    onProgress={screen=ScreenV2.Progress}
                )
                ScreenV2.Topics -> TopicsScreenV2(user.completed,onBack={screen=ScreenV2.Home},onLesson={screen=ScreenV2.LessonView(it)})
                is ScreenV2.LessonView -> LessonScreenV2(
                    lesson=s.lesson,
                    onBack={screen=ScreenV2.Topics},
                    onStartQuiz={
                        val qs=buildPractice(s.lesson.id,StudyTrack.GENERAL,null,5)
                        screen=ScreenV2.Practice("${s.lesson.title} • Adaptif Test",qs,completionTopicId=s.lesson.id)
                    }
                )
                is ScreenV2.PracticeSetup -> {
                    val lesson=s.topicId?.let{id->Curriculum.lessons.firstOrNull{it.id==id}}
                    PracticeSetupScreen(
                        title=if(lesson!=null)"${lesson.title} Testi" else s.title,
                        subtitle=if(lesson!=null)"Bu konudan kolay, orta, zor veya adaptif soru çöz." else s.subtitle,
                        initialTrack=StudyTrack.GENERAL,
                        fixedTopicTitle=lesson?.title,
                        allowTrackChoice=lesson==null,
                        onBack={screen=if(lesson!=null)ScreenV2.LessonView(lesson) else ScreenV2.Home},
                        onStart={track,diff,count->
                            val qs=buildPractice(s.topicId,track,diff,count)
                            screen=ScreenV2.Practice(if(lesson!=null)lesson.title else "${track.label} Soru Bankası",qs)
                        }
                    )
                }
                is ScreenV2.Practice -> PracticeSessionScreen(
                    title=s.title,
                    questions=s.questions,
                    favorites=user.favorites,
                    examMode=s.exam,
                    durationSeconds=s.durationSeconds,
                    onBack={screen=ScreenV2.Home},
                    onAnswer={q,correct->store.recordAnswer(q,correct);refresh()},
                    onToggleFavorite={id->store.toggleFavorite(id);refresh()},
                    onFinish={ s.completionTopicId?.let { store.markLessonDone(it) }; refresh() }
                )
                ScreenV2.ExamSetup -> ExamSetupScreen(
                    onBack={screen=ScreenV2.Home},
                    onStart={track,count,seconds->screen=ScreenV2.Practice("${track.label} Süreli Deneme",buildExam(track,count),exam=true,durationSeconds=seconds)}
                )
                ScreenV2.SmartReview -> {
                    val weakInfos=user.weakTopics.mapNotNull{id->
                        Curriculum.lessons.firstOrNull{it.id==id}?.let{lesson->
                            WeakTopicInfo(id,lesson.title,store.topicWrong(id),store.topicAttempts(id),store.adaptiveDifficulty(id))
                        }
                    }
                    SmartReviewScreen(
                        weakTopics=weakInfos,
                        onBack={screen=ScreenV2.Home},
                        onStart={
                            val topics=if(user.weakTopics.isEmpty())QuestionFactory.allTopics else user.weakTopics
                            screen=ScreenV2.Practice("Akıllı Tekrar",buildPractice(null,StudyTrack.GENERAL,null,10,topicsOverride=topics))
                        }
                    )
                }
                ScreenV2.WrongBook -> {
                    val qs=user.wrongIds.mapNotNull(QuestionFactory::fromId)
                    SavedQuestionsScreen(
                        title="Yanlışlar Defteri",subtitle="Yanlış yaptığın sorular kaybolmaz; öğrenene kadar burada.",questions=qs,
                        favorites=user.favorites,wrongMode=true,onBack={screen=ScreenV2.Home},
                        onToggleFavorite={store.toggleFavorite(it);refresh()},onMastered={store.removeWrong(it);refresh()},
                        onPracticeTopic={screen=ScreenV2.PracticeSetup(it,"Benzer Sorular")}
                    )
                }
                ScreenV2.Favorites -> {
                    val qs=user.favorites.mapNotNull(QuestionFactory::fromId)
                    SavedQuestionsScreen(
                        title="Favori Sorular",subtitle="Yıldızladığın sorular burada.",questions=qs,
                        favorites=user.favorites,wrongMode=false,onBack={screen=ScreenV2.Home},
                        onToggleFavorite={store.toggleFavorite(it);refresh()},onMastered={},
                        onPracticeTopic={screen=ScreenV2.PracticeSetup(it,"Benzer Sorular")}
                    )
                }
                ScreenV2.Tools -> ToolHubScreen(onBack={screen=ScreenV2.Home},onGraph={screen=ScreenV2.FunctionLab},onGeometry={screen=ScreenV2.GeometryLab},onScratch={screen=ScreenV2.Scratchpad})
                ScreenV2.FunctionLab -> FunctionLabScreen{screen=ScreenV2.Tools}
                ScreenV2.GeometryLab -> GeometryLabScreen{screen=ScreenV2.Tools}
                ScreenV2.Scratchpad -> ScratchpadScreen{screen=ScreenV2.Tools}
                ScreenV2.Progress -> ProgressScreenV2(user){screen=ScreenV2.Home}
            }
        }
    }
}
