nop
bs_oemname	db	"CRYSCAN "
bpb_bytspersec	dw	512
bpb_secperclus	db	1
bpb_rsvdseccnt	dw	1
bpb_numfats	db	2
bpb_rootentcnt	dw	224
bpb_totsec16	dw	2880
bpb_media	db	0xf0
bpb_fatsz16	dw	9
bpb_secpertrk	dw	18
bpb_numheads	dw	2
bpb_hiddsec	dd	0
bpb_totsec32	dd	0
bs_drvnum	db	0
bs_reserved1	db	0
bs_bootsig	db	29h
bs_volid	dd	0
bs_vollab	db	"COREOS     "
bs_filesystype	db	"FAT12   "
times	18	db	0
