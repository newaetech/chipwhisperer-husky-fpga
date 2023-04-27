`ifdef SEMIPRO
    `define MAX_SAMPLES 327792
    `define MAX_SEGMENT_SAMPLES 196704
    `define HW_TYPE 11
`else
    `define MAX_SAMPLES 131124
    `define MAX_SEGMENT_SAMPLES 98352
    `define HW_TYPE 10
`endif
`define HW_VER 0
`define SYSTEM_CLK 96000000
`define XADC_EN
`define LOGIC_ANALYZER
`define USERIO_DEBUG
`define TRACE
//`define SAD_ONLY
