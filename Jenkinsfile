pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Set Flutter Channel') {
            steps {
                sh 'flutter channel stable'
            }
        }
        stage('Install Dependencies') {
            steps {
                sh 'flutter pub get'
            }
        }
        stage('Build APK') {
            steps {
                sh 'flutter build apk --release'
            }
        }
        stage('Test') {
            steps {
                sh 'flutter test --reporter=junit --reporter-path=build/test-results/'
            }
        }
    }

    post {
        always {
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
