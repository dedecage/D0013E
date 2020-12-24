#include <stdio.h>

char plain[140];

int coded[] = { 

0x2423ba45, 0xed2b33da, 0x3ba9b055, 0x66030460,
0x9c3b4ac3, 0xf6032806, 0xb08fc508, 0x35fd8d21,
0x3e29f9f6, 0x19f93fce, 0x4ac7a8be, 0x0b728d1b,
0xd1221039, 0xb6beea72, 0xc78e6063, 0x0902dd86,
0xb689b9f6, 0x51059f42, 0xb3ea35aa, 0x22952190,
0xbfd3da46, 0x13214603, 0x46ab0843, 0x0d340894,
0xd2507ae5, 0x406e97ba, 0xfe5c252e, 0xa594d349,
0xcc8a4054, 0x27afdc04, 0xd023495c, 0x54d57774,
0x9c48db5b, 0x0898a707, 0x57338f62, 0xc9f92107,
0x4a1ecf20, 0xd8da221c, 0x022592ca, 0x9cd08223,
0xd4eda1b8, 0xa4e28d51, 0x95a304c0, 0xcd09320a, 
0x0a33d007, 0x0de249e3, 0x81299661, 0xc4cc280f,
0xa722cade, 0x40a22b7a, 0xf505dff8, 0xbcbc709c,
0x32b66fa7, 0x6b236033, 0x422e5e25, 0x4c4721be,
0x185d3b95, 0x4d83bcc6, 0x9c7547c8, 0xf994e8ea,
0xa9953837, 0xb3961566, 0x326a4b7e, 0xf68cd5f1,
0x18e3753d, 0x2751866b, 0x8e7a52f4, 0xe2cfd602,
0x963469ea, 0x359a65fe, 0xf88ae342, 0x31834ede,
0x1bdd5109, 0x977c4409, 0xc5c40afd, 0x997dbb48,
0xbecb39e9, 0x8e7f85a8, 0x2bf37cd4, 0xc6e4a3d6,
0xad67c4ec, 0x5abfec40, 0x1e99d558, 0x6b18317c,
0x6f7805f4, 0x6532bc4c, 0x9ec3ca86, 0x4ddbd53f,
0x803661b5, 0x46793769, 0x89d45b84,     0	 
};

int abc[] = { 

0xc02079a8, 0xaf6edb26, 0xb140ef3b,     0 
};

unsigned int seed = 0x4fa917e0;

int codgen(int *seed_addr) {

	int k;		 // Variable used for storing bits in for loop
	int counter = 0; // Variable used for counting 1's in seed_addr

	int i = 31;	 // Loop variable
	
	// The for loop counts the 1's in seed_addr
	for (i; i >= 0; i--) {
		k = *seed_addr >> i;
		if (k & 1) {
			counter++;
		}
	}

	int x = *seed_addr * 8;
	int y = *seed_addr >> 6;
	*seed_addr = (x - y) - counter;
	return *seed_addr ^ 0x141703d1; // seed XOR 0x141703d1
}

int decode(int *wordarr, char *bytearr, int *seed_addr) {

	unsigned int m, r, x, y;

	x = ~codgen(seed_addr);	// One's complement of codgen

	if (*wordarr == 0) {
		*bytearr = 0;
		r = x;
	} else {
		wordarr++; // Increase pointers
		bytearr++;
		y = decode(wordarr, bytearr, seed_addr);
		wordarr--; // Restore pointers
		bytearr--;
		m = (x - y) ^ *wordarr;	
				
		*bytearr = (m >> 7) & 0xff; // Mask all bits except 14:7
		r = ~codgen(seed_addr) + 1; // Two's complement of codgen
		r = x + y + m + r + 5;
	}
	return r;
}

int main() {
	
	decode(coded, plain, &seed);	

	int index = 0;
	while (index < sizeof(plain)) {
	printf("%c", plain[index]);
	index++;
	}
	
}
