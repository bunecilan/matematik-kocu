package com.matematikkocu.app

import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Calculate
import androidx.compose.material.icons.filled.DeleteSweep
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlin.math.PI
import kotlin.math.abs

@Composable
fun FunctionLabScreen(onBack: () -> Unit) {
    var mode by remember { mutableStateOf("Doğrusal") }
    var a by remember { mutableFloatStateOf(1f) }
    var b by remember { mutableFloatStateOf(0f) }

    Column(Modifier.fillMaxSize().padding(18.dp)) {
        AppHeader("Fonksiyon Grafik Laboratuvarı", "Katsayıyı değiştir, grafiğin nasıl hareket ettiğini gör.", onBack)
        LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            items(listOf("Doğrusal", "Parabol")) { item ->
                FilterChip(selected = mode == item, onClick = { mode = item }, label = { Text(item) })
            }
        }
        Spacer(Modifier.height(10.dp))
        Text(if (mode == "Doğrusal") "y = ${fmt(a)}x ${signed(b)}" else "y = ${fmt(a)}x² ${signed(b)}", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = AppMint)
        Text("a = ${fmt(a)}", fontWeight = FontWeight.Bold)
        Slider(value = a, onValueChange = { a = it }, valueRange = -4f..4f, steps = 15)
        Text("b = ${fmt(b)}", fontWeight = FontWeight.Bold)
        Slider(value = b, onValueChange = { b = it }, valueRange = -5f..5f, steps = 19)
        Spacer(Modifier.height(8.dp))

        Card(colors = CardDefaults.cardColors(containerColor = AppCard), shape = RoundedCornerShape(20.dp)) {
            Canvas(Modifier.fillMaxWidth().height(330.dp).padding(8.dp)) {
                val scale = size.width / 20f
                val ox = size.width / 2f
                val oy = size.height / 2f
                val grid = Color.White.copy(alpha = .08f)
                for (i in -10..10) {
                    drawLine(grid, Offset(ox + i * scale, 0f), Offset(ox + i * scale, size.height), 1f)
                }
                for (i in -8..8) {
                    drawLine(grid, Offset(0f, oy + i * scale), Offset(size.width, oy + i * scale), 1f)
                }
                drawLine(Color.White.copy(alpha=.45f), Offset(0f, oy), Offset(size.width, oy), 2f)
                drawLine(Color.White.copy(alpha=.45f), Offset(ox, 0f), Offset(ox, size.height), 2f)

                val path = Path()
                var started = false
                var px = 0f
                while (px <= size.width) {
                    val x = (px - ox) / scale
                    val y = if (mode == "Doğrusal") a * x + b else a * x * x + b
                    val py = oy - y * scale
                    if (py in -size.height..(size.height * 2f)) {
                        if (!started) { path.moveTo(px, py); started = true } else path.lineTo(px, py)
                    } else started = false
                    px += 2f
                }
                drawPath(path, AppPink, style = Stroke(width = 5f, cap = StrokeCap.Round))
            }
        }
        Spacer(Modifier.height(12.dp))
        Card(colors = CardDefaults.cardColors(containerColor = Color(0xFF173C39)), shape = RoundedCornerShape(18.dp)) {
            Column(Modifier.padding(16.dp)) {
                Text("👀 Şunu fark et", fontWeight = FontWeight.Bold, fontSize = 18.sp)
                Text(
                    if (mode == "Doğrusal") "a büyüdükçe doğru daha dik olur. a negatif olursa doğru diğer yöne eğilir. b ise grafiği yukarı-aşağı taşır."
                    else "a'nın işareti parabolün yukarı mı aşağı mı açılacağını belirler. |a| büyüdükçe parabol daralır. b grafiği yukarı-aşağı taşır.",
                    color = Color(0xFFE2F6F1), lineHeight = 22.sp
                )
                Spacer(Modifier.height(8.dp))
                listOf(-2f, 0f, 2f).forEach { x ->
                    val y = if (mode == "Doğrusal") a*x+b else a*x*x+b
                    Text("x = ${fmt(x)} → y = ${fmt(y)}", color = AppMint, fontWeight = FontWeight.SemiBold)
                }
            }
        }
    }
}

