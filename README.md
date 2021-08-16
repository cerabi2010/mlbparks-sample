# mlbparks-test

## Project : test-cicd

### 1. 소스 패키지 && 이미지 && template
   - 이미지 
     - nexus
     - sonaqube
     - eap73-s2i-basic
     - jenkins
   - 소스 패키지
     - mlbparks 
     - maven file
     - library ( nexus 업로드 )
   - template
     - sonaqube
     - jenkins
     - eap73-s2i-basic

### 2. jenkins app 생성
   - tag 변경 및 imagestream 등록

    registry.wsjeong.ocp4.local:5000/openshift4/ose-jenkins:latest    
    # podman tag registry.wsjeong.ocp4.local:5000/openshift4/ose-jenkins:latest [registry주소]/openshift4/ose-jenkins:latest
    # oc import-image ose-jenkins --from=[registry주소]/openshift4/ose-jenkins:latest  --confirm -n openshift

   - jenkins app 생성

    1.template -> jenkins 선택
    2.ImageStreamTag => ose-jenkins:latest 변경

   - pv 생성

    # oc create -f test-cicd-jenkins-volume.yaml
    # oc get pvc
    NAME                          STATUS   VOLUME                       CAPACITY   ACCESS MODES   STORAGECLASS   AGE
    test-cicd-jenkins-app-pvc   Bound    test-cicd-jenkins-app-pv   20Gi       RWX                           45s    
    
    # PVC 변경
    
    # persistentVolumeClaim:
    #   claimName: test-cicd-jenkins-app-pvc

   - route 설정

    # https 삭제하고 http 연동 route 생성

    # route 생성하고 Port 부분 삭제 후 아래 tls 추가

    #   tls:
    #     termination: edge
    #     insecureEdgeTerminationPolicy: Redirect
    #   wildcardPolicy: None

### 3. neuxs app 생성

   - tag 변경 및 imagestream 등록

    registry.wsjeong.ocp4.local:5000/sonatype/nexus-repository-manager:latest
    # podman tag registry.wsjeong.ocp4.local:5000/sonatype/nexus-repository-manager:latest  [registry주소]/sonatype/nexus-repository-manager:latest
    # oc import-image nexus3 --from=[registry주소]/sonatype/nexus-repository-manager:latest --confirm -n openshift
 
   - nexus app 생성

    1.container image -> nexus image 선택
    
   - pv 생성

    # oc create -f test-cicd-nexus-repository-manager-volume.yaml
    # oc get pvc
    NAME                                           STATUS    VOLUME                                        CAPACITY   ACCESS MODES   STORAGECLASS   AGE
    test-cicd-jenkins-app-pvc                    Bound     test-cicd-jenkins-app-pv                    20Gi       RWX                           83m
    test-cicd-nexus-repository-manager-app-pvc   Bound     test-cicd-nexus-repository-manager-app-pv   20Gi       RWX                           42s

    # PVC 변경
    deploymentconfig 에서 pvc 변경
    persistentVolumeClaim:
    claimName: test-cicd-nexus-repository-manager-app-pvc

   - pv 경로에 library 데이터 복사

    ../nexus-data 하위에 nexus-data백업 복사
    백업 복사 시에 user,group 확인

   - 로그인 및 library 확인 

    # admin / rpinux 로그인 확인
    # mlbparks-proxy / mlbparks-redhat / mlbparks 확인
    # mlbparks library 정보 확인


