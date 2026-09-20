package com.matematikkocu.app

import android.content.Context
import android.content.SharedPreferences
import java.util.TimeZone

class LearningStore(context: Context) {
    private val prefs: SharedPreferences = context.getSharedPreferences("mathcoach_v2", Context.MODE_PRIVATE)

    val completed: Set<String> get() = prefs.getStringSet("completed", emptySet())?.toSet() ?: emptySet()
    val favorites: Set<String> get() = prefs.getStringSet("favorites", emptySet())?.toSet() ?: emptySet()
    val wrongIds: Set<String> get() = prefs.getStringSet("wrong_ids", emptySet())?.toSet() ?: emptySet()
    val xp: Int get() = prefs.getInt("xp", 0)
    val streak: Int get() = prefs.getInt("streak", 0)
    val longestStreak: Int get() = prefs.getInt("longest_streak", 0)
    val attempts: Int get() = prefs.getInt("attempts_total", 0)
    val correctAnswers: Int get() = prefs.getInt("correct_total", 0)
    val reviewedWrong: Int get() = prefs.getInt("reviewed_wrong", 0)

    fun touchStudyDay() {
        val now = System.currentTimeMillis()
        val offset = TimeZone.getDefault().getOffset(now)
        val today = ((now + offset) / 86_400_000L).toInt()
        val last = prefs.getInt("last_study_day", Int.MIN_VALUE)
        if (last == today) return
        val next = if (last == today - 1) prefs.getInt("streak", 0) + 1 else 1
        val longest = maxOf(next, prefs.getInt("longest_streak", 0))
        prefs.edit()
            .putInt("last_study_day", today)
            .putInt("streak", next)
            .putInt("longest_streak", longest)
            .apply()
    }

    fun markLessonDone(id: String, bonusXp: Int = 50) {
        val done = completed
        if (id !in done) {
            prefs.edit()
                .putStringSet("completed", done + id)
                .putInt("xp", xp + bonusXp)
                .apply()
        }
        touchStudyDay()
    }

    fun recordAnswer(question: PracticeQuestion, correct: Boolean) {
        val topic = question.topicId
        val editor = prefs.edit()
            .putInt("attempts_total", attempts + 1)
            .putInt("topic_attempts_$topic", prefs.getInt("topic_attempts_$topic", 0) + 1)

        if (correct) {
            editor
                .putInt("correct_total", correctAnswers + 1)
                .putInt("topic_correct_$topic", prefs.getInt("topic_correct_$topic", 0) + 1)
                .putInt("xp", xp + question.difficulty.xp)
        } else {
            editor
                .putStringSet("wrong_ids", wrongIds + question.id)
                .putInt("topic_wrong_$topic", prefs.getInt("topic_wrong_$topic", 0) + 1)
        }
        editor.apply()
        touchStudyDay()
    }

    fun removeWrong(id: String) {
        if (id in wrongIds) {
            prefs.edit()
                .putStringSet("wrong_ids", wrongIds - id)
                .putInt("reviewed_wrong", reviewedWrong + 1)
                .putInt("xp", xp + 5)
                .apply()
        }
    }

    fun toggleFavorite(id: String) {
        val set = favorites
        prefs.edit().putStringSet("favorites", if (id in set) set - id else set + id).apply()
    }

    fun topicAttempts(topicId: String): Int = prefs.getInt("topic_attempts_$topicId", 0)
    fun topicCorrect(topicId: String): Int = prefs.getInt("topic_correct_$topicId", 0)
    fun topicWrong(topicId: String): Int = prefs.getInt("topic_wrong_$topicId", 0)

    fun adaptiveDifficulty(topicId: String): Difficulty {
        val a = topicAttempts(topicId)
        if (a < 5) return Difficulty.EASY
        val accuracy = topicCorrect(topicId).toFloat() / a.coerceAtLeast(1)
        return when {
            a >= 12 && accuracy >= .82f -> Difficulty.HARD
            accuracy >= .58f -> Difficulty.MEDIUM
            else -> Difficulty.EASY
        }
    }

    fun weakTopics(limit: Int = 5): List<String> {
        return Curriculum.lessons
            .map { lesson ->
                val attempts = topicAttempts(lesson.id)
                val wrong = topicWrong(lesson.id)
                val correct = topicCorrect(lesson.id)
                val weakness = when {
                    attempts == 0 -> 0.0
                    else -> (wrong * 2.0 + 1.0) / (correct + wrong + 1.0)
                }
                lesson.id to weakness
            }
            .filter { it.second > 0.0 }
            .sortedByDescending { it.second }
            .take(limit)
            .map { it.first }
    }

    fun accuracy(): Int = if (attempts == 0) 0 else ((correctAnswers * 100f) / attempts).toInt()

    fun badges(): List<BadgeInfo> = listOf(
        BadgeInfo("İlk Adım", "İlk konunu tamamla", "🌱", completed.isNotEmpty()),
        BadgeInfo("Alev Aldı", "3 günlük seri yap", "🔥", streak >= 3),
        BadgeInfo("Bir Hafta", "7 günlük seri yap", "🗓️", streak >= 7),
        BadgeInfo("100 XP", "100 XP topla", "⭐", xp >= 100),
        BadgeInfo("500 XP", "500 XP topla", "🏆", xp >= 500),
        BadgeInfo("Soru Avcısı", "50 soru cevapla", "🎯", attempts >= 50),
        BadgeInfo("Usta Çözücü", "200 soru cevapla", "🧠", attempts >= 200),
        BadgeInfo("Hatalardan Öğrenen", "10 yanlışı tekrar et", "🔁", reviewedWrong >= 10),
        BadgeInfo("Yolun Yarısı", "Konuların yarısını bitir", "🚀", completed.size >= Curriculum.lessons.size / 2),
        BadgeInfo("Matematik Gezgini", "Tüm konuları tamamla", "👑", completed.size >= Curriculum.lessons.size)
    )
}

fun LearningStore.snapshot(): UserUiState = UserUiState(
    completed = completed,
    favorites = favorites,
    wrongIds = wrongIds,
    xp = xp,
    streak = streak,
    longestStreak = longestStreak,
    attempts = attempts,
    correctAnswers = correctAnswers,
    accuracy = accuracy(),
    weakTopics = weakTopics(),
    badges = badges()
)
