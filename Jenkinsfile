// Jenkinsfile - يتبع المراحل الست المطلوبة في السيناريو

pipeline {
    // 1. طلب عميل مؤقت (Agent) باستخدام التسمية التي تم إعدادها في Jenkins Cloud
    agent {
        label 'build-deploy-agent'
    }

    environment {
        // يتم استخدام رقم البناء كعلامة للصورة (Tag)
        IMAGE_TAG = "${BUILD_NUMBER}"
        // استبدل هذا المسار بالمسار الحقيقي لسجل Docker Hub الخاص بك
        DOCKER_REGISTRY = "esraaeissa81/deploy-tier-app"
        // اسم النطاق المستهدف للنشر (كما هو محدد في المشروع)
        K8S_NAMESPACE = "dev"
        // ID الخاص ببيانات اعتماد Docker Hub التي قمت بإدخالها في Jenkins
        DOCKER_CREDENTIALS_ID = 'docker-hub-esraa' // استبدل بالـ ID الخاص بك
    }

    stages {
        // المرحلة 1: Source Stage - سحب الكود (يتم تلقائياً)
        stage('Source Check') {
            steps {
                echo "Starting CI/CD for Build #${IMAGE_TAG}."
                echo "Code checked out from: ${env.GIT_URL}"
            }
        }

        // المرحلة 2: Build Stage - بناء صور Docker
        stage('Build Images') {
            steps {
                // تنفيذ الأوامر داخل الحاوية 'docker-kubectl-tools' (التي تحتوي على Docker CLI)
                container('docker-kubectl-tools') {
                    echo "Building backend image..."
                    // بناء صورة backend (الموجودة في مجلد backend/)
                    sh "docker build -t ${DOCKER_REGISTRY}/backend:${IMAGE_TAG} ./backend"

                    echo "Building proxy image..."
                    // بناء صورة proxy (الموجودة في مجلد proxy/ أو nginx/)
                    sh "docker build -t ${DOCKER_REGISTRY}/proxy:${IMAGE_TAG} ./proxy"
                    
                    echo "Building database image..."
                    // بناء صورة database (الموجودة في مجلد database/)
                    sh "docker build -t ${DOCKER_REGISTRY}/database:${IMAGE_TAG} ./database"
                }
            }
        }

        // المرحلة 3: Push Stage - دفع الصور إلى السجل (DockerHub)
        stage('Push Images') {
            steps {
                container('docker-kubectl-tools') {
                    // استخدام بيانات الاعتماد المخزنة في Jenkins لتسجيل الدخول
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

        // المرحلة 4: Deploy Stage - النشر إلى Kubernetes
        stage('Deploy to Dev') {
            steps {
                container('docker-kubectl-tools') {
                    // تحديث العنصر النائب في ملفات النشر بـ IMAGE_TAG الجديدة
                    sh "sed -i 's|LATEST_IMAGE_TAG|${IMAGE_TAG}|g' k8s/*.yaml"

                    // إنشاء الـ Namespace المستهدف 'dev' إذا لم يكن موجوداً
                    sh "kubectl create namespace ${K8S_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -"
                    
                    echo "Applying Kubernetes manifests in ${K8S_NAMESPACE}..."
                    // تطبيق ملفات النشر (Deployments, Services, PVCs)
                    sh "kubectl apply -f k8s/ --namespace ${K8S_NAMESPACE}"
                }
            }
        }

        // المرحلة 5: Smoke Test - اختبار التدخين للتحقق من الصحة
        stage('Smoke Test') {
            steps {
                container('docker-kubectl-tools') {
                    echo "Waiting for proxy pod to be ready..."
                    // الانتظار حتى يصبح الـ Deployment الخاص بالـ proxy جاهزاً
                    sh "kubectl wait --for=condition=ready pod -l app=proxy -n ${K8S_NAMESPACE} --timeout=300s"
                    
                    // الحصول على عنوان IP/Port للوصول إلى الخدمة
                    sh "PROXY_HOST=$(kubectl get svc proxy-service -n ${K8S_NAMESPACE} -o jsonpath='{.spec.clusterIP}')"
                    
                    echo "Running health check on http://$PROXY_HOST/health"
                    // إجراء فحص صحي (Health Check) على نقطة النهاية /health [cite: 52]
                    sh "curl --fail http://$PROXY_HOST/health || error 'Smoke test failed: /health endpoint unreachable or returned an error!'"
                }
            }
        }

        // المرحلة 6: Notification - الإشعار بالنتائج
        stage('Notification') {
            steps {
                echo "Pipeline finished successfully. Version ${IMAGE_TAG} deployed to ${K8S_NAMESPACE}."
            }
        }
    }
}