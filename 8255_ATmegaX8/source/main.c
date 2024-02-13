/*
 * main.c
 *
 * Created: 2/8/2024 8:36:16 AM
 *  Author: takuya
	CMT signal changer for MZ-80B

	This is a part of the project to make MZ-80B compatible with MZ-2000.
	Convert and create 8255 inputs and outputs around CMT from MZ-2000 to MZ-80B CMT control using AVR ATmega xx8 seriese(ATmega328P, etc).

	MZ-80BをMZ-2000互換とするためのプロジェクトの一部です
	AVRのATmega xx8 seriese(ATmega328Pなど)を使って、CMT周りの8255入出力をMZ-2000のものからMZ-80BのCMT制御へ変換、作成します。

 */ 

//#include <xc.h>
#include <stdbool.h>
#include <avr/io.h>
#define F_CPU 8000000UL  // 8 MHz internal clock
#include <util/delay.h>
#include <avr/interrupt.h>

/* ATmega328p fuses: Low, High, Extended. */
// FUSES = {0xE2, 0xD9, 0xFF};		
// low	CKDIV8	1		clock divide disable
//		CKOUT	1		clock out disable
//		SUT		10		high speed rising
//		CKSEL	0010	internal RC Osc	 :: default
// high	RSTDIBL	1		PC6 to reset
//		DWEN	1		Debug wire disable
//		SPIEN	0		SPI programing enable
//		WDTON	1		WDT disable
//		EESAVE	1		EEPROM is erasable
//		BOOTSZ	00		Boot loader size set to 2048 words :: default
//		BOOTRST	1		Reset vector set to application section
// ext	7~3		not use (set 1)
//		BODLEVEL 111	Brownout reset disable	

/* for ATmega88 */
// FUSES = {0xE2, 0xDF, 0xF9}


/*
	definitions
*/

/*	deprecated.h	*/
#define cbi(addr,bit) addr &= ~_BV(bit)	/* clear bit	*/
#define sbi(addr,bit) addr |= _BV(bit)	/* set bit		*/
#define ibi(addr,bit) addr ^= _BV(bit)	/* invert bit	*/

// CMT signal from PortD input
#define	STANDY	0	// 00000000
#define	STOP	1	// 00000001
#define	AREW	2	// 00000010
#define PLAY	4	// 00000100
#define APLAY	16	// 00010000
#define FF		32	// 00100000
#define APSS	64	// 01000000
#define REW		128	// 10000000

// MZ-80B CMT signal to CMT deck
#define CMT		PORTC
#define BLK2	PORTC0
#define BLK1	PORTC1	
#define PNL		PORTC2
#define STP		PORTC3
#define _PLAY_HOLED	PORTC4
#define RW		PORTC5

#define PPI		PIND
//  Correspond to 8255 pin 
//#define PA3		PIND0
//#define PA5		PIND1
//#define PA2		PIND2
//#define PA6		PIND4
//#define PA1		PIND5
//#define PA7		PIND6
//#define PA0		PIND7

#define B2000	PINB0
#define TAPEEND	PORTB1	// TAPEEND is L for tape is moving. 

/*
	public variable
*/
	unsigned char	action		= STANDY;
	unsigned char	last_stat	= STANDY;
	bool 			ipl_stat	= true; 

/*
	public function
*/
	void stop(void);
	void play(void);
	void rew(void);
	void ff(void);
	void apss(void);
//	void aplay(void);
//	void arew(void);
	
void init(void)
{
	cli();
	// PD0~7 set to input (pull up), PD3(TAPECOUNTER) set to INT1 interrupt
	PORTD	=	0b11111111;
	DDRD	=	0b00000000;
	
	// PC0~5 set to output
	// PC6 is reset(not use)
	PORTC	=	0b11000010;
	DDRC	=	0b11111111;
		
	// PB0 input(B/_2000), PB1 output(OC1A TAPEEND)
	// PB 2,7 reserved(input) PB3~5 to SPI
	PORTB	=	0b11111111;
	DDRB	=	0b00000010;
		
	MCUCR = 0x00;	
	// INT1 edge trigger interrupt
	EICRA = 0x04;	// both edge trigger	
	EIMSK = 0x00;	// not start
	
	TIMSK0 = 0x00;	// 8bits Timer0 not use 
	TIMSK1 = 0x00;	// 16bits Timer1 not set yet
	TIMSK2 = 0x00;	// 8bits Timer2 not use
	PCMSK0 = 0x00;	// PCINT0(0~7) not use
	PCMSK1 = 0x00;	// PCINT1(8~15) not use
	PCMSK2 = 0b11110111;	// PCINT2(16~23) set to CMT signal input intterupt, without PB1(PD3,TAPECOUNTER)
	PCICR	= 0x00;	// PCINT2	is not start yet
	
	ACSR	= 0x00; 
	PRR		= 0x00;	// full power 
		
	sei();
	return;
}

void interrupt_init(void)
{	
	PCIFR	|= 0x04; 	// reset PCINT2 interrupt demand
	PCICR	= 0x04;		// PCINT2	enable
	// 16bit timer 1 setting for TAPEEND signal, CTC mode
	TIMSK1	=	0;	
	TCNT1	=	0;		
//	ICR1	=	0xFF00;		
// counter max (for overflow bug)
	OCR1A	=	(F_CPU)/170;	// 8MHzclock/256*1.5, 1.5 sec. tape stop 
	TCCR1A	=	0b00000000;		// CTC, OC1A and OC1B to normal pin , top counter is OCR1A 
	TCCR1B	=	0b00001000;		// timer stop
	EIMSK = 0x02;				// INT1 interrupt start
}

