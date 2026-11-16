#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>

/* Refuse symlinks and untrusted runtime directories; include Linux starttime. */
int main(int argc,char **argv){
 if(argc!=3 || (strcmp(argv[2],"0")&&strcmp(argv[2],"1")))return 2;
 char *end;long pid=strtol(argv[1],&end,10);if(*end||pid<2)return 2;
 const char *base=getenv("SHELL_IME_STATE_DIR");if(!base)return 0;
 struct stat info;if(mkdir(base,0700)&&errno!=EEXIST)return 1;
 if(lstat(base,&info)||!S_ISDIR(info.st_mode)||info.st_uid!=getuid()||(info.st_mode&077))return 1;
 char proc[64],buffer[4096];snprintf(proc,sizeof(proc),"/proc/%ld/stat",pid);
 FILE *fp=fopen(proc,"r");if(!fp)return 1;if(!fgets(buffer,sizeof(buffer),fp)){fclose(fp);return 1;}fclose(fp);
 char *field=strrchr(buffer,')');if(!field)return 1;field+=2;
 char *save=NULL,*token=strtok_r(field," ",&save);for(int n=3;n<22&&token;n++)token=strtok_r(NULL," ",&save);if(!token)return 1;
 int dir=open(base,O_RDONLY|O_DIRECTORY|O_NOFOLLOW);if(dir<0)return 1;
 char name[64];snprintf(name,sizeof(name),"%ld",pid);
 int fd=openat(dir,name,O_WRONLY|O_CREAT|O_TRUNC|O_NOFOLLOW,0600);close(dir);if(fd<0)return 1;
 fchmod(fd,0600);dprintf(fd,"%s %s\n",token,argv[2]);close(fd);return 0;
}
