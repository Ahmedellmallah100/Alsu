module alsu
#(
    parameter INPUT_PRIORITY = 1, // 1 = a has priority , 0 = b has priority
    parameter FULL_ADDER = 1      // 1 = enable full adder mode
)
(
    input  wire clk, rst,
    input  wire [2:0] a, b, opcode,
    input  wire cin, serial_in,
    input  wire red_op_a, red_op_b,
    input  wire bypass_a, bypass_b, direction,
    output reg [15:0] leds,
    output reg [5:0] out
);

// internal register signals
reg [2:0] a_reg, b_reg, opcode_reg;
reg serial_in_reg, cin_reg;
reg bypass_a_reg, bypass_b_reg, direction_reg;
reg red_op_a_reg, red_op_b_reg;
wire invalid_case;

// Input Registering
always @(posedge clk or posedge rst) begin
    if (rst) begin
         a_reg <= 0;
         b_reg <= 0; 
         opcode_reg <= 0;
         cin_reg <= 0;
         serial_in_reg <= 0;
        red_op_a_reg <= 0; 
        red_op_b_reg <= 0;
        bypass_a_reg <= 0; 
        bypass_b_reg <= 0;
        direction_reg <= 0;
    end else begin
        a_reg <= a;
        b_reg <= b; 
        opcode_reg <= opcode;
        cin_reg <= cin; 
        serial_in_reg <= serial_in;
        red_op_a_reg <= red_op_a; 
        red_op_b_reg <= red_op_b;
        bypass_a_reg <= bypass_a; 
        bypass_b_reg <= bypass_b;
        direction_reg <= direction;
    end
end

// Invalid Case 
assign invalid_case = 
    (opcode_reg == 3'b110 || opcode_reg == 3'b111 ||
    ((red_op_b_reg || red_op_a_reg) && !(opcode_reg == 3'b000 || opcode_reg == 3'b001)));

//  ALSU Logic
always @(posedge clk) begin
    if (rst) begin
        out <= 6'b0; 
        leds <= 16'b0;
    end else if (invalid_case) begin
        leds <= ~leds;
        if (bypass_a_reg && bypass_b_reg)
            out <= (INPUT_PRIORITY ? a_reg : b_reg);
        else if (bypass_a_reg)
            out <= a_reg;
        else if (bypass_b_reg)
            out <= b_reg;
        else
            out <= 6'b0;
    end else begin
        leds <= 16'b0;
        case (opcode_reg)
            3'b000: begin // AND
                if (red_op_a_reg && red_op_b_reg)
                    out <= (INPUT_PRIORITY ? &a_reg : &b_reg);
                else if (red_op_a_reg)
                    out <= &a_reg;
                else if (red_op_b_reg)
                    out <= &b_reg;
                else
                    out <= a_reg & b_reg;
            end
            3'b001: begin // XOR
                if (red_op_a_reg && red_op_b_reg)
                    out <= (INPUT_PRIORITY ? ^a_reg : ^b_reg);
                else if (red_op_a_reg)
                    out <= ^a_reg;
                else if (red_op_b_reg)
                    out <= ^b_reg;
                else
                    out <= a_reg ^ b_reg; 
            end
            3'b010: begin // ADD
                if (FULL_ADDER)
                    out <= a_reg + b_reg + cin_reg;
                else
                    out <= a_reg + b_reg;
            end
            3'b011: out <= a_reg * b_reg; // MULTIPLY
            3'b100: begin // SHIFT
                if (direction_reg)
                    out <= {out[4:0], serial_in_reg}; // left shift
                else
                    out <= {serial_in_reg, out[5:1]}; // right shift
            end
            3'b101: begin // ROTATE
                if (direction_reg)
                    out <= {out[4:0], out[5]}; // left rotate
                else
                    out <= {out[0], out[5:1]}; // right rotate
            end
            default: out <= 6'b0;
        endcase
    end
end


endmodule