@Composable
fun GeometryLabScreen(onBack: () -> Unit) {
    var shape by remember { mutableStateOf("Üçgen") }
    var sizeValue by remember { mutableFloatStateOf(5f) }
    val transition = rememberInfiniteTransition(label = "geo")
    val angle by transition.animateFloat(
        initialValue = -6f,
        targetValue = 6f,
        animationSpec = infiniteRepeatable(tween(1600), RepeatMode.Reverse),
        label = "angle"
    )

    Column(Modifier.fillMaxSize().padding(18.dp)) {
        AppHeader("Hareketli Geometri", "Şekli gör, formülü ezberlemek yerine neyi ölçtüğünü anla.", onBack)
        LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            items(listOf("Üçgen", "Dikdörtgen", "Daire")) { item ->
                FilterChip(selected = shape == item, onClick = { shape = item }, label = { Text(item) })
            }
        }
        Spacer(Modifier.height(10.dp))
        Text(if (shape == "Daire") "Yarıçap = ${fmt(sizeValue)}" else "Temel ölçü = ${fmt(sizeValue)}", fontWeight = FontWeight.Bold)
        Slider(value = sizeValue, onValueChange = { sizeValue = it }, valueRange = 2f..10f, steps = 15)

        Card(colors = CardDefaults.cardColors(containerColor = AppCard), shape = RoundedCornerShape(22.dp)) {
            Canvas(Modifier.fillMaxWidth().height(300.dp).padding(24.dp)) {
                val c = center
                val unit = minOf(size.width, size.height) / 18f
                rotate(angle, c) {
                    when (shape) {
                        "Üçgen" -> {
                            val w = sizeValue * unit
                            val h = sizeValue * .8f * unit
                            val p = Path().apply {
                                moveTo(c.x, c.y - h/2)
                                lineTo(c.x - w/2, c.y + h/2)
                                lineTo(c.x + w/2, c.y + h/2)
                                close()
                            }
                            drawPath(p, AppPurple.copy(alpha=.45f))
                            drawPath(p, AppMint, style = Stroke(5f, cap = StrokeCap.Round))
                            drawLine(AppPink, Offset(c.x, c.y-h/2), Offset(c.x, c.y+h/2), 3f)
                        }
                        "Dikdörtgen" -> {
                            val w = sizeValue * unit
                            val h = sizeValue * .65f * unit
                            val rect = Rect(c.x-w/2, c.y-h/2, c.x+w/2, c.y+h/2)
                            drawRect(AppPurple.copy(alpha=.45f), rect.topLeft, rect.size)
                            drawRect(AppMint, rect.topLeft, rect.size, style=Stroke(5f))
                        }
                        else -> {
                            val radius = sizeValue * unit / 2f
                            drawCircle(AppPurple.copy(alpha=.45f), radius, c)
                            drawCircle(AppMint, radius, c, style=Stroke(5f))
                            drawLine(AppPink, c, Offset(c.x+radius, c.y), 4f)
                        }
                    }
                }
            }
        }
        Spacer(Modifier.height(14.dp))
        Card(colors = CardDefaults.cardColors(containerColor = Color(0xFF2B2053)), shape = RoundedCornerShape(18.dp)) {
            Column(Modifier.padding(16.dp)) {
                Text("📐 Ne hesaplıyoruz?", fontWeight = FontWeight.Bold, fontSize = 18.sp)
                val text = when(shape) {
                    "Üçgen" -> "Üçgen alanı = taban × yükseklik ÷ 2. Pembe çizgi yüksekliği temsil ediyor. Taban ${fmt(sizeValue)} ve yükseklik yaklaşık ${fmt(sizeValue*.8f)} olursa alan ≈ ${fmt(sizeValue*sizeValue*.8f/2f)} birim²."
                    "Dikdörtgen" -> "Dikdörtgen alanı = kısa kenar × uzun kenar. Ölçüler yaklaşık ${fmt(sizeValue)} ve ${fmt(sizeValue*.65f)} ise alan ≈ ${fmt(sizeValue*sizeValue*.65f)} birim²."
                    else -> "Dairenin alanı = π × r². Burada r ≈ ${fmt(sizeValue/2f)} olduğundan alan ≈ ${fmt((PI*(sizeValue/2f)*(sizeValue/2f)).toFloat())} birim²."
                }
                Text(text, color = AppTextSoft, lineHeight = 22.sp)
            }
        }
    }
}

