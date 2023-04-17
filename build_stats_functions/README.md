## Build Stats Functions

Python Files that analyze and parse Bazel Build statistics.

Maintainer: @halseycamilla (Tensorflow)

* * *

Python Google Cloud Functions that use EventArc triggers to grab and then parse build profiles and build event protocols from TensorFlow's public build logs. The functions are called every time a build log is uploaded to the Google Cloud Storage bucket storing TensorFlow's build logs. Once the function parses the data it uploads it to a Bigquery table. The folders also include a requirements.txt that states the necessary imports to run the functions.

## Testing Locally:

- Download any missing requirements from requirements.txt
- Clone the tensorflow/build Github repository on your local device
- Use `pwd` to get your local path
- `cd` into `build/build_stats_functions` and into each of the `build_profile` and `build_event_protocol` directories
- In each directory, edit the `_test.py` file and add your local path to the start of any files starting with `//build` 
- Do `pytest` and the name of the `_test.py` file to run the tests
