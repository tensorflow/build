This dashboard is a work-in-progress. See https://github.com/tensorflow/build/tree/master/tf_oss_dashboard

- Click on a star to favorite that job, placing it at the top of the list.
- Jobs with a diamond in the top-right corner are the jobs that TF DevInfra considers to be "important," and will always appear first, after your favorites.
- Click on a status dot to see the full status for that commit.
- Jobs only appear on this list if they have a result for the last 100 commits.
- Kokoro does not report in-progress jobs, so there are no glowing progress dots.
- Result logs may point to Google-internal inaccessible links. These jobs are
  not supposed to be useful for external users, so this is expected (although not ideal, of course).
- Each "diff" links to the diff between this commit and the previous commit for that job. GitHub occasionally does not show a diff here. Take a screenshot and let us know if that happens.
- The "kokoro" job is actually multiple jobs that are all called "kokoro." If you own one of these, you need to change the `github_status_context` github_scm config value to a real name.
