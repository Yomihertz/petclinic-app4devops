FROM tomcat

# Copy the WAR file to the webapps directory
COPY **/*.war /usr/local/tomcat/webapps

# Install curl and unzip
RUN apt-get update -y && \
    apt-get install -y curl unzip

# Download and extract New Relic agent
RUN curl -O https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip && \
    unzip newrelic-java.zip -d /usr/local/tomcat/webapps && \
    rm newrelic-java.zip

# Set environment variables for New Relic
ENV JAVA_OPTS="$JAVA_OPTS -javaagent:/usr/local/tomcat/webapps/newrelic/newrelic.jar"
ENV NEW_RELIC_APP_NAME="myapp"
ENV NEW_RELIC_LOG_FILE_NAME=STDOUT
ENV NEW_RELIC_LICENSE_KEY="'ec69feb5532a8ea32dcdf2a694ed2e56FFFFNRAL'"

# Copy New Relic configuration
COPY newrelic.yml /usr/local/tomcat/webapps/newrelic/newrelic.yml

# Set working directory
WORKDIR /usr/local/tomcat/webapps

# Define the entry point
ENTRYPOINT ["java", "-jar", "spring-petclinic-2.4.2.war", "--server.port=8080"]
