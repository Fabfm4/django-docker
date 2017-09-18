# print text with color
out() {
#     Num  Colour    #define         R G B
#     0    black     COLOR_BLACK     0,0,0
#     1    red       COLOR_RED       1,0,0
#     2    green     COLOR_GREEN     0,1,0
#     3    yellow    COLOR_YELLOW    1,1,0
#     4    blue      COLOR_BLUE      0,0,1
#     5    magenta   COLOR_MAGENTA   1,0,1
#     6    cyan      COLOR_CYAN      0,1,1
#     7    white     COLOR_WHITE     1,1,1
    text=$1
    color=$2
    echo "$(tput setaf $color)$text $(tput sgr 0)"
}

create_docker_env(){
    if [[ ! -d "./.env"  ]]; then
        rm -rf ./.env
    fi
    touch ./.env
    echo "PROJECT_TYPE=python" >> ./.env
    echo "PROJECT_NAME=$1" >> ./.env
    echo "PROJECT_ROOT=./src" >> ./.env
    echo "DB_ROOT_PASSWORD=password" >> ./.env
    echo "DB_NAME=$1" >> ./.env
    echo "DB_USERNAME=docker" >> ./.env
    echo "DB_PASSWORD=docker" >> ./.env
    echo "DB_HOST=localhost" >> ./.env
}

create_docker_compose_files(){
    if [[ ! -d "./docker-compose.yml" ]]; then
        rm -rf ./docker-compose.yml
    fi
    touch ./docker-compose.yml
    cat ./utils/docker/docker.init.yml >> ./docker-compose.yml
    cat ./utils/docker/docker.django.yml >> ./docker-compose.yml
    cat ./utils/docker/docker.postgresql.yml >> ./docker-compose.yml
}

create_docker_file(){
    if [[ ! -d "./Dockerfile" ]]; then
        rm -rf ./Dockerfile
    fi
    cp -R ./utils/django/requirements ./src/
    touch ./Dockerfile
    echo "FROM python:3" >> ./Dockerfile
    echo "ENV PYTHONUNBUFFERED 1" >> ./Dockerfile
    echo "RUN mkdir /src" >> ./Dockerfile
    echo "RUN mkdir /src/requirements" >> ./Dockerfile
    echo "WORKDIR /src" >> ./Dockerfile
    echo "ADD src/requirements/local.txt /src/requirements/" >> ./Dockerfile
    echo "ADD src/requirements/base.txt /src/requirements/" >> ./Dockerfile
    echo "RUN pip install -r requirements/local.txt" >> ./Dockerfile
    echo "ADD . /src/" >> ./Dockerfile
}

# create files docker...
create_docker_files(){
    out "Create .env file docker..." 3
    create_docker_env $1
    out "done..." 2
    out "Create docker-compose file ..." 3
    create_docker_compose_files $1
    out "done..." 2
    out "Create Dockerfile ..." 3
    create_docker_file $1
    out "done..." 2
}

create_django_project(){
    out "Creating project Django..." 3
    docker-compose run django django-admin.py startproject $1 .
    docker-compose build
    out "Done..." 2
}

move_core_api(){
    out "Moving Core Api..." 3
    mkdir ./src/$1/settings
    cp ./utils/django/settings_base.py ./src/$1/settings/__init__.py
    cp ./utils/django/settings_local.py ./src/$1/settings
    cp ./utils/django/settings_staging.py ./src/$1/settings
    cp ./utils/django/settings_testing.py ./src/$1/settings
    out "Done..." 2
}

edit_configuration(){
    out "Creating configurations..." 3
    text_original=$1.settings
    text_change=$1.settings.settings_local
    sed "s/${text_original}/${text_change}/g" src/manage.py >> src/manage.py.temp
    rm -rf src/manage.py
    mv src/manage.py.temp src/manage.py
    sed "s/\${PROJECT_NAME}/${1}/g" src/$1/settings/__init__.py >> src/$1/settings/__init__.py.temp
    rm -rf src/$1/settings/__init__.py
    mv src/$1/settings/__init__.py.temp src/$1/settings/__init__.py

    sed "s/\${PROJECT_NAME}/${1}/g" src/$1/settings/settings_local.py >> src/$1/settings/settings_local.py.temp
    rm -rf src/$1/settings/settings_local.py
    mv src/$1/settings/settings_local.py.temp src/$1/settings/settings_local.py

    sed "s/\${PROJECT_NAME}/${1}/g" src/$1/settings/settings_staging.py >> src/$1/settings/settings_staging.py.temp
    rm -rf src/$1/settings/settings_staging.py
    mv src/$1/settings/settings_staging.py.temp src/$1/settings/settings_staging.py

    sed "s/\${PROJECT_NAME}/${1}/g" src/$1/settings/settings_testing.py >> src/$1/settings/settings_testing.py.temp
    rm -rf src/$1/settings/settings_testing.py
    mv src/$1/settings/settings_testing.py.temp src/$1/settings/settings_testing.py
    out "Done..." 2
}

up(){
    out "Up docker..." 3
    docker-compose up -d
    out "Done..." 2
}

version() {
    echo 0.0.1
}

get_project_name(){
    cd src
    project_name=""
    for entry in *
    do
        if [ ! "$entry" == "requirements" ] && [ ! "$entry" == "manage.py" ]; then
            project_name=$entry
        fi
    done
    echo "$project_name"
}

migrate(){
    out "Apply migrations..." 3
    local project_name=$(get_project_name)
    docker exec -it ${project_name}_django bash -c "python3 manage.py migrate"
    out "Done..." 2
}

makemigrations(){
    out "Make migrations..." 3
    local project_name=$(get_project_name)
    docker exec -it ${project_name}_django bash -c "python3 manage.py makemigrations"
    out "Done..." 2
}

createsuperuser(){
    out "Create super user..." 3
    local project_name=$(get_project_name)
    docker exec -it ${project_name}_django bash -c "python3 manage.py createsuperuser"
    out "Done..." 2
}

createapplication(){
    out "Make migrations..." 3
    local project_name=$(get_project_name)
    mkdir src/$project_name/$1
    docker exec -it ${project_name}_django bash -c "python3 manage.py startapp ${1} ${project_name}/${1}"
    out "Done..." 2
}

init(){
    out "Create project Django Docker..." 3

    out "Create directory /src" 3
    if [[ ! -d "./src" ]]; then
        mkdir ./src
    fi
    out "Done..." 2

    out "Create directory /media" 3
    if [[ ! -d "./media" ]]; then
        mkdir ./src
    fi
    out "Done..." 2

    out "Name of project:" 4
    read project_name

    create_docker_files $project_name
    create_django_project $project_name
    move_core_api $project_name
    edit_configuration $project_name
    out "Done..." 2
}

# call arguments verbatim:
$@
