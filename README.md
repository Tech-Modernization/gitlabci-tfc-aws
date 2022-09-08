# GitLab CI, Terraform Cloud and AWS Integration

## Introduction

Documentation for Automation, IaC, Terraform, GitLab, CICD is everywhere. This article will cover steps to integrate GitLab CI, Terraform Cloud and AWS by creating an AWS EC2 instance with Terraform code and GitLab CI. Terraform code can be extended to include additional components as required.

## The Background

**Terraform** is an open-source software tool for managing cloud infrastructure. A traditional approach depending on the size of the organization is by running the Terraform commands locally while using the Git repository to store the code and using a datastore like Cloud Storage for the remote state. However, as the complexity and size of an organization grows, there is a need for terraform to share structure and workflows in order to enable collaboration among team members and also keep the environments consistent. Terraform Cloud will address this requirement.

**GitLab** is a software as a service (SaaS) used by developers to plan, store, test, deploy, and monitor source code. Gitlab allows the team members to integrate their work and the entire workflow can be automated and customized using the GitLab CI (Continuous Integration), one of the GitLab services that iteratively builds, tests, and deploys the application. Gitlab CI is an industry-standard tool for implementing CI/CD pipelines and its close integration with Git enables robust version control.

## Getting Started

To begin the automation journey, ideally, you set up your continuous integration (CI) by writing your Terraform resource files with an editor of your choice, you then push the code to a repository via git to Gitlab and the required changes to the infrastructure will be made by the GitLab's CI Pipeline.

Correct tools selection is really important in the CI setup, and the following tools are used for the demo in this article.

- GitLab 30 days trial version is being used
- Terraform Cloud free version is used which will provide collaboration access for free up to 5 users
- AWS free tier account can be used

This article can be used as proof of concept for any organization who likes to begin their automation journey.

## Prerequisite

- Terraform Cloud Free Registration
- Terraform Cloud Setup
- GitLab Trial Registration 
- GitLab Runner Setup 
- AWS Free Tier Account

## Terraform Cloud Setup

- Create a new Organization (This value is used as GitLab variable "TFC_ORG" which is explained in the upcoming section)
- Create Terraform Cloud API Token by navigating Terraform Cloud -> (Select your Organization) -> Settings -> Organization settings -> Teams -> Team API Token -> Create a team token (Copy this token value in a safe manner and this token is used as GitLab variable "TFC_TOKEN" which is explained in the upcoming section)

## GitLab Runner Setup

GitLab runner is required to execute jobs defined in GitLab stages. 

GitLab Registration Token is required to register a GitLab runner which can be retrieved by navigating to GitLab Menu -> Groups -> (Select your Group) -> CI/CD -> "Register a group runner"

The following commands are used to setup Amazon Linux EC2 instance as GitLab runner
- **curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh" | sudo bash**
- **sudo yum install gitlab-runner**
- **sudo gitlab-runner register (will prompt for the following values)**
    - Enter the GitLab instance URL (for example, https://gitlab.com/):  https://gitlab.com/
    - Enter the registration token: (Retrieved as explained in above step)
    - Enter a description for the runner: (E.g. Terraform Cloud AWS GitLab Runner Shell)
    - Enter tags for the runner (comma-separated): (E.g. tfc-aws-gitlab-runner-shell)
    - Enter optional maintenance note for the runner: (Provide any notes if required or leave it blank)
    - Enter an executor: kubernetes, custom, parallels, shell, virtualbox, docker-ssh+machine, docker, docker-ssh, ssh, docker+machine: **shell**

On successful execution, GitLab runner will be registered as shown

## GitLab pipeline setup

**Stages involved in GitLab CI:**

- Create Terraform Workspace
- Create Terraform Workspace Variable
- Upload Terraform Code
- Execute Terraform Plan
- Destroy Terraform Execution (Cleanup)

## GitLab project setup

**Step 1:** Create new blank project e.g. gitlabci-tfc-aws

**Step 2:** Create the following variables in Project -> Settings -> CI/CD -> Expand -> Add Variable
- AWS_ACCESS_KEY_ID: AWS Credential Value 
- AWS_DEFAULT_REGION: AWS Default region
- AWS_SECRET_ACCESS_KEY: AWS Credential Value
- AWS_SESSION_TOKEN: AWS Credential Value
- GITLAB_RUNNER: GitLab runner tag created as in prerequisite step E.g. tfc-aws-gitlab-runner-shell
- TFC_HTTPS_URL: https://app.terraform.io
- TFC_ORG: Value created as in prerequisite step
- TFC_TOKEN: Value created as in prerequisite step
- TFC_WS_NAME: Terraform workspace name e.g. gitlabci-tfc-aws

**Step 3: Copy files from https://github.com/contino/gitlabci-tfc-aws**

**Note:** The .gitlab-ci.yml configuration file needs to be added to the root directory of your repository in order for Gitlab CI to build your project. The project will be ignored if the .gitlab-ci.yml is not in the repository, or if it is an invalid YAML file.

## Terraform Cloud Workspace Creation

On successful execution of GitLab stage "TFC_WS_Setup", Terraform Cloud workspace with the name provided in TFC_WS_NAME (GitLab variables) will be created in your Terraform Cloud Organization.

## Terraform Cloud Workspace Variable Setup
On successful execution of GitLab stage "TFC_WS_Variables_Setup", aws_account with value provided in GitLab variables will be created in Terraform Cloud Workspace.

"aws_account" variable is set to be sensitive, so it cannot be modified at Terraform Cloud Workspace. "aws_account" variable is set with the format as {access_key="<<aws_access_key_id value>>", secret_key="<<aws_secret_access_key value>>", token="<<aws_session_token value>>" region="ap-southeast-2"} where the values of AWS credentials are substituted with GitLab variables defined in the GitLab Project Setup.

## Terraform Cloud Workspace Code Upload
On successful execution of GitLab stage "TFC_WS_Code_Upload", all *.tf files will be uploaded as configuration version to Terraform Cloud workspace.

## Terraform Cloud Workspace Code Execution
On successful execution of GitLab stage "TFC_CODE_APPLY", Terraform run will be triggered in Terraform Cloud Workspace. 
Terraform "Confirm & Apply" can be executed once after confirming Terraform plan.


## Terraform Cloud Workspace Code Destroy Execution
GitLab stage "TFC_CODE_DESTROY" is set as manual step in GitLab CI and it can be executed manually to destroy the infrastructure created in the previous stage.Terraform "Confirm & Apply" can be executed once after confirming Terraform plan to destroy.