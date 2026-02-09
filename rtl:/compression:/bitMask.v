`timescale 1ns/1ps

module CapabilityCompressor129(
    input wire[128:0]cap_in,
    input wire enable_comp,
    output wire[128:0]cap_out
    output wire[21:0]mantissa_trunc 
);
wire[21:0]mantissa_trunc_w=cap_in[31:10];  
assign mantissa_trunc=mantissa_trunc_w;

wire[31:0]masked_mantissa={mantissa_trunc_w,10'b0};
wire[127:0]payload_out=
        enable_comp?{cap_in[127:32],masked_mantissa}
                    :cap_in[127:0];

    assign cap_out={cap_in[128],payload_out};
endmodule