module sha256(
    input logic clock,
    input logic reset,
    input logic start,
    input logic [511:0] block,
    output logic [255:0] digest,
    output logic finish
);

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

    function automatic logic [31:0] choose(input logic [31:0] select, input logic [31:0] x, input logic [31:0] y);
        return (x & select) ^ (y & ~select);
    endfunction

    function automatic logic [31:0] majority (input logic [31:0] j, input logic [31:0] k, input logic [31:0] l);
        return (j & k) ^ (j & l) ^ (k & l);
    endfunction

    function automatic logic [31:0] S0 (input logic [31:0] in);
        return rotate_right(in, 2) ^ rotate_right(in, 13) ^ rotate_right(in, 22);
    endfunction

    function automatic logic [31:0] S1 (input logic [31:0] in);
        return rotate_right(in, 6) ^ rotate_right(in, 11) ^ rotate_right(in ,25);
    endfunction

    // always_comb begin
    //     for (int b = 0; b < 16; b++) begin 
    //         W[b] = block[511-b*32:(b+1)*16];
    //     end
    //     for (int a = 16; a < 64; a++) begin
    //         W[a] = s1(W[a-2]) + W[a-7] + s0(W[a-15]) + W[a-16];
    //     end
    // end

    
    logic [31:0] temp1;
    logic [31:0] temp2;
    logic [31:0] W [63:0];

    logic [31:0] a, b, c, d, e, f, g, h;
    logic [31:0] H0, H1, H2, H3, H4, H5, H6, H7;
    logic [31:0] K [63:0];

    assign K = '{
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
    };

    // computer temp1 & temp2 in combinational logic to avoid pipeline hazard //
    assign temp1 <= h + S1(e) + choose(e,f,g) + K[timer] + W[timer];
    assign temp2 <= S0(a) + majority(a,b,c);

    logic [6:0] timer;
    always_ff @(posedge clock or negedge reset) begin
        if (!reset) begin 
            timer <= 0;

            H0 <= 32'h0x6a09e667;
            H1 <= 32'h0xbb67ae85;
            H2 <= 32'h0x3c6ef372;
            H3 <= 32'h0xa54ff53a;
            H4 <= 32'h0x510e527f;
            H5 <= 32'h0x9b05688c;
            H6 <= 32'h0x1f83d9ab;
            H7 <= 32'h0x5be0cd19;

            a <= 32'h0x6a09e667;
            b <= 32'h0xbb67ae85;
            c <= 32'h0x3c6ef372;
            d <= 32'h0xa54ff53a;
            e <= 32'h0x510e527f;
            f <= 32'h0x9b05688c;
            g <= 32'h0x1f83d9ab;
            h <= 32'h0x5be0cd19;
        end
        else if (start) begin
            for (int z = 0; z < 16; z++) begin
                W[z] <= block[511-z*32 -: 32];
            end
            timer <= 16;
        end else if (timer >= 16 && timer < 64) begin

            h <= g;
            g <= f;
            f <= e;
            e <= d + temp1;
            d <= c;
            c <= b;
            b <= a;
            a <= temp1 + temp2;

            W[timer] <= s1(W[timer-2]) + W[timer-7] + s0(W[timer-15]) + W[timer-16];
            timer <= timer + 1;
        end else if (timer == 64) {
            H0 <= H0 + a;
            H1 <= H1 + b;
            H2 <= H2 + c;
            H3 <= H3 + d;
            H4 <= H4 + e;
            H5 <= H5 + f;
            H6 <= H6 + g;
            H7 <= H7 + h;

            finish <= 1;
        }
    end

    assign digest = '{H0, H1, H2, H3, H4, H5, H6, H7};

endmodule