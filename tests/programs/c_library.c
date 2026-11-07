// ROM library, called from C: every routine that does not depend on timing.
// The comparison checks RAM, frame buffer (with the variables of the library),
// sprite registers, and changeable characters.

#include "k16.h"
#include "k16lib.h"

unsigned results[40];
char text[20];
unsigned words[64];
unsigned lines[4] = { 0x8142, 0x2418, 0x1824, 0x4281 };

int main(void)
{
   unsigned high;
   unsigned i;
   int a = -1234;
   int b = 56;
   unsigned s = 3;

   // Arithmetic
   results[0] = a * b;
   results[1] = a / b;
   results[2] = a % b;
   results[3] = a >> s;
   results[4] = (unsigned)a >> s;
   results[5] = b << s;
   results[6] = Mul32(54321, 43210, &high);
   results[7] = high;
   results[8] = Div32(0x1234, 0x5678, 0x4321, &high);
   results[9] = high;
   results[10] = MulDiv(30000, 30000, 60000);
   results[11] = Sqrt(65535u);

   // Memory and strings
   for (i = 0; i < 64; i++)
   {
      words[i] = i * i + 0x1100;
   }
   MemCopy(words + 2, words, 10);
   MemCopy(words, words + 3, 10);
   MemFill(words + 20, 0x5A5A, 5);
   results[12] = StrLen("library");
   results[13] = StrCpy(text, "abc") - text;
   results[14] = StrCmp("abc", "abd");
   results[15] = StrCmp(text, "abc");
   results[16] = IntToStr(-32768, text) - text;
   results[17] = UIntToStr(65535u, text) - text;
   results[18] = HexToStr(0xBEEF, text) - text;

   // Random numbers
   results[19] = Random();
   results[20] = Random();
   SetSeed(1234);
   results[21] = Random();

   // Text
   ClearScreen(' ', BG_BLUE | FG_WHITE);
   Print("Text at the start");
   PrintAt(36, 2, "wraps to the next row");
   PutChar('\n');
   SetTextColor(BG_GREEN | FG_RED);
   PrintHex(0xA1F0);
   PutChar(' ');
   PrintInt(-4321);
   FillCharRect(10, 10, 5, 3, BG_RED | FG_WHITE | 'x');
   CopyCharRect(20, 10, 8, 2, words);
   SetChar(128, lines);
   SetChar(255, lines);
   PrintAt(0, 28, "the end of the screen");
   PrintAt(35, 29, "scrolls up");

   // Scrolling
   ScrollDown(BG_CYAN | '-');
   ScrollLeft(BG_MAGENTA | '<');
   ScrollRight(BG_YELLOW | '>');
   ScrollUp(BG_WHITE | '^');

   // Graphics
   for (i = 0; i < 8; i++)
   {
      DrawPixel(i, 20, i);
      results[22 + i] = GetPixel(i, 20);
   }
   results[30] = GetPixel(80, 0);
   DrawPixel(-1, -1, 7);
   DrawLine(0, 22, 79, 59, 1);
   DrawLine(79, 22, 70, 59, 2);
   DrawRect(10, 24, 12, 6, 3);
   FillRect(30, 24, 12, 6, 4);
   DrawEllipse(40, 40, 15, 8, 5);
   DrawEllipse(55, 45, 6, 12, 6);

   // Sprites
   for (i = 0; i < 64; i++)
   {
      words[i] = 0x9999 + i;
   }
   SetSpriteImage(0, words);
   SetSpriteImage(7, words);
   PlaceSprite(0, 100, 50);
   PlaceSprite(7, 110, 60);
   ShowSprite(0);
   ShowSprite(7);
   results[31] = SpriteCollide(0, 7);
   HideSprite(7);
   results[32] = SpriteCollide(0, 7);
   PlaceSprite(3, -8, -4);
   ShowSprite(3);
   results[33] = SpriteCollide(0, 3);

   // Sound
   PlayNote(69);
   PlayNote(0);
   return 0;
}
