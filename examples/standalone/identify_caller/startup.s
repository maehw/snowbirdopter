.global main

_reset_handler:
	b startup;

startup:
	mov r0, lr;
	bl main;

_done:
	b _done;

