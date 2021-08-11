# How to GitLab CI/CD

This document describe:
* How to register the GitLab Runner
* How to setup GitLab CI
* How to setup GitLab CD

## Registering runners
* invoke "docker-compose -f gitlab-cicd/docker-compose.yml up"
* on another terminal, invoke "docker exec -it gitlab-cicd_runner_1 /bin/bash" to go into docker gitlab-cicd_runner_1
* go to the GitLab project page; go to "Settings > CI/CD" and expand Runners
* inside docker gitlab-cicd_runner_1, invoke:
    + for https://gitlab.com/ DinD
        ```shell
        gitlab-runner register -n \
        --url "GITLAB_URL" \
        --registration-token "PROJECT_REGISTRATION_TOKEN" \
        --executor docker \
        --description "Kam's GitLab DinD test runner" \
        --docker-image "docker:20.10" \
        --docker-volumes "/certs/client" \
        --docker-privileged \
        --run-untagged="true"
        ```
    + for https://tess.hk-tess.com:7080/ DinD
        - https://docs.gitlab.com/runner/configuration/tls-self-signed.html#supported-options-for-self-signed-certificates-targeting-the-gitlab-server
        add "--tls-ca-file /etc/gitlab-runner/tess.hk-tess.com.cer \" in the above gitlab-runner register parameter
    + where GITLAB_URL might be "https://gitlab.com/" or https://tess.hk-tess.com:7080/
    + where PROJECT_REGISTRATION_TOKEN is the registration token in GitLab web page > Settings > CI/CD > Runners
* refresh GitLab web page > Settings > CI/CD and expand Runners, should show a new runner under "Runners activated for this project" upon successful runner registration

## How to GitLab CI
* you have Maintainer or Owner role for the project
* assume gitlab runner is properly set up
* create file .gitlab-ci.yml at project's root and push it to gitlab repo
* when the .gitlab-ci.yml is pushed to repository, the runner runs the jobs
* go to the GitLab project page; go to "CI/CD > Pipelines" to check the project's pipeline status

## How to GitLab CD
* ???

## References
* [GitLab CI/CD](https://docs.gitlab.com/ee/ci/)
* [Registering runners](https://docs.gitlab.com/runner/register/)
* [Use Docker to build Docker images](https://docs.gitlab.com/ee/ci/docker/using_docker_build.html)
* [Gitlab-CI runner: ignore self-signed certificate](https://stackoverflow.com/questions/44458410/gitlab-ci-runner-ignore-self-signed-certificate)
* [Export & Download — SSL Certificate from Server (Site URL)](https://medium.com/@menakajain/export-download-ssl-certificate-from-server-site-url-bcfc41ea46a2)
* [GitLab-Runner “listen_address not defined” error](https://stackoverflow.com/a/57205607)
* [Use tags to limit the number of jobs using the runner](https://docs.gitlab.com/ee/ci/runners/configure_runners.html#use-tags-to-limit-the-number-of-jobs-using-the-runner)
* tutorial
    + [Microservices based Application Deployment using Gitlab CI/CD on Docker Swarm](https://faun.pub/microservices-based-application-deployment-using-gitlab-ci-cd-on-docker-swarm-at-digital-ocean-586eefb07294)
    + [Deploy docker swarm from Gitlab CI](https://golangforall.com/en/post/go-deploy-docker-swarm-gitlab.html)
    + [How we’re using GitLab to test and deploy our application(s) to Docker Swarm](https://medium.com/@ju5t_/how-were-using-gitlab-to-test-and-deploy-our-application-s-to-docker-swarm-e3f556dbf8fe)
