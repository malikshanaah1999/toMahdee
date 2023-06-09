module conv_encoder(input clk, input reset_n, input [7:0] data_in, output reg [15:0] encoded_data);

parameter g1 = 8'b10110111; // Generator polynomial for Encoder 1
parameter g2 = 8'b11110001; // Generator polynomial for Encoder 2

reg [7:0] state1, state2;
wire [7:0] next_state1, next_state2;
wire out1, out2;

// Encoder 1
conv_encoder_1 encoder_1 (
  .clk(clk),
  .data_in(data_in),
  .reset_n(reset_n),
  .state(state1),
  .next_state(next_state1),
  .out(out1)
);

// Encoder 2
conv_encoder_2 encoder_2 (
  .clk(clk),
  .data_in(data_in),
  .reset_n(reset_n),
  .state(state2),
  .next_state(next_state2),
  .out(out2)
);

// Mux the outputs of the two encoders based on input bit 0
always @(*) begin
  if (data_in[0]) begin
    encoded_data = {out2, out1};
  end else begin
    encoded_data = {out1, out2};
  end
end

// Update the encoder states
always @(posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    state1 <= 8'b00000000;
    state2 <= 8'b00000000;
  end else begin
    state1 <= next_state1;
    state2 <= next_state2;
  end
end

// Encoder 1
module conv_encoder_1(input clk, input [7:0] data_in, input reset_n, input [7:0] state, output reg [7:0] next_state, output reg out);

reg [7:0] state_reg;

// State register
always @(posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    state_reg <= 8'b00000000;
  end else begin
    state_reg <= state;
  end
end

// Encoder logic
always @(posedge clk) begin
  case (state_reg)
    8'b00000000: begin
      next_state = 8'b10000000;
      out = data_in[7] ^ data_in[6] ^ data_in[5] ^ data_in[3] ^ data_in[2] ^ data_in[0];
    end
    default: begin
      next_state = {state_reg[6:0], data_in[7]};
      out = state_reg[7] ^ state_reg[6] ^ state_reg[5] ^ state_reg[3] ^ state_reg[2] ^ state_reg[0];
    end
  endcase
end

endmodule

// Encoder 2
module conv_encoder_2(input clk, input [7:0] data_in, input reset_n, input [7:0] state, output reg [7:0] next_state, output reg out);

reg [7:0] state_reg;

// State register
always @(posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    state_reg <= 8'b00000000;
  end else begin
    state_reg <= state;
  end
end

// Encoder logic
always @(posedge clk) begin
case (state_reg)
8'b00000000: begin
next_state = 8'b10000000;
out = data_in[7] ^ data_in[6] ^ data_in[4] ^ data_in[2] ^ data_in[0];
end
default: begin
next_state = {state_reg[6:0], data_in[7]};
out = state_reg[7] ^ state_reg[6] ^ state_reg[4] ^ state_reg[2] ^ state_reg[0];
end
endcase
end

endmodule
