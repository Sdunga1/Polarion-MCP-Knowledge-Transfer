gcloud auth login
# config docker
gcloud auth configure-docker
# set project to serious-mile-462615-a2
gcloud config set project serious-mile-462615-a2
docker build -t polarion_v22r2 .
docker tag polarion_v22r2 us-central1-docker.pkg.dev/serious-mile-462615-a2/atoms-rm/polarion
docker push us-central1-docker.pkg.dev/serious-mile-462615-a2/atoms-rm/polarion