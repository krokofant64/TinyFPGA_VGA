// C compiler test: strings, structs, pointers, function pointers, switch,
// and the frame buffer (characters and pixels).

#include "k16.h"

struct Item
{
   char name[8];
   int count;
   struct Item *next;
};

struct Item items[4];
struct Item *first;
int checksums[8];

void copyString(char *destination, char *source)
{
   while ((*destination++ = *source++) != 0)
   {
   }
}

int length(char *text)
{
   int n = 0;
   while (text[n])
   {
      n++;
   }
   return n;
}

void print(int column, int row, char *text, unsigned color)
{
   unsigned *position = FRAME_BUFFER + row * SCREEN_COLUMNS + column;
   while (*text)
   {
      *position++ = *text++ | color;
   }
}

void setPixel(int x, int y, unsigned color)
{
   unsigned *word = FRAME_BUFFER + (y >> 1) * SCREEN_COLUMNS + (x >> 1);
   int shift = ((y & 1) * 2 + (x & 1)) * 3;
   if ((*word & PIXELS) == 0)
   {
      *word = PIXELS;
   }
   *word = (*word & ~(7 << shift)) | (color << shift);
}

int twice(int x) { return x * 2; }
int square(int x) { return x * x; }
int negate(int x) { return -x; }

int classify(char c)
{
   switch (c)
   {
      case 'a': case 'e': case 'i': case 'o': case 'u':
         return 1;
      case ' ':
         return 2;
      default:
         if (c >= '0' && c <= '9')
         {
            return 3;
         }
         return 0;
   }
}

int main(void)
{
   char *names[4] = { "apple", "pear", "fig", "kiwi" };
   int (*operations[3])(int) = { twice, square, negate };
   struct Item *item;
   int i;
   int x;
   char line[24];

   // Linked list in reverse order
   first = 0;
   for (i = 0; i < 4; i++)
   {
      copyString(items[i].name, names[i]);
      items[i].count = length(names[i]) * 10 + i;
      items[i].next = first;
      first = &items[i];
   }
   i = 0;
   for (item = first; item != 0; item = item->next)
   {
      checksums[i++] = item->count + item->name[0];
      print(1, 1 + i, item->name, FG_YELLOW | BG_BLUE);
   }

   for (i = 0; i < 3; i++)
   {
      checksums[4 + i] = operations[i](7 + i);
   }

   copyString(line, "hello world 2024");
   x = 0;
   for (i = 0; line[i]; i++)
   {
      x = x * 4 + classify(line[i]);
   }
   checksums[7] = x;
   print(10, 0, line, FG_WHITE | BG_RED);

   // Pixels: a diagonal and a frame in the lower half of the screen
   for (x = 0; x < 40; x++)
   {
      setPixel(x, 30 + x / 2, x & 7);
      setPixel(x, 58, RED);
      setPixel(79 - x, 59, GREEN);
   }
   return checksums[0];
}
