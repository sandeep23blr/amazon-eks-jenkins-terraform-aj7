FROM anapsix/alpine-java
VOLUME /tmp
ADD target/spring-petclinic-2.1.0.war app.war
EXPOSE 8083
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.war"]
