/**
 *
 * TODO: change printf to output things on the Quake console instead
 */
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/shm.h>
#include <sys/wait.h>
#include <stdio.h>
#include <sys/audioio.h>
#include <errno.h>
#include <stropts.h>
#include <time.h>
#include <signal.h>

#include "../client/client.h"
#include "../client/snd_loc.h"



/*
 *	How this works:
 *
 *	Quake[12] are designed to use a dma buffer into which the sound is mixed by
 *	the snd_mix.c routines. This is used as a simple ring buffer.  The routine
 *	SNDDMA_GetDMAPos should return the point in the buffer where the dma engine
 *	is currently playing.  The global variable paintedtime indicates how far
 *	the sound code has already written the buffer data.
 *	
 *	Originally we used the audio driver's idea of how many samples had been written
 *	in order to compute the play location.  This turned out to be unreliable, and
 *	led to weird echos, etc in the sample stream.  We now use time, knowing that
 *	we send exactly SAMPLE_RATE samples/sec.
 *	
 *	I've hard-coded this to require stero and SAMPLE_RATE samples/sec; this is a perf.
 *	win and all ultrasparcs support this.
 *
 *      Note that the flush appears to cause some probs. with static; I'll try and
 *	get around this in the future.
 *
 *
 */

int audio_fd;
int snd_inited;

static int bufpos;
static int prevbufpos;

static audio_info_t info;

#define BUFFER_SIZE		2048*16		// nice and big = about 3 seconds worth so
						// the sound is ok if the game slows down
#define SAMPLE_BITS		16		// fixed to speed things up a bit

#define	SAMPLE_RATE		(11025)

#define WRITE_SIZE		(((SAMPLE_RATE)/100) << 2) /* write 1 tick's worth of data */

unsigned char dma_buffer[BUFFER_SIZE];

static volatile dma_t  *shm = 0;

static long long timestart;

static timer_t timer_id;
struct sigevent ev;
struct itimerspec itimerspec;

static void sig_sound();

static int bytes_so_far;

control_timer(int on)
{
	struct sigaction act;

	if (on) {
		itimerspec.it_value.tv_nsec =
			itimerspec.it_interval.tv_nsec = 10000000;

		itimerspec.it_value.tv_sec =
			itimerspec.it_interval.tv_sec = 0;			
	} else {
		itimerspec.it_value.tv_nsec = 
			itimerspec.it_value.tv_sec = 0;
	}

	memset(&act, 0, sizeof (act));
	act.sa_handler = sig_sound;

	if (sigaction(SIGALRM, &act, NULL) < 0) {
		perror("sigaction failure");
		close (audio_fd);
		return (0);
	}

	if (timer_settime(timer_id, 0, &itimerspec, NULL) < 0) {
		perror("timer failure");
		close (audio_fd);
		return (0);
	}	

	return (1);
}

qboolean SNDDMA_Init(void)
{
	shm = &dma;

	audio_fd = open("/dev/audio", O_WRONLY|O_NDELAY);

	if (timer_id == 0) {
		ev.sigev_notify = SIGEV_SIGNAL;
		ev.sigev_signo = SIGALRM;

		itimerspec.it_value.tv_nsec =
			itimerspec.it_interval.tv_nsec = 10000000;

		itimerspec.it_value.tv_sec =
			itimerspec.it_interval.tv_sec = 0;			

		if (timer_create(CLOCK_REALTIME, &ev, &timer_id) < 0) {
			perror("timer_create");
			return (0);
		}
	}

	if (audio_fd < 0) {
		if (errno == EBUSY) {
			printf("Audio device is being used by another process\n");
		}
		perror("/dev/audio");
		printf("Could not open /dev/audio\n");
		return (0);
	}

	if (ioctl(audio_fd, AUDIO_GETINFO, &info) < 0) {
		perror("/dev/audio");
		printf("Could not communicate with audio device.\n");
		close(audio_fd);
		return 0;
	}

	//
	// set to nonblock
	//

	if (fcntl(audio_fd, F_SETFL, O_NONBLOCK) < 0) {
		perror("/dev/audio");
		close(audio_fd);
		return 0;
	}

	AUDIO_INITINFO(&info);

	shm->speed = SAMPLE_RATE;

	// require 16 bit stereo - all recent hardware supports this

	info.play.encoding = AUDIO_ENCODING_LINEAR;
	info.play.sample_rate = SAMPLE_RATE;
	info.play.channels = 2;
	info.play.precision = 16;

	if (ioctl(audio_fd, AUDIO_SETINFO, &info) < 0) {
		printf("Incapable sound hardware.\n");
		close(audio_fd);
		return 0;
	}
	
	


	shm->samplebits = SAMPLE_BITS;
	shm->channels = 2;
	shm->samples = sizeof(dma_buffer) / (SAMPLE_BITS/8); // assume mono stream
	shm->samplepos = 0;
	shm->submission_chunk = 1;
	shm->buffer = (unsigned char *)dma_buffer;

	snd_inited = 1;
	
	control_timer(1);
	       
	printf("16 bit stereo sound initialized\n");	
	return 1;
}

