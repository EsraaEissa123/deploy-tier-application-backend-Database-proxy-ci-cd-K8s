pipeline {
    agent {
        kubernetes {
            label 'build-deploy-agent'
        }
    }

    environment {
        IMAGE_TAG = "${env.BUILD_NUMBER ?: 'local-'+env.BUILD_ID}"
        DOCKER_REGISTRY = 'esraaeissa81'   // اسم اليوزر في DockerHub
        K8S_NAMESPACE = 'dev'
        DOCKER_CREDENTIALS_ID = 'docker-hub-esraa'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "Checked out ${env.GIT_COMMIT}"
            }
        }

        stage('Build Images') {
            steps {
                echo 'Building backend image...'
                sh "docker build -t ${DOCKER_REGISTRY}/esraaeissa81/backend:${IMAGE_TAG} -f backend/Dockerfile backend/"

                echo 'Building proxy image...'
                sh "docker build -t ${DOCKER_REGISTRY}/esraaeissa81/proxy:${IMAGE_TAG} -f proxy/Dockerfile proxy/"
            }
        }

        stage('Push Images') {
            steps {
                withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    sh "docker push ${DOCKER_REGISTRY}/esraaeissa81/backend:${IMAGE_TAG}"
                    sh "docker push ${DOCKER_REGISTRY}/esraaeissa81/proxy:${IMAGE_TAG}"
                }
            }
        }

        stage('Prepare Manifests') {
            steps {
                echo 'Generating updated Kubernetes manifests...'
                sh '''
        mkdir -p k8s-generated
        for f in k8s/*.yaml; do
          sed "s|LATEST_IMAGE_TAG|'"${IMAGE_TAG}"'|g" "$f" > "k8s-generated/$(basename $f)"
        done
        ls -la k8s-generated
        '''
            }
        }

        stage('Deploy to K8s') {
            steps {
                // نتأكد من ال namespace موجود
                sh "kubectl create namespace ${K8S_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -"
                // نطبق المانيفست الجاهز
                sh "kubectl apply -f k8s-generated/ -n ${K8S_NAMESPACE}"
                sh "kubectl rollout status deployment/backend-deployment -n ${K8S_NAMESPACE} --timeout=120s || true"
                sh "kubectl rollout status deployment/proxy-deployment -n ${K8S_NAMESPACE} --timeout=120s || true"
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    // نحاول الوصول للـ service عبر port-forward مؤقت
                    sh "kubectl -n ${K8S_NAMESPACE} get svc -o wide"
                    // forwarding proxy svc لو اسمه proxy-service أو proxy
                    // هنا نفترض إن اسم الـ service هو proxy-service ويعرض على port 80
                    sh "kubectl port-forward svc/proxy-service 8080:80 -n ${K8S_NAMESPACE} & sleep 3; curl --fail http://127.0.0.1:8080/health || (echo 'SMOKE TEST FAILED' ; exit 1)"
                    sh "pkill -f 'kubectl port-forward' || true"
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline succeeded. Deployed ${DOCKER_REGISTRY} images with tag ${IMAGE_TAG} to ${K8S_NAMESPACE}."
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
