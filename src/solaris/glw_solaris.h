#ifndef __GLW_SOLARIS_H__
#define __GLW_SOLARIS_H__

typedef struct
{
	void *OpenGLLib; // instance of OpenGL library

	FILE *log_fp;
} glwstate_t;

extern glwstate_t glw_state;

#endif
