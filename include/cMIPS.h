
#define x_INST_BASE_ADDR 0x00000000
#define x_DATA_BASE_ADDR 0x00040000
#define x_IO_BASE_ADDR   0x0F000000
#define x_IO_MEM_SZ      0x00002000
#define x_IO_ADDR_RANGE  0x00000020
#define x_IO_ADDR_MASK   (0 - x_IO_ADDR_RANGE)


#define IO_PRINT_ADDR   x_IO_BASE_ADDR;
#define IO_STDOUT_ADDR  (x_IO_BASE_ADDR + 1 * x_IO_ADDR_RANGE);
#define IO_STDIN_ADDR   (x_IO_BASE_ADDR + 2 * x_IO_ADDR_RANGE);
#define IO_READ_ADDR    (x_IO_BASE_ADDR + 3 * x_IO_ADDR_RANGE);
#define IO_WRITE_ADDR   (x_IO_BASE_ADDR + 4 * x_IO_ADDR_RANGE);
#define IO_COUNT_ADDR   (x_IO_BASE_ADDR + 5 * x_IO_ADDR_RANGE);
#define IO_FPU_ADDR     (x_IO_BASE_ADDR + 6 * x_IO_ADDR_RANGE);
#define IO_UART_ADDR    (x_IO_BASE_ADDR + 7 * x_IO_ADDR_RANGE);
#define IO_STATS_ADDR   (x_IO_BASE_ADDR + 8 * x_IO_ADDR_RANGE);
#define IO_DSP7SEG_ADDR (x_IO_BASE_ADDR + 9 * x_IO_ADDR_RANGE);
#define IO_KEYBD_ADDR   (x_IO_BASE_ADDR +10 * x_IO_ADDR_RANGE);
//#define IO_LCD_ADDR     (x_IO_BASE_ADDR +11 * x_IO_ADDR_RANGE);

//-------------------------- BCD -----------------------------------------------
// 11* pois existem IO_DSP7SEG_ADDR e IO_KEYBD_ADDR em packageMemory.vhd
#define IO_BCDW_ADDR  (x_IO_BASE_ADDR + 11 * x_IO_ADDR_RANGE);
#define IO_BCDR_ADDR  (x_IO_BASE_ADDR + 12 * x_IO_ADDR_RANGE);

//-------------------------- DMA_USB -------------------------------------------
#define IO_DMA_USB_ADDR (x_IO_BASE_ADDR + 13 * x_IO_ADDR_RANGE);

//-------------------------- DMA_VGA -------------------------------------------
#define IO_DMA_VGA_ADDR (x_IO_BASE_ADDR + 14 * x_IO_ADDR_RANGE);


extern void exit(int);
extern void print(int);
extern void to_stdout(char c);
extern int  from_stdin(char *);

extern void writeInt(int);
extern void writeClose(void);
extern int  readInt(int*);
extern void dumpRAM(void);

int clkcount(void);

extern void cmips_delay(int);

extern void startCounter(int, int);
extern void stopCounter(void);
extern int  readCounter(void);

extern void enableInterr(void);
extern void disableInterr(void);

extern char *memcpy(char*, const char*, int);
extern char *memset(char*, const int, int);

extern void LCDinit(void);
extern int  LCDprobe(void); 
extern int  LCDset(int);
extern int  LCDput(int);
extern void LCDclr(void);
extern void LCDtopLine(void);
extern void LCDbotLine(void);


extern void DSP7SEGput(int MSD, int MSdot, int lsd, int lsdot);
extern int  KBDget(void);
extern int  SWget(void);

//-------------------------- BCD -----------------------------------------------
extern void bcdWWr(int ); // Escrita de dados em buffer Write
extern int  bcdWSt(void); // Leitura de estado do buffer Write

extern int  bcdRRd(void); // Leitura de dados em buffer Read
extern int  bcdRSt(void); // Leitura de estado do buffer Read

//--------------------------VGA -----------------------------------------------

extern int  dmaVGA_st(void);
extern void dmaVGA_init(int, int, int);
extern int  dmaVGA_closeFile(void);

//--------------------------USB -----------------------------------------------

extern void dmaUSB_init(int, int, int);
extern int  dmaUSB_st(void);

// struct to access the system statistics "peripheral"
typedef struct sStats {
  int dc_ref;      // data cache references
  int dc_rd_hit;   // data cache read-hits
  int dc_wr_hit;   // data cache write-hits
  int dc_flush;    // data cache (write-back) flushes of dirty blocks
  int ic_ref;      // instruction cache references
  int ic_hit;      // instruction cache hits
} sStats;

extern void readStats(sStats *);
