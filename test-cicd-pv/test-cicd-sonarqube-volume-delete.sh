oc delete -f test-cicd-sonarqube-volume.yaml
sleep 1

#rm -rf  kvm\/nfs/test-cicd/sonarqube
#ls -alR kvm\/nfs/test-cicd

oc get pv | grep test-cicd-sonarqube
oc get pvc -n test-cicd | grep test-cicd-sonarqube
