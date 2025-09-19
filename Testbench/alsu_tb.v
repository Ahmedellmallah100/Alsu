module alsu_tb ();
    localparam INPUT_PRIORITY = 1;  // 1 = a has priority
    localparam FULL_ADDER = 1;        // 1 = enable full adder mode
  

    reg clk_tb, rst_tb;
    reg [2:0] a_tb, b_tb, opcode_tb;
    reg cin_tb, serial_in_tb;
    reg red_op_a_tb, red_op_b_tb;
    reg bypass_a_tb, bypass_b_tb, direction_tb;
    wire [15:0] leds_tb;
    wire [5:0] out_tb;

    alsu #(
        .INPUT_PRIORITY(INPUT_PRIORITY),
        .FULL_ADDER(FULL_ADDER)
    ) Alsu_tb (
        .clk(clk_tb),
        .rst(rst_tb),
        .a(a_tb),
        .b(b_tb),
        .opcode(opcode_tb),
        .cin(cin_tb),
        .serial_in(serial_in_tb),
        .red_op_a(red_op_a_tb),
        .red_op_b(red_op_b_tb),
        .bypass_a(bypass_a_tb),
        .bypass_b(bypass_b_tb),
        .direction(direction_tb),
        .leds(leds_tb),
        .out(out_tb)
    );

    // Clock generation
    initial begin
        clk_tb = 0;
        forever #5 clk_tb = ~clk_tb;
    end

    integer i = 0;
    
    initial begin
        // Zero input and enable reset test
        rst_tb = 1;
        a_tb = 3'b0; 
        b_tb = 3'b0; 
        opcode_tb = 3'b0;
        cin_tb = 0; 
        serial_in_tb = 0;
        red_op_a_tb = 0; 
        red_op_b_tb = 0;
        bypass_a_tb = 0; 
        bypass_b_tb = 0; 
        direction_tb = 0;
          

        @(negedge clk_tb);
        if (out_tb !==  6'b0 || leds_tb != 16'b0)
            $display("FAILED");
        else
            $display("PASSED");

        rst_tb = 0;
        
        // Verify Bypass Functionality
        bypass_a_tb = 1;
        bypass_b_tb = 1;

        for (i = 0; i < 10; i = i + 1) begin
            a_tb = $random;
            b_tb = $random;
            opcode_tb = $urandom_range(6, 7);
        
            repeat (2) @(negedge clk_tb);

            if (out_tb != (INPUT_PRIORITY ? a_tb : b_tb)) begin
                $display("Error in Verify Bypass");
                $stop;
                 
            end
        end

        // Verify opcode 0 Functionality
        bypass_a_tb = 0;
        bypass_b_tb = 0;
        opcode_tb = 0;

        for (i = 0; i < 10; i = i + 1) begin
            a_tb = $random;
            b_tb = $random;
            red_op_a_tb = $random;
            red_op_b_tb = $random;

            repeat (2) @(negedge clk_tb);
             
            case ({red_op_a_tb, red_op_b_tb})
                2'b00: begin
                    if (out_tb != (a_tb & b_tb)) begin
                        $display("Error in bitwise operation in opcode 0");
                        $stop;
                    end
                end
                2'b01: begin
                    if (out_tb != &b_tb) begin
                        $display("Error in reduction operation in opcode 0");
                        $stop;
                    end
                end
                2'b10: begin
                    if (out_tb != &a_tb) begin
                        $display("Error in reduction operation in opcode 0");
                        $stop;
                    end
                end
                2'b11: begin
                    if (out_tb != (INPUT_PRIORITY ? &a_tb : &b_tb)) begin
                        $display("Error in reduction operation in opcode 0");
                        $stop;
                    end
                end
            endcase
        end

        // Verify opcode 1 Functionality 
        opcode_tb = 1;

        for (i = 0; i < 10; i = i + 1) begin
            a_tb = $random;
            b_tb = $random;
            red_op_a_tb = $random;
            red_op_b_tb = $random;

            repeat (2) @(negedge clk_tb);
             
            case ({red_op_a_tb, red_op_b_tb})
                2'b00: begin
                    if (out_tb != (a_tb ^ b_tb)) begin
                        $display("Error in bitwise operation in opcode 1");
                        $stop;
                    end
                end
                2'b01: begin
                    if (out_tb != ^b_tb) begin
                        $display("Error in reduction operation in opcode 1");
                        $stop;
                    end
                end
                2'b10: begin
                    if (out_tb != ^a_tb) begin
                        $display("Error in reduction operation in opcode 1");
                        $stop;
                    end
                end
                2'b11: begin
                    if (out_tb != (INPUT_PRIORITY ? ^a_tb : ^b_tb)) begin
                        $display("Error in reduction operation in opcode1");
                        $stop;
                    end
                end
            endcase
        end

        // Verify opcode 2 Functionality 
        opcode_tb = 2;
        red_op_a_tb = 0;
        red_op_b_tb = 0;

        for (i = 0; i < 10; i = i + 1) begin
            a_tb = $random;
            b_tb = $random;
            cin_tb = $random;

            repeat (2) @(negedge clk_tb);

            if (out_tb != ((FULL_ADDER) ? (a_tb + b_tb + cin_tb) : (a_tb + b_tb))) begin
                $display("Addition operation Error in Opcode 2");
                $stop;
            end
        end

        // Verify opcode 3 Functionality 
        opcode_tb = 3;
        for (i = 0; i < 10; i = i + 1) begin
            a_tb = $random;
            b_tb = $random;

            repeat (2) @(negedge clk_tb);

            if (out_tb != (a_tb * b_tb)) begin
                $display("Multiplication operation Error in Opcode 3");
                $stop;
            end
        end

        // Verify opcode 4 Functionality 
        opcode_tb = 4;
        for (i = 0; i < 10; i = i + 1) begin
            a_tb =  $random;
            b_tb =  $random;
            serial_in_tb = $random;
            direction_tb = $random;
            repeat (2) @(negedge clk_tb);
        end

        // Verify opcode 5 Functionality 
        opcode_tb = 5;
        for (i = 0; i < 10; i = i + 1) begin
            a_tb = $random;
            b_tb = $random;
            serial_in_tb =  $random;
            direction_tb =  $random;
            repeat (2) @(negedge clk_tb);
        end
          
        $display("All tests passed successfully!");      
    end
    
initial begin 

    $monitor("rst_tb=%b ,a_tb=%b ,b_tb=%b ,opcode_tb=%b ,cin_tb=%b ,serial_in_tb=%b ,direction_tb=%b, red_op_a_tb=%b ,red_op_b_tb=%b ,bypass_a_tb=%b ,bypass_b_tb=%b ,out_tb=%b ,leds_tb=%b",
        rst_tb ,a_tb ,b_tb ,opcode_tb ,cin_tb ,serial_in_tb ,direction_tb ,red_op_a_tb ,red_op_b_tb ,bypass_a_tb ,bypass_b_tb ,out_tb ,leds_tb);
        
        $stop;
       end
endmodule