/*	
 1.5 sec interrupt from timer start  
 this is TAPEEND status
*/
ISR(TIMER1_COMPA_vect)
{
	TCCR1B	=	0b00001000;	// timer stop
	TIMSK1	=	0;
	sbi(PORTB,TAPEEND);		// TAPEEND set to high until next timer start. 
	// for AREW and PLAY
	if ((last_stat == REW) && (~PPI & APLAY) && (ipl_stat == false)) {
		play();
		return;
	} else 	if ((last_stat == PLAY) && (~PPI & AREW) && (ipl_stat == false)) {
		rew();
		return;
	}
	//stop();
	last_stat = STOP;
}

/*
 almost 2 sec interrupt from timer start
 this interrupt never occurred. something wrong.(TOP insurance)
*/
ISR(TIMER1_OVF_vect)
{
	TCCR1B	=	0b00001000;		// timer stop
	TIMSK1	=	0;		
	sbi(PORTB,TAPEEND);			// OC1A to high
}

/*
Interrupt for TAPECOUNTER operation
Start timer
*/
ISR(INT1_vect)
{
	// start timer with interrupt and reset counter
	TCNT1	= 0;
	TIMSK1	=	0b00000011;	// OCR1A(TOP) and OVF(0xFFFF) value interrupt
	TCCR1B	=	0b00001100; // timer start 1/256 clock
	cbi(PORTB,TAPEEND);		// TAPEEND got to low.
}

/*
Intterupt for CMT function call
*/
ISR(PCINT2_vect)
{
	// multiple functions call never to be asserted at the same time.
	// action |= ~(PPI | ( 1<<PIND3));
	unsigned char temp_act =	~(PPI | ( 1<<PIND3)) ;
	if (temp_act & 0xff ) {		// get value only when some function is asserted.
		action = temp_act;
	}
	if (ipl_stat) {
		ipl_stat = false;
	}
}

void stop(void)
{
	action &= ~(STOP);
	if (last_stat != STOP ) {
		CMT = (1<<STP | 1<<BLK1 | 1<<_PLAY_HOLED);
		_delay_ms(15);
    	CMT = (1<<BLK1 | 1<<_PLAY_HOLED);
	}
	last_stat = STOP;
	return;
}

void play(void)
{
	action &= ~(PLAY);
	if (last_stat !=PLAY) {
		if (last_stat != STOP) 	{
				// reset CMT status
				CMT = (1<<STP | 1<<BLK1 | 1<<_PLAY_HOLED);
				_delay_ms(5);
			}
		CMT	= (1<<BLK1 | 1<<_PLAY_HOLED);
		_delay_ms(5);
		CMT = (1<<RW | 1<<BLK1 | 1<<_PLAY_HOLED);
		_delay_ms(15);
		CMT = (1<<BLK1 | 1<<_PLAY_HOLED);
		_delay_ms(35);
		CMT = (1<<PNL | 1<< BLK1 | 1<<_PLAY_HOLED);
		_delay_ms(15);
		CMT = (1<<BLK1 | 1<<_PLAY_HOLED);
		last_stat	= PLAY;
	}
	return;
}

void ff(void)
{
	action &= ~(FF);
	if (last_stat != STOP){						// for last status is not stop
		stop();
	}

	CMT = (1<<BLK1 | 1<<_PLAY_HOLED);			// set Forward state
	_delay_ms(5);
	CMT = (1<<RW | 1<<BLK1 | 1<<_PLAY_HOLED);	// latch Forward state
	_delay_ms(15);
	CMT = (1<<BLK1 | 1<<_PLAY_HOLED);	
	_delay_ms(35);
	CMT = (1<<BLK1 | 1<<BLK2 | 1<<_PLAY_HOLED);	// Reel motor on
	_delay_ms(15);
	CMT = (1<<BLK1 | 1<<_PLAY_HOLED);
	last_stat = FF;
	return;
}

void rew(void)
{
	action &= ~(REW);
	if (last_stat != STOP){					// for last status is not stop
		stop();
	}

	CMT = (1<<_PLAY_HOLED); 				// set Rew state
	_delay_ms(5);
	CMT = (1<<RW | 1<<_PLAY_HOLED); 		// latch
	_delay_ms(15);
	CMT = (1<<_PLAY_HOLED);
	_delay_ms(15);
	CMT = (1<<BLK1 | 1<<_PLAY_HOLED);
	_delay_ms(20);
	CMT = (1<<BLK1 | 1<<BLK2 | 1<<_PLAY_HOLED); //reel motor on
	_delay_ms(15);
	CMT = (1<<BLK1 | 1<<_PLAY_HOLED);
	last_stat = REW;		
	return;
}

void apss(void)
{
	// MZ-80B CMT deck always works as APSS mode.
	action &= ~(APSS);
	return;
}

/*
void aplay(void)
{
	//
	action &= ~(APLAY);
	return;
}

void arew(void)
{
	//
	action &= ~(AREW);
	return;
}
*/

int main(void)
{
	init();
	// wait for MZ-2000 mode.
    sbi(CMT,_PLAY_HOLED);
	while(bit_is_set(PINB,B2000)) 	(action		= STANDY);
	// start 
	last_stat = REW;
    CMT = (1<<BLK1 | 1<<_PLAY_HOLED);	// default IPL CMT status

	interrupt_init();					// start all intterrupt
	// signal change function enable
    while(1)
    {
		if (action & STOP)	stop();
		if (action & PLAY)	play();
		if (action & FF)	ff();
		if (action & REW)	rew();
		if (action & APSS)	apss();
//		if (action & APLAY)	aplay();
//		if (action & AREW)	arew();
    }	
}