This is TensorFlow's open-source build status dashboard. It tracks all
GitHub statuses for the TensorFlow repository that are published to GitHub.
The source for the dashboard is on [TensorFlow SIG Build](https://github.com/tensorflow/build/tree/master/tf_oss_dashboard).

Many of these jobs use Google's internal continuous integration systems, and may
not report their results publically. We're trying to make more of our important
jobs visible to external developers, but security concerns make this a slow
process.

Here are some tips and notes about the dashboard:

- Click on a status dot to see all statuses for that commit. The job you
  clicked is highlighted.
- Click the toggle switch in the navbar to swap to colorblind mode.
- All times are always in USA Pacific time.
- The dashboard is a static page, and is re-generated roughly every 15 minutes.
  This page refreshes roughly every 5 minutes to check for updates.
- The "cl/..." badge on each commit links to Google's internal code review
  system and is unavailable to external users. This is the same as the
  "PiperOrigin-RevId" Git trailer in each commit message.
- You can zoom out to fit more jobs on the page at once.
- Click on a star to favorite that job. Favorites are displayed in the
  "Favorites" section at the top, in the same order as they are on the page.
- "Public" build results should be visible to external users. "Internal" build
  results are only visible to Googlers.
- Each "diff" links to the diff between this commit and the previous commit for
  that job. GitHub occasionally reports that there is actually no diff. Take a
  screenshot and let us know if that happens.
- Jobs which ran on a PR that was cleanly merged also appear on this dashboard.
  These commits do not show CLs for internal users. For example,
  `import/copybara` is a pull-request job whose status also appears on its
  merge commit, if Copybara (the Google system that merges PRs or pulls them
  into our internal code review system) decides to merge the PR directly. It's
  if this actually applies all PRs, rather than just some.
- Kokoro, Google's CI system that powers most of these jobs, does not report
  "in progress" jobs, so there is no way to see how many Kokoro jobs are
  pending.
- The "kokoro" job is actually multiple jobs that are all called "kokoro." These
  statuses overlap and are effectively useless, because each dot points to a
  different job. If your (Google) team owns one of these, you need to change the
  `commit_status_context` github_scm config value to a real name.
