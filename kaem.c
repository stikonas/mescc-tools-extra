/* Copyright (C) 2016 Jeremiah Orians
 * This file is part of stage0.
 *
 * stage0 is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * stage0 is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with stage0.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/wait.h>
#include <getopt.h>
#define FALSE 0
#define TRUE 1
#define max_string 4096
#define max_args 256

char** tokens;
int command_done;
int VERBOSE;
int STRICT;

int match(char* a, char* b)
{
	int i = -1;
	do
	{
		i = i + 1;
		if(a[i] != b[i])
		{
			return FALSE;
		}
	} while((0 != a[i]) && (0 !=b[i]));
	return TRUE;
}

void collect_comment(FILE* input)
{
	int c;
	do
	{
		c = fgetc(input);
		if(-1 == c)
		{
			fprintf(stderr, "IMPROPERLY TERMINATED LINE COMMENT!\nABORTING HARD\n");
			exit(EXIT_FAILURE);
		}
	} while('\n' != c);
}

int collect_string(FILE* input, int index, char* target)
{
	int c;
	do
	{
		c = fgetc(input);
		if(-1 == c)
		{
			fprintf(stderr, "IMPROPERLY TERMINATED RAW string!\nABORTING HARD\n");
			exit(EXIT_FAILURE);
		}
		else if('"' == c)
		{
			c = 0;
		}
		target[index] = c;
		index = index + 1;
	} while(0 != c);
	return index;
}

char* collect_token(FILE* input)
{
	char* token = calloc(max_string, sizeof(char));
	char c;
	int i = 0;
	do
	{
		c = fgetc(input);
		if(-1 == c)
		{// Deal with end of file
			fprintf(stderr, "execution complete\n");
			exit(EXIT_SUCCESS);
		}
		else if((' ' == c) || ('\t' == c))
		{// space and tab are token seperators
			c = 0;
		}
		else if('\n' == c)
		{// Command terminates at end of line
			c = 0;
			command_done = 1;
		}
		else if('"' == c)
		{// RAW strings are everything between a pair of ""
			i = collect_string(input, i, token);
			c = 0;
		}
		else if('#' == c)
		{// Line comments to aid the humans
			collect_comment(input);
			c = 0;
			command_done = 1;
		}
		else if('\\' == c)
		{// Support for end of line escapes, drops the char after
			fgetc(input);
			c = 0;
		}
		token[i] = c;
		i = i + 1;
	} while (0 != c);
	if(1 == i)
	{// Nothing worth returning
		free(token);
		return NULL;
	}
	return token;
}

void execute_command(FILE* script, char** envp)
{
	tokens = calloc(max_args, sizeof(char*));
	int i = 0;
	int status = 0;
	command_done = 0;
	do
	{
		char* result = collect_token(script);
		if(0 != result)
		{
			tokens[i] = result;
			i = i + 1;
		}
	} while(0 == command_done);

	if(VERBOSE && (0 < i))
	{
		fprintf(stdout, " +> ");
		for(int j = 0; j < i; j = j + 1)
		{
			fprintf(stdout, "%s ", tokens[j]);
		}
		fprintf(stdout, "\n");
	}

	if(0 < i)
	{ // Not a line comment
		int f = fork();
		if (f == -1)
		{
			fprintf(stderr,"fork() failure");
			exit(EXIT_FAILURE);
		}
		else if (f == 0)
		{ // child
			/* execve() returns only on error */
			execve(tokens[0], tokens, envp);
			/* Prevent infinite loops */
			_exit(EXIT_SUCCESS);
		}
		// Otherwise we are the parent
		// And we should wait for it to complete
		waitpid(f, &status, 0);
		// Then go again
		if(STRICT && (0 != status))
		{
			fprintf(stderr, "Subprocess error %d\nABORTING HARD\n", status);
			exit(EXIT_FAILURE);
		}
	}
	else
	{
//		fprintf(stderr, "Recieved and dropped line comment\n");
	}
}

#if !__MESC__
static
#endif
struct option long_options[] = {
	{"strict", no_argument, &STRICT, TRUE},
	{"verbose", no_argument, &VERBOSE, TRUE},
	{"file", required_argument, 0, 'f'},
	{"help", no_argument, 0, 'h'},
	{"version", no_argument, 0, 'v'},
	{0, 0, 0, 0}
};


int main(int argc, char** argv, char** envp)
{
	VERBOSE = 0;
	STRICT = 0;
	char* filename = "kaem.run";
	FILE* script = NULL;

	int c;
	int option_index = 0;
	while ((c = getopt_long(argc, argv, "f:h:o:V", long_options, &option_index)) != -1)
	{
		switch(c)
		{
			case 0: break;
			case 'h':
			{
				fprintf(stdout, "kaem only accepts --help, --version, --verbose or no arguments\n");
				exit(EXIT_SUCCESS);
			}
			case 'f':
			{
				filename = optarg;
				break;
			}
			case 'V':
			{
				fprintf(stdout, "kaem version 0.1\n");
				exit(EXIT_SUCCESS);
			}
			default:
			{
				fprintf(stderr, "Unknown option\n");
				exit(EXIT_FAILURE);
			}
		}
	}

	#if __MESC__
		script = open(filename, O_RDONLY);
	#else
		script = fopen(filename, "r");
	#endif

	if(NULL == script)
	{
		fprintf(stderr, "The file: %s can not be opened!\n", filename);
		exit(EXIT_FAILURE);
	}

	while(1)
	{
		execute_command(script, envp);
	}
	fclose(script);
	return EXIT_SUCCESS;
}
