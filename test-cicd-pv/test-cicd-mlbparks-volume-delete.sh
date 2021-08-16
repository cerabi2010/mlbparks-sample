oc delete -f test-cicd-mlbparks-volume.yaml
sleep 1

#rm -rf  kvm\/nfs/test-cicd/mlbparks
#ls -alR kvm\/nfs/test-cicd

oc get pv | grep test-cicd-mlbparks
oc get pvc -n test-cicd | grep test-cicd-mlbparks
