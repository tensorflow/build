This is TensorFlow's open-source build status dashboard. It tracks all
GitHub statuses for the TensorFlow repository that are published to GitHub.
The source for the dashboard is on [TensorFlow SIG Build](https://github.com/tensorflow/build/tree/master/tf_oss_dashboard).

Many of these jobs use Google's internal continuous integration systems, and may
not report their results publicly. We're trying to make more of our important
jobs visible to external developers, but security concerns make this a slow
process.

Here are some tips and notes about the dashboard:

#### Basic Usage

- Click on a status dot to see all statuses for that commit. The job you
  clicked is highlighted.
- Click the left toggle switch in the navbar to show a section at the top
  that contains all "important" jobs that the TF build cop team monitors.
- Click the right toggle switch in the navbar to swap to colorblind mode.
- You can zoom out to fit more jobs on the page at once.
- You can copy the URL while a commit modal is open to share that commit.
  - Add `#<commit-id>` to the dashboard URL to find a specific commit.
  - Add `#<cl-number>` to the dashboard URL to find a specific CL (this is one
    easy way to check if your CL has landed on GitHub, on Nightlies, etc). You
    can include the "cl/" too if you're copy-pasting.
  - Add `#<pr-number>` to the dashboard URL to find a specific merged PR.
- This page refreshes roughly every 5 minutes to check for updates.
- The last dot you clicked on is outlined in black. It goes away after refresh.
- Click the "Reveal All" button in a modal to highlight every dot for that
  commit. This is useful for e.g. seeing all commits after a nightly release.
  You can clear the selection by refreshing the page. Only one commit is shown
  at a time.
- Statuses:
  - SUCCESS - all good
  - FAILURE - a test failed
  - ERROR - infrastructure aborted the job for some reason. Kokoro may report
    timeouts as ERRORs.
  - TIMEOUT - Testing ran over time. Kokoro doesn't seem to report this.
  - PENDING - Queued or still running. Kokoro does not report this correctly,
    so this is limited to the few GitHub Actions jobs.

#### Appearance

- All times are always in USA Pacific time.
- The dashboard is a static page, and is re-generated roughly every 15 minutes.
- The "cl/..." badge on each commit links to Google's internal code review
  system and is unavailable to external users. This is the same as the
  "PiperOrigin-RevId" Git trailer in each commit message.
- "Public" build results should be visible to external users. "Internal" build
  results are only visible to Googlers.
- Each "diff" badge links to the diff between this commit and the previous
  commit for that job. GitHub occasionally reports that there is actually no
  diff. Take a screenshot and let us know if that happens.

#### Surprises

- Most nightly jobs run on the same commit, but some don't.
- The date on nightly jobs is the date of the final commit that was included in
  that job. The TF team sometimes refers to these in a different way: the
  "Nightly for today" usually refers to the Nightly jobs whose final commits
  were *yesterday*. So if today is Feb 11, you want the Nightly labeled Feb 10.
- Jobs that run more than once on the same commit have different status
  dots but get doubled-up in the commit overview. This isn't very common.
- Jobs which ran on a PR that was cleanly merged also appear on this dashboard.
  These commits do not show CLs for internal users. For example,
  `import/copybara` is a pull-request job whose status also appears on its
  merge commit, if Copybara decides to merge the PR directly. It's unknown
  whether this happens to all PRs or not.
- Kokoro, Google's CI system that powers most of these jobs, does not report
  "in progress" jobs, so there is no way to see how many Kokoro jobs are
  pending.
- The "kokoro" job (at the very bottom) is actually multiple jobs that are all
  called "kokoro." These statuses overlap and are effectively useless, because
  each dot points to a different job. If your (Google) team owns one of these,
  you need to change the `commit_status_context` github_scm config value to a
  real name.

#### Cookies

We use Google Analytics to help figure out how many people are using the
dashboard, and that's it. If you disable cookies on this site, it will still
function correctly. [Learn more about Cookies
here](https://policies.google.com/technologies/cookies). [Learn more about
Google's privacy policy here](https://policies.google.com/privacy?hl=en-US).
