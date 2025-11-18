pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: agent
spec:
  serviceAccountName: jenkins
  containers:
  - name: docker
    image: docker:latest
    command:
    - cat
    tty: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - cat
    tty: true
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
"""
        }
    }
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker-hub-esraa')
        REGISTRY = 'esraaeissa81'
        NAMESPACE = 'dev'
    }
    
    stages {
        stage('📥 Checkout') {
            steps {
                echo '📥 Pulling code from GitHub...'
                checkout scm
            }
        }
        
        stage('🔨 Build Images') {
            steps {
                container('docker') {
                    script {
                        echo "🔨 Building Docker images with tag: ${BUILD_NUMBER}"
                        
                        // Build Backend
                        sh """
                            docker build -t ${REGISTRY}/backend:${BUILD_NUMBER} -f backend/Dockerfile backend/
                            docker tag ${REGISTRY}/backend:${BUILD_NUMBER} ${REGISTRY}/backend:latest
                        """
                        
                        // Build Proxy
                        sh """
                            docker build -t ${REGISTRY}/proxy:${BUILD_NUMBER} -f proxy/Dockerfile proxy/
                            docker tag ${REGISTRY}/proxy:${BUILD_NUMBER} ${REGISTRY}/proxy:latest
                        """
                    }
                }
            }
        }
        
        stage('📤 Push to DockerHub') {
            steps {
                container('docker') {
                    script {
                        echo '📤 Pushing images to DockerHub...'
                        sh """
                            echo \${DOCKERHUB_CREDENTIALS_PSW} | docker login -u \${DOCKERHUB_CREDENTIALS_USR} --password-stdin
                            
                            docker push ${REGISTRY}/backend:${BUILD_NUMBER}
                            docker push ${REGISTRY}/backend:latest
                            
                            docker push ${REGISTRY}/proxy:${BUILD_NUMBER}
                            docker push ${REGISTRY}/proxy:latest
                        """
                    }
                }
            }
        }
        
        stage('🚀 Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    script {
                        echo "🚀 Deploying to Kubernetes namespace: ${NAMESPACE}"
                        sh """
                            # Update Backend
                            kubectl set image deployment/backend-deployment \
                                go-app=${REGISTRY}/backend:${BUILD_NUMBER} \
                                -n ${NAMESPACE}
                            
                            # Update Proxy
                            kubectl set image deployment/proxy-deployment \
                                nginx-proxy=${REGISTRY}/proxy:${BUILD_NUMBER} \
                                -n ${NAMESPACE}
                            
                            # Wait for rollout
                            kubectl rollout status deployment/backend-deployment -n ${NAMESPACE} --timeout=300s
                            kubectl rollout status deployment/proxy-deployment -n ${NAMESPACE} --timeout=300s
                        """
                    }
                }
            }
        }
        
        stage('🧪 Smoke Test') {
            steps {
                container('kubectl') {
                    script {
                        echo '🧪 Running smoke tests...'
                        sh """
                            # Wait for pods to be ready
                            sleep 10
                            
                            # Test Backend
                            kubectl run smoke-test-\${BUILD_NUMBER} \
                                --image=curlimages/curl \
                                --rm -i --restart=Never \
                                -n ${NAMESPACE} \
                                -- curl -f http://backend-service:8000/ || exit 1
                            
                            echo "✅ Smoke tests passed!"
                        """
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo '✅ Pipeline completed successfully! 🎉'
            echo "✅ Backend: ${REGISTRY}/backend:${BUILD_NUMBER}"
            echo "✅ Proxy: ${REGISTRY}/proxy:${BUILD_NUMBER}"
        }
        failure {
            echo '❌ Pipeline failed! Check the logs above.'
        }
        always {
            container('docker') {
                sh 'docker logout || true'
            }
        }
    }
}