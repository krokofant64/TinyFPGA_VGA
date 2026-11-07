// ROM library: the routines that depend on time. The program measures the
// times itself with the clock counter and stores only whether they are in range,
// so that the results are the same in the emulator and in the hardware
// simulation. All interrupts happen far below the stack pointer of main, and
// clearStack() removes what they leave behind in RAM.

#include "k16.h"
#include "k16lib.h"

#define FRAME_CLOCKS_LOW 0x68A0u // 800 * 525 clocks = 0x668A0

unsigned results[12];
unsigned start;
volatile unsigned calls = 0;

void tick(void)
{
   // Uses the runtime in the ROM, as a function called by the handler can
   unsigned twice = calls * 2;
   calls = twice / 2 + 1;
}

unsigned inRange(unsigned theMinimum, unsigned theExtra)
{
   unsigned elapsed = COUNTER_LO - start;
   return elapsed >= theMinimum && elapsed <= theMinimum + theExtra;
}

void work(void)
{
   unsigned pad[32];
   unsigned sum = 0;
   unsigned frames;
   pad[0] = 0;

   // Sleep, without interrupts
   start = COUNTER_LO;
   SleepMs(2);
   results[0] = inRange(50000u, 500);
   start = COUNTER_LO;
   SleepUs(10);
   results[1] = inRange(250, 500);
   start = COUNTER_LO;
   SleepUs(2000);
   results[2] = inRange(50000u, 500);
   start = COUNTER_LO;
   SleepMs(0);
   SleepUs(0);
   results[3] = inRange(0, 500);

   // WaitFrame starts the handler: one frame from interrupt to interrupt
   WaitFrame();
   start = COUNTER_LO;
   WaitFrame();
   results[4] = inRange(FRAME_CLOCKS_LOW - 200, 400);
   results[5] = calls;

   // A function is called in every frame, and the program is not disturbed
   SetInterrupt(tick);
   while (calls < 3)
   {
      sum = sum + 3;
      if (sum > 60000u)
      {
         sum = 0;
      }
   }
   results[6] = calls;
   results[7] = sum % 3;
   WaitFrame();
   results[8] = calls;

   // No function any more, but the frames are still counted
   SetInterrupt(0);
   frames = *(unsigned *)0x8503;
   WaitFrame();
   WaitFrame();
   results[9] = calls;
   results[10] = *(unsigned *)0x8503 - frames;
   start = 0;
}

void clearStack(void)
{
   unsigned here;
   unsigned *p;
   for (p = (unsigned *)0x0E00; p < &here - 8; p++)
   {
      *p = 0;
   }
}

int main(void)
{
   work();
   clearStack();
   return 0;
}
