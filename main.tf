terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "sonarqube" {
  metadata {
    name = "sonarqube"
  }
}

resource "helm_release" "postgresql" {
  name       = "db"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  namespace  = kubernetes_namespace.sonarqube.metadata[0].name
  timeout    = 300

  set {
    name  = "global.postgresql.auth.username"
    value = "sonar"
  }

  set {
    name  = "global.postgresql.auth.password"
    value = "sonar123"
  }

  set {
    name  = "global.postgresql.auth.database"
    value = "sonar"
  }
}

resource "helm_release" "sonarqube" {
  name       = "sonarqube"
  repository = "https://SonarSource.github.io/helm-chart-sonarqube"
  chart      = "sonarqube"
  namespace  = kubernetes_namespace.sonarqube.metadata[0].name
  depends_on = [helm_release.postgresql]
  timeout    = 300

  values = [
    <<-EOF
    postgresql:
      enabled: false

    # Environment variables for database connection
    env:
      - name: SONAR_JDBC_URL
        value: "jdbc:postgresql://db-postgresql:5432/sonar"
      - name: SONAR_JDBC_USERNAME
        value: "sonar"
      - name: SONAR_JDBC_PASSWORD
        value: "sonar123"

    # SonarQube properties
    sonarProperties:
      sonar.jdbc.url: "jdbc:postgresql://db-postgresql:5432/sonar"
      sonar.jdbc.username: "sonar"
      sonar.jdbc.password: "sonar123"
    
    persistence:
      enabled: true
      size: 3Gi
    
    ingress:
      enabled: true
      annotations:
        kubernetes.io/ingress.class: nginx
    EOF
  ]
}
