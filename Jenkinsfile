pipeline {
    agent any

    environment {
        ECR_REPO = '359329123577.dkr.ecr.us-east-1.amazonaws.com/nti-app'
        EKS_NAMESPACE = 'nti-project'
        SONARQUBE_SERVER = 'SonarQube' 
        SONARQUBE_PROJECT_KEY = 'nti-3tier-final-project'
        AWS_DEFAULT_REGION = 'us-east-1'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Mohanadm212/NTI-Final-Project.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_SERVER}") {
                    sh '''
                        cd backend
                        sonar-scanner \
                          -Dsonar.projectKey=${SONARQUBE_PROJECT_KEY} \
                          -Dsonar.sources=. \
                          -Dsonar.host.url=$SONAR_HOST_URL \
                          -Dsonar.login=$SONAR_AUTH_TOKEN
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build and Push Docker Images') {
            steps {
                sh '''
                    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REPO

                    # Frontend
                    docker build -t nti-app:frontend ./frontend
                    docker tag nti-app:frontend $ECR_REPO:frontend
                    docker push $ECR_REPO:frontend

                    # Backend
                    docker build -t nti-app:backend ./backend
                    docker tag nti-app:backend $ECR_REPO:backend
                    docker push $ECR_REPO:backend
                '''
            }
        }

        stage('Trivy Scan') {
            steps {
                sh '''
                    # Scan frontend
                    trivy image --exit-code 1 --severity HIGH,CRITICAL $ECR_REPO:frontend || true

                    # Scan backend
                    trivy image --exit-code 1 --severity HIGH,CRITICAL $ECR_REPO:backend || true
                '''
            }
        }

        stage('Deploy to EKS via Helm') {
            steps {
                sh '''
                    helm upgrade frontend ./k8s/helm/frontend -n $EKS_NAMESPACE --install
                    helm upgrade backend ./k8s/helm/backend -n $EKS_NAMESPACE --install
                '''
            }
        }
    }
}