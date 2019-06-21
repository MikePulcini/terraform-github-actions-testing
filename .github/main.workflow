workflow "Terraform" {
  resolves = "terraform-plan"
  on = "pull_request"
}

action "filter-to-pr-open-synced" {
  uses = "actions/bin/filter@master"
  args = "action 'opened|synchronize'"
}

action "terraform-fmt" {
  uses = "hashicorp/terraform-github-actions/fmt@v0.3.1"
  needs = "filter-to-pr-open-synced"
  secrets = ["GITHUB_TOKEN"]
  env = {
    TF_ACTION_WORKING_DIR = "."
  }
}

action "terraform-init" {
  uses = "hashicorp/terraform-github-actions/init@v0.3.1"
  needs = "terraform-fmt"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    TF_ACTION_WORKING_DIR = "."
  }
}

action "terraform-validate" {
  uses = "hashicorp/terraform-github-actions/validate@v0.3.1"
  needs = "terraform-init"
  secrets = ["GITHUB_TOKEN"]
  env = {
    TF_ACTION_WORKING_DIR = "."
  }
}

action "terraform-plan" {
  uses = "hashicorp/terraform-github-actions/plan@v0.3.1"
  needs = "terraform-validate"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    TF_ACTION_WORKING_DIR = "."
    # If you're using Terraform workspaces, set this to the workspace name.
    TF_ACTION_WORKSPACE = "default"
  }
}


workflow "Apply" {
  resolves = "terraform-apply"
  # Here you can see we're reacting to the pull_request event.
  on = "pull_request"
}

# Filter to pull request merged events.
action "merged-prs-filter" {
  uses = "actions/bin/filter@master"
  args = "merged true"
}

# Additionally, filter to pull requests merged to master.
action "base-branch-filter" {
  uses = "hashicorp/terraform-github-actions/base-branch-filter@v0.3.1"
  # If you want to run apply when merging into other branches,
  # set this regex.
  args = "^master$"
  needs = "merged-prs-filter"
}

# init must be run before apply.
action "terraform-init-apply" {
  uses = "hashicorp/terraform-github-actions/init@v0.3.1"
  needs = "base-branch-filter"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    TF_ACTION_WORKING_DIR = "."
  }
}

# Finally, run apply.
action "terraform-apply" {
  needs = "terraform-init-apply"
  uses = "hashicorp/terraform-github-actions/apply@v0.3.1"
  secrets = ["GITHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    TF_ACTION_WORKING_DIR = "."
    TF_ACTION_WORKSPACE = "default"
  }
}
