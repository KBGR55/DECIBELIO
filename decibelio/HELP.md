

# Eclipse Starter for Jakarta EE

This is a sample application generated by the Eclipse Foundation starter for Jakarta EE.

### Liberty's Dev Mode

During development, you can use Liberty's development mode (dev mode) to code while observing and testing your changes on the fly.
With the dev mode, you can code along and watch the change reflected in the running server right away;
unit and integration tests are run on pressing Enter in the command terminal; you can attach a debugger to the running server at any time to step through your code.

You can run the application by executing the following command from the directory where this file resides. Please ensure you have installed a [Java SE 8+ implementation](https://adoptium.net/?variant=openjdk8) appropriate for your Jakarta EE version and runtime choice (we have tested with Java SE 8, Java SE 11 and Java SE 17). Note, the [Maven Wrapper](https://maven.apache.org/wrapper/) is already included in the project, so a Maven install is not actually needed. You may first need to execute `chmod +x mvnw`.

```
./mvnw liberty:dev
```

Once the runtime starts, you can access the project at http://localhost:9080.

You can also run the project via Docker. To build the Docker image, execute the following commands from the directory where this file resides. Please ensure you have installed a [Java SE 8+ implementation](https://adoptium.net/?variant=openjdk8) appropriate for your Jakarta EE version/runtime choice and [Docker](https://docs.docker.com/get-docker/) (we have tested with Java SE 8, Java SE 11 and Java SE 17). Note, the [Maven Wrapper](https://maven.apache.org/wrapper/) is already included in the project, so a Maven install is not actually needed. You may first need to execute `chmod +x mvnw`.

```
./mvnw clean package
docker build -t decibelio-api:v1 .
```

You can then run the Docker image by executing:

```
docker run -it --rm -p 9080:9080 decibelio-api:v1
```

Once the runtime starts, you can access the project at http://localhost:9080/.


### Liberty's Deployment Mode with docker compose

To deployment run command to create images and deployment in production mode

    docker-compose -f docker-compose.yml up

To deployment run command to create images and deployment in development mode

    docker-compose --env-file .docker-env-dev -f docker-compose.yml up

Other form to start containers

    docker-compose -f docker-compose.yml start

To finisih

    docker-compose -f docker-compose.yml stop

## Specification examples


### JWT Auth

Have a look at the **TestSecureController** class (main application) which calls the protected endpoint on the secondary application.
The **ProtectedController** contains the protected endpoint since it contains the _@RolesAllowed_ annotation on the JAX-RS endpoint method.

The _TestSecureController_ code creates a JWT based on the private key found within the resource directory.
However, any method to send a REST request with an appropriate header will work of course. Please feel free to change this code to your needs.



### Rest Client

A type safe invocation of HTTP rest endpoints. Specification [here](https://microprofile.io/project/eclipse/microprofile-rest-client)

The example calls one endpoint from another JAX-RS resource where generated Rest Client is injected as CDI bean.

