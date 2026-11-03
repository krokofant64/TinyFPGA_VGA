// Sprites: draws 8 sprite shapes, moves the sprites (also partly off the
// screen), and reads the sprite data back while the video reads the sprite
// rows (the CPU waits for the frame buffer then). The comparison checks RAM,
// frame buffer, and sprite registers.

#include "k16.h"

int x[SPRITE_COUNT];
int y[SPRITE_COUNT];
int dx[SPRITE_COUNT];
int dy[SPRITE_COUNT];
unsigned readBack[16];
unsigned checksums[8];

// (2 * i - 15) squared: the distance from the sprite center
int squares[16] = { 225, 169, 121, 81, 49, 25, 9, 1, 1, 9, 25, 49, 81, 121, 169, 225 };

// A ring with a transparent hole, in two colors
void drawShape(int n)
{
   unsigned *data = SPRITE_DATA + n * SPRITE_SIZE;
   int row;
   int column;
   int i;
   for (row = 0; row < 16; row++)
   {
      for (column = 0; column < 4; column++)
      {
         unsigned word = 0;
         for (i = 3; i >= 0; i--)
         {
            int distance = squares[column * 4 + i] + squares[row];
            unsigned point = 0;
            if (distance < 64)
            {
               point = 0;
            }
            else if (distance < 144)
            {
               point = SPRITE_OPAQUE | ((n + 1) & 7);
            }
            else if (distance < 256)
            {
               point = SPRITE_OPAQUE | (7 - (n & 7));
            }
            word = (word << 4) | point;
         }
         data[row * 4 + column] = word;
      }
   }
}

int main(void)
{
   int n;
   int step;
   int k;
   unsigned *position;
   char c = 'A';

   // Text in the background
   position = FRAME_BUFFER;
   for (k = 0; k < SCREEN_COLUMNS * SCREEN_ROWS; k++)
   {
      *position++ = c | FG_WHITE | BG_BLUE;
      if (++c > 'Z')
      {
         c = 'A';
      }
   }

   for (n = 0; n < SPRITE_COUNT; n++)
   {
      drawShape(n);
      x[n] = n * 40 - 10;
      y[n] = n * 30 - 8;
      dx[n] = n - 4;
      dy[n] = 3 - n;
      if (dx[n] == 0)
      {
         dx[n] = 1;
      }
   }

   for (step = 0; step < 8; step++)
   {
      unsigned sum = 0;
      for (n = 0; n < SPRITE_COUNT; n++)
      {
         x[n] += 4 * dx[n];
         y[n] += 4 * dy[n];
         if (x[n] < -8 || x[n] > 312)
         {
            dx[n] = -dx[n];
         }
         if (y[n] < -8 || y[n] > 232)
         {
            dy[n] = -dy[n];
         }
         SPRITE_REGS[2 * n] = SPRITE_ENABLE | (x[n] & 0x03FF);
         SPRITE_REGS[2 * n + 1] = y[n] & 0x01FF;
      }
      // Read all sprite data (the video reads it at the same time)
      for (k = 0; k < SPRITE_COUNT * SPRITE_SIZE; k++)
      {
         sum = (sum << 1) ^ SPRITE_DATA[k];
      }
      checksums[step] = sum;
   }

   SPRITE_REGS[14] = 0; // Sprite 7 off
   for (k = 0; k < 16; k++)
   {
      readBack[k] = SPRITE_REGS[k];
   }
   return checksums[7];
}
