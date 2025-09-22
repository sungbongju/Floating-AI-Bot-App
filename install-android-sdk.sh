#!/bin/bash

# 🚀 Android SDK 자동 설치 스크립트
# GitHub Codespaces용 Android 개발 환경 설정

set -e  # 오류 발생 시 스크립트 중단

echo "🚀 Android SDK 설치 스크립트 시작"
echo "=================================="
echo ""

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 진행 상황 표시 함수
print_step() {
    echo -e "${BLUE}[단계 $1]${NC} $2"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 1. 환경 확인
print_step "1" "환경 확인 중..."
echo "현재 디렉토리: $(pwd)"
echo "사용자: $(whoami)"
echo "기본 Java 버전: $(java -version 2>&1 | head -1)"
echo ""

# ==========================================================
# ☕ 1.5단계: Java 버전을 17로 설정 (추가된 부분)
# ==========================================================
print_step "1.5" "Java 버전을 17로 설정합니다..."
sudo update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
echo "변경된 Java 버전:"
java -version
echo "JAVA_HOME 설정: $JAVA_HOME"
print_success "Java 버전이 17로 성공적으로 변경되었습니다."
echo ""

# 2. 기존 Android SDK 확인
print_step "2" "기존 Android SDK 확인 중..."
if [ -d "/usr/local/android-sdk" ]; then
    print_warning "기존 Android SDK가 발견되었습니다. 제거 후 재설치합니다."
    sudo rm -rf /usr/local/android-sdk
fi

if [ -f "local.properties" ]; then
    print_warning "기존 local.properties 파일을 백업합니다."
    cp local.properties local.properties.backup
fi
echo ""

# 3. 임시 디렉토리 생성 및 이동
print_step "3" "임시 작업 디렉토리 설정 중..."
TEMP_DIR="/tmp/android-sdk-install"
rm -rf $TEMP_DIR
mkdir -p $TEMP_DIR
cd $TEMP_DIR
print_success "작업 디렉토리 생성: $TEMP_DIR"
echo ""

# 4. Android Command Line Tools 다운로드
print_step "4" "Android Command Line Tools 다운로드 중..."
DOWNLOAD_URL="https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip"
echo "다운로드 URL: $DOWNLOAD_URL"

if command -v wget >/dev/null 2>&1; then
    wget -O commandlinetools.zip "$DOWNLOAD_URL" --progress=bar:force 2>&1
elif command -v curl >/dev/null 2>&1; then
    curl -L -o commandlinetools.zip "$DOWNLOAD_URL" --progress-bar
else
    print_error "wget 또는 curl이 필요합니다."
    exit 1
fi

print_success "다운로드 완료 ($(du -h commandlinetools.zip | cut -f1))"
echo ""

# 5. 압축 해제
print_step "5" "압축 해제 중..."
if ! unzip -q commandlinetools.zip; then
    print_error "압축 해제에 실패했습니다."
    exit 1
fi
print_success "압축 해제 완료"
echo ""

# 6. Android SDK 디렉토리 설정
print_step "6" "Android SDK 디렉토리 설정 중..."
ANDROID_SDK_PATH="/usr/local/android-sdk"

sudo mkdir -p "$ANDROID_SDK_PATH/cmdline-tools"
sudo mv cmdline-tools "$ANDROID_SDK_PATH/cmdline-tools/latest"
sudo chmod -R 755 "$ANDROID_SDK_PATH"
sudo chown -R $(whoami):$(whoami) "$ANDROID_SDK_PATH" 2>/dev/null || true

print_success "Android SDK 디렉토리 설정 완료: $ANDROID_SDK_PATH"
echo ""

# 7. 환경 변수 설정
print_step "7" "환경 변수 설정 중..."
export ANDROID_HOME="$ANDROID_SDK_PATH"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

echo "ANDROID_HOME=$ANDROID_HOME"
echo "PATH에 Android 도구 경로 추가됨"
print_success "환경 변수 설정 완료"
echo ""

# 8. local.properties 파일 생성
print_step "8" "local.properties 파일 생성 중..."
cd /workspaces/simple-android-app
echo "sdk.dir=$ANDROID_SDK_PATH" > local.properties
echo "local.properties 내용:"
cat local.properties
print_success "local.properties 파일 생성 완료"
echo ""

# 9. Android SDK 라이선스 동의
print_step "9" "Android SDK 라이선스 동의 중..."
SDKMANAGER="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"

if ! yes | "$SDKMANAGER" --licenses > /dev/null 2>&1; then
    print_error "라이선스 동의에 실패했습니다."
    exit 1
fi
print_success "라이선스 동의 완료"
echo ""

# 10. 필수 Android 컴포넌트 설치
print_step "10" "필수 Android 컴포넌트 설치 중..."
echo "설치할 컴포넌트:"
echo "  - platform-tools (adb, fastboot 등)"
echo "  - platforms;android-33 (Android 13 SDK)"
echo "  - build-tools;33.0.0 (빌드 도구)"
echo ""

if ! "$SDKMANAGER" "platform-tools" "platforms;android-33" "build-tools;33.0.0"; then
    print_error "Android 컴포넌트 설치에 실패했습니다."
    exit 1
fi
print_success "필수 컴포넌트 설치 완료"
echo ""

# 11. 설치 확인
print_step "11" "설치 확인 중..."
echo "설치된 디렉토리 구조:"
ls -la "$ANDROID_SDK_PATH/"
echo ""
echo "설치된 플랫폼:"
ls -la "$ANDROID_SDK_PATH/platforms/" 2>/dev/null || echo "플랫폼 디렉토리 없음"
echo ""
echo "설치된 빌드 도구:"
ls -la "$ANDROID_SDK_PATH/build-tools/" 2>/dev/null || echo "빌드 도구 디렉토리 없음"
echo ""

# 12. 환경 변수 영구 설정
print_step "12" "환경 변수 영구 설정 중..."
BASHRC_FILE="/home/codespace/.bashrc"
if [ -f "$BASHRC_FILE" ]; then
    if ! grep -q "ANDROID_HOME" "$BASHRC_FILE"; then
        echo "" >> "$BASHRC_FILE"
        echo "# Android SDK 환경 변수" >> "$BASHRC_FILE"
        echo "export ANDROID_HOME=$ANDROID_SDK_PATH" >> "$BASHRC_FILE"
        echo "export PATH=\$PATH:\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools" >> "$BASHRC_FILE"
        print_success "환경 변수가 .bashrc에 추가되었습니다"
    else
        print_warning "환경 변수가 이미 .bashrc에 설정되어 있습니다"
    fi
fi
echo ""

# 13. 임시 파일 정리
print_step "13" "임시 파일 정리 중..."
cd /workspaces/simple-android-app
rm -rf "$TEMP_DIR"
print_success "임시 파일 정리 완료"
echo ""

# 14. Android 앱 빌드 시도
print_step "14" "Android 앱 빌드 시도 중..."
echo "Gradle 빌드를 시작합니다..."
echo ""

if ./gradlew assembleDebug --no-daemon; then
    print_success "🎉 Android 앱 빌드 성공!"
    echo ""
    echo "생성된 APK 파일:"
    find . -name "*.apk" -type f 2>/dev/null || echo "APK 파일을 찾을 수 없습니다"
else
    print_error "Android 앱 빌드에 실패했습니다"
    echo "문제 해결을 위해 다음 명령어를 실행해보세요:"
    echo "  ./gradlew assembleDebug --stacktrace"
fi

echo ""
echo "=================================="
echo "🎉 Android SDK 설치 스크립트 완료"
echo "=================================="
echo ""
echo "📋 설치 요약:"
echo "  - Android SDK 위치: $ANDROID_SDK_PATH"
echo "  - local.properties: $(pwd)/local.properties"
echo "  - 환경 변수: ANDROID_HOME, PATH 설정됨"
echo ""
echo "🚀 이제 다음 명령어로 앱을 빌드할 수 있습니다:"
echo "  ./gradlew assembleDebug"
echo ""
echo "📱 APK 파일 위치:"
echo "  app/build/outputs/apk/debug/app-debug.apk"
