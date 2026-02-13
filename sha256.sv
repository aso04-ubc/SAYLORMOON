module sha256(
    input logic clk,
    input logic rst_n,
    input logic start,
    input logic [511:0] block,
    output logic [255:0] digest,
    output logic done
);

logic [31:0] W [0:15];

function automatic logic [31:0] rotate_right(input logic[31:0] in, input int positions);
    // return {x[0], x[31:1]};
    return (in >> positions) | (in << (31-positions));
endfunction

function automatic logic [31:0] s0(input logic[31:0] in);
    return (rotate_right(in, 7) ^ rotate_right(in,18) ^ (in >> 3));
endfunction

function automatic logic [31:0] s1(input logic [31:0] in);
    return (rotate_right(in, 17) ^ rotate_right(in, 19) ^ (in >> 10));
endfunction