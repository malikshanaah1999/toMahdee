module encoder (
    input clk,
    input rst,
    input in_bit,
    output reg [1:0] x_encoded
);

reg [6:0] state;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        state <= 7'b0;
    end
    else begin
        state[5:0] <= state[6:1];
        state[1:0] <= in_bit;
    end
end

assign x_encoded[1] = (in_bit ^ state[6] ^ state[5] ^ state[3] ^ state[1]);
assign x_encoded[0] = (in_bit ^ state[1] ^ state[4] ^ state[3] ^ state[2]);

endmodule
