module DSP48A1(A, B, C, D, CARRYIN, M, P, CARRYOUT, CARRYOUTF
                ,CLK, OPMODE
                ,CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP
                ,RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP, BCIN, BCOUT, PCIN, PCOUT);
    
    parameter A0REG=0, 
        A1REG=1,
        B0REG=0,
        B1REG=1,
        CREG=1, 
        DREG=1, 
        MREG=1,
        PREG=1, 
        CARRYINREG=1,
        CARRYOUTREG=1,
        OPMODEREG=1;
    parameter CARRYINSEL="OPMODE5";
    parameter B_INPUT="DIRECT";
    parameter RSTTYPE="SYNC";

    input [17:0] A, B, D, BCIN;
    input [47:0] C, PCIN;
    input CARRYIN, CLK, CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP;
    input RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP;
    input [7:0] OPMODE;

    output [35:0] M;
    output [47:0] P, PCOUT;
    output CARRYOUT, CARRYOUTF;
    output [17:0] BCOUT;

    wire CARRY_MUL_IN, CARRY_MUL_OUT, CARRY_OUT;
    wire [7:0] OPMODE_reg;
    wire [17:0] A_reg0, A_reg1, B_reg0_in, B_reg0_out, D_reg, Pre_ADD_SUB, PRE_MUX;
    wire [35:0] M_in;
    wire [47:0] C_reg, P_reg, PCIN_reg, X_OUT, Z_OUT, POST_ADD_SUB;

    FF_MUX_block #(.size(18), .RSTTYPE(RSTTYPE)) blockA0(A, A_reg0, CEA, CLK, RSTA, A0REG);
    FF_MUX_block #(.size(18), .RSTTYPE(RSTTYPE)) blockA1(A_reg0, A_reg1, CEA, CLK, RSTA, A1REG);
    FF_MUX_block #(.size(18), .RSTTYPE(RSTTYPE)) blockD(D, D_reg, CED, CLK, RSTD, DREG);
    FF_MUX_block #(.size(48), .RSTTYPE(RSTTYPE)) blockC(C, C_reg, CEC, CLK, RSTC, CREG);
    FF_MUX_block #(.size(8), .RSTTYPE(RSTTYPE)) blockOPMODE(OPMODE, OPMODE_reg, CEOPMODE, CLK, RSTOPMODE, OPMODEREG);

    assign B_reg0_in = (B_INPUT=="CASCADE")? BCIN : B;
    FF_MUX_block #(.size(18), .RSTTYPE(RSTTYPE)) blockB0(B_reg0_in, B_reg0_out, CEB, CLK, RSTB, OPMODEREG);


    assign Pre_ADD_SUB = (OPMODE_reg[6])? D_reg-B_reg0_out : D_reg+B_reg0_out;
    assign PRE_MUX = (OPMODE_reg[4])? Pre_ADD_SUB : B_reg0_out;
    FF_MUX_block #(.size(18), .RSTTYPE(RSTTYPE)) blockB1(PRE_MUX, BCOUT, CEB, CLK, RSTB, B1REG);


    assign M_in = A_reg1 * BCOUT ;
    FF_MUX_block #(.size(36), .RSTTYPE(RSTTYPE)) blockM(M_in, M, CEM, CLK, RSTM, MREG);


    assign X_OUT = (OPMODE_reg[1]==0 && OPMODE_reg[0]==0)? 0 :
                   (OPMODE_reg[1]==0 && OPMODE_reg[0]==1)? {12'b0,M} :
                   (OPMODE_reg[1]==1 && OPMODE_reg[0]==0)? PCOUT :
                   (OPMODE_reg[1]==1 && OPMODE_reg[0]==1)? {3'b0,D_reg[11:0], A_reg1[17:0], BCOUT[17:0]} : 
                   0;


    assign Z_OUT = (OPMODE_reg[3]==0 && OPMODE_reg[2]==0)? 0 :
                   (OPMODE_reg[3]==0 && OPMODE_reg[2]==1)? PCIN :
                   (OPMODE_reg[3]==1 && OPMODE_reg[2]==0)? PCOUT :
                   (OPMODE_reg[3]==1 && OPMODE_reg[2]==1)? C_reg : 
                   0;
    
    assign CARRY_MUL_IN = (CARRYINSEL == "CARRYIN")? CARRYIN : OPMODE_reg[5];
    FF_MUX_block #(.RSTTYPE(RSTTYPE)) blockCARRYIN(CARRY_MUL_IN, CARRY_MUL_OUT, CECARRYIN, CLK, RSTCARRYIN, CARRYINREG);


    assign {CARRY_OUT, POST_ADD_SUB} = (OPMODE_reg[7])? Z_OUT - (X_OUT + CARRY_MUL_OUT) : X_OUT + Z_OUT + CARRY_MUL_OUT ;

    FF_MUX_block #(.RSTTYPE(RSTTYPE)) blockCARRYOUT(CARRY_OUT, CARRYOUT, CECARRYIN, CLK, RSTCARRYIN, CARRYOUTREG);
    assign CARRYOUTF = CARRYOUT;

    FF_MUX_block #(.size(48), .RSTTYPE(RSTTYPE)) blockP(POST_ADD_SUB, P_reg, CEP, CLK, RSTP, PREG);
    assign P = P_reg;
    assign PCOUT = P_reg;

    

endmodule