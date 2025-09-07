package com.example.simpleapp

import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : AppCompatActivity() {
    
    private lateinit var welcomeText: TextView
    private lateinit var counterText: TextView
    private lateinit var clickButton: Button
    private lateinit var timeButton: Button
    private lateinit var colorButton: Button
    
    private var clickCount = 0
    private val colors = arrayOf("#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", "#FFEAA7")
    private var colorIndex = 0
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        initializeViews()
        setupClickListeners()
    }
    
    private fun initializeViews() {
        welcomeText = findViewById(R.id.welcomeText)
        counterText = findViewById(R.id.counterText)
        clickButton = findViewById(R.id.clickButton)
        timeButton = findViewById(R.id.timeButton)
        colorButton = findViewById(R.id.colorButton)
    }
    
    private fun setupClickListeners() {
        clickButton.setOnClickListener {
            clickCount++
            counterText.text = "클릭 횟수: $clickCount"
            Toast.makeText(this, "클릭! 총 ${clickCount}번", Toast.LENGTH_SHORT).show()
        }
        
        timeButton.setOnClickListener {
            val currentTime = SimpleDateFormat("HH:mm:ss", Locale.getDefault()).format(Date())
            welcomeText.text = "현재 시간: $currentTime"
            Toast.makeText(this, "시간이 업데이트되었습니다!", Toast.LENGTH_SHORT).show()
        }
        
        colorButton.setOnClickListener {
            colorIndex = (colorIndex + 1) % colors.size
            val color = android.graphics.Color.parseColor(colors[colorIndex])
            welcomeText.setTextColor(color)
            Toast.makeText(this, "색깔이 변경되었습니다!", Toast.LENGTH_SHORT).show()
        }
    }
}