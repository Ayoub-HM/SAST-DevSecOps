# devops-tp-docker-hammou-ayoub

![Build and Scan](https://github.com/Ayoub-HM/TP2_Pipeline-DevSecOps-avec-GitHub-Actions/actions/workflows/docker-deploy.yml/badge.svg)
![CodeQL](https://github.com/Ayoub-HM/TP2_Pipeline-DevSecOps-avec-GitHub-Actions/actions/workflows/codeql-analysis.yml/badge.svg)

## Pipeline DevSecOps

Ce projet implémente un pipeline CI/CD sécurisé pour Docker avec :

- Analyse statique du code (CodeQL)
- Lint du Dockerfile (Hadolint)
- Scan de l'image Docker (Trivy)
- Scan des dépendances (Dependabot)
- Secret Scanning
- Security Gates (blocage sur vulnérabilités critiques)
- SBOM (Software Bill of Materials)

## Architecture de Sécurité
