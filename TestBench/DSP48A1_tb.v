module DSP48A1_tb();
    parameter A0REG=0, A1REG=1, B0REG=0, B1REG=1, CREG=1, DREG=1, MREG=1, PREG=1, CARRYINREG=1, 
              CARRYOUTREG=1, OPMODEREG=1;
    parameter CARRYINSEL="OPMODE5";
    parameter B_INPUT="DIRECT";
    parameter RSTTYPE="SYNC";

    reg [17:0] A, B, D, BCIN;
    reg [47:0] C, PCIN;
    reg CARRYIN, CLK, CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP;
    reg RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP;
    reg [7:0] OPMODE;

    wire [35:0] M;
    wire [47:0] P, PCOUT;
    wire CARRYOUT, CARRYOUTF;
    wire [17:0] BCOUT;

    DSP48A1 DUT(A, B, C, D, CARRYIN, M, P, CARRYOUT, CARRYOUTF
                ,CLK, OPMODE
                ,CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP
                ,RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP, BCIN, BCOUT, PCIN, PCOUT);

    initial begin
        CLK = 0;

        forever begin
            #5 CLK=~CLK;
        end
    end

    initial begin
        RSTA=1; RSTB=1; RSTC=1; RSTCARRYIN=1; RSTD=1; RSTM=1; RSTOPMODE=1; RSTP=1;

        A=$random; B=$random; D=$random; BCIN=$random;

        CARRYIN=$random; CEA=$random; CEB=$random; CEC=$random; CECARRYIN=$random; 
        CED=$random; CEM=$random; CEOPMODE=$random; CEP=$random;

        OPMODE=$random;
        C=$random; PCIN=$random;

        @(negedge CLK);

        if(M!=0 || P!=0 || CARRYOUT!=0 || CARRYOUTF!=0 || BCOUT!=0  || PCOUT!=0) begin
            $display("Error in reset");
            $stop;
        end

        RSTA=0; RSTB=0; RSTC=0; RSTCARRYIN=0; RSTD=0; RSTM=0; RSTOPMODE=0; RSTP=0;

        CARRYIN=1; CEA=1; CEB=1; CEC=1; CECARRYIN=1; 
        CED=1; CEM=1; CEOPMODE=1; CEP=1;


        //path 1
        OPMODE = 8'b11011101;
        A=20; B=10; C=350; D=25;
        BCIN=$random; PCIN=$random; CARRYIN=$random;

        repeat (4) @(negedge CLK);

        if(BCOUT!='hf || M!='h12c ||  P!='h32 || PCOUT!='h32 || CARRYOUT!=0 || CARRYOUTF!=0) begin
            $display("Error in path 1");
            $stop;
        end


        //path 2
        OPMODE = 8'b00010000;
        A=20; B=10; C=350; D=25;
        BCIN=$random; PCIN=$random; CARRYIN=$random;

        repeat (3) @(negedge CLK);

        if(BCOUT!='h23 || M!='h2bc || P!=0 || PCOUT!=0 || CARRYOUT!=0 || CARRYOUTF!=0) begin
            $display("Error in path 2");
            $stop;
        end


        //path 3
        OPMODE = 8'b00001010;
        A=20; B=10; C = 350; D=25;
        BCIN=$random; PCIN=$random; CARRYIN=$random;

        repeat (3) @(negedge CLK);

        if(BCOUT!='ha || M!='hc8 || P!=PCOUT || CARRYOUT!=CARRYOUTF) begin
            $display("Error in path 3");
            $stop;
        end


        //path 4
        OPMODE = 8'b10100111;
        A=5; B=6; C=350; D=25; PCIN=3000;
        BCIN=$random; CARRYIN=$random;

        repeat (3) @(negedge CLK);

        if(BCOUT!='h6 || M!='h1e || P!='hfe6fffec0bb1 || PCOUT!='hfe6fffec0bb1 || CARRYOUT!=1 || CARRYOUTF!=1) begin
            $display("Error in path 4");
            $stop;
        end

        $stop;
    end

    initial begin
        $monitor("A: %h, B: %h, C: %h, D: %h, CARRYIN: %b, M: %h, P: %h, CARRYOUT: %b, CARRYOUTF: %b, BCOUT: %h, PCOUT: %h, OPMODE=%b",
                A, B, C, D, CARRYIN, M, P, CARRYOUT, CARRYOUTF, BCOUT, PCOUT, OPMODE);
    end
endmodule