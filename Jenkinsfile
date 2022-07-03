def appName = env.JOB_BASE_NAME
def environment = params.NAMESPACE.substring(params.NAMESPACE.lastIndexOf('-') + 1)

pipeline {
    agent any
    stages {
        stage('Restart the pods') {
            when { expression { params.RESTART_ONLY } }
            steps {
                sh "oc rollout latest dc/${appName} -n ${params.NAMESPACE}"
            }
        }
        // Update the ImageStream tags (needed for tracking tags like "latest" or "v2.1")
        stage('Update ImageStream tags') {
            when { expression { !params.RESTART_ONLY } }
            steps {
                sh "oc import-image ${appName} --all -o name -n ${params.NAMESPACE}"
            }
        }
        stage('Apply configuration') {
            when { expression { !params.RESTART_ONLY } }
            steps {
                sh "oc process -f ${appName}/${appName}.yaml --param-file=${appName}/${appName}_${environment}.params | oc apply -f - -n ${params.NAMESPACE}"
            }
        }
        stage('Wait for rollout to finish') {
            steps {
                sh "sleep 2 && oc rollout status dc/${appName} --timeout=90s -n ${params.NAMESPACE}"
            }
        }
    }
    post {
        always {
            sh "oc status --suggest -n ${params.NAMESPACE}"
            script { currentBuild.description = "${params.NAMESPACE}, branch: ${params.BRANCH}" }
        }
    }
}
