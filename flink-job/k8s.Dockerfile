FROM openjdk:8 AS job-build
WORKDIR /home/gradle/app/

COPY build.gradle settings.gradle ./
COPY gradlew ./
COPY gradle gradle
# To cause download and cache of verifyGoogleJavaFormat dependency
RUN echo "class Dummy {}" > Dummy.java
# download dependencies
RUN ./gradlew build
COPY . .
RUN rm Dummy.java
RUN ./gradlew build
RUN mv /home/gradle/app/build/libs/dynamic-fraud-detection-demo*-deploy.jar /home/gradle/app/build/libs/dynamic-fraud-detection-demo-deploy.jar

# ---

#FROM flink:1.8.2
FROM flink:1.17.1-scala_2.12-java8 
RUN mkdir -p $FLINK_HOME/usrlib

COPY --from=job-build /home/gradle/app/build/libs/dynamic-fraud-detection-demo-deploy.jar $FLINK_HOME/usrlib/job.jar
COPY docker-entrypoint.sh /

USER flink
EXPOSE 8081 6123
ENTRYPOINT ["/docker-entrypoint.sh"]