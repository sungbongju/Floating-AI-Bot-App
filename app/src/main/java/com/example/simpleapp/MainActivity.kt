package com.example.simpleapp

import android.app.PictureInPictureParams
import android.content.Intent
import android.content.res.Configuration
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Rational
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.annotation.RequiresApi
import androidx.appcompat.app.AppCompatActivity
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : AppCompatActivity() {
    
    private lateinit var welcomeText: TextView
    private lateinit var counterText: TextView
    private lateinit var clickButton: Button
    private lateinit var timeButton: Button
    private lateinit var colorButton: Button
    private lateinit var pipButton: Button
    private lateinit var floatingButton: Button
    
    private var clickCount = 0
    private val colors = arrayOf("#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", "#FFEAA7")
    private var colorIndex = 0
    
    companion object {
        private const val REQUEST_CODE_OVERLAY_PERMISSION = 1001
    }
    
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
        pipButton = findViewById(R.id.pipButton)
        floatingButton = findViewById(R.id.floatingButton)
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
        
        // PIP 버튼 클릭 리스너
        pipButton.setOnClickListener {
            enterPictureInPictureMode()
        }
        
        // Floating Widget 버튼 클릭 리스너
        floatingButton.setOnClickListener {
            startFloatingWidget()
        }
    }
    
    // PIP 모드 진입 함수
    private fun enterPictureInPictureMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val aspectRatio = Rational(16, 9)
            val params = PictureInPictureParams.Builder()
                .setAspectRatio(aspectRatio)
                .build()
            enterPictureInPicture(params)
            Toast.makeText(this, "PIP 모드로 전환합니다!", Toast.LENGTH_SHORT).show()
        } else {
            Toast.makeText(this, "PIP 모드는 Android 8.0 이상에서 지원됩니다", Toast.LENGTH_SHORT).show()
        }
    }
    
    // 홈 버튼 누를 때 자동으로 PIP 모드 진입
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            enterPictureInPictureMode()
        }
    }
    
    // PIP 모드 변경 시 호출
    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        if (isInPictureInPictureMode) {
            // PIP 모드일 때 ActionBar 숨기기
            supportActionBar?.hide()
            Toast.makeText(this, "PIP 모드 활성화!", Toast.LENGTH_SHORT).show()
        } else {
            // 일반 모드일 때 ActionBar 보이기
            supportActionBar?.show()
            Toast.makeText(this, "일반 모드로 복귀!", Toast.LENGTH_SHORT).show()
        }
    }
    
    // Floating Widget 시작 함수
    private fun startFloatingWidget() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!Settings.canDrawOverlays(this)) {
                // 권한이 없으면 권한 요청
                val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
                intent.data = Uri.parse("package:$packageName")
                startActivityForResult(intent, REQUEST_CODE_OVERLAY_PERMISSION)
                Toast.makeText(this, "오버레이 권한을 허용해주세요", Toast.LENGTH_LONG).show()
            } else {
                // 권한이 있으면 서비스 시작
                // startFloatingService() // 다음 단계에서 구현할 예정
                Toast.makeText(this, "Floating Widget 기능은 다음 단계에서 추가됩니다!", Toast.LENGTH_SHORT).show()
            }
        } else {
            // startFloatingService() // 다음 단계에서 구현할 예정
            Toast.makeText(this, "Floating Widget 기능은 다음 단계에서 추가됩니다!", Toast.LENGTH_SHORT).show()
        }
    }
    
    // 권한 요청 결과 처리
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_OVERLAY_PERMISSION) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (Settings.canDrawOverlays(this)) {
                    Toast.makeText(this, "권한이 허용되었습니다!", Toast.LENGTH_SHORT).show()
                    // startFloatingService() // 다음 단계에서 구현할 예정
                } else {
                    Toast.makeText(this, "권한이 거부되었습니다", Toast.LENGTH_SHORT).show()
                }
            }
        }
    }
}
