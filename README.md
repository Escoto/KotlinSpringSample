# Kotlin + Spring + Docker 

This is an example on how to build a simple Web API with Kotlin and run it on docker.

Take a look at my [medium post](https://medium.com/codex/containerizing-your-application-b1644385e2ef "Containerizing Your First Application"), where I explain in detail how this repository works.

## In short

### You need:
1. Docker
2. Kotlin
3. Maven

### To run:

In a console pointing to the root directory of this project.

```
$> mvn compile
$> mvn package
$> docker build -t kotlinapihello .
$> docker run -d -p 8080:8080 --name workinginstance kotlinapihello
```

-----------------

For the proper documentation on how all this is tied together please take a look at my [medium post](https://medium.com/codex/containerizing-your-application-b1644385e2ef "Containerizing Your First Application").