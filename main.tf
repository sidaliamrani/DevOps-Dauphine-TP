resource "google_sql_database" "wordpress" {
  name     = "wordpress"
  instance = "main-instance"
}

resource "google_sql_user" "wordpress" {
  name     = "wordpress"
  instance = "main-instance"
  password = "ilovedevops"
}


data "google_iam_policy" "noauth" {
   binding {
      role = "roles/run.invoker"
      members = [
         "allUsers",
      ]
   }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
   location    = google_cloud_run_service.default.location # remplacer par le nom de votre ressource
   project     = google_cloud_run_service.default.project # remplacer par le nom de votre ressource
   service     = google_cloud_run_service.default.name # remplacer par le nom de votre ressource

   policy_data = data.google_iam_policy.noauth.policy_data
}


  - name: 'gcr.io/cloud-builders/docker'
    id: 'Build Docker Image'
    args:
      - 'build'
      - '-t'
      - 'us-central1-docker.pkg.dev/single-mix-449209-n7/my-repository/my-custom-wordpress:${_IMAGE_TAG}'
      - '.'

  - name: 'gcr.io/cloud-builders/docker'
    id: 'Push Docker Image'
    args:
      - 'push'
      - 'us-central1-docker.pkg.dev/single-mix-449209-n7/my-repository/my-custom-wordpress:${_IMAGE_TAG}'
images:
  - 'us-central1-docker.pkg.dev/single-mix-449209-n7/my-repository/my-custom-wordpress:${_IMAGE_TAG}'
substitutions:
    _IMAGE_TAG: '1.1'
resource "google_cloud_run_service" "wordpress-service" {
  name     = "wordpress-service"
  location = "us-central1"
  project  = var.project_id

  template {
    spec {
      containers {
        image = "us-central1-docker.pkg.dev/g8single-mix-449209-n7/my-repository/my-custom-wordpress:1.1"
        ports {
          container_port = 80
        }
      }
    }
  }

  traffic {
    latest_revision = true
    percent         = 100
  }
}
data "google_iam_policy" "noauth" {
   binding {
      role = "roles/run.invoker"
      members = [
         "allUsers",
      ]
   }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
   location    = google_cloud_run_service.wordpress-service.location
   project     = google_cloud_run_service.wordpress-service.project
   service     = google_cloud_run_service.wordpress-service.name

   policy_data = data.google_iam_policy.noauth.policy_data
}