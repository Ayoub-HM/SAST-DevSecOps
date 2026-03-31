# TP DevSecOps avec Docker

![Build and Scan](https://github.com/Ayoub-HM/TP2_Pipeline-DevSecOps-avec-GitHub-Actions/actions/workflows/docker-deploy.yml/badge.svg)
![CodeQL](https://github.com/Ayoub-HM/TP2_Pipeline-DevSecOps-avec-GitHub-Actions/actions/workflows/codeql-analysis.yml/badge.svg)

## Pipeline DevSecOps

Ce projet implemente un pipeline CI/CD securise pour Docker avec :

- Analyse statique du code avec CodeQL
- Analyse statique additionnelle avec Semgrep
- Analyse qualite et securite avec SonarQube
- Lint du Dockerfile avec Hadolint
- Secret scanning avec Gitleaks
- Scan de l'image Docker avec Trivy
- Scan de vulnerabilites avec Grype
- Security Gates bloquants sur les severites HIGH et CRITICAL
- Generation d'un SBOM
- Surveillance des dependances avec Dependabot

## Architecture de securite

Code Push
    |
    v
[Secret Scanning] --> Blocage si secret
    |
    v
[Security Analysis Job]
    |
    +-- Hadolint (Lint Dockerfile)
    |
    v
[Build Docker Image]
    |
    v
[Security Scan Job]
    |
    +-- Trivy (Scan image)
    +-- Grype (Scan vulnerabilites)
    +-- Security Gates
    |
    v
[Push to GHCR] --> Si securite OK

En parallele, CodeQL s'execute dans un workflow dedie sur `push` et `pull_request` pour `main` et `test`.
Semgrep et SonarQube s'executent aussi dans leurs propres workflows dedies.

## Workflows GitHub Actions

- `.github/workflows/docker-deploy.yml` : pipeline principal container
- `.github/workflows/codeql-analysis.yml` : analyse SAST CodeQL
- `.github/workflows/semgrep.yml` : analyse SAST Semgrep
- `.github/workflows/sonarqube.yml` : analyse SonarQube
- `.github/dependabot.yml` : surveillance automatique des dependances

## Branche de demonstration

La branche `test` est preparee pour la demonstration du TP :

- `package.json` contient des versions volontairement vulnerables
- Dependabot doit proposer des mises a jour
- les scans permettent de montrer la detection

La branche `main` peut ensuite etre utilisee pour presenter l'etat final corrige avec pipeline verte.

## Securite de l'image

- Image de base versionnee : `nginx:1.25.4-alpine`
- Utilisateur non-root dedie
- Headers de securite dans Nginx
- Healthcheck HTTP
- Port applicatif `8080`
- Pas de secret embarque dans l'image

## Execution locale

```bash
docker build -t devops-tp-docker:local .
docker run -p 8080:8080 devops-tp-docker:local
```

Puis ouvrir `http://localhost:8080`.

## Scans de securite locaux

```bash
docker build -t devops-tp-docker:local .
trivy image devops-tp-docker:local
trivy image --severity HIGH,CRITICAL --exit-code 1 devops-tp-docker:local
trivy image --format json --output report.json devops-tp-docker:local
docker run --rm -i hadolint/hadolint < Dockerfile
```

## Demonstration du secret scanning

Activer dans GitHub :

- Secret scanning
- Push protection

Puis tester avec un faux secret :

```bash
git checkout test
echo github_token=ghp_ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 > test-secret.txt
git add test-secret.txt
git commit -m "Test secret detection"
git push
```

Le push doit etre bloque.

## Correctif attendu apres la demonstration

Une seconde phase du TP consiste a corriger les versions vulnerables de `package.json`, accepter les PR Dependabot puis relancer la pipeline jusqu'a obtenir un etat securise.

Versions corrigees attendues ensuite :

```json
{
  "name": "devops-tp-docker",
  "version": "1.0.1",
  "description": "TP DevSecOps avec Docker",
  "scripts": {
    "test": "echo \"No tests yet\""
  },
  "dependencies": {
    "express": "^4.18.2",
    "lodash": "^4.17.21"
  },
  "devDependencies": {
    "eslint": "^8.55.0"
  }
}
```

## Resultats attendus

- Workflow CodeQL actif sur `main` et `test`
- Workflow Semgrep actif sur `main` et `test`
- Workflow SonarQube actif sur `main` et `test`
- Pipeline Docker enchainee dans l'ordre :
  - Secret Scanning
  - Security Analysis
  - Build Docker Image
  - Security Scan
  - Push to GHCR
- Alertes visibles dans l'onglet Security
- PR Dependabot generees
- SBOM exporte en artefact

## Configuration SonarQube a faire par vous

Pour que `.github/workflows/sonarqube.yml` fonctionne, vous devez faire ces actions manuelles :

1. Creer un projet dans SonarQube Server.
2. Donner au projet la cle `Ayoub-HM_TP2_Pipeline-DevSecOps-avec-GitHub-Actions`
   ou bien modifier `sonar-project.properties` pour faire correspondre la cle exacte de votre projet.
3. Dans SonarQube, generer un token d'analyse.
4. Dans GitHub, ajouter un secret de repository nomme `SONAR_TOKEN`.
5. Si vous utilisez SonarQube Cloud, aucune variable `SONAR_HOST_URL` n'est necessaire.
   Le workflow utilise directement `https://sonarcloud.io`.
6. Relancer le workflow `SonarQube`.

Notes importantes :

- d'apres la documentation SonarSource, `SONAR_TOKEN` doit etre un secret GitHub
- l'action officielle recommandee est `SonarSource/sonarqube-scan-action`
- sur SonarQube Server, l'analyse de pull request et l'analyse multi-branches sont disponibles a partir de Developer Edition
- si vous utilisez une edition Community et que les PR posent probleme, gardez le workflow mais faites surtout vos verifications sur la branche principale de votre projet
- si vous utilisez SonarQube Server au lieu de SonarQube Cloud plus tard, il faudra remettre `SONAR_HOST_URL` vers votre serveur

## Interventions manuelles necessaires

Certaines taches doivent etre faites dans GitHub par vous :

- activer `Secret scanning`
- activer `Push protection`
- verifier `Code scanning` si GitHub demande une activation via l'interface
- creer/configurer le projet SonarQube
- ajouter `SONAR_TOKEN` dans les secrets GitHub
- observer et merger les PR Dependabot
- faire la demonstration du faux secret puis nettoyer l'historique de test si necessaire


