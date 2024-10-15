pipeline {
    agent any

    environment {
        FLUTTER_HOME = 'E:/flutter'
        PATH = "$FLUTTER_HOME/bin:$PATH"
    }

    stages {
        stage('Checkout') {
            steps {
                // Clone project repository
                git 'https://github.com/your-repository/flutter-project.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                // Install dependencies
                sh 'flutter pub get'
            }
        }

        stage('Test') {
            steps {
                // Run Flutter tests
                sh 'flutter test'
            }
        }

        stage('Build') {
            steps {
                // Build APK for Android or app for iOS
                sh 'flutter build apk --release'  // สำหรับ Android
                // sh 'flutter build ios --release'  // สำหรับ iOS
            }
        }
    }

    post {
        always {
            // Archive APK or app builds
            archiveArtifacts artifacts: '**/build/app/outputs/**/*.apk', allowEmptyArchive: true
            // Archive test results
            junit 'build/test-results/test/*.xml'
        }
        success {
            echo 'Build and test successful!'
        }
        failure {
            echo 'Build or test failed.'
        }
    }
}
