# Suite of verification tests for the SINGLE TensorFlow wheel in /tf/pkg
# or whatever path is set as $TF_WHEEL.

setup_file() {
    cd /tf/pkg
    if [[ -z "$TF_WHEEL" ]]; then
        export TF_WHEEL=$(find /tf/pkg -iname "*.whl")
    fi
}

teardown_file() {
    rm -rf /tf/venv
}

@test "Wheel is manylinux2010 (manylinux_2_12) compliant" {
    python3 -m auditwheel show "$TF_WHEEL" > audit.txt
    grep --quiet 'This constrains the platform tag to "manylinux_2_12_x86_64"' audit.txt
}

@test "Wheel conforms to upstream size limitations" {
    WHEEL_MEGABYTES=$(stat --format %s "$TF_WHEEL" | awk '{print int($1/(1024*1024))}')
    case "$TF_WHEEL" in
        *cpu*manylinux*) LARGEST_OK_SIZE=170 ;;
        *cpu*win*)       LARGEST_OK_SIZE=170 ;;
        *manylinux*)     LARGEST_OK_SIZE=450 ;;
        *win*)           LARGEST_OK_SIZE=350 ;;
        *macos*)         LARGEST_OK_SIZE=170 ;;
        *)
            echo "The wheel's name is in an unknown format."
            exit 1
            ;;
    esac
    echo "Size of $TF_WHEEL is $WHEEL_MEGABYTES / $LARGEST_OK_SIZE megabytes."
    test "$WHEEL_MEGABYTES" -le "$LARGEST_OK_SIZE"
}

# Note: this runs before the following tests, so TF is installed in the venv
# and the venv is active
@test "Wheel is installable" {
    python3 -m venv /tf/venv
    source /tf/venv/bin/activate
    python3 -m pip install "$TF_WHEEL"
}

@test "TensorFlow is importable" {
    source /tf/venv/bin/activate
    python3 -c 'import tensorflow as tf; t1=tf.constant([1,2,3,4]); t2=tf.constant([5,6,7,8]); print(tf.add(t1,t2).shape)'
}

# Is this still useful?
@test "TensorFlow has Keras" {
    source /tf/venv/bin/activate
    python3 -c 'import sys; import tensorflow as tf; sys.exit(0 if "_v2.keras" in tf.keras.__name__ else 1)'
}

# Is this still useful?
@test "TensorFlow has Estimator" {
    source /tf/venv/bin/activate
    python3 -c 'import sys; import tensorflow as tf; sys.exit(0 if "_v2.estimator" in tf.estimator.__name__ else 1)'
}
