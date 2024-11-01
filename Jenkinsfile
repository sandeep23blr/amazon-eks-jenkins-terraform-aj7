/*
pipeline {
    agent any
       triggers {
        pollSCM "* * * * *"
       }
    stages {
        stage('Build Application') { 
            steps {
                echo '=== Building Petclinic Application ==='
                sh 'mvn -B -DskipTests clean package' 
            }
        }
        stage('Test Application') {
            steps {
                echo '=== Testing Petclinic Application ==='
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage('Build Docker Image') {
            when {
                branch 'master'
            }
            steps {
                echo '=== Building Petclinic Docker Image ==='
                script {
                    app = docker.build("ibuchh/petclinic-spinnaker-jenkins")
                }
            }
        }
        stage('Push Docker Image') {
            when {
                branch 'master'
            }
            steps {
                echo '=== Pushing Petclinic Docker Image ==='
                script {
                    GIT_COMMIT_HASH = sh (script: "git log -n 1 --pretty=format:'%H'", returnStdout: true)
                    SHORT_COMMIT = "${GIT_COMMIT_HASH[0..7]}"
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerHubCredentials') {
                        app.push("$SHORT_COMMIT")
                        app.push("latest")
                    }
                }
            }
        }
        stage('Remove local images') {
            steps {
                echo '=== Delete the local docker images ==='
                sh("docker rmi -f ibuchh/petclinic-spinnaker-jenkins:latest || :")
                sh("docker rmi -f ibuchh/petclinic-spinnaker-jenkins:$SHORT_COMMIT || :")
            }
        }
    }
}
*/
pipeline {
    agent any
    triggers {
        pollSCM "* * * * *"
    }
    environment {
        TARGET_VM = 'ec2-user@3.110.153.6'  // Replace with actual user and target VM IP
        SSH_KEY_CREDENTIALS = 'SSHtoken'  // Replace with your Jenkins SSH key credentials ID
        MAVEN_OPTS = "-Xmx1024m" // Increased memory settings
    }
    stages {
        stage('Build Application') { 
            steps {
                echo '=== Building Petclinic Application ==='
                sh 'mvn -B -DskipTests clean package' 
            }
        }
        stage('Test Application') {
            steps {
                echo '=== Testing Petclinic Application ==='
                sh 'mvn -e -X test'  // Added -e for error logging
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'  // Ensure correct path for junit
                }
                failure {
                    echo 'Tests failed. Please check the Surefire reports for details.'
                }
            }
        }
        stage('Build Docker Image') {
            when {
                branch 'master'
            }
            steps {
                echo '=== Building Petclinic Docker Image ==='
                script {
                    def GIT_COMMIT_HASH = sh(script: "git log -n 1 --pretty=format:'%H'", returnStdout: true).trim()
                    def SHORT_COMMIT = GIT_COMMIT_HASH.substring(0, 7)
                    app = docker.build("petclinic-app:${SHORT_COMMIT}")
                }
            }
        }
        stage('Remove Local Images') {
            steps {
                echo '=== Deleting Local Docker Images ==='
                sh("docker rmi -f petclinic-app:latest || :")
                sh("docker rmi -f petclinic-app:$SHORT_COMMIT || :")
            }
        }
        stage('Deploy to Target VM') {
            steps {
                echo '=== Deploying to Target VM ==='
                sshagent(credentials: [SSHtoken]) {
                    sh """
                    ssh -o StrictHostKeyChecking=no $TARGET_VM 'docker load -i /tmp/petclinic-app.tar && docker stop petclinic || true && docker rm petclinic || true && docker run -d --name petclinic -p 8083:8080 petclinic-app:$SHORT_COMMIT'
                    """
                }
            }
        }
    }
}
