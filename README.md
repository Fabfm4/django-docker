# Django-Docker

script wrote in bash with the finallity to create a django project with Docker like environmet

# requirements

[Docker](https://docs.docker.com/engine/installation/)
[Docker Compose](https://docs.docker.com/compose/install/)

# Getting Started

```bash
git clone https://github.com/Fabfm4/django-docker.git
mv django-docker/* .
chmod +x django-docker-cli.sh
sudo mv django-docker-cli.sh /usr/local/bin/django-docker
```

### Create Project
```bash
django-docker init
```

### Run Project
```bash
django-docker up
```

### Makemigrations
```bash
django-docker makemigrations
```

### Run migrations
```bash
django-docker migrate
```

### Create Application
```bash
django-docker startapp [app-label]
```
