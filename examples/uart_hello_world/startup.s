.global main

_reset_handler:
	b startup;

startup:
	bl main;

_done:
	b _done;