@Composable
fun ScratchpadScreen(onBack: () -> Unit) {
    val strokes = remember { mutableStateListOf<List<Offset>>() }
    var current by remember { mutableStateOf<List<Offset>>(emptyList()) }
    var first by remember { mutableStateOf("") }
    var second by remember { mutableStateOf("") }
    var op by remember { mutableStateOf("+") }

    val a = first.replace(',', '.').toDoubleOrNull()
    val b = second.replace(',', '.').toDoubleOrNull()
    val result = if (a != null && b != null) when(op) {
        "+" -> a+b
        "−" -> a-b
        "×" -> a*b
        else -> if (b == 0.0) null else a/b
    } else null

    Column(Modifier.fillMaxSize().padding(18.dp)) {
        AppHeader("Karalama & Hesap Alanı", "Parmağınla işlem yap, yan tarafta hızlı hesapla.", onBack)
        Card(colors = CardDefaults.cardColors(containerColor = Color(0xFFF7F5FF)), shape = RoundedCornerShape(20.dp)) {
            Box(Modifier.fillMaxWidth().height(310.dp)) {
                Canvas(
                    Modifier.fillMaxSize().pointerInput(Unit) {
                        detectDragGestures(
                            onDragStart = { p -> current = listOf(p) },
                            onDrag = { change, _ -> current = current + change.position },
                            onDragEnd = { if (current.size > 1) strokes.add(current); current = emptyList() },
                            onDragCancel = { current = emptyList() }
                        )
                    }
                ) {
                    fun drawStroke(points: List<Offset>) {
                        if (points.size < 2) return
                        val p = Path().apply {
                            moveTo(points.first().x, points.first().y)
                            points.drop(1).forEach { lineTo(it.x, it.y) }
                        }
                        drawPath(p, Color(0xFF1D1740), style = Stroke(5f, cap = StrokeCap.Round))
                    }
                    strokes.forEach(::drawStroke)
                    drawStroke(current)
                }
                IconButton(onClick = { strokes.clear(); current = emptyList() }, modifier = Modifier.padding(8.dp)) {
                    Icon(Icons.Default.DeleteSweep, "Temizle", tint = Color(0xFF4D456A))
                }
            }
        }
        Spacer(Modifier.height(14.dp))
        Card(colors = CardDefaults.cardColors(containerColor = AppCard), shape = RoundedCornerShape(20.dp)) {
            Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Row(verticalAlignment = androidx.compose.ui.Alignment.CenterVertically) {
                    Icon(Icons.Default.Calculate, null, tint = AppMint)
                    Spacer(Modifier.width(8.dp))
                    Text("Hızlı Hesap Makinesi", fontSize = 18.sp, fontWeight = FontWeight.Bold)
                }
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    OutlinedTextField(first, { first = it }, label={Text("1. sayı")}, singleLine=true, modifier=Modifier.weight(1f), keyboardOptions=KeyboardOptions(keyboardType=KeyboardType.Decimal))
                    OutlinedTextField(second, { second = it }, label={Text("2. sayı")}, singleLine=true, modifier=Modifier.weight(1f), keyboardOptions=KeyboardOptions(keyboardType=KeyboardType.Decimal))
                }
                LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    items(listOf("+","−","×","÷")) { item ->
                        FilterChip(selected = op == item, onClick = { op = item }, label={Text(item, fontSize=18.sp)})
                    }
                }
                Text("Sonuç: ${result?.let { fmt(it.toFloat()) } ?: "—"}", fontSize=23.sp, fontWeight=FontWeight.ExtraBold, color=AppMint)
            }
        }
    }
}

private fun fmt(v: Float): String {
    val rounded = kotlin.math.round(v * 100f) / 100f
    return if (abs(rounded - rounded.toInt()) < .001f) rounded.toInt().toString() else rounded.toString().replace('.', ',')
}
private fun signed(v: Float): String = if (v >= 0) "+ ${fmt(v)}" else "− ${fmt(abs(v))}"
