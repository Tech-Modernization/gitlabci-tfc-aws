# GitLab CI Terraform Cloud Integration

## Introduction

Documentation for Automation, IaC, Terraform, GitLab, CICD is everywhere. This article will cover simple steps to integrate GitLab CI, Terraform Cloud and any Cloud Technologies. The demo in this article focuses on AWS.

## The Background

Terraform is an open-source software tool for managing cloud infrastructure. A traditional approach depending on the size of the organization is by running the Terraform commands locally while using the Git repository to store the code and using a datastore like Cloud Storage for the remote state. However, as the complexity and size of an organization grows, there is a need for terraform to share structure and workflows in order to enable collaboration among team members and also keep the environments consistent. Terraform Cloud will address this requirement.

GitLab is a software as a service (SaaS) used by developers to plan, store, test, deploy, and monitor source code. Gitlab allows the team members to integrate their work and the entire workflow can be automated and customized using the GitLab CI (Continuous Integration), one of the GitLab services that iteratively builds, tests, and deploys the application. Gitlab CI is an industry-standard tool for implementing CI/CD pipelines and its close integration with Git enables robust version control.

## Getting Started

To begin the automation journey, ideally, you set up your continuous integration (CI) by writing your Terraform resource files with an editor of your choice, you then push the code to a repository via git to Gitlab and the required changes to the infrastructure will be made by the GitLab's CI Pipeline.

Correct tools selection is really important in the CI setup, and the following tools are used for the demo in this article.
- GitLab 30 days trial version is being used.
- Terraform Cloud free version is used which will provide collaboration access for free up to 5 users.
- AWS free tier account can be used.

This article can be used as proof of concept for any organization who likes to begin their automation journey.

## Prerequisite

- GitLab Trial Registration
- Terraform Cloud Free Registration
- AWS Free Tier Account
- Shell based GitLab runner setup to execute jobs (Amazon Linux EC2 instance is used and used GitLab group runner registration token for GitLab runner registration)
- GitLab Menu -> Groups -> (Select your Group) -> CI/CD -> "Register a group runner"
- Terraform Cloud Organization creation
- Terraform Cloud API Token ( Terraform Cloud -> (Select your Organization) -> Settings -> Organization settings -> Teams -> Team API Token -> create token (This token will be used as GitLab variables later)

## GitLab pipeline setup
Stages involved in GitLab CI:
- Create Terraform Workspace
- Create Terraform Workspace variable
- Upload Terraform Code
- Execute Terraform Plan

## GitLab project setup
- Create new blank project e.g. gitlabci-tfc-aws
- Create the following variables in Project -> Settings -> CI/CD -> Expand -> Add Variable
    - AWS_ACCESS_KEY_ID: AWS Credential Value
    - AWS_DEFAULT_REGION: AWS Default region 
    - AWS_SECRET_ACCESS_KEY: AWS Credential Value
    - AWS_SESSION_TOKEN: AWS Credential Value
    - GITLAB_RUNNER: GitLab runner created as in prerequisite step
    - TFC_HTTPS_URL: https://app.terraform.io
    - TFC_ORG: Value created as in prerequisite step
    - TFC_TOKEN: Value created as in prerequisite step
    - TFC_WS_NAME: Terraform workspace name e.g. gitlabci-tfc-aws
- Copy files from https://github.com/contino/gitlabci-tfc-aws

**Note:** The .gitlab-ci.yml configuration file needs to be added to the root directory of your repository in order for Gitlab CI to build your project. The project will be ignored if the .gitlab-ci.yml is not in the repository, or if it is an invalid YAML file.

## Terraform Cloud workspace creation
On successful execution of GitLab stage "TFC_WS_Setup", Terraform Cloud workspace with the name provided in TFC_WS_NAME will be created in your Terraform Cloud Organization.

## Terraform Cloud workspace variable setup
On successful execution of GitLab stage "TFC_WS_Variables_Setup", aws_account with value provided in GitLab variables will be created in Terraform Cloud Workspace

## Terraform Cloud workspace code upload
On successful execution of GitLab stage "TFC_WS_Code_Upload", all *.tf files will be uploaded as configuration version to Terraform Cloud workspace

## Terraform Cloud workspace code execution
On successful execution of GitLab stage "TFC_CODE_APPLY", Terraform run will be triggered in Terraform Cloud Workspace. Terraform "Confirm & Apply" can be executed once after confirming Terraform plan