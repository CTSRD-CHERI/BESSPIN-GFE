// See LICENSE for license details.

#ifndef __GFE_MACROS
#define __GFE_MACROS

/*============================
=            UART            =
============================*/

#define UART_BASE 0x62300000

/* Uart base registers */

#define UART_BUFFER 0x0;    /* receive buffer (when read)       */
                            /*   OR transmit hold (when written)    */
#define UART_IER 0x4;       /* interrupt enable         */
#define UART_IIR 0x8;   /* interrupt identification (when read) */
                        /*   OR FIFO control (when written) */
#define UART_LCR 0xc;   /* line control register        */
#define UART_MCR 0x10;  /* modem control register       */
#define UART_LSR 0x14;  /* line status register         */
#define UART_MSR 0x18;  /* modem status register        */
#define UART_SCR 0x1C;  /* scratch register         */

#define UART_DLL 0x0;   /* Divisor Latch LSB        */
#define UART_DLM 0x4;   /* Divisor Latch MSB        */

/* Definition of individual bits in control and status registers    */

/* Interrupt enable bits */

#define UART_IER_ERBFI  0x01    /* Received data interrupt mask     */
#define UART_IER_ETBEI  0x02    /* Transmitter buffer empty interrupt   */
#define UART_IER_ELSI   0x04    /* Recv line status interrupt mask  */
#define UART_IER_EMSI   0x08    /* Modem status interrupt mask      */

/* Interrupt identification masks */

#define UART_IIR_IRQ    0x01    /* Interrupt pending bit        */
#define UART_IIR_IDMASK 0x0E    /* 3-bit field for interrupt ID     */
#define UART_IIR_MSC    0x00    /* Modem status change          */
#define UART_IIR_THRE   0x02    /* Transmitter holding register empty   */
#define UART_IIR_RDA    0x04    /* Receiver data available      */
#define UART_IIR_RLSI   0x06    /* Receiver line status interrupt   */
#define UART_IIR_RTO    0x0C    /* Receiver timed out           */

/* FIFO control bits */

#define UART_FCR_EFIFO  0x01    /* Enable in and out hardware FIFOs */
#define UART_FCR_RRESET 0x02    /* Reset receiver FIFO          */
#define UART_FCR_TRESET 0x04    /* Reset transmit FIFO          */
#define UART_FCR_TRIG0  0x00    /* RCVR FIFO trigger level one char */
#define UART_FCR_TRIG1  0x40    /* RCVR FIFO trigger level 1/4      */
#define UART_FCR_TRIG2  0x80    /* RCVR FIFO trigger level 2/4      */
#define UART_FCR_TRIG3  0xC0    /* RCVR FIFO trigger level 3/4      */

/* Line control bits */

#define UART_LCR_DLAB   0x80    /* Divisor latch access bit     */
#define UART_LCR_8N1    0x03    /* 8 bits, no parity, 1 stop        */

/* Modem control bits */

#define UART_MCR_OUT2   0x08    /* User-defined OUT2            */
#define UART_MCR_LOOP   0x10    /* Enable loopback test mode        */

/* Line status bits */

#define UART_LSR_DR 0x01    /* Data ready               */
#define UART_LSR_THRE   0x20    /* Transmit-hold-register empty     */
#define UART_LSR_TEMT   0x40    /* Transmitter empty            */

/*===========================
=            DDR            =
===========================*/

#define DDR_BASE 0x80000000
#define DDR_TOP  0x90000000

/*===============================
=            BOOTROM            =
===============================*/

#define BOOTROM_BASE 0x70000000

#endif