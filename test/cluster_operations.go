package test

import (
	"flag"
	"fmt"
	batchv1 "k8s.io/api/batch/v1"
	apiv1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/client-go/util/homedir"
	"log"
	"path/filepath"
	"time"
)

func newK8s(kubeConfigPath string) (*kubernetes.Clientset, error) {
	var clientSet *kubernetes.Clientset
	var kubeconfig *string

	if len(kubeConfigPath) > 0 {
		kubeconfig = &kubeConfigPath
	} else if home := homedir.HomeDir(); home != "" {
		kc := filepath.Join(home, ".kube", "config")
		kubeconfig = &kc
	} else {
		return nil, fmt.Errorf("kube config path not specified and could not be found in home directory")
	}

	flag.Parse()
	config, err := clientcmd.BuildConfigFromFlags("", *kubeconfig)
	if err != nil {
		return nil, err
	}
	clientSet, err = kubernetes.NewForConfig(config)
	if err != nil {
		return nil, err
	}

	return clientSet, nil
}

func executeJob(jobName string, imageName string, containerArgs []string, clientSet *kubernetes.Clientset) (containerExitCode int32, cErr error) {

	ctx := generateDefaultContext()

	jobsClient := clientSet.BatchV1().Jobs("default")

	var ttl int32 = 0

	job := &batchv1.Job{
		ObjectMeta: metav1.ObjectMeta{
			Name: jobName,
		},
		Spec: batchv1.JobSpec{
			TTLSecondsAfterFinished: &ttl,
			Template: apiv1.PodTemplateSpec{
				ObjectMeta: metav1.ObjectMeta{
					Name: jobName,
				},
				Spec: apiv1.PodSpec{
					RestartPolicy: apiv1.RestartPolicyNever,
					Containers: []apiv1.Container{
						{
							Name:  jobName,
							Image: imageName,
							Args:  containerArgs,
						},
					},
				},
			},
		},
	}

	podWatchList, err := clientSet.CoreV1().Pods("default").Watch(ctx, metav1.ListOptions{})

	if err != nil {
		return 0, fmt.Errorf("error creating pod watch: %w", err)
	}

	_, _ = jobsClient.Create(ctx, job, metav1.CreateOptions{})

	defer func() {
		deletionPropagation := metav1.DeletePropagationForeground
		err := jobsClient.Delete(ctx, jobName, metav1.DeleteOptions{
			PropagationPolicy: &deletionPropagation,
		})
		if err != nil {
			cErr = err
		}
	}()

	go func() {
		time.Sleep(300 * time.Second)
		log.Print("Timeout waiting for pod to complete")
		podWatchList.Stop()
	}()

	for event := range podWatchList.ResultChan() {
		p, ok := event.Object.(*apiv1.Pod)
		if !ok {
			log.Fatal("unexpected type")
		}
		if p.Status.Phase == apiv1.PodSucceeded {
			return p.Status.ContainerStatuses[0].State.Terminated.ExitCode, nil
		}
	}

	return -1, fmt.Errorf("error waiting for pod to complete")
}