### 4. sonaqube app 생성
   - tag 변경 및 imagestream 등록

    registry.wsjeong.ocp4.local:5000/openshift4/sonarqube:8.8-community
    # podman tag registry.wsjeong.ocp4.local:5000/openshift4/sonarqube:8.8-community  [registry주소]/openshift4/sonarqube:8.8-community
    # oc import-image nexus3 --from=[registry주소]/openshift4/sonarqube:8.8-community --confirm -n openshift

   - sonaqube app 생성

    # template 에서 sonarqube 선택

   - pv 생성

    ### postgresql-sonarqube
    # oc create -f test-cicd-postgresql-sonarqube-volume.yaml
   
    ###sonarqube 
    # oc create -f test-cicd-sonarqube-volume.yaml

    # oc get pvc
    NAME                                           STATUS   VOLUME                                        CAPACITY   ACCESS MODES   STORAGECLASS   AGE
    test-cicd-jenkins-app-pvc                    Bound    test-cicd-jenkins-app-pv                    20Gi       RWX                           124m
    test-cicd-nexus-repository-manager-app-pvc   Bound    test-cicd-nexus-repository-manager-app-pv   20Gi       RWX                           31m
    test-cicd-postgresql-sonarqube-app-pvc       Bound    test-cicd-postgresql-sonarqube-app-pv       20Gi       RWX                           12m
    test-cicd-sonarqube-app-pvc                  Bound    test-cicd-sonarqube-app-pv                  20Gi       RWX                           7m3s

   - pvc 설정

    ### postgresql-sonarqube
    
    # spec:
    #   volumes:
    #     - name: postgresql-data
    #       persistentVolumeClaim:
    #         claimName: test-cicd-postgresql-sonarqube-app-pvc    <-변경


    ### sonarqube

    # spec:
    #   volumes:
    #     - name: sonarqube-data
    #       persistentVolumeClaim:
    #         claimName: test-cicd-sonarqube-app-pvc     <-변경

    
    #     from:
    #       kind: ImageStreamTag
    #       namespace: openshift     <--- openshift 로 namespace변경
    #       name: 'sonarqube:8.8-community'

   - sonaqube Group 만들기
      
    마우스 오른쪽 버튼 클릭 ->  Edit Application Grouping  
    create application -> group 명 생성

   - sonaqube 로그인
    
    admin / admin 으로 로그인하여 passwd 변경

   - project 생성

    manually 를 선택 -> project 명으로 생성 -> token 생성 -> maven -> 생성된 데이터 복사

   - jenkins 의 jenkins 파일에 sonarqube 에 설정 

    #  stage('Source Analysis ') {
    #      sh "mvn sonar:sonar \
    #        -Dsonar.projectKey=mlbparks-test \
    #        -Dsonar.host.url=http://sonarqube-test-cicd.apps.wsjeong.ocp4.local \
    #        -Dsonar.login=9a312747e6e9cde36daec751edca20dfcc7b1329 "
    #        }


### 5. mlbparks app 생성
   - buildconfig pipeline 생성
    
    # build -> create buildconfig 

    #  spec:
    #    nodeSelector: null
    #    output: {}
    #    resources: {}
    #    successfulBuildsHistoryLimit: 5
    #    failedBuildsHistoryLimit: 5
    #    strategy:
    #      type: JenkinsPipeline
    #      jenkinsPipelineStrategy:
    #        jenkinsfilePath: Jenkinsfile
    #    postCommit: {}
    #    source:
    #      type: Git
    #      git:
    #        uri: 'http://gitlab.wsjeong.ocp4.local/ocp4/mlbparks-sample'
    #        ref: master
    #    runPolicy: Serial
    #  status:
    #    lastVersion: 1

   - setting.xml 설정 변경

    # repository 주소 변경
  
    # <settings>
    # <mirrors>
    #     <mirror>
    #           <id>nexus</id>
    #           <mirrorOf>*</mirrorOf>
    #           <name>Local nexus repository</name>
    #           <url>http://nexus-repository-manager-test-cicd.apps.wsjeong.ocp4.local/repository/mlbparks-proxy/</url>
    #     </mirror>
    #     <mirror>
    #           <id>nexus_1</id>
    #           <mirrorOf>*</mirrorOf>
    #           <name>redhat nexus repository</name>
    #           <url>http://nexus-repository-manager-test-cicd.apps.wsjeong.ocp4.local/repository/mlbparks-redhat/</url>
    #     </mirror>
    #  </mirrors>
    # </settings>

    



   




    




