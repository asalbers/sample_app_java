#
# Build stage
#
FROM maven:3.6.0-jdk-11-slim AS build
WORKDIR /build
COPY pom.xml .
COPY src ./src
COPY web ./web
RUN mvn clean package

#
# Package stage
#
FROM tomcat:9.0.64-jre11-openjdk-slim
COPY tomcat-users.xml /usr/local/tomcat/conf
COPY --from=build /build/target/*.war /usr/local/tomcat/webapps/FlightBookingSystemSample.war
EXPOSE 8080
CMD ["catalina.sh", "run"]