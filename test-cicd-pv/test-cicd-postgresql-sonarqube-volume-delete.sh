oc delete -f test-cicd-postgresql-sonarqube-volume.yaml
sleep 1

#rm -rf  kvm\/nfs/test-cicd/postgresql-sonarqube
#ls -alR kvm\/nfs/test-cicd

oc get pv | grep test-cicd-postgresql-sonarqube
oc get pvc -n test-cicd | grep test-cicd-postgresql-sonarqube
