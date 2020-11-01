package test

import (
	"bytes"
	"context"
	"flag"
	"fmt"
	"io"
	"log"
	"path/filepath"

	batchv1 "k8s.io/api/batch/v1"
	apiv1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/client-go/util/homedir"
)

func NewK8s(kubeConfigPath string) (*kubernetes.Clientset, error) {
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

func ExecuteJob(jobName string, imageName string, containerArgs []string, labels map[string]string, clientSet *kubernetes.Clientset) (int32, string, error) {

	ctx := generateDefaultContext(KubernetesTimeout)

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
					Name:   jobName,
					Labels: labels,
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

	podWatchList, err := clientSet.CoreV1().Pods("default").Watch(ctx, metav1.ListOptions{
		LabelSelector: fmt.Sprintf("job-name=%s", jobName),
	})

	if err != nil {
		return 0, "", fmt.Errorf("error creating pod watch: %w", err)
	}

	_, _ = jobsClient.Create(ctx, job, metav1.CreateOptions{})

	var lastPodLog string
	for event := range podWatchList.ResultChan() {
		p, ok := event.Object.(*apiv1.Pod)
		if !ok {
			log.Fatal("unexpected type")
		}
		if p.Status.Phase == apiv1.PodSucceeded {
			logs := getPodLogs(ctx, clientSet, *p)
			return p.Status.ContainerStatuses[0].State.Terminated.ExitCode, logs, nil
		} else if p.Status.Phase == apiv1.PodFailed {
			logs := getPodLogs(ctx, clientSet, *p)
			log.Printf("job pod failed - logs are: %s", logs)
		}
		lastPodLog = getPodLogs(ctx, clientSet, *p)
	}

	return -1, lastPodLog, fmt.Errorf("error waiting for pod to complete")
}

func getPodLogs(ctx context.Context, clientSet *kubernetes.Clientset, pod apiv1.Pod) string {
	podLogOpts := apiv1.PodLogOptions{}

	req := clientSet.CoreV1().Pods(pod.Namespace).GetLogs(pod.Name, &podLogOpts)
	podLogs, err := req.Stream(ctx)
	if err != nil {
		return "error in opening stream"
	}
	defer podLogs.Close()

	buf := new(bytes.Buffer)
	_, err = io.Copy(buf, podLogs)
	if err != nil {
		return "error in copy information from podLogs to buf"
	}
	str := buf.String()

	return str
}
