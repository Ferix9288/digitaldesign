.section    .start
.global     _start

_start:
    li      $sp, 0x10004000
    jal    main
    la $t4, 0x40000000
    jr $t4
