#define COUNT 0x10000010

int tstart, tend;
register int a;
static volatile int b, state = ‘r’;
char s[100];


while(1) {
	switch(state) {
		case ‘r’:
		// register variable addi
		tstart = *COUNT;
		r100M();
		tend = *COUNT;
		sprint(s,”r: %d”,tstart-tend);
		out(s);
		break;

		case ‘R’:
		// register variable, plusone function call
		

		case ‘v’:
		// volatile variable, addi
	
		case ‘V’:
		// volatile variable, plusone function call

		default:
		// print error? (optional)
	}
}

