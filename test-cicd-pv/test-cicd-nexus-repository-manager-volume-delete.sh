oc delete -f test-cicd-nexus-repository-manager-volume.yaml
sleep 1

#rm -rf  kvm\/nfs/test-cicd/nexus-repository-manager
#ls -alR kvm\/nfs/test-cicd

oc get pv | grep test-cicd-nexus-repository-manager
oc get pvc -n test-cicd | grep test-cicd-nexus-repository-manager