static void sig_sound()
{
	/*
	  compute the time, write the data, but don't pass
	  paintedtime
	  */



	long long delta = gethrtime()-timestart; 

	int samples = (int)((float)(delta) / 1.e9 * (double)SAMPLE_RATE);
	int ret = (samples << 1) & (sizeof(dma_buffer) / (SAMPLE_BITS/8) - 1) ;
	int start = ((ret) << 1 ) & (BUFFER_SIZE-1);
	int dont_pass = (paintedtime << 2) & (BUFFER_SIZE - 1);
	int count;
	int slop;
	int write_size;
	int sav;

	/*
	 * check how we're doing...
	 * we want many bytes of buffering (sigh) to prevent noise 
	 * this causes some game lag, but is better than the static
	 */

	if (ioctl(audio_fd, AUDIO_GETINFO, &info) < 0) {
		perror("/dev/audio");
		printf("Could not communicate with audio device.\n");
		close(audio_fd);
 	}

	slop = (SAMPLE_RATE<<4) / 100 - (bytes_so_far - (info.play.samples << 2));
	slop &= ~3;

	write_size = slop + WRITE_SIZE  ;
 			
	/*
	 *  write enough so we keep a few ticks of sound in the pipe.
	 */

	sav = bytes_so_far;

	if (start + (write_size) > BUFFER_SIZE) { /* wrap around */
		if (dont_pass > start) {
			write(audio_fd, dma_buffer + start, dont_pass - start);
			return;
		}
		count =  BUFFER_SIZE - start;
		writesmall (audio_fd, dma_buffer + start, count);
		bytes_so_far += count;
		count = start + (write_size) - BUFFER_SIZE;
		if (count > dont_pass)
			count = dont_pass;
		writesmall (audio_fd, dma_buffer, count);
		bytes_so_far += count;
	} else {
		if (dont_pass > start &&
		    dont_pass < start + (write_size))
			count = dont_pass - start;
		else
			count = write_size;
		writesmall(audio_fd, dma_buffer + start, count);
		bytes_so_far += count;
	}

	//printf("wrote %d bytes\n", bytes_so_far - sav);

}

int
writesmall(int fd, char * s, int count)
{
	int i;
	
	write(fd, s, count);
	return (0);
}

		
	
	
int	SNDDMA_GetDMAPos(void)
{
	int ret;
	int samples;
	static int last;


	if (!snd_inited)
		return (0);

	if (timestart == 0LL)
		timestart = gethrtime();

	/*
	 * we'll just use time directly here; the audiodriver doesn't
	 * seem to be reliable here
	 */

	samples = (int)((float)(gethrtime()-timestart)/1.e9*(double)SAMPLE_RATE);

	ret = (samples << 1) & (sizeof(dma_buffer) / (SAMPLE_BITS/8) - 1) ;

	prevbufpos = bufpos;
	bufpos = ((ret) << 1 ) & (BUFFER_SIZE-1);
 
	return (ret);
}

void SNDDMA_Shutdown(void)
{
	printf("SNDDMA_Shutdown\n");
	
	if (snd_inited) {
		bytes_so_far = 0;
		control_timer(0);
		close(audio_fd);
		snd_inited = 0;
	}
}

void SNDDMA_BeginPainting (void)
{
}

void SNDDMA_Submit(void)
{
}

