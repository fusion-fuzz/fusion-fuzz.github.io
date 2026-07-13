// RUN: fir-opt --split-input-file --cuf-device-global="cuda-unified=true" %s | FileCheck %s --check-prefix=UNIFIED
     +test)
#else
