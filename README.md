# CI/CD with Golang

[![Go](https://github.com/devenes/containerization-dummy-go/actions/workflows/go.yml/badge.svg)](https://github.com/devenes/containerization-dummy-go/actions/workflows/go.yml) [![Docker Build And Push](https://github.com/devenes/containerization-dummy-go/actions/workflows/dockerx.yml/badge.svg)](https://github.com/devenes/containerization-dummy-go/actions/workflows/dockerx.yml)

## Part 1

- Since we want to trigger the CI/CD process with the push we will perform within the GitHub ecosystem, we have pushed the source code to our own repo.

- We used GitHub Actions, the Pipeline as Code tool offered by GitHub, to trigger the process with the push commit.

- A script was written to perform the Docker build process with the trigger and to give the version number.

```
FROM golang:1.16-alpine

WORKDIR /app

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY *.go .

RUN go build -o /dummy-app
EXPOSE 8080

CMD ["/dummy-app"]
```

- The username and password of the Docker Hub Registry, which is the environment we will push our Docker images to after we build, are defined as secrets in GitHub Repo Settings and used as environment variables in the GitHub Actions pipeline.

- To trigger our Jenkins pipeline, we add the curl command to the end of our GitHub Actions pipeline and our token that we defined in Jenkins to send a request to the webhook link of the server.

  - Note: Token is defined as environment variable in secrets from GitHub repo settings.

In our Jenkins pipeline, we first stop and delete the running container and clean up the old images. Then we download the Image that we have determined with the current tag number and run it as a container.

We give 80 as the port number in the docker run command so that our Jenkins running on 8080 and our Go application do not conflict with each other.

The output of our operations looks like this:

Our image that we pushed to Docker Hub after we got the Build:

## Part 2

Before starting to operate on CodeBuild, we give some permissions to reach the ECR and to examine the post-process logs in detail:

We selected our repo by logging into CodeBuild with GitHub. Then we edit the build spec file with the links we got from the ECR settings:

```
version: 0.2

phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - docker build -t mydockerrepo .
      - docker tag mydockerrepo:latest 32976713052.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image...
      - docker push 32976713052.dkr.ecr.us-east-1.amazonaws.com/mydockerrepo:latest
```

We see that our action steps have been successfully completed:

![image](</readme-images/1%20(6).png>)

At the end of our Image Build process, we come to the repo we opened on ECR to see if our push to ECR was successful:

![image](</readme-images/1%20(7).png>)

<!-- # CI/CD with Golang

## 1. K??s??m

- GitHub ekosistemi i??inde ger??ekle??tirece??imiz Push i??lemiyle birlikte CI/CD s??recini tetiklemek istedi??imiz i??in kaynak kodu kendi repomuza pushlad??k.

- Push commiti ile birlikte s??reci tetikleme i??lemini ba??latmak i??in GitHub?????n sundu??u Pipeline as Code arac?? olan GitHub Actions????? kulland??k.

- Docker build i??leminin tetikleme ile birlikte ger??ekle??mesi ve versiyon numaras??n??n verilmesi i??in script yaz??ld??.

- Docker imajlar??m??z?? build ald??ktan sonra push???layaca????m??z ortam olan Docker Hub Registry???nin kullan??c?? ad?? ve ??ifresi GitHub Repo Ayarlar?? i??inde secrets olarak tan??mland?? ve GitHub Actions pipeline????? i??inde ortam de??i??keni olarak kullan??ld??.

- Jenkins pipeline?????m??z?? tetiklemek i??in server???a ait webhook linkine istek g??ndermek amac??yla GitHub Actions pipeline?????m??z??n sonuna curl komutu ve Jenkins???e de tan??mlad??????m??z token?????m??z?? ekliyoruz.

  - Not: Token GitHub repo ayarlar??ndan secretlar i??erisinde ortam de??i??keni olarak tan??mland??.

Jenkins pipeline?????m??zda ??ncelikle ??al????an konteyn??r?? durdurup siliyoruz ve eski imajlar?? temizliyoruz. Ard??ndan g??ncel tag numaras?? ile belirledi??imiz ??maj?? indirip konteyn??r olarak ??al????t??r??yoruz.

Docker run komutu i??inde port numaras?? olarak 80???i veriyoruz ki 8080???de ??al????an Jenkins ile Go uygulamam??z birbiriyle ??ak????mas??n.

????lemlerimizin ????kt??s?? ??u ??ekilde kar????m??za geliyor:

Build ald??ktan sonra Docker Hub???a pushlad??????m??z imaj??m??z:

## 2. K??s??m

CodeBuild ??zerinde i??lem yapmaya ba??lamadan ??nce ECR???a ula??mas?? i??in ve i??lem sonras?? loglar??n detayl?? olarak incelenebilmesi i??in baz?? yetkiler veriyoruz:

CodeBuild ??zerinde GitHub ile oturum a??arak repomuzu se??tik. Sonras??nda build spec dosyas??n?? ECR ayarlar??ndan ald??????m??z linklerle d??zenliyoruz:

????lem ad??mlar??m??z??n ba??ar??yla tamamland??????n?? g??r??yoruz:

Image Build i??lemimiz sonunda ECR???a push aktivitemiz ba??ar??l?? olmu?? mu, bunu g??rmek i??in ECR ??zerinde a??t??????m??z repoya geliyoruz: -->
