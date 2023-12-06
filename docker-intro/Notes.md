# Intro
Let's assume you have docker installed.

## Does It Work?
Let's try `hello-world`.

```bash
tyler@cse-johnmcclane:~/presentations/docker-intro$ docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

## Important Terminology
**host**: this is the infrastructure (e.g. VM, server) that the container will run on.

**image**: a packaged binary that contains (almost) everything you need to run a container

**container**: a sandboxed process that runs your application

you **download** an image and you **run** a container on your **host**.

## Let's try their suggestion

run `docker run -it ubuntu bash`

how do i know im in the container?

well, i'm root@644a31...

let's open another terminal and check something:

```bash
tyler@cse-johnmcclane:~/presentations/docker-intro$ docker ps
CONTAINER ID   IMAGE                                COMMAND                  CREATED          STATUS          PORTS                                                  NAMES
644a31c42747   ubuntu                               "bash"                   56 seconds ago   Up 55 seconds                                                          magical_williamson
```

yep! that's the right image. i can't do much in here though, it isn't a full blown linux install. it doesn't even have `less` or `vi` or even `nano`...


## Ok well that was fun. Now what?
Let's try something more complicated. Let's build our own image.

First, we need an idea of what kind of application we need to run, and then we need a Dockerfile. Let's do a simple web server.

I've got a very simple `index.html` that we will serve.

Dockerfiles can be extremely complicated and there are many tools to make it easier to orchestrate complex programs (such as docker-compose). This one should be pretty easy. Dockerfiles have their own unique syntax and there's a lot of documentation and articles explaining how to do that if you ever need to do it yourself. The one we're using will be fairly self explanatory.


### Building an Image

To build the image, we can run `docker build -t my-nginx .`.

This tells docker to build the Dockerfile in the present directory, and to name the image `my-nginx`.

We can see our new image if we run `docker image ls` (notice the name)

```bash
tyler@cse-johnmcclane:~/presentations/docker-intro$ docker image ls
REPOSITORY                TAG          IMAGE ID       CREATED        SIZE
my-nginx                  latest       61ce56cb049c   19 hours ago   187MB
ubuntu                    latest       b6548eacb063   5 days ago     77.8MB
hello-world               latest       9c7a54a9a43c   7 months ago   13.3kB
lyanthropos/doenet_test   apache-dev   9b0e116b5302   2 years ago    59.3MB
lyanthropos/doenet_test   mysql-dev    69f4ccfae81d   3 years ago    455MB
lyanthropos/doenet_test   php-dev      ef83f7160451   8 years ago    1.39GB
```

Tags are a helpful way to organize different versions of the image. "latest" is a default tag that will always have your most recent build.

### Running an Image
Now that we know we have an image built, we can run a container properly with the command:
`docker run -p 8080:80 my-nginx`

Ok, what's the `-p` flag doing? It is saying that the host's port 8080 should route traffic it receives to the `my-nginx` port 80 (standard http port). This let's us specify port access very specifically and flexibly.

### Check out the logs!
A good application will send the logs directly to the Docker logging interface. We're currently running docker in the foreground so we can see them in the terminal, but if we ran it in the background we could access them with the command:

`docker logs <container_id>`

If we try to access html files or endpoints that don't exist, we actually see the messages in the log!

There are also ways to make that nicer so you don't have to look up the container id every time (such as giving your container a name when you run it -- the `docker run --help` command goes over all of that and more!).

In docker, you **really** don't want to log to a file directly, because as soon as the container stops or restarts, any data that hasn't been stored somewhere permanent will be gone.

### Docker best practices -- Impermanence
This takes us to an important point and one of the key best practices you'll here: you should not be storing data of any kind in your docker application.

This is because docker containers are meant to be like "livestock" rather than "pets" -- they should be interchangeable, and you should be able to take one container, kill it, and replace it with another one and it should work normally.

As soon as you have stateful data, that core principle is violated. Now all of a sudden, you have to figure out how to save data from your broken container before you can shut it down, and then you have to figure out how to get it back in to the new container you want to spin up.

## A Quantum Leap
Ok, that was a very brief intro to building and running a container. But let's look at some actual code.

### Basic Structure
The basic structure of the puppet code for these apps are:

1) Set up environment files needed for the application to run successfully.
2) Download the image and start a container
3) Set up some apache vhosts to make the URL "prettier" (alternatively, the F5 could have an FQDN which forwards traffic to the host machine, and this is what should be done if there are containers spread out among multiple hosts)

This general structure is applicable to quite a few web applications that the Web team is trying to migrate.

#### Important Notes
We are injecting information into the containers in two visible ways:

1) we are providing an .env file. these are just normal environment variables that the web application knows how to look for.

2) we are providing a "volume" -- this is one way that docker lets us make resources from the host machine available to the container. In this case, we are providing certificates from the host machine to the container. Certificates will be let's-encrypted, but that's a bit more involved than this illustration.

### Process
What about the non-docker pieces of the process?

1. Customer (Web Team or other group who wants to host services)
2. Artifactory: customer will upload docker images to artifactory
    - Puppet pulls down image from artifactory
    - Access is controlled by Grouper
3. Database: any web application that needs to store data should have a database (hosted by OIT)
4. F5: If the application will be load balanced, the F5 will distribute traffic to the pool members, which are the docker hosts.

## The End
There's a ton more to docker. We've really only discussed pretty simple web applications, but docker can run practically any kind of service you'd want.

It's so powerful and abstract and "simple" to use that it's easy to forget how complicated it really is under the hood. It feels like magic.

##### Appendix: Important Commands
- sudo docker ps: list the running docker containers
- sudo docker image ls: list the docker images on the host machine
- sudo docker container: lists the docker containers on the host machine
- sudo docker run: the command to use to run a container from an impage
- sudo docker inspect: tells you LOTS of information, some of which might be helpful for debugging
- sudo docker exec -it <container_id> /bin/sh: gives you a shell inside the container
- sudo docker logs <container_id>: shows you the docker logs for a container

##### Appendix: Other helpful info
- Our documentation: https://tdx.umn.edu/TDClient/31/Portal/KB/ArticleDet?ID=7390
- A more complicated Dockerfile, for one of the web team's applications: https://github.umn.edu/CSE-IT/ddev-2d/blob/main/.docker/Dockerfile