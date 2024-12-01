#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <unistd.h>
#include <spawn.h>
#include <sys/wait.h>

extern char **environ;

void test_fork_exec(void);
void test_posix_spawn(void);

int main(void) {
  test_fork_exec();
  test_posix_spawn();
  return EXIT_SUCCESS;
}

void test_fork_exec(void) {
  pid_t pid;
  int status;
  puts("Testing fork/exec");
  fflush(NULL);
  pid = fork();
  switch (pid) {
  case -1:
    perror("fork");
    break;
  case 0:
    execl("/bin/ls", "ls", (char *) 0);
    perror("exec");
    break;
  default:
    printf("Child id: %i\n", pid);
    fflush(NULL);
    if (waitpid(pid, &status, 0) != -1) {
      printf("Child exited with status %i\n", status);
    } else {
      perror("waitpid");
    }
    break;
  }
}

void test_posix_spawn(void) {
  pid_t pid;
  char *argv[] = {"ls", (char *) 0};
  int status;
  puts("Testing posix_spawn");
  fflush(NULL);
  status = posix_spawn(&pid, "/bin/ls", NULL, NULL, argv, environ);
  if (status == 0) {
    printf("Child id: %i\n", pid);
    fflush(NULL);
    if (waitpid(pid, &status, 0) != -1) {
      printf("Child exited with status %i\n", status);
    } else {
      perror("waitpid");
    }
  } else {
    printf("posix_spawn: %s\n", strerror(status));
  }
}
