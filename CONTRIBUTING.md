# How to Contribute

## Project Showcase

To add your own project to our showcase, you can:

* Add a link and a short description to the Project Showcase in
  [README.md](README.md) in the same format as the other links, and then file a
  PR, or,
* Copy the [Directory Template](directory_template) into a new folder, fill in
  the template, and add it to the showcase. Make sure to update
  [CODEOWNERS](CODEOWNERS) as well. If you contribute a new project, you're
  expected to own it.

Please try to keep lists and tables in alphabetical sort order.

This repo is a good place for small additions, but if the project is a big one,
it may be better to maintain it in your own repository for better encapsulation
of responsibility (and so you can make your own rules for further
contributions).

## Community Builds Table

We maintain a list of community-maintained TensorFlow builds and packages in
[README.md](README.md). If you'd like to add your own build to the list,
please file a PR. Your build must follow these rules:

1. Your build cannot be more than two weeks late. So e.g. a "nightly" build
   shouldn't be more than two weeks old, and a "release" build should include
   TensorFlow 2.X.Y within two weeks after 2.X.Y is released by the TensorFlow
   team. After two weeks we'll reach out to you. At worst, we'll remove the
   entry from the table while you fix it.
   
   We'd prefer to feature community builds that are up-to-date with the latest
   TF release, but you can also specify that your build is a legacy build that
   only targets old versions of TF.  Please keep up with patch releases for
   the latest official TF version.
   
2. Your build requires two maintainers: a main contact and a backup contact. 
   Add these to the "Community Build Infra Owners" table in the README.
   
Thank you!

## Contributor License Agreement

There are just a few small standard guidelines you need to follow as well:

Contributions to this project must be accompanied by a Contributor License
Agreement. You (or your employer) retain the copyright to your contribution;
this simply gives us permission to use and redistribute your contributions as
part of the project. Head over to <https://cla.developers.google.com/> to see
your current agreements on file or to sign a new one.

You generally only need to submit a CLA once, so if you've already submitted one
(even if it was for a different project), you probably don't need to do it
again.

## Code reviews

All submissions, including submissions by project members, require review. We
use GitHub pull requests for this purpose. Consult
[GitHub Help](https://help.github.com/articles/about-pull-requests/) for more
information on using pull requests.

## Community Guidelines

This project follows
[TensorFlow's Code of Conduct](CODE_OF_CONDUCT.md), which is mirrored in our
repository.
