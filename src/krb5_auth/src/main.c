#include <stdio.h>
#include "krb5_franklin.h"

int main(void)
{
    puts("This is a shared library test...");
    foo();
    return 0;
}
