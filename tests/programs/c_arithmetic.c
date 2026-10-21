// C compiler test: arithmetic, comparisons, recursion, and sorting.
// The results are stored in global arrays, which the comparison checks
// (RAM of the emulator and the hardware simulation must be identical).

int values[8] = { 0, 1, -1, 7, -7, 1000, -32768, 32767 };
int products[64];
int quotients[64];
int remainders[64];
unsigned unsignedQuotients[64];
int flags[64];
int shifts[16];
int fibonacci[16];
int sorted[16] = { 9, -4, 300, 0, 17, -1000, 5, 5, 42, -42, 1, 2, 3, 32767, -32768, 8 };

int fib(int n)
{
   if (n < 2)
   {
      return n;
   }
   return fib(n - 1) + fib(n - 2);
}

void quicksort(int *a, int low, int high)
{
   int pivot;
   int i;
   int j;
   int t;
   if (low >= high)
   {
      return;
   }
   pivot = a[(low + high) / 2];
   i = low;
   j = high;
   while (i <= j)
   {
      while (a[i] < pivot) i++;
      while (a[j] > pivot) j--;
      if (i <= j)
      {
         t = a[i];
         a[i] = a[j];
         a[j] = t;
         i++;
         j--;
      }
   }
   quicksort(a, low, j);
   quicksort(a, i, high);
}

int main(void)
{
   int i;
   int j;
   int k = 0;
   for (i = 0; i < 8; i++)
   {
      for (j = 0; j < 8; j++)
      {
         int a = values[i];
         int b = values[j];
         products[k] = a * b;
         if (b != 0)
         {
            quotients[k] = a / b;
            remainders[k] = a % b;
            unsignedQuotients[k] = (unsigned)a / (unsigned)b;
         }
         flags[k] = (a < b) | (a <= b) << 1 | (a > b) << 2 | (a >= b) << 3 |
                    (a == b) << 4 | (a != b) << 5 | ((unsigned)a < (unsigned)b) << 6 |
                    ((unsigned)a >= (unsigned)b) << 7 | (a && b) << 8 | (a || b) << 9;
         k++;
      }
   }
   for (i = 0; i < 16; i++)
   {
      shifts[i] = (values[6] >> i) ^ (int)((unsigned)values[6] >> i) ^ (values[5] << i);
      fibonacci[i] = fib(i);
   }
   quicksort(sorted, 0, 15);
   return fibonacci[15];
}
