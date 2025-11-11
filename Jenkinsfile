pipeline {
    agent {
        kubernetes {
            label 'build-deploy-agent'   // نفس الاسم القديم عشان Pipelines الحالية
            yaml '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: build-deploy-agent
spec:
  containers:
  - name: docker
    image: docker:29.0.0-dind
    command:
    - dockerd-entrypoint.sh
    args:
    - --host=tcp://0.0.0.0:2375
    - --host=unix:///var/run/docker.sock
    securityContext:
      privileged: true
    tty: true
'''
        }
    }

    environment {
        IMAGE_TAG = "${env.BUILD_NUMBER ?: 'local-'+env.BUILD_ID}"
        DOCKER_REGISTRY = 'esraaeissa81'
        K8S_NAMESPACE = 'dev'
        DOCKER_CREDENTIALS_ID = 'docker-hub-esraa'
    }

    stages {
        stage('Check Agent') {
            steps {
                container('docker') {
                    sh 'echo "Running on Pod: $NODE_NAME"'
                    sh 'docker version'
                }
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
                echo "Checked out ${env.GIT_COMMIT}"
            }
        }

        stage('Build Images') {
            steps {
                container('docker') {
                    echo 'Building backend image...'
                    sh "docker build -t ${DOCKER_REGISTRY}/backend:${IMAGE_TAG} -f backend/Dockerfile backend/"

                    echo 'Building proxy image...'
                    sh "docker build -t ${DOCKER_REGISTRY}/proxy:${IMAGE_TAG} -f proxy/Dockerfile proxy/"
                }
            }
        }

        stage('Push Images') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                        sh "docker push ${DOCKER_REGISTRY}/backend:${IMAGE_TAG}"
                        sh "docker push ${DOCKER_REGISTRY}/proxy:${IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Prepare Manifests') {
            steps {
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
                sh "kubectl create namespace ${K8S_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -"
                sh "kubectl apply -f k8s-generated/ -n ${K8S_NAMESPACE}"
                sh "kubectl rollout status deployment/backend-deployment -n ${K8S_NAMESPACE} --timeout=120s || true"
                sh "kubectl rollout status deployment/proxy-deployment -n ${K8S_NAMESPACE} --timeout=120s || true"
            }
        }

        stage('Smoke Test') {
            steps {
                sh "kubectl -n ${K8S_NAMESPACE} get svc -o wide"
                sh "kubectl port-forward svc/proxy-service 8080:80 -n ${K8S_NAMESPACE} & sleep 3; curl --fail http://127.0.0.1:8080/health || (echo 'SMOKE TEST FAILED' ; exit 1)"
                sh "pkill -f 'kubectl port-forward' || true"
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
