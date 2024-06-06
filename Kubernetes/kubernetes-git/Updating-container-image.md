Updating a container image:

1- First,  build a new version of image by adding a new tag to the image:
docker build -t pierre1980/kube-app:2.0 .

2-Push the new version of the image to docker hub
- docker push pierre1980/kube-app:2.0

3- Now we have to set the new version of the image in the container:
- kubectl set image deployment/kub-deploy kube-app=pierre1980/kube-app:2.0

having the kub-deploy as the deployment name and the kube-app as the conatiner name equal to the new version of the image.

-4 Finally run the kubectl rollout status command to watch the status of a rollout until it's complete. This is useful for monitoring the deployment process and ensuring that your application is successfully deployed or updated, Run: 
kubectl rollout status deployment/kub-deploy



ROLLBACK:

To rollback to a prior version run:
- kubectl rollout undo deployment/kub-deploy

To rollback to the first version run:
- kubectl rollout undo deployment/kub-deploy --to-revision=1

To see the different version of deployment that has made:
- kubectl rollout history deployment/kub-deploy

To see details about a specific deployment:
- kubectl rollout history deployment/kub-deploy --revision=1




To expose an external port to a deployment and make accesible from the controleplan and outside:
- kubectl expose deployment kub-deploy --type=LoadBalancer --port=8080


 
