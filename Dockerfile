# my-builder
FROM openshift/base-centos7

# TODO: Put the maintainer name in the image metadata
LABEL maintainer="yann.chaysinh@gmail.com"

# TODO: Rename the builder environment variable to inform users about application you provide them
ARG JAVA_VERSION="1.8-131"

ARG GROUP_ID=org.springframework
ARG ART_ID=gs-rest-service
ARG ART_VERSION=0.1.1-SNAPSHOT
ARG REPO=libs-snapshot-local

# TODO: Set labels used in OpenShift to describe the builder image
LABEL io.k8s.description="Platform for building springboot apps" \
      io.k8s.display-name="java-runtime 0.0.1" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="runtime,openjdk-1.8.131,"


RUN yum install -y curl java-1.8.0-openjdk-devel &&  \
    yum clean all -y

# sets io.openshift.s2i.scripts-url label that way, or update that label
#COPY ./s2i/bin/ /usr/libexec/s2i
#RUN chmod -R +x /usr/libexec/s2i

#RUN mkdir /opt/app-root

# download app from Artifactory 
RUN version=$(curl -u${ART_USER}:${ART_PASS} "${ART_URL}/api/search/latestVersion?g=${GROUP_ID}&a=${ART_ID}&v=${ART_VERSION}&repos=${REPO}") && curl -u${ART_USER}:${ART_PASS} "${ART_URL}/${REPO}/{GROUP_ID}/${ART_ID}/${ART_VERSION}/${ART_ID}-${version}.jar" -O && mv ${ART_ID}* /opt/app-root/ 

RUN chown -R 1001:1001 /opt/app-root

RUN ls -l /opt/app-root/${ART_ID}*

RUN java -version

# This default user is created in the openshift/base-centos7 image
USER 1001

# TODO: Set the default port for applications built using this image
EXPOSE 8080

# TODO: Set the default CMD for the image
#CMD ["/usr/libexec/s2i/usage"]
CMD ["$(ls /opt/app-root/${ART_ID}*)"]
ENTRYPOINT ["java", "-jar"]
