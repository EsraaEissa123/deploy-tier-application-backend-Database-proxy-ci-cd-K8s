pipeline {
    agent {
        kubernetes {
            label 'build-deploy-agent'
            container 'jnlp' 
        }
    }

    environment {
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_REGISTRY = "esraaeissa81/deploy-tier-app"
        K8S_NAMESPACE = "dev"
        DOCKER_CREDENTIALS_ID = 'docker-hub-esraa'
    }

    stages {
        stage('Source Check') {
            steps {
                echo "Starting CI/CD for Build #${IMAGE_TAG}."
                echo "Code checked out from: ${env.GIT_URL}"
            }
        }

        stage('Build Images') {
            steps {
                container('docker-kubectl-tools') {
                    echo "Building backend image..."
                    sh "docker build -t ${DOCKER_REGISTRY}/backend:${IMAGE_TAG} ./backend"

                    echo "Building proxy image..."
                    sh "docker build -t ${DOCKER_REGISTRY}/proxy:${IMAGE_TAG} ./proxy"
                    
                    echo "Building database image..."
                    sh "docker build -t ${DOCKER_REGISTRY}/database:${IMAGE_TAG} ./database"
                }
            }
        }

        stage('Push Images') {
            steps {
                container('docker-kubectl-tools') {
                    withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "docker login -u $USER -p $PASS"

                        echo "Pushing images to registry..."
                        sh "docker push ${DOCKER_REGISTRY}/backend:${IMAGE_TAG}"
                        sh "docker push ${DOCKER_REGISTRY}/proxy:${IMAGE_TAG}"
                        sh "docker push ${DOCKER_REGISTRY}/database:${IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Deploy to Dev') {
            steps {
                container('docker-kubectl-tools') {
                    sh "sed -i 's|LATEST_IMAGE_TAG|${IMAGE_TAG}|g' k8s/*.yaml"

                    sh "kubectl create namespace ${K8S_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -"
                    
                    echo "Applying Kubernetes manifests in ${K8S_NAMESPACE}..."
                    sh "kubectl apply -f k8s/ --namespace ${K8S_NAMESPACE}"
                }
            }
        }

        stage('Smoke Test') {
            steps {
                container('docker-kubectl-tools') {
                    echo "Waiting for proxy pod to be ready..."
                    sh "kubectl wait --for=condition=ready pod -l app=proxy -n ${K8S_NAMESPACE} --timeout=300s"
                    
                    script {
                        def proxyHost = sh(
                            script: "kubectl get svc proxy-service -n ${K8S_NAMESPACE} -o jsonpath='{.spec.clusterIP}'",
                            returnStdout: true
                        ).trim()
                        
                        echo "Running health check on http://${proxyHost}/health"
                        sh "curl --fail http://${proxyHost}/health || error 'Smoke test failed: /health endpoint unreachable or returned an error!'"
                    }
                }
            }
        }

        stage('Notification') {
            steps {
                echo "Pipeline finished successfully. Version ${IMAGE_TAG} deployed to ${K8S_NAMESPACE}."
            }
        }
    }
}