package com.matematikkocu.app

enum class Difficulty(val label: String, val xp: Int) {
    EASY("Kolay", 6), MEDIUM("Orta", 10), HARD("Zor", 16)
}

enum class StudyTrack(val label: String) {
    GENERAL("Genel"), TYT("TYT"), AYT("AYT")
}

data class PracticeQuestion(
    val id: String,
    val topicId: String,
    val prompt: String,
    val options: List<String>,
    val correctIndex: Int,
    val explanation: String,
    val difficulty: Difficulty,
    val track: StudyTrack,
    val hint: String = ""
)

data class BadgeInfo(
    val title: String,
    val description: String,
    val icon: String,
    val unlocked: Boolean
)

data class UserUiState(
    val completed: Set<String>,
    val favorites: Set<String>,
    val wrongIds: Set<String>,
    val xp: Int,
    val streak: Int,
    val longestStreak: Int,
    val attempts: Int,
    val correctAnswers: Int,
    val accuracy: Int,
    val weakTopics: List<String>,
    val badges: List<BadgeInfo>
)

data class WeakTopicInfo(
    val id: String,
    val title: String,
    val wrong: Int,
    val attempts: Int,
    val difficulty: Difficulty
)
