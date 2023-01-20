/*
 * main.c
 *
 * Created: 1/14/2022 8:36:16 AM
 *  Author: takuya
	CMT signal change for MZ-80B to MZ-2000 
	MZ-80BをMZ-2000互換とするためのプロジェクトの一部でCMT周りの8255入出力を互換とするように変更
	
 */ 

#include <xc.h>
#include <stdbool.h>
#include <avr/io.h>
#define F_CPU 8000000UL  // 8 MHz internal clock
#include <util/delay.h>
#include <avr/interrupt.h>
#include "integer.h"

// FUSES = {0xD2, 0xDF, 0xFF};		/* ATmega328p fuses: Low, High, Extended. */
// low	CKDIV8	1		clock divide disable
//		CKOUT	1		clock out disable
//		SUT		01		high speed rising
//		CKSEL	0010	internal clock
// high	RSTDIBL	1		PC6 to reset
//		DWEN	1		Debug wire disable
//		SPIEN	0		SPI programing enable
//		WDTON	1		WDT disable
//		EESAVE	1		EEPROM is erasable
//		BOOTSZ	11		Boot loader size set to minimal(256 words)
//		BOOTRST	1		Reset vector set to application section
// ext	7~3		not use (set 1)
//		BODLEVEL 111	Brownout reset disable	

/*
	definitions
*/

/*	deprecated.h	*/
#define cbi(addr,bit) addr &= ~_BV(bit)	/* clear bit	*/
#define sbi(addr,bit) addr |= _BV(bit)	/* set bit		*/
#define ibi(addr,bit) addr ^= _BV(bit)	/* invert bit	*/
/*
#define	STANDY	0	// 00000000
#define	STOP	1	// 00000001
#define	PLAY	2	// 00000010
#define FF		4	// 00000100
#define REW		8	// 00001000
#define APSS	16	// 00010000
#define APLAY	32	// 00100000
#define AREW	64	// 01000000
*/

// set CMT signal from PortD input
#define	STANDY	0	// 00000000
#define	STOP	1	// 00000001
#define	AREW	2	// 00000010
#define PLAY	4	// 00000100
#define APLAY	16	// 00010000
#define FF		32	// 00100000
#define APSS	64	// 01000000
#define REW		128	// 10000000

// MZ-80B CMT signal to deck
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
#define TAPEEND	PORTB1	// PWM Timer output. 


/*
	public variable
*/
	BYTE action		= STANDY;
	bool play_flg	= false;
	bool rew_flg	= false;

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
		
	MCUCR = 0x00;	/*	JTAG,電圧などのリセットフラグ	*/
	// INT1 edge trigger interrupt
	EICRA = 0x04;	
	EIMSK = 0x02;
	
	TIMSK0 = 0x00;	/*	8ビットtimer0の割り込みソースの設定(初期設定は何も割り込みを設定しない)	*/
	TIMSK1 = 0x00;	/*	16ビットtimer1の割り込みソースの設定(初期設定は何も割り込みを設定しない)	*/
	TIMSK2 = 0x00;	/*	8ビットtimer2の割り込みソースの設定	*/
	PCMSK0 = 0x00;	/*	PCINT0(0~7)の割り込み	（不使用）	*/
	PCMSK1 = 0x00;	/*	PCINT1(8~15)の割り込み	（不使用）	*/
	PCMSK2 = 0b11110111;	/*	PCINT2(16~23)の割り込み	（使用）	*/
	PCICR	= 0x04;	/*	PCINT2	*/
	ACSR	= 0x00; /*	アナログコンパレータ無効	*/
	PRR		= 0x00;	/*	電力削減レジスタの設定（すべてフルパワーで使用可能)	*/
		
	sei();
	return;
}

void timer_init(void)
{	// 16bit timer 1 setting for TAPE END signal
	TIMSK1	=	0x00;		/*開始時には割り込みなし*/
	TCNT1	=	0;		
	ICR1	=	0xFF00;		// counter max (for overflow bug)
	OCR1A	=	(F_CPU)/256;	// 8MHzclock/256, 1 sec. tape stop 
	TCCR1A	=	0b11000010;	// high speed PWM, inverted output to OC1A, top counter is ICR1
	TCCR1B	=	0b00011000; // timer stop
}

