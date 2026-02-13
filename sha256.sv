module sha256(
    input logic clock,
    input logic reset,
    input logic start,
    input logic [511:0] block,
    output logic [255:0] digest,
    output logic finish
);

    typedef enum logic[3:0] {

    } state_t;

    logic [31:0] W [63:0];

    function automatic logic [31:0] rotate_right(input logic[31:0] in, input int positions);
        // return {x[0], x[31:1]};
        return (in >> positions) | (in << (32-positions));
    endfunction

    function automatic logic [31:0] s0(input logic[31:0] in);
        return (rotate_right(in, 7) ^ rotate_right(in,18) ^ (in >> 3));
    endfunction

    function automatic logic [31:0] s1(input logic [31:0] in);
        return (rotate_right(in, 17) ^ rotate_right(in, 19) ^ (in >> 10));
    endfunction

    // always_comb begin
    //     for (int b = 0; b < 16; b++) begin 
    //         W[b] = block[511-b*32:(b+1)*16];
    //     end
    //     for (int a = 16; a < 64; a++) begin
    //         W[a] = s1(W[a-2]) + W[a-7] + s0(W[a-15]) + W[a-16];
    //     end
    // end

    logic [6:0] count;
    always_ff @(posedge clock || negedge reset) begin
        if (reset) count <= 0;
        else if (start) begin
            for (int z = 0; z < 16; z++) begin
                W[z] = block[511-b*32 +: 32];
            end
            count <= 16;
        end else if (count >= 16 && count < 64) begin
            W[count] = s1(W[count-2]) + W[count-7] + s0(W[count-15]) + W[count-16];
            count <= count + 1;
        end
    end

endmodule