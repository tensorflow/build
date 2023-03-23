This dashboard is a work-in-progress. 

Source is on [SIG Build](https://github.com/tensorflow/build/tree/master/tf_oss_dashboard).

- Click on a status dot to see all statuses for that commit.
- Click on a star to favorite that job. Favorites move to the front of the section. Order is not really consistent.
- Kokoro, Google's CI system that powers most of these jobs, does not report "in progress" jobs, so there is no way to see how many Kokoro jobs are pending.
- "Public" build results should be visible to external users. "Internal" build results are only visible to Googlers.
- Each "diff" links to the diff between this commit and the previous commit for that job. GitHub occasionally does not show a diff here. Take a screenshot and let us know if that happens.
- The "kokoro" job is actually multiple jobs that are all called "kokoro." If you own one of these, you need to change the `github_status_context` github_scm config value to a real name.