// 1 sec interrupt from timer start  
// this is TAPEEND status
ISR(TIMER1_COMPA_vect)
{
	// stop timer
	TCCR1B	=	0b00011000; // timer stop
	TIMSK1	=	0x00;		
	// counter reset
//	TCNT1	=	0;
	// TAPEEND go to high until next timer start. 
	// for AREW and PLAY
	if (play_flg && (~PPI & AREW)) rew();
	if (rew_flg && (~PPI & APLAY)) play();
/* TODO and need check
	もしplay＋AREWの状態もしくはREW＋APLAYの状態で、手動でテープを止めたらどうなるか？
	tc9121pには、テープの終わりも手動で止まるのも同じなのではないか？
	キー入力が禁止なのはKINHが有効の時で、これは8255のPC5
	これがどのように制御されているかは不明だが、これもMZ-2000と同じ実装をしたので、同じタイミングでキー入力が効かなくなるはず		
*/
}

// almost 2 sec interrupt from timer start
// this interrupt never occurred
// for something wrong.(TOP insurance)
ISR(TIMER1_OVF_vect)
{
	// stop timer
	TCCR1B	=	0b00011000; // timer stop
	TIMSK1	=	0x00;		
	// counter reset
	TCNT1	=	0;
	// OC1A to high
	sbi(PORTB,TAPEEND);
}

ISR(INT1_vect)
{
	// start timer with interrupt and reset counter
	TCNT1	= 0;
	TIMSK1	=	0b00000011;	// OCR1A and TOP(ICR1)value interrupt
	TCCR1B	=	0b00011100; // timer start 1/256
	// TAPEEND got to low.
}

ISR(PCINT2_vect)
{
	// CMT function call
	action |= ~(PPI | ( 1<<PIND3));
}

void stop(void)
{
	action &= ~(STOP);
	CMT = (1<<STP | 1<<BLK1);
	_delay_ms(15);
	CMT	= (1<<BLK1);
	play_flg = false;
	rew_flg = false;
	return;
}

void play(void)
{
	action &= ~(PLAY);
	CMT	= (1<<BLK1);
	_delay_ms(5);
	CMT = (1<<RW | 1<<BLK1);
	_delay_ms(15);
	CMT = (1<<BLK1);
	_delay_ms(35);
	CMT = (1<<PNL | 1<< BLK1);
	_delay_ms(15);
	CMT = (1<<BLK1);
	play_flg = true;
	rew_flg = false;
	return;
}

void ff(void)
{
	action &= ~(FF);
	CMT = (1<<BLK1);
	_delay_ms(5);
	CMT = (1<<RW | 1<<BLK1);
	_delay_ms(15);
	CMT = (1<<BLK1);
	_delay_ms(35);
	CMT = (1<<BLK1 | 1<<BLK2);
	_delay_ms(15);
	CMT = (1<<BLK1);
	play_flg = false;
	rew_flg = false;
	return;
}

void rew(void)
{
	action &= ~(REW);
	CMT = 0;
	_delay_ms(5);
	CMT = (1<<RW);
	_delay_ms(15);
	CMT = 0;
	_delay_ms(15);
	CMT = (1<<BLK1);
	_delay_ms(20);
	CMT = (1<<BLK1 | 1<<BLK2);
	_delay_ms(15);
	CMT = (1<<BLK1);
	play_flg = false;	
	rew_flg = true;		
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
	timer_init();
	// wait for MZ-2000 mode.
	cbi(CMT,_PLAY_HOLED);
	while(bit_is_set(PINB,B2000)) ;
	// set _REC_hold to stop tape
	// TODO: check tape end.
	sbi(CMT,_PLAY_HOLED);
	// signal change function enable
    while(1)
    {
		if (action & STOP)	stop();
			else if (action & PLAY)	play();
			else if (action & FF)		ff();
			else if (action & REW)	rew();
			else if (action & APSS)	apss();
//			else if (action & APLAY)	aplay();
//			else if (action & AREW)	arew();
			else ; // STANDY	
    }	
}