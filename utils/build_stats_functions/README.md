## Build Stats Functions

Python Files that analyze and parse Bazel Build statistics.

Maintainer: @halseycamilla (Tensorflow)

* * *

Python Google Cloud Functions that use EventArc triggers to grab and then parse build profiles and build event protocols from Tensorflow's public build logs. The functions are called every time a build log is uploaded to the Google Cloud Storage bucket storing Tensorflow's build logs. Once the function parses the data it uploads it to a Bigquery table. The folders also include a requirements.txt that states the necessary imports to run the functions.
