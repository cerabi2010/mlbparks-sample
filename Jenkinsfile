node('maven') {
  
  stage('Clone sources') {
       sh " oc whoami"
       sh " pwd ; id;"
       git url: "http://gitlab.wsjeong.ocp4.local/ocp4/mlbparks-test"
    }

  stage('Maven Build') {  
    sh "cp settings.xml ~/.m2/"
    sh "mvn package"
    sh "ls  *"
  }
  
  stage('Source Analysis ') {
    sh "mvn sonar:sonar \
      -Dsonar.projectKey=mlbparks-test \
      -Dsonar.host.url=http://sonarqube-test-cicd.apps.wsjeong.ocp4.local \
      -Dsonar.login=78ede155c18c725472759d8934c2c01364a19415 "
      }

  stage('Build Image(OCP Deploy)') {
    sh "oc start-build mlbparks-test --from-file=target/mlbparks-1.0.war --follow"  
  }
   
}
