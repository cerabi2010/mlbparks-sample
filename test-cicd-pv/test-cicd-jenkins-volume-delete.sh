oc delete -f test-cicd-jenkins-volume.yaml
sleep 1

#rm -rf  kvm\/nfs/test-cicd/jenkins
#ls -alR kvm\/nfs/test-cicd

oc get pv | grep test-cicd-jenkins
oc get pvc -n test-cicd | grep test-cicd-jenkins
