# run_with_rotate_output
Like nohup run something, the output may be too large if run long time. The script/binary will auto rotate output like the logger in golang/python/java...

Run it like:
./your-binary-with-some-output 2>&1 | ./rotate_output.sh logger-file 4 81920000
