module interleaver(Input, Reset, Clock, Output);

    input wire Input;
    input wire Reset;
    input wire Clock;
    output reg Output;

    parameter N_CBPS = 48;
    parameter N_COLS = 16;
    parameter N_ROWS = N_CBPS / 16;

    reg [3:0] j_col_IN;
    reg [1:0] i_row_IN;
    reg [0:15] MEM_IN [0:2];
    reg [3:0] j_col_OUT;
    reg [1:0] i_row_OUT;
    reg [0:15] MEM_OUT [0:2];
    reg [7:0] counter;

    integer k;
    always @(posedge Clock, posedge Reset)
    begin
        if (Reset)
        begin
            j_col_IN <= 4'b0000;
            i_row_IN <= 2'b00;
            for(k = 0; k < N_ROWS; k = k + 1)               //  Memory Initilizing
                MEM_IN[k] <= 16'h0000;
            j_col_OUT <= 4'b0000;
            i_row_OUT <= 2'b00;
            for(k = 0; k < N_ROWS; k = k + 1)               //  Memory Initilizing
                MEM_OUT[k] <= 16'h0000;
            counter <= 8'h01;
        end
        else
        begin
            counter <= counter + 8'h01;
            if (counter == N_CBPS)
            begin
                // $display("[INNER_TEST]: (MEM_OUT <= MEM_IN)");
                for(k = 0; k < N_ROWS; k = k + 1)           //  Copy Memory
                begin
                    MEM_OUT[k] <= MEM_IN[k];
                    // $display("%b", MEM_IN[k]);
                end
                j_col_IN <= 4'b0000;
                i_row_IN <= 2'b00;
                j_col_OUT <= 4'b0000;
                i_row_OUT <= 2'b00;
                counter <= 8'h01;

                //  OUT Memory last indice:
                MEM_OUT[i_row_IN][j_col_IN] <= Input;
            end
            else
            begin
                //  Input Memory Mapping:
                MEM_IN[i_row_IN][j_col_IN] <= Input;
                j_col_IN <= j_col_IN + 4'b0001;
                if (j_col_IN == 4'b1111)
                    i_row_IN <= i_row_IN + 2'b01;
                
                //  Output Memory Mapping:
                i_row_OUT <= i_row_OUT + 2'b01;
                if (i_row_OUT + 2'b01 == N_ROWS)
                begin
                    j_col_OUT <= j_col_OUT + 4'b0001;
                    i_row_OUT <= 2'b00;
                end 
            end
        end
    end

    //  Output Update:
    always @(posedge Clock, posedge Reset)
    begin
        if (Reset)
            Output <= 1'b0;
        else
            Output <= MEM_OUT[i_row_OUT][j_col_OUT];
    end
endmodule