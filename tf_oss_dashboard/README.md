# TF OSS Dashboard

Dashboard for all continuous statuses on TF GitHub Commits.

Maintainer: @angerson (TensorFlow, SIG Build)

* * * 

This is a dashboard that scrapes the GitHub GraphQL API to
display all statuses on a repository's commits. It requires no backend, no
maintenance and works great on GitHub Pages. It is deployed to 
https://tensorflow.github.io/build/ via https://github.com/tensorflow/build/tree/master/.github/workflows/dashboard.yml

## Can I Use This?

If you are a TensorFlow or Google ML Ecosystem project, e.g.
`google/foo`, you can make a PR to add yourself to
https://tensorflow.github.io/build/foo. Simply:

1. Decide on a config name, e.g. `foo`
2. Duplicate an existing configuration yaml file to "foo.yaml" and update it
3. Add `foo` to the matrix in .github/workflows/dashboard.yml
4. Request a review from @angerson and @MichaelHudgins

If you are not a TensorFlow or Google ML Ecosystem project, or if you want to
use your own domain, you can easily host this dashboard yourself. Just fork
this repository and tweak the configuration. You will need to set up GitHub
Pages for the repo and configure it to update from GitHub Actions, then enable
the Dashboard Generator action. In our repo, "tensorflow.yaml" is treated as
the root configuration for the site, so update .github/workflows/dashboard.yml
to use whatever you rename it to instead.

We'd like to one day provide a single GitHub Action you can use instead of
needing to fork this repository.

## My Scheduled GitHub Actions Don't Appear

The dashboard scrapes the Statuses for all branch commits. Scheduled GitHub
Actions don't set statuses by default, but you can update your workflow to
set a commit status explicitly with an Action like [set-commit-status-action](https://github.com/myrotvorets/set-commit-status-action).

Here is a very basic example:

```
jobs:
  sets_a_commit:
    # Required for set-commit-status-action
    permissions:
      statuses: write

    steps:
      - uses: myrotvorets/set-commit-status-action@master
        # Always run this even if previous steps fail
        if: always()
        with:
          # Note: defaults to Workflow name. You can set "context" with a
          # matrix value if you want to split statuses by their matrix.
          status: ${{ job.status }}
          # set-commit-status-action doesn't know how to fetch SHA by itself
          sha: ${{ github.sha }}
```

## I Lost All My Historical Data, or Want to Change the Dashboard Data

The dashboard accumulates data over time. If you lose it all, have reset it by
accident, or want to delete certain bad data, you can overwrite the data by
creating a GitHub Gist starting from the artifacts from a previous successful
job.

For example, say you want to restore "foo".

1. Download the "foo" artifact data you want to restore from a successful job
2. Create a non-private GitHub Gist containing a file named "foo" whose
   contents are the same as "old.json" from the artifact. You can modify the
   contents if you wish to delete some data. You can have multiple files if you
   want to restore multiple dashboards. Empty or missing files will have no
   effect.
3. Trigger the Dashboard Generater workflow and put the Gist ID (a long
   hexadecimal string) in the "Overwrite..." field.

## Does this Support PR status monitoring?

No. This may be worked on later but is not currently planned.
