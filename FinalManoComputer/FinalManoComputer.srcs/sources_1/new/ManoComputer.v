`timescale 1ns / 1ps

module ManoComputer(AR, PC, DR, AC, IR, TR, E, SC, clk);

    output reg [11:0] AR;
    output reg [11:0] PC;
    output reg [15:0] DR;
    output reg [15:0] AC;
    output reg [15:0] IR;
    output reg [15:0] TR;
    output reg E;
    output reg [3:0] SC;
    input clk;
    reg J;
    reg S;
    reg [15:0] MEM [4095:0];
    
    //initialize memory with random words
    initial
    begin
    SC <= 0;
    IR <= 0;
    TR <= 0;
    DR <= 0;
    AC <= 0;
    PC <= 0;
    AR <= 0;
    J <= 0;
    E <= 0;
    $readmemh("D:/vivado/Application/DataInMem.txt", MEM);
    end
    
    always @(posedge clk)
    begin
            //fetch Data 
        if (SC == 0) begin    
            AR <= PC;
            SC <= SC + 1; end
        
        else if (SC == 1) begin
            IR <= MEM[AR[11:0]]; 
            PC <= PC + 1;        
            SC <= SC + 1; end
            //Decode Data
        else if (SC == 2) begin
            AR <= IR[11:0];
            J <= IR[15];
            SC <= SC +1; end
        else begin
                    if (IR[14:12] != 3'b111) begin
                        if(J == 0) begin // direct
                            if (SC == 3)
                                SC <= SC + 1; //do nothing
                            else begin
                                if(IR[14:12] == 3'b000) begin //AND
                                    if(SC == 4) begin
                                        DR <= MEM[AR[11:0]]; 
                                        SC <= SC + 1; end
                                    else begin
                                        AC <= (AC & DR);
                                        SC <= 0; end
                                end
                                else if(IR[14:12] == 3'b001) begin//ADD
                                    if(SC == 4) begin
                                        DR <= MEM[AR[11:0]];
                                        SC <= SC + 1; end
                                    else begin
                                        {E,AC} <= AC + DR;
                                        SC <= 0; end
                                end        
                                else if(IR[14:12] == 3'b010) begin//LDA
                                    if(SC == 4) begin
                                        DR <= MEM[AR[11:0]];
                                        SC <= SC + 1; end
                                    else begin
                                        AC <= DR;
                                        SC <= 0; end
                                end        
                                else if(IR[14:12] == 3'b011) begin //STA
                                    MEM[AR[11:0]] <= AC ; 
                                    SC <= 0;
                                end
                                else if(IR[14:12] == 3'b100) begin //BUN
                                    PC <= AR;
                                    SC <= 0;
                                end
                                else if(IR[14:12] == 3'b101) begin //BSA
                                    if (SC == 4) begin
                                        MEM[AR[11:0]] <= PC; 
                                        AR <= AR + 1; end
                                    else begin
                                        PC <= AR;
                                        SC <= 0; end
                                end        
                                else if(IR[14:12] == 3'b110) begin //ISZ
                                    if (SC == 4) begin
                                        DR <= MEM[AR[11:0]]; 
                                        SC <= SC +1; end
                                    else if(SC ==5) begin
                                        DR <= DR +1;
                                        SC <= SC +1; end
                                    else  begin
                                        MEM[AR[11:0]] <= DR;
                                            if(DR == 0)
                                                PC <= PC +1;
                                        SC <= SC +1; end
                                end
                            end
                        end
                        else if(J == 1) begin   // indirect
                            if (SC == 3) begin
                                AR <= MEM[AR[11:0]]; 
                                SC <= SC + 1; end
                            else begin
                                if(IR[14:12] == 3'b000) begin //AND
                                        if(SC == 4) begin
                                        DR <= MEM[AR[11:0]]; 
                                        SC <= SC + 1; end
                                    else begin
                                        AC <= (AC & DR);
                                        SC <= 0; end
                                end
                                else if(IR[14:12] == 3'b001) begin //ADD 
                                    if(SC == 4) begin
                                        DR <= MEM[AR[11:0]]; 
                                        SC <= SC + 1; end
                                    else begin
                                        {E,AC} <= AC + DR;
                                        SC <= 0; end
                                end
                                else if(IR[14:12] == 3'b010) begin //LDA
                                    if(SC == 4) begin
                                        DR <= MEM[AR[11:0]]; 
                                        SC <= SC + 1; end
                                    else begin
                                        AC <= DR;
                                        SC <= 0; end
                                end        
                                else if(IR[14:12] == 3'b011) begin//STA
                                    MEM[AR[11:0]] <= AC ; 
                                    SC <= 0;
                                end
                                else if(IR[14:12] == 3'b100) begin //BUN
                                    PC <= AR;
                                    SC <= 0;
                                end
                                else if(IR[14:12] == 3'b101) begin //BSA
                                    if (SC == 4) begin
                                        MEM[AR[11:0]] <= PC; 
                                        AR <= AR + 1; end
                                    else begin
                                        PC <= AR;
                                        SC <= 0; end
                                end        
                                else if(IR[14:12] == 3'b110) begin //ISZ
                                    if (SC == 4) begin
                                        DR <= MEM[AR[11:0]]; 
                                        SC <= SC +1; end
                                    else if(SC ==5) begin
                                        DR <= DR +1;
                                        SC <= SC +1; end
                                    else begin
                                        MEM[AR[11:0]] <= DR; 
                                            if(DR == 0)
                                                PC <= PC +1;
                                        SC <= SC +1; end
                               end
                           end
                        end
                    end
                    else begin
                        if(J == 0) begin// Register-reference (end is at 105)
                            
                           if(AR[11] == 1) begin//CLA
                                            AC <= 0;
                                            SC <= 0; end
                                            
                                        else if(AR[10] == 1) begin//CLE
                                            E <= 0;
                                            SC <= 0; end
                                            
                                        else if(AR[9] == 1) begin //CMA
                                            AC <= ~AC;
                                            SC <= 0; end
                                            
                                        else if(AR[8] == 1) begin//CME
                                            E <= ~E;
                                            SC <= 0; end
                                            
                                        else if(AR[7] == 1) begin//CIR
                                            AC <= (AC >> 1); 
                                            AC[15] <= E;
                                            E <= AC[0];
                                            SC <= 0; end
                                            
                                        else if(AR[6] == 1) begin//CIL
                                            AC <= (AC << 1);
                                            AC[0] <= E;
                                            E <= AC[15];
                                            SC <= 0; end
                                            
                                        else if(AR[5] == 1) begin //INC
                                            AC <= AC + 1;
                                            SC <= 0; end
                                            
                                        else if(AR[4] == 1) begin //SPA
                                            if ( AC [15] == 0)
                                                PC <= PC +1;
                                            SC <= 0;
                                            end
                                        else if(AR[3] == 1) begin//SNA
                                            if ( AC [15] == 1)
                                                PC <= PC +1;
                                            SC <= 0;
                                            end
                                        else if(AR[2] == 1) begin //SZA
                                            if ( AC == 0)
                                                PC <= PC +1;
                                            SC <= 0;
                                            end
                                        else if(AR[1] == 1) begin //SZE
                                            if ( E == 0)
                                                PC <= PC +1;
                                            SC <= 0;
                                            end
                                        else begin// HLT
                                            S <= 0;
                                            SC <= 0; end
                        end
                    end
        end
        
    end //end for always
    
    
    
    
endmodule
