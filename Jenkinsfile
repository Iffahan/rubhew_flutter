pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                // ดึงโค้ดจาก Git repository
                checkout scm
            }
        }
        stage('Install Dependencies') {
            steps {
                // ติดตั้ง dependencies ของ Flutter project
                sh 'flutter pub get'
            }
        }
        stage('Build APK') {
            steps {
                // Build APK สำหรับ Android
                sh 'flutter build apk --release'
            }
        }
        stage('Test') {
            steps {
                // รัน unit tests ของ Flutter
                sh 'flutter test'
            }
        }
    }
    
    post {
        always {
            // จัดการผลลัพธ์ของการทดสอบ
            junit 'build/test-results/**/*.xml'
        }
        success {
            echo 'Build and Test Success!'
        }
        failure {
            echo 'Build or Test Failed.'
        }
    }
}
