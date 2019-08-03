This is version 1

Next enchancement will implement:
1) Able to decide process snail using GPU or CPU
2) Check the version of GPU if used.

How to set to run gpu:

1.     Disable/Enable GPU
To verify Snail using CPU only, GPU will need to be disabled by setting the following variable. This can be added to .bashrc to make sure variable is set for all sessions. Note:  Executing labcodes will overwrite this file, so the source must be changed in /home/genia/projects/labcodes/scripts

export CUDA_VISIBLE_DEVICES=
unset CUDA_VISIBLE_DEVICES    (to remove setting)

Use the following command to verify GPU is disabled (this required existence of progam, memcheck_demo to exist. See appendix A):

cuda-memcheck ./memcheck_demo
 
 With GPU disabled:
 $ ./memcheck_demo
 Mallocing memory
 Running unaligned_kernel
 Ran unaligned_kernel: no CUDA-capable device is detected
 Sync: no CUDA-capable device is detected
 Running out_of_bounds_kernel
 Ran out_of_bounds_kernel: no CUDA-capable device is detected
 Sync: no CUDA-capable device is detected
  
  With GPU enabled:
  $ unset CUDA_VISIBLE_DEVICES
  $ ./memcheck_demo
  Mallocing memory
  Running unaligned_kernel
  Ran unaligned_kernel: invalid device function
  Sync: no error
  Running out_of_bounds_kernel
  Ran out_of_bounds_kernel: invalid device function
  Sync: no error

  memcheck_demo can be copied from eevee:/home/genia/scripts


