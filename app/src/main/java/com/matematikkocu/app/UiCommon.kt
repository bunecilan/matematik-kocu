package com.matematikkocu.app

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

internal val AppPurple = Color(0xFF7C4DFF)
internal val AppPink = Color(0xFFFF5FA2)
internal val AppDark = Color(0xFF15112B)
internal val AppCard = Color(0xFF211A3C)
internal val AppCard2 = Color(0xFF2A2050)
internal val AppMint = Color(0xFF46D9B3)
internal val AppTextSoft = Color(0xFFC9C1E8)

@Composable
internal fun AppHeader(title: String, subtitle: String? = null, onBack: () -> Unit) {
    Row(
        modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        IconButton(onClick = onBack) { Icon(Icons.Default.ArrowBack, "Geri") }
        androidx.compose.foundation.layout.Column {
            Text(title, fontSize = 25.sp, fontWeight = FontWeight.ExtraBold)
            if (!subtitle.isNullOrBlank()) Text(subtitle, color = AppTextSoft, fontSize = 13.sp)
        }
    }
}
