#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/resource.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <errno.h>
/* Diagnostic launcher. exec resets its address space; fork then creates a child
 * from this small address space rather than the Python observer's retained heap.
 * The outer harness still owns the five-second process-group deadline. */
int main(int argc, char **argv) {
  if (argc < 3) return 2;
  struct rusage before, usage;
  getrusage(RUSAGE_SELF, &before);
  pid_t child = fork();
  if (child < 0) return 3;
  if (child == 0) { execvp(argv[2], argv + 2); _exit(127); }
  int status;
  while (wait4(child, &status, 0, &usage) < 0) if (errno != EINTR) return 4;
  FILE *output = fopen(argv[1], "w");
  if (!output) return 5;
  fprintf(output, "{\"launcherPeakRssKiB\":%ld,\"childPeakRssKiB\":%ld,\"exitCode\":%d}\n", before.ru_maxrss, usage.ru_maxrss, WIFEXITED(status) ? WEXITSTATUS(status) : 128 + WTERMSIG(status));
  fclose(output);
  return WIFEXITED(status) ? WEXITSTATUS(status) : 128 + WTERMSIG(status);
}
