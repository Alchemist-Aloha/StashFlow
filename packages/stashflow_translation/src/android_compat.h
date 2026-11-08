#pragma once
#ifdef __ANDROID__
#include <cerrno>
#include <pthread.h>
#include <sched.h>
// Bionic has no pthread_setaffinity_np. StashFlow does not request explicit
// affinity (CT2 cpu_core_offset=-1); reject it rather than binding a newer API.
inline int sf_pthread_setaffinity_np(pthread_t, size_t, const cpu_set_t*) {
  return ENOTSUP;
}
#define pthread_setaffinity_np sf_pthread_setaffinity_np
#endif
